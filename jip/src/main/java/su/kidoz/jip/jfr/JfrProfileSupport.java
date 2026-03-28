package su.kidoz.jip.jfr;

import com.mentorgen.tools.profile.Controller;
import jdk.jfr.Recording;
import jdk.jfr.ValueDescriptor;
import jdk.jfr.consumer.RecordedClass;
import jdk.jfr.consumer.RecordedEvent;
import jdk.jfr.consumer.RecordedFrame;
import jdk.jfr.consumer.RecordedMethod;
import jdk.jfr.consumer.RecordedStackTrace;
import jdk.jfr.consumer.RecordingFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import su.kidoz.jip.output.ProfileOutputFiles;

public final class JfrProfileSupport {
	private static final Object LOCK = new Object();
	private static final String EXECUTION_SAMPLE = "jdk.ExecutionSample";
	private static final String NATIVE_METHOD_SAMPLE = "jdk.NativeMethodSample";
	private static final String CPU_TIME_SAMPLE = "jdk.CPUTimeSample";
	private static final String OBJECT_ALLOCATION_SAMPLE = "jdk.ObjectAllocationSample";
	private static final String OBJECT_ALLOCATION_TLAB = "jdk.ObjectAllocationInNewTLAB";
	private static final String OBJECT_ALLOCATION_OUTSIDE_TLAB = "jdk.ObjectAllocationOutsideTLAB";
	private static final String JAVA_MONITOR_ENTER = "jdk.JavaMonitorEnter";
	private static final String JAVA_MONITOR_WAIT = "jdk.JavaMonitorWait";
	private static final String THREAD_PARK = "jdk.ThreadPark";

	private static Recording activeRecording;
	private static RecordingMetadata activeMetadata = RecordingMetadata.disabled();
	private static Path stoppedRecordingFile;
	private static JfrReport stoppedReport = JfrReport.disabled();
	private static JfrReport preparedReport = JfrReport.disabled();
	private static String preparedTargetPath;

	private JfrProfileSupport() {
	}

	public static void startProfileSession() {
		synchronized (LOCK) {
			clearPreparedState();
			deleteStoppedRecording();
			stoppedReport = JfrReport.disabled();

			if (!Controller._jfrEnabled) {
				closeActiveRecording();
				return;
			}

			closeActiveRecording();

			try {
				Recording recording = new Recording();
				recording.setName("JIP sampled companion");
				Duration samplePeriod = Duration.ofMillis(Math.max(1, Controller._jfrSamplePeriodMs));
				RecordingMetadata metadata = new RecordingMetadata(samplePeriod.toMillis());
				metadata.executionSamplingEnabled = enablePeriodicEvent(recording, EXECUTION_SAMPLE, samplePeriod);
				metadata.nativeSamplingEnabled = enablePeriodicEvent(recording, NATIVE_METHOD_SAMPLE, samplePeriod);
				metadata.cpuTimeSamplingEnabled = enablePeriodicEvent(recording, CPU_TIME_SAMPLE, samplePeriod);
				metadata.monitorEnterEventsEnabled = enableEvent(recording, JAVA_MONITOR_ENTER);
				metadata.monitorWaitEventsEnabled = enableEvent(recording, JAVA_MONITOR_WAIT);
				metadata.threadParkEventsEnabled = enableEvent(recording, THREAD_PARK);

				if (Controller._trackObjectAlloc) {
					boolean allocationEnabled = false;
					allocationEnabled |= enableEvent(recording, OBJECT_ALLOCATION_SAMPLE);
					allocationEnabled |= enableEvent(recording, OBJECT_ALLOCATION_TLAB);
					allocationEnabled |= enableEvent(recording, OBJECT_ALLOCATION_OUTSIDE_TLAB);
					metadata.allocationEventsEnabled = allocationEnabled;
				}

				recording.start();
				activeRecording = recording;
				activeMetadata = metadata;
			} catch (Throwable t) {
				closeActiveRecording();
				activeMetadata = RecordingMetadata.disabled();
				stoppedReport = JfrReport.unavailable("Unable to start JFR companion recording: " + t.getMessage(),
						RecordingMetadata.disabled());
				System.err.println(stoppedReport.warning());
			}
		}
	}

