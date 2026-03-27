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
	private static final String OBJECT_ALLOCATION_SAMPLE = "jdk.ObjectAllocationSample";
	private static final String OBJECT_ALLOCATION_TLAB = "jdk.ObjectAllocationInNewTLAB";
	private static final String OBJECT_ALLOCATION_OUTSIDE_TLAB = "jdk.ObjectAllocationOutsideTLAB";

	private static Recording activeRecording;
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
				enablePeriodicEvent(recording, EXECUTION_SAMPLE, samplePeriod);
				enablePeriodicEvent(recording, NATIVE_METHOD_SAMPLE, samplePeriod);

				if (Controller._trackObjectAlloc) {
					enableEvent(recording, OBJECT_ALLOCATION_SAMPLE);
					enableEvent(recording, OBJECT_ALLOCATION_TLAB);
					enableEvent(recording, OBJECT_ALLOCATION_OUTSIDE_TLAB);
				}

				recording.start();
				activeRecording = recording;
			} catch (Throwable t) {
				closeActiveRecording();
				stoppedReport = JfrReport.unavailable("Unable to start JFR companion recording: " + t.getMessage());
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
				stoppedReport = summarize(tempFile, tempFile.toString());
			} catch (Throwable t) {
				deleteStoppedRecording();
				stoppedReport = JfrReport.unavailable("Unable to finalize JFR companion recording: " + t.getMessage());
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
					preparedReport = summarize(target, targetPath);
				} else if (stoppedRecordingFile != null && Files.exists(stoppedRecordingFile)) {
					Files.copy(stoppedRecordingFile, target, StandardCopyOption.REPLACE_EXISTING);
					preparedReport = stoppedReport.withArtifactPath(targetPath);
				} else if (!stoppedReport.enabled()) {
					preparedReport = JfrReport.disabled();
				} else {
					preparedReport = stoppedReport.withArtifactPath(targetPath);
				}
			} catch (Throwable t) {
				preparedReport = JfrReport.unavailable("Unable to write JFR companion artifact: " + t.getMessage());
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
		}
	}

	private static void enablePeriodicEvent(Recording recording, String eventName, Duration samplePeriod) {
		try {
			recording.enable(eventName).withPeriod(samplePeriod);
		} catch (Throwable ignored) {
		}
	}

	private static void enableEvent(Recording recording, String eventName) {
		try {
			recording.enable(eventName);
		} catch (Throwable ignored) {
		}
	}

	private static JfrReport summarize(Path recordingFile, String artifactPath) throws IOException {
		Map<String, MethodSample> methodSamples = new LinkedHashMap<String, MethodSample>();
		Map<String, AllocationSample> allocationSamples = new LinkedHashMap<String, AllocationSample>();

		long executionSamples = 0;
		long nativeSamples = 0;
		long allocationEvents = 0;

		try (RecordingFile reader = new RecordingFile(recordingFile)) {
			while (reader.hasMoreEvents()) {
				RecordedEvent event = reader.readEvent();
				String eventName = event.getEventType().getName();

				if (EXECUTION_SAMPLE.equals(eventName)) {
					executionSamples++;
					addMethodSample(methodSamples, event);
				} else if (NATIVE_METHOD_SAMPLE.equals(eventName)) {
					nativeSamples++;
					addMethodSample(methodSamples, event);
				} else if (OBJECT_ALLOCATION_SAMPLE.equals(eventName) || OBJECT_ALLOCATION_TLAB.equals(eventName)
						|| OBJECT_ALLOCATION_OUTSIDE_TLAB.equals(eventName)) {
					allocationEvents++;
					addAllocationSample(allocationSamples, event);
				}
			}
		}

		List<MethodSample> topMethodSamples = new ArrayList<MethodSample>(methodSamples.values());
		Collections.sort(topMethodSamples, new MethodSampleComparator());

		List<AllocationSample> topAllocationSamples = new ArrayList<AllocationSample>(allocationSamples.values());
		Collections.sort(topAllocationSamples, new AllocationSampleComparator());

		return JfrReport.enabled(artifactPath, executionSamples, nativeSamples, allocationEvents,
				trimMethodSamples(topMethodSamples), trimAllocationSamples(topAllocationSamples));
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

	private static void closeActiveRecording() {
		if (activeRecording != null) {
			try {
				activeRecording.close();
			} catch (Throwable ignored) {
			}
			activeRecording = null;
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
		private final long executionSampleCount;
		private final long nativeSampleCount;
		private final long allocationSampleCount;
		private final List<MethodSample> topSampledMethods;
		private final List<AllocationSample> topAllocationSamples;
		private final String warning;

		private JfrReport(boolean enabled, String artifactPath, long executionSampleCount, long nativeSampleCount,
				long allocationSampleCount, List<MethodSample> topSampledMethods,
				List<AllocationSample> topAllocationSamples, String warning) {
			this.enabled = enabled;
			this.artifactPath = artifactPath;
			this.executionSampleCount = executionSampleCount;
			this.nativeSampleCount = nativeSampleCount;
			this.allocationSampleCount = allocationSampleCount;
			this.topSampledMethods = topSampledMethods;
			this.topAllocationSamples = topAllocationSamples;
			this.warning = warning;
		}

		public static JfrReport disabled() {
			return new JfrReport(false, null, 0, 0, 0, new ArrayList<MethodSample>(), new ArrayList<AllocationSample>(),
					null);
		}

		public static JfrReport unavailable(String warning) {
			return new JfrReport(true, null, 0, 0, 0, new ArrayList<MethodSample>(), new ArrayList<AllocationSample>(),
					warning);
		}

		public static JfrReport enabled(String artifactPath, long executionSampleCount, long nativeSampleCount,
				long allocationSampleCount, List<MethodSample> topSampledMethods,
				List<AllocationSample> topAllocationSamples) {
			return new JfrReport(true, artifactPath, executionSampleCount, nativeSampleCount, allocationSampleCount,
					topSampledMethods, topAllocationSamples, null);
		}

		public boolean enabled() {
			return enabled;
		}

		public String artifactPath() {
			return artifactPath;
		}

		public long executionSampleCount() {
			return executionSampleCount;
		}

		public long nativeSampleCount() {
			return nativeSampleCount;
		}

		public long allocationSampleCount() {
			return allocationSampleCount;
		}

		public List<MethodSample> topSampledMethods() {
			return topSampledMethods;
		}

		public List<AllocationSample> topAllocationSamples() {
			return topAllocationSamples;
		}

		public String warning() {
			return warning;
		}

		public JfrReport withArtifactPath(String targetPath) {
			return new JfrReport(enabled, targetPath, executionSampleCount, nativeSampleCount, allocationSampleCount,
					topSampledMethods, topAllocationSamples, warning);
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
}
