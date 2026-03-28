package su.kidoz.jip.timeline;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

public final class TimelineRecorder {
	private static final long DEFAULT_BUCKET_SIZE_NANOS = 50_000_000L;

	private static volatile long sessionStartNanos = System.nanoTime();
	private static final AtomicLong sessionEndNanos = new AtomicLong();
	private static volatile long bucketSizeNanos = DEFAULT_BUCKET_SIZE_NANOS;

	private static volatile ConcurrentHashMap<Integer, TimelineBucket> buckets = new ConcurrentHashMap<Integer, TimelineBucket>();
	private static volatile ConcurrentHashMap<Long, ThreadActivity> threads = new ConcurrentHashMap<Long, ThreadActivity>();

	private TimelineRecorder() {
	}

	public static void init() {
		sessionStartNanos = System.nanoTime();
		sessionEndNanos.set(sessionStartNanos);
		bucketSizeNanos = DEFAULT_BUCKET_SIZE_NANOS;
		buckets = new ConcurrentHashMap<Integer, TimelineBucket>();
		threads = new ConcurrentHashMap<Long, ThreadActivity>();
	}

	public static void record(long threadId, long endTimeNanos, long durationNanos) {
		if (durationNanos < 0) {
			durationNanos = 0;
		}

		int bucketIndex = bucketIndex(endTimeNanos);
		TimelineBucket bucket = buckets.computeIfAbsent(Integer.valueOf(bucketIndex), ignored -> new TimelineBucket(bucketIndex));
		bucket.record(threadId, durationNanos);

		ThreadActivity thread = threads.computeIfAbsent(Long.valueOf(threadId), ignored -> new ThreadActivity(threadId));
		thread.record(bucketIndex, durationNanos);
		sessionEndNanos.accumulateAndGet(endTimeNanos, Math::max);
	}

	public static TimelineSnapshot snapshot() {
		List<TimelineBucketSnapshot> bucketSnapshots = new ArrayList<TimelineBucketSnapshot>();
		for (TimelineBucket bucket : buckets.values()) {
			bucketSnapshots.add(bucket.snapshot(bucketSizeNanos));
		}
		Collections.sort(bucketSnapshots, new TimelineBucketSnapshotComparator());

		List<ThreadActivitySnapshot> threadSnapshots = new ArrayList<ThreadActivitySnapshot>();
		for (ThreadActivity thread : threads.values()) {
			threadSnapshots.add(thread.snapshot(bucketSizeNanos));
		}
		Collections.sort(threadSnapshots, new ThreadActivitySnapshotComparator());

		long endNanos = sessionEndNanos.get();
		long durationNanos = Math.max(0L, endNanos - sessionStartNanos);
		return new TimelineSnapshot(bucketSizeNanos / 1_000_000L, durationNanos, bucketSnapshots, threadSnapshots);
	}

	private static int bucketIndex(long endTimeNanos) {
		long offset = Math.max(0L, endTimeNanos - sessionStartNanos);
		return (int) (offset / bucketSizeNanos);
	}

	private static final class TimelineBucket {
		private final int index;
		private final AtomicLong observedTimeNanos = new AtomicLong();
		private final AtomicLong eventCount = new AtomicLong();
		private final ConcurrentHashMap<Long, AtomicLong> threadContributions = new ConcurrentHashMap<Long, AtomicLong>();

		private TimelineBucket(int index) {
			this.index = index;
		}

		private void record(long threadId, long durationNanos) {
			observedTimeNanos.addAndGet(durationNanos);
			eventCount.incrementAndGet();
			threadContributions.computeIfAbsent(Long.valueOf(threadId), ignored -> new AtomicLong()).addAndGet(durationNanos);
		}

		private TimelineBucketSnapshot snapshot(long bucketSizeNanos) {
			List<BucketThreadContribution> topThreads = new ArrayList<BucketThreadContribution>();
			for (Map.Entry<Long, AtomicLong> entry : threadContributions.entrySet()) {
				topThreads.add(new BucketThreadContribution(entry.getKey().longValue(), entry.getValue().get()));
			}
			Collections.sort(topThreads, new BucketThreadContributionComparator());
			if (topThreads.size() > 3) {
				topThreads = new ArrayList<BucketThreadContribution>(topThreads.subList(0, 3));
			}
			return new TimelineBucketSnapshot(index, (index * bucketSizeNanos) / 1_000_000L,
					((index + 1) * bucketSizeNanos) / 1_000_000L, observedTimeNanos.get(), eventCount.get(),
					threadContributions.size(), topThreads);
		}
	}

	private static final class ThreadActivity {
		private final long threadId;
		private final AtomicLong observedTimeNanos = new AtomicLong();
		private final AtomicLong eventCount = new AtomicLong();
		private final ConcurrentHashMap<Integer, AtomicLong> bucketContributions = new ConcurrentHashMap<Integer, AtomicLong>();

		private ThreadActivity(long threadId) {
			this.threadId = threadId;
		}

		private void record(int bucketIndex, long durationNanos) {
			observedTimeNanos.addAndGet(durationNanos);
			eventCount.incrementAndGet();
			bucketContributions.computeIfAbsent(Integer.valueOf(bucketIndex), ignored -> new AtomicLong()).addAndGet(durationNanos);
		}