	public static void stopProfileSession() {
		synchronized (LOCK) {
			if (activeRecording == null) {
				return;
			}

			clearPreparedState();

			try {
				activeRecording.stop();
				Path tempFile = Files.createTempFile("jip-profile-", ".jfr");
				activeRecording.dump(tempFile);
				stoppedRecordingFile = tempFile;
				stoppedReport = summarize(tempFile, tempFile.toString(), activeMetadata);
			} catch (Throwable t) {
				deleteStoppedRecording();
				stoppedReport = JfrReport.unavailable(
						"Unable to finalize JFR companion recording: " + t.getMessage(), activeMetadata);
				System.err.println(stoppedReport.warning());
			} finally {
				closeActiveRecording();
			}
		}
	}

	public static JfrReport prepareReport(ProfileOutputFiles files) {
		synchronized (LOCK) {
			if (!Controller._jfrEnabled) {
				preparedReport = JfrReport.disabled();
				preparedTargetPath = null;
				return preparedReport;
			}

			String targetPath = files.jfrFileName();
			if (preparedTargetPath != null && preparedTargetPath.equals(targetPath)) {
				return preparedReport;
			}

			Path target = Path.of(targetPath);

			try {
				if (target.getParent() != null) {
					Files.createDirectories(target.getParent());
				}

				if (activeRecording != null) {
					activeRecording.dump(target);
					preparedReport = summarize(target, targetPath, activeMetadata);
				} else if (stoppedRecordingFile != null && Files.exists(stoppedRecordingFile)) {
					Files.copy(stoppedRecordingFile, target, StandardCopyOption.REPLACE_EXISTING);
					preparedReport = stoppedReport.withArtifactPath(targetPath);
				} else if (!stoppedReport.enabled()) {
					preparedReport = JfrReport.disabled();
				} else {
					preparedReport = stoppedReport.withArtifactPath(targetPath);
				}
			} catch (Throwable t) {
				preparedReport = JfrReport.unavailable("Unable to write JFR companion artifact: " + t.getMessage(),
						activeMetadata);
				System.err.println(preparedReport.warning());
			}

			preparedTargetPath = targetPath;
			return preparedReport;
		}
	}

	static void resetForTests() {
		synchronized (LOCK) {
			closeActiveRecording();
			clearPreparedState();
			deleteStoppedRecording();
			stoppedReport = JfrReport.disabled();
			activeMetadata = RecordingMetadata.disabled();
		}
	}

	private static boolean enablePeriodicEvent(Recording recording, String eventName, Duration samplePeriod) {
		try {
			recording.enable(eventName).withPeriod(samplePeriod);
			return true;
		} catch (Throwable ignored) {
			return false;
		}
	}

	private static boolean enableEvent(Recording recording, String eventName) {
		try {
			recording.enable(eventName);
			return true;
		} catch (Throwable ignored) {
			return false;
		}
	}

	private static JfrReport summarize(Path recordingFile, String artifactPath, RecordingMetadata metadata)
			throws IOException {
		Map<String, MethodSample> methodSamples = new LinkedHashMap<String, MethodSample>();
		Map<String, AllocationSample> allocationSamples = new LinkedHashMap<String, AllocationSample>();
		Map<String, AllocationPathSample> allocationPathSamples = new LinkedHashMap<String, AllocationPathSample>();
		Map<String, ContentionSample> contentionSamples = new LinkedHashMap<String, ContentionSample>();
		Map<Integer, JfrTimelineBucket> timelineBuckets = new LinkedHashMap<Integer, JfrTimelineBucket>();

		long executionSamples = 0;
		long nativeSamples = 0;
		long cpuTimeSamples = 0;
		long allocationEvents = 0;
		long monitorEnterEvents = 0;
		long monitorWaitEvents = 0;
		long threadParkEvents = 0;
		long totalContentionDurationNanos = 0;
		long timelineBucketSizeMs = Math.max(50L, metadata.samplePeriodMs() <= 0 ? 50L : metadata.samplePeriodMs() * 5L);
		Instant firstEventTime = null;

		try (RecordingFile reader = new RecordingFile(recordingFile)) {
			while (reader.hasMoreEvents()) {
				RecordedEvent event = reader.readEvent();
				String eventName = event.getEventType().getName();
				Instant eventStartTime = safeEventStartTime(event);
				if (firstEventTime == null && eventStartTime != null) {
					firstEventTime = eventStartTime;
				}
				int bucketIndex = timelineBucketIndex(firstEventTime, eventStartTime, timelineBucketSizeMs);

				if (EXECUTION_SAMPLE.equals(eventName)) {
					executionSamples++;
					addMethodSample(methodSamples, event);
					recordTimelineEvent(timelineBuckets, bucketIndex, timelineBucketSizeMs, TimelineEventType.ExecutionSample);
				} else if (CPU_TIME_SAMPLE.equals(eventName)) {
					cpuTimeSamples++;
					addMethodSample(methodSamples, event);
					recordTimelineEvent(timelineBuckets, bucketIndex, timelineBucketSizeMs, TimelineEventType.CpuTimeSample);
				} else if (NATIVE_METHOD_SAMPLE.equals(eventName)) {
					nativeSamples++;
					addMethodSample(methodSamples, event);
					recordTimelineEvent(timelineBuckets, bucketIndex, timelineBucketSizeMs, TimelineEventType.NativeSample);
				} else if (OBJECT_ALLOCATION_SAMPLE.equals(eventName) || OBJECT_ALLOCATION_TLAB.equals(eventName)
						|| OBJECT_ALLOCATION_OUTSIDE_TLAB.equals(eventName)) {
					allocationEvents++;
					addAllocationSample(allocationSamples, event);
					addAllocationPathSample(allocationPathSamples, event);
					recordTimelineEvent(timelineBuckets, bucketIndex, timelineBucketSizeMs, TimelineEventType.Allocation);
				} else if (JAVA_MONITOR_ENTER.equals(eventName)) {
					monitorEnterEvents++;
					totalContentionDurationNanos += addContentionSample(contentionSamples, event,
							ContentionType.MonitorEnter);
					recordTimelineEvent(timelineBuckets, bucketIndex, timelineBucketSizeMs, TimelineEventType.Contention);
				} else if (JAVA_MONITOR_WAIT.equals(eventName)) {
					monitorWaitEvents++;
					totalContentionDurationNanos += addContentionSample(contentionSamples, event,
							ContentionType.MonitorWait);
					recordTimelineEvent(timelineBuckets, bucketIndex, timelineBucketSizeMs, TimelineEventType.Contention);
				} else if (THREAD_PARK.equals(eventName)) {
					threadParkEvents++;
					totalContentionDurationNanos += addContentionSample(contentionSamples, event, ContentionType.ThreadPark);
					recordTimelineEvent(timelineBuckets, bucketIndex, timelineBucketSizeMs, TimelineEventType.Contention);
				}
			}
		}

		List<MethodSample> topMethodSamples = new ArrayList<MethodSample>(methodSamples.values());
		Collections.sort(topMethodSamples, new MethodSampleComparator());

		List<AllocationSample> topAllocationSamples = new ArrayList<AllocationSample>(allocationSamples.values());
		Collections.sort(topAllocationSamples, new AllocationSampleComparator());
		List<AllocationPathSample> topAllocationPaths = new ArrayList<AllocationPathSample>(allocationPathSamples.values());
		Collections.sort(topAllocationPaths, new AllocationPathSampleComparator());

		List<ContentionSample> topContentionSamples = new ArrayList<ContentionSample>(contentionSamples.values());
		Collections.sort(topContentionSamples, new ContentionSampleComparator());
		List<JfrTimelineBucket> timeline = new ArrayList<JfrTimelineBucket>(timelineBuckets.values());
		Collections.sort(timeline, new JfrTimelineBucketComparator());

		return JfrReport.enabled(artifactPath, executionSamples, nativeSamples, cpuTimeSamples, allocationEvents,
				monitorEnterEvents, monitorWaitEvents, threadParkEvents, totalContentionDurationNanos,
				trimMethodSamples(topMethodSamples), trimAllocationSamples(topAllocationSamples),
				trimAllocationPathSamples(topAllocationPaths),
				trimContentionSamples(topContentionSamples), trimTimelineBuckets(timeline), timelineBucketSizeMs,
				metadata);
	}