		private ThreadActivitySnapshot snapshot(long bucketSizeNanos) {
			int peakBucketIndex = 0;
			long peakBucketObservedNanos = 0;

			for (Map.Entry<Integer, AtomicLong> entry : bucketContributions.entrySet()) {
				long bucketObserved = entry.getValue().get();
				if (bucketObserved > peakBucketObservedNanos) {
					peakBucketObservedNanos = bucketObserved;
					peakBucketIndex = entry.getKey().intValue();
				}
			}

			return new ThreadActivitySnapshot(threadId, observedTimeNanos.get(), eventCount.get(), peakBucketIndex,
					(peakBucketIndex * bucketSizeNanos) / 1_000_000L, ((peakBucketIndex + 1) * bucketSizeNanos) / 1_000_000L,
					peakBucketObservedNanos);
		}
	}

	public static final class TimelineSnapshot {
		private final long bucketSizeMs;
		private final long durationNanos;
		private final List<TimelineBucketSnapshot> buckets;
		private final List<ThreadActivitySnapshot> threadActivity;

		private TimelineSnapshot(long bucketSizeMs, long durationNanos, List<TimelineBucketSnapshot> buckets,
				List<ThreadActivitySnapshot> threadActivity) {
			this.bucketSizeMs = bucketSizeMs;
			this.durationNanos = durationNanos;
			this.buckets = buckets;
			this.threadActivity = threadActivity;
		}

		public long bucketSizeMs() {
			return bucketSizeMs;
		}

		public long durationNanos() {
			return durationNanos;
		}

		public List<TimelineBucketSnapshot> buckets() {
			return buckets;
		}

		public List<ThreadActivitySnapshot> threadActivity() {
			return threadActivity;
		}
	}

	public static final class TimelineBucketSnapshot {
		private final int bucketIndex;
		private final long startOffsetMs;
		private final long endOffsetMs;
		private final long observedTimeNanos;
		private final long eventCount;
		private final int activeThreadCount;
		private final List<BucketThreadContribution> topThreads;

		private TimelineBucketSnapshot(int bucketIndex, long startOffsetMs, long endOffsetMs, long observedTimeNanos,
				long eventCount, int activeThreadCount, List<BucketThreadContribution> topThreads) {
			this.bucketIndex = bucketIndex;
			this.startOffsetMs = startOffsetMs;
			this.endOffsetMs = endOffsetMs;
			this.observedTimeNanos = observedTimeNanos;
			this.eventCount = eventCount;
			this.activeThreadCount = activeThreadCount;
			this.topThreads = topThreads;
		}

		public int bucketIndex() {
			return bucketIndex;
		}

		public long startOffsetMs() {
			return startOffsetMs;
		}

		public long endOffsetMs() {
			return endOffsetMs;
		}

		public long observedTimeNanos() {
			return observedTimeNanos;
		}

		public long eventCount() {
			return eventCount;
		}

		public int activeThreadCount() {
			return activeThreadCount;
		}

		public List<BucketThreadContribution> topThreads() {
			return topThreads;
		}
	}

	public static final class ThreadActivitySnapshot {
		private final long threadId;
		private final long observedTimeNanos;
		private final long eventCount;
		private final int peakBucketIndex;
		private final long peakStartOffsetMs;
		private final long peakEndOffsetMs;
		private final long peakObservedTimeNanos;

		private ThreadActivitySnapshot(long threadId, long observedTimeNanos, long eventCount, int peakBucketIndex,
				long peakStartOffsetMs, long peakEndOffsetMs, long peakObservedTimeNanos) {
			this.threadId = threadId;
			this.observedTimeNanos = observedTimeNanos;
			this.eventCount = eventCount;
			this.peakBucketIndex = peakBucketIndex;
			this.peakStartOffsetMs = peakStartOffsetMs;
			this.peakEndOffsetMs = peakEndOffsetMs;
			this.peakObservedTimeNanos = peakObservedTimeNanos;
		}

		public long threadId() {
			return threadId;
		}

		public long observedTimeNanos() {
			return observedTimeNanos;
		}

		public long eventCount() {
			return eventCount;
		}

		public int peakBucketIndex() {
			return peakBucketIndex;
		}

		public long peakStartOffsetMs() {
			return peakStartOffsetMs;
		}

		public long peakEndOffsetMs() {
			return peakEndOffsetMs;
		}

		public long peakObservedTimeNanos() {
			return peakObservedTimeNanos;
		}
	}

	public static final class BucketThreadContribution {
		private final long threadId;
		private final long observedTimeNanos;

		private BucketThreadContribution(long threadId, long observedTimeNanos) {
			this.threadId = threadId;
			this.observedTimeNanos = observedTimeNanos;
		}

		public long threadId() {
			return threadId;
		}

		public long observedTimeNanos() {
			return observedTimeNanos;
		}
	}

	private static final class TimelineBucketSnapshotComparator implements Comparator<TimelineBucketSnapshot> {
		@Override
		public int compare(TimelineBucketSnapshot left, TimelineBucketSnapshot right) {
			return Integer.compare(left.bucketIndex, right.bucketIndex);
		}
	}

	private static final class ThreadActivitySnapshotComparator implements Comparator<ThreadActivitySnapshot> {
		@Override
		public int compare(ThreadActivitySnapshot left, ThreadActivitySnapshot right) {
			int byObserved = Long.compare(right.observedTimeNanos, left.observedTimeNanos);
			if (byObserved != 0) {
				return byObserved;
			}
			return Long.compare(left.threadId, right.threadId);
		}
	}

	private static final class BucketThreadContributionComparator implements Comparator<BucketThreadContribution> {
		@Override
		public int compare(BucketThreadContribution left, BucketThreadContribution right) {
			int byObserved = Long.compare(right.observedTimeNanos, left.observedTimeNanos);
			if (byObserved != 0) {
				return byObserved;
			}
			return Long.compare(left.threadId, right.threadId);
		}
	}
}