	private static void addMethodSample(Map<String, MethodSample> methodSamples, RecordedEvent event) {
		String methodName = topFrameName(event);
		if (methodName == null) {
			return;
		}

		MethodSample sample = methodSamples.get(methodName);
		if (sample == null) {
			sample = new MethodSample(methodName, 0);
			methodSamples.put(methodName, sample);
		}
		sample.samples++;
	}

	private static void addAllocationSample(Map<String, AllocationSample> allocationSamples, RecordedEvent event) {
		String className = recordedClassName(event);
		if (className == null) {
			return;
		}

		AllocationSample sample = allocationSamples.get(className);
		if (sample == null) {
			sample = new AllocationSample(className, 0, 0);
			allocationSamples.put(className, sample);
		}

		sample.samples++;
		sample.bytes += recordedAllocationBytes(event);
	}

	private static void addAllocationPathSample(Map<String, AllocationPathSample> allocationPathSamples,
			RecordedEvent event) {
		String className = recordedClassName(event);
		if (className == null) {
			return;
		}

		String pathName = topFrameName(event);
		if (pathName == null) {
			pathName = "<unknown>";
		}

		String key = className + "@" + pathName;
		AllocationPathSample sample = allocationPathSamples.get(key);
		if (sample == null) {
			sample = new AllocationPathSample(className, pathName);
			allocationPathSamples.put(key, sample);
		}

		sample.samples++;
		sample.bytes += recordedAllocationBytes(event);
	}

	private static long addContentionSample(Map<String, ContentionSample> contentionSamples, RecordedEvent event,
			ContentionType type) {
		String methodName = topFrameName(event);
		if (methodName == null) {
			methodName = type.displayName;
		}

		ContentionSample sample = contentionSamples.get(methodName);
		if (sample == null) {
			sample = new ContentionSample(methodName);
			contentionSamples.put(methodName, sample);
		}

		long durationNanos = recordedDurationNanos(event);
		sample.totalDurationNanos += durationNanos;
		if (type == ContentionType.MonitorEnter) {
			sample.monitorEnterCount++;
		} else if (type == ContentionType.MonitorWait) {
			sample.monitorWaitCount++;
		} else if (type == ContentionType.ThreadPark) {
			sample.threadParkCount++;
		}

		return durationNanos;
	}

	private static String topFrameName(RecordedEvent event) {
		RecordedStackTrace stackTrace = event.getStackTrace();
		if (stackTrace == null) {
			return null;
		}

		for (RecordedFrame frame : stackTrace.getFrames()) {
			RecordedMethod method = frame.getMethod();
			if (method == null || method.getType() == null) {
				continue;
			}

			String className = method.getType().getName();
			if (className == null || className.length() == 0) {
				continue;
			}

			if (className.startsWith("com.mentorgen.tools.profile.") || className.startsWith("su.kidoz.jip.")
					|| className.startsWith("jdk.jfr.")) {
				continue;
			}

			return className + ":" + method.getName();
		}

		return null;
	}

	private static String recordedClassName(RecordedEvent event) {
		if (!hasField(event, "objectClass")) {
			return null;
		}

		try {
			RecordedClass recordedClass = event.getValue("objectClass");
			return recordedClass == null ? null : recordedClass.getName();
		} catch (Throwable ignored) {
			return null;
		}
	}

	private static long recordedAllocationBytes(RecordedEvent event) {
		return firstLongField(event, "allocationSize", "tlabSize", "weight");
	}

	private static long recordedDurationNanos(RecordedEvent event) {
		try {
			Duration duration = event.getDuration();
			if (duration != null) {
				return duration.toNanos();
			}
		} catch (Throwable ignored) {
		}
		return 0;
	}

	private static long firstLongField(RecordedEvent event, String... fieldNames) {
		for (String fieldName : fieldNames) {
			if (!hasField(event, fieldName)) {
				continue;
			}

			try {
				Object value = event.getValue(fieldName);
				if (value instanceof Number) {
					return ((Number) value).longValue();
				}
			} catch (Throwable ignored) {
			}
		}

		return 0;
	}

	private static boolean hasField(RecordedEvent event, String fieldName) {
		for (ValueDescriptor field : event.getEventType().getFields()) {
			if (fieldName.equals(field.getName())) {
				return true;
			}
		}

		return false;
	}

	private static List<MethodSample> trimMethodSamples(List<MethodSample> samples) {
		return samples.size() <= 20 ? samples : new ArrayList<MethodSample>(samples.subList(0, 20));
	}

	private static List<AllocationSample> trimAllocationSamples(List<AllocationSample> samples) {
		return samples.size() <= 20 ? samples : new ArrayList<AllocationSample>(samples.subList(0, 20));
	}

	private static List<AllocationPathSample> trimAllocationPathSamples(List<AllocationPathSample> samples) {
		return samples.size() <= 20 ? samples : new ArrayList<AllocationPathSample>(samples.subList(0, 20));
	}

	private static List<ContentionSample> trimContentionSamples(List<ContentionSample> samples) {
		return samples.size() <= 20 ? samples : new ArrayList<ContentionSample>(samples.subList(0, 20));
	}

	private static List<JfrTimelineBucket> trimTimelineBuckets(List<JfrTimelineBucket> buckets) {
		return buckets.size() <= 60 ? buckets : new ArrayList<JfrTimelineBucket>(buckets.subList(0, 60));
	}

	private static int timelineBucketIndex(Instant firstEventTime, Instant eventStartTime, long bucketSizeMs) {
		if (firstEventTime == null || eventStartTime == null) {
			return 0;
		}

		long offsetMs = Math.max(0L, Duration.between(firstEventTime, eventStartTime).toMillis());
		return (int) (offsetMs / bucketSizeMs);
	}

	private static void recordTimelineEvent(Map<Integer, JfrTimelineBucket> timelineBuckets, int bucketIndex,
			long bucketSizeMs, TimelineEventType type) {
		JfrTimelineBucket bucket = timelineBuckets.computeIfAbsent(Integer.valueOf(bucketIndex),
				ignored -> new JfrTimelineBucket(bucketIndex, bucketSizeMs));
		bucket.record(type);
	}

	private static Instant safeEventStartTime(RecordedEvent event) {
		try {
			return event.getStartTime();
		} catch (Throwable ignored) {
			return null;
		}
	}

	private static void closeActiveRecording() {
		if (activeRecording != null) {
			try {
				activeRecording.close();
			} catch (Throwable ignored) {
			}
			activeRecording = null;
			activeMetadata = RecordingMetadata.disabled();
		}
	}

	private static void deleteStoppedRecording() {
		if (stoppedRecordingFile != null) {
			try {
				Files.deleteIfExists(stoppedRecordingFile);
			} catch (IOException ignored) {
			}
			stoppedRecordingFile = null;
		}
	}

	private static void clearPreparedState() {
		preparedReport = JfrReport.disabled();
		preparedTargetPath = null;
	}

	public static final class JfrReport {
		private final boolean enabled;
		private final String artifactPath;
		private final RecordingMetadata metadata;
		private final long executionSampleCount;
		private final long nativeSampleCount;
		private final long cpuTimeSampleCount;
		private final long allocationSampleCount;
		private final long monitorEnterCount;
		private final long monitorWaitCount;
		private final long threadParkCount;
		private final long contentionDurationNanos;
		private final long timelineBucketSizeMs;
		private final List<MethodSample> topSampledMethods;
		private final List<AllocationSample> topAllocationSamples;
		private final List<AllocationPathSample> topAllocationPaths;
		private final List<ContentionSample> topContentionSamples;
		private final List<JfrTimelineBucket> timelineBuckets;
		private final String warning;

		private JfrReport(boolean enabled, String artifactPath, RecordingMetadata metadata, long executionSampleCount,
				long nativeSampleCount, long cpuTimeSampleCount, long allocationSampleCount, long monitorEnterCount,
				long monitorWaitCount, long threadParkCount, long contentionDurationNanos,
				List<MethodSample> topSampledMethods, List<AllocationSample> topAllocationSamples,
				List<AllocationPathSample> topAllocationPaths,
				List<ContentionSample> topContentionSamples, List<JfrTimelineBucket> timelineBuckets,
				long timelineBucketSizeMs, String warning) {
			this.enabled = enabled;
			this.artifactPath = artifactPath;
			this.metadata = metadata;
			this.executionSampleCount = executionSampleCount;
			this.nativeSampleCount = nativeSampleCount;
			this.cpuTimeSampleCount = cpuTimeSampleCount;
			this.allocationSampleCount = allocationSampleCount;
			this.monitorEnterCount = monitorEnterCount;
			this.monitorWaitCount = monitorWaitCount;
			this.threadParkCount = threadParkCount;
			this.contentionDurationNanos = contentionDurationNanos;
			this.timelineBucketSizeMs = timelineBucketSizeMs;
			this.topSampledMethods = topSampledMethods;
			this.topAllocationSamples = topAllocationSamples;
			this.topAllocationPaths = topAllocationPaths;
			this.topContentionSamples = topContentionSamples;
			this.timelineBuckets = timelineBuckets;
			this.warning = warning;
		}

		public static JfrReport disabled() {
			return new JfrReport(false, null, RecordingMetadata.disabled(), 0, 0, 0, 0, 0, 0, 0, 0,
					new ArrayList<MethodSample>(), new ArrayList<AllocationSample>(),
					new ArrayList<AllocationPathSample>(), new ArrayList<ContentionSample>(),
					new ArrayList<JfrTimelineBucket>(), 0, null);
		}

		public static JfrReport unavailable(String warning, RecordingMetadata metadata) {
			return new JfrReport(true, null, metadata, 0, 0, 0, 0, 0, 0, 0, 0, new ArrayList<MethodSample>(),
					new ArrayList<AllocationSample>(), new ArrayList<AllocationPathSample>(),
					new ArrayList<ContentionSample>(),
					new ArrayList<JfrTimelineBucket>(), 0, warning);
		}

		public static JfrReport enabled(String artifactPath, long executionSampleCount, long nativeSampleCount,
				long cpuTimeSampleCount, long allocationSampleCount, long monitorEnterCount, long monitorWaitCount,
				long threadParkCount, long contentionDurationNanos, List<MethodSample> topSampledMethods,
				List<AllocationSample> topAllocationSamples, List<AllocationPathSample> topAllocationPaths,
				List<ContentionSample> topContentionSamples,
				List<JfrTimelineBucket> timelineBuckets, long timelineBucketSizeMs, RecordingMetadata metadata) {
			return new JfrReport(true, artifactPath, metadata, executionSampleCount, nativeSampleCount,
					cpuTimeSampleCount, allocationSampleCount, monitorEnterCount, monitorWaitCount, threadParkCount,
					contentionDurationNanos, topSampledMethods, topAllocationSamples, topAllocationPaths,
					topContentionSamples,
					timelineBuckets, timelineBucketSizeMs, null);
		}

		public boolean enabled() {
			return enabled;
		}

		public String artifactPath() {
			return artifactPath;
		}

		public RecordingMetadata metadata() {
			return metadata;
		}

		public long executionSampleCount() {
			return executionSampleCount;
		}

		public long nativeSampleCount() {
			return nativeSampleCount;
		}

		public long cpuTimeSampleCount() {
			return cpuTimeSampleCount;
		}

		public long allocationSampleCount() {
			return allocationSampleCount;
		}

		public long monitorEnterCount() {
			return monitorEnterCount;
		}

		public long monitorWaitCount() {
			return monitorWaitCount;
		}

		public long threadParkCount() {
			return threadParkCount;
		}

		public long contentionEventCount() {
			return monitorEnterCount + monitorWaitCount + threadParkCount;
		}

		public long contentionDurationNanos() {
			return contentionDurationNanos;
		}

		public List<MethodSample> topSampledMethods() {
			return topSampledMethods;
		}

		public List<AllocationSample> topAllocationSamples() {
			return topAllocationSamples;
		}

		public List<AllocationPathSample> topAllocationPaths() {
			return topAllocationPaths;
		}

		public List<ContentionSample> topContentionSamples() {
			return topContentionSamples;
		}

		public List<JfrTimelineBucket> timelineBuckets() {
			return timelineBuckets;
		}

		public long timelineBucketSizeMs() {
			return timelineBucketSizeMs;
		}

		public String warning() {
			return warning;
		}

		public JfrReport withArtifactPath(String targetPath) {
			return new JfrReport(enabled, targetPath, metadata, executionSampleCount, nativeSampleCount,
					cpuTimeSampleCount, allocationSampleCount, monitorEnterCount, monitorWaitCount, threadParkCount,
					contentionDurationNanos, topSampledMethods, topAllocationSamples, topAllocationPaths,
					topContentionSamples,
					timelineBuckets, timelineBucketSizeMs, warning);
		}
	}

	public static final class RecordingMetadata {
		private final long samplePeriodMs;
		private boolean executionSamplingEnabled;
		private boolean nativeSamplingEnabled;
		private boolean cpuTimeSamplingEnabled;
		private boolean allocationEventsEnabled;
		private boolean monitorEnterEventsEnabled;
		private boolean monitorWaitEventsEnabled;
		private boolean threadParkEventsEnabled;

		private RecordingMetadata(long samplePeriodMs) {
			this.samplePeriodMs = samplePeriodMs;
		}

		public static RecordingMetadata disabled() {
			return new RecordingMetadata(0);
		}

		public long samplePeriodMs() {
			return samplePeriodMs;
		}

		public boolean executionSamplingEnabled() {
			return executionSamplingEnabled;
		}

		public boolean nativeSamplingEnabled() {
			return nativeSamplingEnabled;
		}

		public boolean cpuTimeSamplingEnabled() {
			return cpuTimeSamplingEnabled;
		}

		public boolean allocationEventsEnabled() {
			return allocationEventsEnabled;
		}

		public boolean monitorEnterEventsEnabled() {
			return monitorEnterEventsEnabled;
		}

		public boolean monitorWaitEventsEnabled() {
			return monitorWaitEventsEnabled;
		}

		public boolean threadParkEventsEnabled() {
			return threadParkEventsEnabled;
		}
	}

	public static final class MethodSample {
		private final String name;
		private long samples;

		private MethodSample(String name, long samples) {
			this.name = name;
			this.samples = samples;
		}

		public String name() {
			return name;
		}

		public long samples() {
			return samples;
		}
	}

	public static final class AllocationSample {
		private final String className;
		private long samples;
		private long bytes;

		private AllocationSample(String className, long samples, long bytes) {
			this.className = className;
			this.samples = samples;
			this.bytes = bytes;
		}

		public String className() {
			return className;
		}

		public long samples() {
			return samples;
		}

		public long bytes() {
			return bytes;
		}
	}

	public static final class AllocationPathSample {
		private final String className;
		private final String pathName;
		private long samples;
		private long bytes;

		private AllocationPathSample(String className, String pathName) {
			this.className = className;
			this.pathName = pathName;
		}

		public String className() {
			return className;
		}

		public String pathName() {
			return pathName;
		}

		public long samples() {
			return samples;
		}

		public long bytes() {
			return bytes;
		}
	}

	public static final class ContentionSample {
		private final String name;
		private long monitorEnterCount;
		private long monitorWaitCount;
		private long threadParkCount;
		private long totalDurationNanos;

		private ContentionSample(String name) {
			this.name = name;
		}

		public String name() {
			return name;
		}

		public long monitorEnterCount() {
			return monitorEnterCount;
		}

		public long monitorWaitCount() {
			return monitorWaitCount;
		}

		public long threadParkCount() {
			return threadParkCount;
		}

		public long totalEventCount() {
			return monitorEnterCount + monitorWaitCount + threadParkCount;
		}

		public long totalDurationNanos() {
			return totalDurationNanos;
		}
	}

	public static final class JfrTimelineBucket {
		private final int bucketIndex;
		private final long startOffsetMs;
		private final long endOffsetMs;
		private long executionSamples;
		private long nativeSamples;
		private long cpuTimeSamples;
		private long allocationEvents;
		private long contentionEvents;

		private JfrTimelineBucket(int bucketIndex, long bucketSizeMs) {
			this.bucketIndex = bucketIndex;
			this.startOffsetMs = bucketIndex * bucketSizeMs;
			this.endOffsetMs = (bucketIndex + 1L) * bucketSizeMs;
		}

		private void record(TimelineEventType type) {
			if (type == TimelineEventType.ExecutionSample) {
				executionSamples++;
			} else if (type == TimelineEventType.NativeSample) {
				nativeSamples++;
			} else if (type == TimelineEventType.CpuTimeSample) {
				cpuTimeSamples++;
			} else if (type == TimelineEventType.Allocation) {
				allocationEvents++;
			} else if (type == TimelineEventType.Contention) {
				contentionEvents++;
			}
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

		public long executionSamples() {
			return executionSamples;
		}

		public long nativeSamples() {
			return nativeSamples;
		}

		public long cpuTimeSamples() {
			return cpuTimeSamples;
		}

		public long allocationEvents() {
			return allocationEvents;
		}

		public long contentionEvents() {
			return contentionEvents;
		}
	}

	private enum ContentionType {
		MonitorEnter("monitor-enter"),
		MonitorWait("monitor-wait"),
		ThreadPark("thread-park");

		private final String displayName;

		ContentionType(String displayName) {
			this.displayName = displayName;
		}
	}

	private enum TimelineEventType {
		ExecutionSample,
		NativeSample,
		CpuTimeSample,
		Allocation,
		Contention
	}

	private static final class MethodSampleComparator implements Comparator<MethodSample> {
		@Override
		public int compare(MethodSample left, MethodSample right) {
			int bySamples = Long.compare(right.samples(), left.samples());
			if (bySamples != 0) {
				return bySamples;
			}
			return left.name().compareTo(right.name());
		}
	}

	private static final class AllocationSampleComparator implements Comparator<AllocationSample> {
		@Override
		public int compare(AllocationSample left, AllocationSample right) {
			int bySamples = Long.compare(right.samples(), left.samples());
			if (bySamples != 0) {
				return bySamples;
			}
			return left.className().compareTo(right.className());
		}
	}

	private static final class AllocationPathSampleComparator implements Comparator<AllocationPathSample> {
		@Override
		public int compare(AllocationPathSample left, AllocationPathSample right) {
			int byBytes = Long.compare(right.bytes(), left.bytes());
			if (byBytes != 0) {
				return byBytes;
			}
			int bySamples = Long.compare(right.samples(), left.samples());
			if (bySamples != 0) {
				return bySamples;
			}
			int byPath = left.pathName().compareTo(right.pathName());
			if (byPath != 0) {
				return byPath;
			}
			return left.className().compareTo(right.className());
		}
	}

	private static final class ContentionSampleComparator implements Comparator<ContentionSample> {
		@Override
		public int compare(ContentionSample left, ContentionSample right) {
			int byDuration = Long.compare(right.totalDurationNanos, left.totalDurationNanos);
			if (byDuration != 0) {
				return byDuration;
			}
			int byCount = Long.compare(right.totalEventCount(), left.totalEventCount());
			if (byCount != 0) {
				return byCount;
			}
			return left.name.compareTo(right.name);
		}
	}

	private static final class JfrTimelineBucketComparator implements Comparator<JfrTimelineBucket> {
		@Override
		public int compare(JfrTimelineBucket left, JfrTimelineBucket right) {
			return Integer.compare(left.bucketIndex(), right.bucketIndex());
		}
	}
}
