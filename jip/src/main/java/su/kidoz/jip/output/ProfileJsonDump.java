package su.kidoz.jip.output;

import com.mentorgen.tools.profile.Controller;
import com.mentorgen.tools.profile.runtime.ClassAllocation;
import com.mentorgen.tools.profile.runtime.Frame;
import com.mentorgen.tools.profile.runtime.Profile;
import su.kidoz.jip.asyncprofiler.AsyncProfilerSupport;
import su.kidoz.jip.asyncprofiler.AsyncProfilerSupport.ArtifactLink;
import su.kidoz.jip.asyncprofiler.AsyncProfilerSupport.AsyncProfilerReport;
import su.kidoz.jip.asyncprofiler.AsyncProfilerSupport.CollapsedReport;
import su.kidoz.jip.asyncprofiler.AsyncProfilerSupport.FrameSample;
import su.kidoz.jip.asyncprofiler.AsyncProfilerSupport.StackSample;
import su.kidoz.jip.jfr.JfrProfileSupport;
import su.kidoz.jip.jfr.JfrProfileSupport.AllocationSample;
import su.kidoz.jip.jfr.JfrProfileSupport.AllocationPathSample;
import su.kidoz.jip.jfr.JfrProfileSupport.ContentionSample;
import su.kidoz.jip.jfr.JfrProfileSupport.JfrTimelineBucket;
import su.kidoz.jip.jfr.JfrProfileSupport.JfrReport;
import su.kidoz.jip.jfr.JfrProfileSupport.MethodSample;
import su.kidoz.jip.jfr.JfrProfileSupport.RecordingMetadata;
import su.kidoz.jip.timeline.TimelineRecorder;
import su.kidoz.jip.timeline.TimelineRecorder.BucketThreadContribution;
import su.kidoz.jip.timeline.TimelineRecorder.ThreadActivitySnapshot;
import su.kidoz.jip.timeline.TimelineRecorder.TimelineBucketSnapshot;
import su.kidoz.jip.timeline.TimelineRecorder.TimelineSnapshot;
import su.kidoz.jip.output.RecordingHistorySupport.HistoryEntry;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;

public final class ProfileJsonDump {
	public static SnapshotDocument dump(ProfileOutputFiles files) throws IOException {
		SnapshotDocument document = buildSnapshotDocument(files);

		FileWriter out = new FileWriter(files.jsonFileName());
		BufferedWriter bufferedWriter = new BufferedWriter(out);
		PrintWriter writer = new PrintWriter(bufferedWriter);
		writer.print(document.json());
		writer.flush();
		out.close();
		return document;
	}

	public static String buildSnapshot(ProfileOutputFiles files) {
		return buildSnapshotDocument(files).json();
	}

	public static SnapshotDocument buildSnapshotDocument(ProfileOutputFiles files) {
		SnapshotState state = SnapshotState.capture();
		JfrReport jfrReport = JfrProfileSupport.prepareReport(files);
		AsyncProfilerReport asyncProfilerReport = AsyncProfilerSupport.prepareReport();
		HistoryEntry currentHistoryEntry = RecordingHistorySupport.createCurrentEntry(files,
				state.topMethods.isEmpty() ? "" : state.topMethods.get(0).name, state.threadCount,
				state.totalObservedTimeNanos, Controller._outputType == Controller.OutputType.Html,
				jfrReport.artifactPath());
		List<HistoryEntry> historyEntries = RecordingHistorySupport.collectHistory(files, currentHistoryEntry);
		List<HistoryEntry> embeddedHistory = RecordingHistorySupport.embeddedPreview(historyEntries);
		StringBuilder json = new StringBuilder(64 * 1024);

		json.append("{\n");
		appendQuotedField(json, "schemaVersion", "jip-v1", 1, true);
		appendQuotedField(json, "snapshotLabel", files.snapshotLabel(), 1, true);
		appendQuotedField(json, "generatedAt", files.snapshotTimestamp(), 1, true);
		appendQuotedField(json, "clockResolution", Controller._timeResoltion.name(), 1, true);
		appendSummary(json, state, 1);
		json.append(",\n");
		appendTimeline(json, TimelineRecorder.snapshot(), jfrReport, 1);
		json.append(",\n");
		appendThreads(json, state, 1);
		json.append(",\n");
		appendMethodSummaries(json, "topMethods", state.topMethods, 1);
		json.append(",\n");
		appendMethodSummaries(json, "methodSummary", state.methodSummary, 1);
		json.append(",\n");
		appendAllocations(json, state.allocations, jfrReport, 1);
		json.append(",\n");
		appendJfr(json, jfrReport, 1);
		json.append(",\n");
		appendAsyncProfiler(json, asyncProfilerReport, 1);
		json.append(",\n");
		appendInsights(json, InsightsAnalyzer.analyze(state, jfrReport), 1);
		json.append(",\n");
		appendHistory(json, files, currentHistoryEntry, embeddedHistory, 1);
		json.append(",\n");
		indent(json, 1);
		json.append("\"artifacts\": {\n");
		appendQuotedField(json, "basePath", files.basePath(), 2, true);
		appendQuotedField(json, "json", files.jsonFileName(), 2, true);
		appendQuotedField(json, "html", files.htmlFileName(), 2, true);
		appendQuotedField(json, "jfr", jfrReport.artifactPath() == null ? "" : jfrReport.artifactPath(), 2, true);
		appendQuotedField(json, "recordingIndex", files.historyEnabled() ? files.recordingIndexFileName() : "", 2,
				false);
		json.append("\n");
		indent(json, 1);
		json.append("}\n");
		json.append("}\n");

		return new SnapshotDocument(json.toString(), historyEntries);
	}

	private static void appendSummary(StringBuilder json, SnapshotState state, int depth) {
		indent(json, depth);
		json.append("\"summary\": {\n");
		appendNumericField(json, "threadCount", state.threadCount, depth + 1, true);
		appendNumericField(json, "interactionCount", state.interactionCount, depth + 1, true);
		appendNumericField(json, "frameCount", state.frameCount, depth + 1, true);
		appendNumericField(json, "allocationClassCount", state.allocations.size(), depth + 1, true);
		appendNumericField(json, "totalObservedTimeNanos", state.totalObservedTimeNanos, depth + 1, false);
		json.append("\n");
		indent(json, depth);
		json.append("}");
	}

	private static void appendTimeline(StringBuilder json, TimelineSnapshot timeline, JfrReport report, int depth) {
		indent(json, depth);
		json.append("\"timeline\": {\n");
		appendNumericField(json, "bucketSizeMs", timeline.bucketSizeMs(), depth + 1, true);
		appendNumericField(json, "durationNanos", timeline.durationNanos(), depth + 1, true);
		appendNumericField(json, "jfrBucketSizeMs", report.timelineBucketSizeMs(), depth + 1, true);
		appendTimelineBuckets(json, timeline.buckets(), depth + 1);
		json.append(",\n");
		appendThreadActivity(json, timeline.threadActivity(), depth + 1);
		json.append(",\n");
		appendJfrTimelineBuckets(json, report.timelineBuckets(), depth + 1);
		json.append("\n");
		indent(json, depth);
		json.append("}");
	}

	private static void appendThreads(StringBuilder json, SnapshotState state, int depth) {
		indent(json, depth);
		json.append("\"threads\": [\n");

		for (int threadIndex = 0; threadIndex < state.threads.size(); threadIndex++) {
			ThreadSnapshot thread = state.threads.get(threadIndex);
			indent(json, depth + 1);
			json.append("{\n");
			appendNumericField(json, "threadId", thread.threadId, depth + 2, true);
			appendNumericField(json, "totalTimeNanos", thread.totalTimeNanos, depth + 2, true);
			indent(json, depth + 2);
			json.append("\"interactions\": [\n");
			for (int i = 0; i < thread.interactions.size(); i++) {
				appendFrame(json, thread.interactions.get(i), depth + 3);
				if (i + 1 < thread.interactions.size()) {
					json.append(",");
				}
				json.append("\n");
			}
			indent(json, depth + 2);
			json.append("]\n");
			indent(json, depth + 1);
			json.append("}");
			if (threadIndex + 1 < state.threads.size()) {
				json.append(",");
			}
			json.append("\n");
		}

		indent(json, depth);
		json.append("]");
	}

	private static void appendTimelineBuckets(StringBuilder json, List<TimelineBucketSnapshot> buckets, int depth) {
		indent(json, depth);
		json.append("\"buckets\": [\n");

		for (int i = 0; i < buckets.size(); i++) {
			TimelineBucketSnapshot bucket = buckets.get(i);
			indent(json, depth + 1);
			json.append("{\n");
			appendNumericField(json, "bucketIndex", bucket.bucketIndex(), depth + 2, true);
			appendNumericField(json, "startOffsetMs", bucket.startOffsetMs(), depth + 2, true);
			appendNumericField(json, "endOffsetMs", bucket.endOffsetMs(), depth + 2, true);
			appendNumericField(json, "observedTimeNanos", bucket.observedTimeNanos(), depth + 2, true);
			appendNumericField(json, "eventCount", bucket.eventCount(), depth + 2, true);
			appendNumericField(json, "activeThreadCount", bucket.activeThreadCount(), depth + 2, true);
			appendBucketThreads(json, bucket.topThreads(), depth + 2);
			json.append("\n");
			indent(json, depth + 1);
			json.append("}");
			if (i + 1 < buckets.size()) {
				json.append(",");
			}
			json.append("\n");
		}

		indent(json, depth);
		json.append("]");
	}

	private static void appendBucketThreads(StringBuilder json, List<BucketThreadContribution> threads, int depth) {
		indent(json, depth);
		json.append("\"topThreads\": [\n");

		for (int i = 0; i < threads.size(); i++) {
			BucketThreadContribution thread = threads.get(i);
			indent(json, depth + 1);
			json.append("{\n");
			appendNumericField(json, "threadId", thread.threadId(), depth + 2, true);
			appendNumericField(json, "observedTimeNanos", thread.observedTimeNanos(), depth + 2, false);
			json.append("\n");
			indent(json, depth + 1);
			json.append("}");
			if (i + 1 < threads.size()) {
				json.append(",");
			}
			json.append("\n");
		}

		indent(json, depth);
		json.append("]");
	}

	private static void appendThreadActivity(StringBuilder json, List<ThreadActivitySnapshot> threads, int depth) {
		indent(json, depth);
		json.append("\"threads\": [\n");

		for (int i = 0; i < threads.size(); i++) {
			ThreadActivitySnapshot thread = threads.get(i);
			indent(json, depth + 1);
			json.append("{\n");
			appendNumericField(json, "threadId", thread.threadId(), depth + 2, true);
			appendNumericField(json, "observedTimeNanos", thread.observedTimeNanos(), depth + 2, true);
			appendNumericField(json, "eventCount", thread.eventCount(), depth + 2, true);
			appendNumericField(json, "peakBucketIndex", thread.peakBucketIndex(), depth + 2, true);
			appendNumericField(json, "peakStartOffsetMs", thread.peakStartOffsetMs(), depth + 2, true);
			appendNumericField(json, "peakEndOffsetMs", thread.peakEndOffsetMs(), depth + 2, true);
			appendNumericField(json, "peakObservedTimeNanos", thread.peakObservedTimeNanos(), depth + 2, false);
			json.append("\n");
			indent(json, depth + 1);
			json.append("}");
			if (i + 1 < threads.size()) {
				json.append(",");
			}
			json.append("\n");
		}

		indent(json, depth);
		json.append("]");
	}

	private static void appendJfrTimelineBuckets(StringBuilder json, List<JfrTimelineBucket> buckets, int depth) {
		indent(json, depth);
		json.append("\"jfrBuckets\": [\n");

		for (int i = 0; i < buckets.size(); i++) {
			JfrTimelineBucket bucket = buckets.get(i);
			indent(json, depth + 1);
			json.append("{\n");
			appendNumericField(json, "bucketIndex", bucket.bucketIndex(), depth + 2, true);
			appendNumericField(json, "startOffsetMs", bucket.startOffsetMs(), depth + 2, true);
			appendNumericField(json, "endOffsetMs", bucket.endOffsetMs(), depth + 2, true);
			appendNumericField(json, "executionSamples", bucket.executionSamples(), depth + 2, true);
			appendNumericField(json, "nativeSamples", bucket.nativeSamples(), depth + 2, true);
			appendNumericField(json, "cpuTimeSamples", bucket.cpuTimeSamples(), depth + 2, true);
			appendNumericField(json, "allocationEvents", bucket.allocationEvents(), depth + 2, true);
			appendNumericField(json, "contentionEvents", bucket.contentionEvents(), depth + 2, false);
			json.append("\n");
			indent(json, depth + 1);
			json.append("}");
			if (i + 1 < buckets.size()) {
				json.append(",");
			}
			json.append("\n");
		}

		indent(json, depth);
		json.append("]");
	}

	private static void appendFrame(StringBuilder json, Frame frame, int depth) {
		indent(json, depth);
		json.append("{\n");
		appendQuotedField(json, "name", frame.getName(), depth + 1, true);
		appendQuotedField(json, "className", frame.getClassName(), depth + 1, true);
		appendQuotedField(json, "methodName", frame.getMethodName(), depth + 1, true);
		appendNumericField(json, "count", frame._metrics.getCount(), depth + 1, true);
		appendNumericField(json, "totalTimeNanos", frame._metrics.getTotalTime(), depth + 1, true);
		appendNumericField(json, "netTimeNanos", frame.netTime(), depth + 1, true);
		indent(json, depth + 1);
		json.append("\"children\": [\n");

		List<Frame> children = new ArrayList<Frame>();
		for (Frame child : frame.childIterator()) {
			children.add(child);
		}

		for (int i = 0; i < children.size(); i++) {
			appendFrame(json, children.get(i), depth + 2);
			if (i + 1 < children.size()) {
				json.append(",");
			}
			json.append("\n");
		}

		indent(json, depth + 1);
		json.append("]\n");
		indent(json, depth);
		json.append("}");
	}

	private static void appendMethodSummaries(StringBuilder json, String fieldName, List<MethodSummary> summaries,
			int depth) {
		indent(json, depth);
		json.append("\"");
		json.append(fieldName);
		json.append("\": [\n");

		for (int i = 0; i < summaries.size(); i++) {
			MethodSummary summary = summaries.get(i);
			indent(json, depth + 1);
			json.append("{\n");
			appendQuotedField(json, "name", summary.name, depth + 2, true);
			appendQuotedField(json, "className", summary.className, depth + 2, true);
			appendQuotedField(json, "methodName", summary.methodName, depth + 2, true);
			appendNumericField(json, "count", summary.count, depth + 2, true);
			appendNumericField(json, "totalTimeNanos", summary.totalTimeNanos, depth + 2, true);
			appendNumericField(json, "netTimeNanos", summary.netTimeNanos, depth + 2, false);
			json.append("\n");
			indent(json, depth + 1);
			json.append("}");
			if (i + 1 < summaries.size()) {
				json.append(",");
			}
			json.append("\n");
		}

		indent(json, depth);
		json.append("]");
	}

	private static void appendAllocations(StringBuilder json, List<AllocationSummary> allocations, JfrReport report,
			int depth) {
		LinkedHashMap<String, AllocationSummary> allocationByClass = new LinkedHashMap<String, AllocationSummary>();
		for (AllocationSummary allocation : allocations) {
			allocationByClass.put(allocation.className, allocation);
		}
		LinkedHashMap<String, AllocationSample> sampledAllocations = new LinkedHashMap<String, AllocationSample>();
		for (AllocationSample sample : report.topAllocationSamples()) {
			sampledAllocations.put(sample.className(), sample);
			if (!allocationByClass.containsKey(sample.className())) {
				allocationByClass.put(sample.className(), new AllocationSummary(sample.className(), sample.className(), 0));
			}
		}

		indent(json, depth);
		json.append("\"allocations\": [\n");

		List<AllocationSummary> mergedAllocations = new ArrayList<AllocationSummary>(allocationByClass.values());
		Collections.sort(mergedAllocations, new AllocationSummaryComparator());

		for (int i = 0; i < mergedAllocations.size(); i++) {
			AllocationSummary allocation = mergedAllocations.get(i);
			AllocationSample sampled = sampledAllocations.get(allocation.className);
			indent(json, depth + 1);
			json.append("{\n");
			appendQuotedField(json, "className", allocation.className, depth + 2, true);
			appendQuotedField(json, "internalClassName", allocation.internalClassName, depth + 2, true);
			appendNumericField(json, "count", allocation.count, depth + 2, true);
			appendNumericField(json, "jfrSampleCount", sampled == null ? 0 : sampled.samples(), depth + 2, true);
			appendNumericField(json, "jfrSampleBytes", sampled == null ? 0 : sampled.bytes(), depth + 2, false);
			json.append("\n");
			indent(json, depth + 1);
			json.append("}");
			if (i + 1 < mergedAllocations.size()) {
				json.append(",");
			}
			json.append("\n");
		}

		indent(json, depth);
		json.append("]");
	}

	private static void appendJfr(StringBuilder json, JfrReport report, int depth) {
		indent(json, depth);
		json.append("\"jfr\": {\n");
		appendBooleanField(json, "enabled", report.enabled(), depth + 1, true);
		appendQuotedField(json, "artifact", report.artifactPath() == null ? "" : report.artifactPath(), depth + 1,
				true);
		appendQuotedField(json, "warning", report.warning() == null ? "" : report.warning(), depth + 1, true);
		appendJfrMetadata(json, report.metadata(), depth + 1);
		json.append(",\n");
		appendNumericField(json, "executionSampleCount", report.executionSampleCount(), depth + 1, true);
		appendNumericField(json, "nativeSampleCount", report.nativeSampleCount(), depth + 1, true);
		appendNumericField(json, "cpuTimeSampleCount", report.cpuTimeSampleCount(), depth + 1, true);
		appendNumericField(json, "allocationSampleCount", report.allocationSampleCount(), depth + 1, true);
		appendNumericField(json, "monitorEnterCount", report.monitorEnterCount(), depth + 1, true);
		appendNumericField(json, "monitorWaitCount", report.monitorWaitCount(), depth + 1, true);
		appendNumericField(json, "threadParkCount", report.threadParkCount(), depth + 1, true);
		appendNumericField(json, "contentionEventCount", report.contentionEventCount(), depth + 1, true);
		appendNumericField(json, "contentionDurationNanos", report.contentionDurationNanos(), depth + 1, true);
		appendJfrMethodSamples(json, report.topSampledMethods(), depth + 1);
		json.append(",\n");
		appendJfrAllocationSamples(json, report.topAllocationSamples(), depth + 1);
		json.append(",\n");
		appendJfrAllocationPaths(json, report.topAllocationPaths(), depth + 1);
		json.append(",\n");
		appendJfrContentionSamples(json, report.topContentionSamples(), depth + 1);
		json.append("\n");
		indent(json, depth);
		json.append("}");
	}

	private static void appendAsyncProfiler(StringBuilder json, AsyncProfilerReport report, int depth) {
		indent(json, depth);
		json.append("\"asyncProfiler\": {\n");
		appendBooleanField(json, "enabled", report.enabled(), depth + 1, true);
		appendQuotedField(json, "warning", report.warning(), depth + 1, true);
		appendAsyncProfilerArtifacts(json, report.artifacts(), depth + 1);
		json.append(",\n");
		appendAsyncProfilerCollapsed(json, report.collapsed(), depth + 1);
		json.append("\n");
		indent(json, depth);
		json.append("}");
	}

	private static void appendJfrMetadata(StringBuilder json, RecordingMetadata metadata, int depth) {
		indent(json, depth);
		json.append("\"metadata\": {\n");
		appendNumericField(json, "samplePeriodMs", metadata.samplePeriodMs(), depth + 1, true);
		appendBooleanField(json, "executionSamplingEnabled", metadata.executionSamplingEnabled(), depth + 1, true);
		appendBooleanField(json, "nativeSamplingEnabled", metadata.nativeSamplingEnabled(), depth + 1, true);
		appendBooleanField(json, "cpuTimeSamplingEnabled", metadata.cpuTimeSamplingEnabled(), depth + 1, true);
		appendBooleanField(json, "allocationEventsEnabled", metadata.allocationEventsEnabled(), depth + 1, true);
		appendBooleanField(json, "monitorEnterEventsEnabled", metadata.monitorEnterEventsEnabled(), depth + 1, true);
		appendBooleanField(json, "monitorWaitEventsEnabled", metadata.monitorWaitEventsEnabled(), depth + 1, true);
		appendBooleanField(json, "threadParkEventsEnabled", metadata.threadParkEventsEnabled(), depth + 1, false);
		json.append("\n");
		indent(json, depth);
		json.append("}");
	}

	private static void appendInsights(StringBuilder json, List<Insight> insights, int depth) {
		indent(json, depth);
		json.append("\"insights\": [\n");

		for (int i = 0; i < insights.size(); i++) {
			Insight insight = insights.get(i);
			indent(json, depth + 1);
			json.append("{\n");
			appendQuotedField(json, "type", insight.type, depth + 2, true);
			appendQuotedField(json, "severity", insight.severity, depth + 2, true);
			appendQuotedField(json, "title", insight.title, depth + 2, true);
			appendQuotedField(json, "summary", insight.summary, depth + 2, true);
			appendStringArray(json, "evidence", insight.evidence, depth + 2);
			json.append("\n");
			indent(json, depth + 1);
			json.append("}");
			if (i + 1 < insights.size()) {
				json.append(",");
			}
			json.append("\n");
		}

		indent(json, depth);
		json.append("]");
	}

	private static void appendHistory(StringBuilder json, ProfileOutputFiles files, HistoryEntry currentEntry,
			List<HistoryEntry> entries, int depth) {
		indent(json, depth);
		json.append("\"history\": {\n");
		appendBooleanField(json, "enabled", files.historyEnabled(), depth + 1, true);
		appendQuotedField(json, "indexArtifact", files.historyEnabled() ? files.recordingIndexFileName() : "", depth + 1,
				true);
		appendHistoryEntry(json, "current", currentEntry, depth + 1);
		json.append(",\n");
		appendHistoryEntries(json, entries, depth + 1);
		json.append("\n");
		indent(json, depth);
		json.append("}");
	}

	private static void appendJfrMethodSamples(StringBuilder json, List<MethodSample> methods, int depth) {
		indent(json, depth);
		json.append("\"topSampledMethods\": [\n");

		for (int i = 0; i < methods.size(); i++) {
			MethodSample method = methods.get(i);
			indent(json, depth + 1);
			json.append("{\n");
			appendQuotedField(json, "name", method.name(), depth + 2, true);
			appendNumericField(json, "samples", method.samples(), depth + 2, false);
			json.append("\n");
			indent(json, depth + 1);
			json.append("}");
			if (i + 1 < methods.size()) {
				json.append(",");
			}
			json.append("\n");
		}

		indent(json, depth);
		json.append("]");
	}

	private static void appendJfrAllocationSamples(StringBuilder json, List<AllocationSample> allocations, int depth) {
		indent(json, depth);
		json.append("\"topAllocationSamples\": [\n");

		for (int i = 0; i < allocations.size(); i++) {
			AllocationSample allocation = allocations.get(i);
			indent(json, depth + 1);
			json.append("{\n");
			appendQuotedField(json, "className", allocation.className(), depth + 2, true);
			appendNumericField(json, "samples", allocation.samples(), depth + 2, true);
			appendNumericField(json, "bytes", allocation.bytes(), depth + 2, false);
			json.append("\n");
			indent(json, depth + 1);
			json.append("}");
			if (i + 1 < allocations.size()) {
				json.append(",");
			}
			json.append("\n");
		}

		indent(json, depth);
		json.append("]");
	}

	private static void appendJfrAllocationPaths(StringBuilder json, List<AllocationPathSample> allocationPaths,
			int depth) {
		indent(json, depth);
		json.append("\"topAllocationPaths\": [\n");

		for (int i = 0; i < allocationPaths.size(); i++) {
			AllocationPathSample allocation = allocationPaths.get(i);
			indent(json, depth + 1);
			json.append("{\n");
			appendQuotedField(json, "className", allocation.className(), depth + 2, true);
			appendQuotedField(json, "pathName", allocation.pathName(), depth + 2, true);
			appendNumericField(json, "samples", allocation.samples(), depth + 2, true);
			appendNumericField(json, "bytes", allocation.bytes(), depth + 2, false);
			json.append("\n");
			indent(json, depth + 1);
			json.append("}");
			if (i + 1 < allocationPaths.size()) {
				json.append(",");
			}
			json.append("\n");
		}

		indent(json, depth);
		json.append("]");
	}

	private static void appendJfrContentionSamples(StringBuilder json, List<ContentionSample> contentionSamples,
			int depth) {
		indent(json, depth);
		json.append("\"topContentionSamples\": [\n");

		for (int i = 0; i < contentionSamples.size(); i++) {
			ContentionSample contention = contentionSamples.get(i);
			indent(json, depth + 1);
			json.append("{\n");
			appendQuotedField(json, "name", contention.name(), depth + 2, true);
			appendNumericField(json, "monitorEnterCount", contention.monitorEnterCount(), depth + 2, true);
			appendNumericField(json, "monitorWaitCount", contention.monitorWaitCount(), depth + 2, true);
			appendNumericField(json, "threadParkCount", contention.threadParkCount(), depth + 2, true);
			appendNumericField(json, "eventCount", contention.totalEventCount(), depth + 2, true);
			appendNumericField(json, "durationNanos", contention.totalDurationNanos(), depth + 2, false);
			json.append("\n");
			indent(json, depth + 1);
			json.append("}");
			if (i + 1 < contentionSamples.size()) {
				json.append(",");
			}
			json.append("\n");
		}

		indent(json, depth);
		json.append("]");
	}

	private static void appendAsyncProfilerArtifacts(StringBuilder json, List<ArtifactLink> artifacts, int depth) {
		indent(json, depth);
		json.append("\"artifacts\": [\n");

		for (int i = 0; i < artifacts.size(); i++) {
			ArtifactLink artifact = artifacts.get(i);
			indent(json, depth + 1);
			json.append("{\n");
			appendQuotedField(json, "label", artifact.label(), depth + 2, true);
			appendQuotedField(json, "type", artifact.type(), depth + 2, true);
			appendQuotedField(json, "path", artifact.path(), depth + 2, false);
			json.append("\n");
			indent(json, depth + 1);
			json.append("}");
			if (i + 1 < artifacts.size()) {
				json.append(",");
			}
			json.append("\n");
		}

		indent(json, depth);
		json.append("]");
	}

	private static void appendAsyncProfilerCollapsed(StringBuilder json, CollapsedReport collapsed, int depth) {
		indent(json, depth);
		json.append("\"collapsed\": {\n");
		appendQuotedField(json, "path", collapsed.path(), depth + 1, true);
		appendNumericField(json, "totalSamples", collapsed.totalSamples(), depth + 1, true);
		appendAsyncProfilerFrameSamples(json, "topLeafFrames", collapsed.topLeafFrames(), depth + 1);
		json.append(",\n");
		appendAsyncProfilerStackSamples(json, collapsed.topStacks(), depth + 1);
		json.append("\n");
		indent(json, depth);
		json.append("}");
	}

	private static void appendAsyncProfilerFrameSamples(StringBuilder json, String name, List<FrameSample> samples,
			int depth) {
		indent(json, depth);
		json.append("\"");
		json.append(name);
		json.append("\": [\n");

		for (int i = 0; i < samples.size(); i++) {
			FrameSample sample = samples.get(i);
			indent(json, depth + 1);
			json.append("{\n");
			appendQuotedField(json, "name", sample.name(), depth + 2, true);
			appendNumericField(json, "samples", sample.samples(), depth + 2, false);
			json.append("\n");
			indent(json, depth + 1);
			json.append("}");
			if (i + 1 < samples.size()) {
				json.append(",");
			}
			json.append("\n");
		}

		indent(json, depth);
		json.append("]");
	}

	private static void appendAsyncProfilerStackSamples(StringBuilder json, List<StackSample> samples, int depth) {
		indent(json, depth);
		json.append("\"topStacks\": [\n");

		for (int i = 0; i < samples.size(); i++) {
			StackSample sample = samples.get(i);
			indent(json, depth + 1);
			json.append("{\n");
			appendQuotedField(json, "leafFrame", sample.leafFrame(), depth + 2, true);
			appendQuotedField(json, "stack", sample.stack(), depth + 2, true);
			appendNumericField(json, "samples", sample.samples(), depth + 2, false);
			json.append("\n");
			indent(json, depth + 1);
			json.append("}");
			if (i + 1 < samples.size()) {
				json.append(",");
			}
			json.append("\n");
		}

		indent(json, depth);
		json.append("]");
	}

	private static void appendHistoryEntry(StringBuilder json, String fieldName, HistoryEntry entry, int depth) {
		indent(json, depth);
		json.append("\"");
		json.append(fieldName);
		json.append("\": {\n");
		appendQuotedField(json, "snapshotLabel", entry.snapshotLabel(), depth + 1, true);
		appendQuotedField(json, "generatedAt", entry.generatedAt(), depth + 1, true);
		appendNumericField(json, "threadCount", entry.threadCount(), depth + 1, true);
		appendNumericField(json, "totalObservedTimeNanos", entry.totalObservedTimeNanos(), depth + 1, true);
		appendQuotedField(json, "topMethod", entry.topMethod(), depth + 1, true);
		appendQuotedField(json, "json", entry.jsonPath(), depth + 1, true);
		appendQuotedField(json, "html", entry.htmlPath(), depth + 1, true);
		appendQuotedField(json, "jfr", entry.jfrPath(), depth + 1, true);
		appendBooleanField(json, "current", entry.current(), depth + 1, false);
		json.append("\n");
		indent(json, depth);
		json.append("}");
	}

	private static void appendHistoryEntries(StringBuilder json, List<HistoryEntry> entries, int depth) {
		indent(json, depth);
		json.append("\"entries\": [\n");

		for (int i = 0; i < entries.size(); i++) {
			HistoryEntry entry = entries.get(i);
			indent(json, depth + 1);
			json.append("{\n");
			appendQuotedField(json, "snapshotLabel", entry.snapshotLabel(), depth + 2, true);
			appendQuotedField(json, "generatedAt", entry.generatedAt(), depth + 2, true);
			appendNumericField(json, "threadCount", entry.threadCount(), depth + 2, true);
			appendNumericField(json, "totalObservedTimeNanos", entry.totalObservedTimeNanos(), depth + 2, true);
			appendQuotedField(json, "topMethod", entry.topMethod(), depth + 2, true);
			appendQuotedField(json, "json", entry.jsonPath(), depth + 2, true);
			appendQuotedField(json, "html", entry.htmlPath(), depth + 2, true);
			appendQuotedField(json, "jfr", entry.jfrPath(), depth + 2, true);
			appendBooleanField(json, "current", entry.current(), depth + 2, false);
			json.append("\n");
			indent(json, depth + 1);
			json.append("}");
			if (i + 1 < entries.size()) {
				json.append(",");
			}
			json.append("\n");
		}

		indent(json, depth);
		json.append("]");
	}

	private static void appendStringArray(StringBuilder json, String name, List<String> values, int depth) {
		indent(json, depth);
		json.append("\"");
		json.append(name);
		json.append("\": [\n");

		for (int i = 0; i < values.size(); i++) {
			indent(json, depth + 1);
			appendQuotedValue(json, values.get(i));
			if (i + 1 < values.size()) {
				json.append(",");
			}
			json.append("\n");
		}

		indent(json, depth);
		json.append("]");
	}

	private static void appendQuotedField(StringBuilder json, String name, String value, int depth,
			boolean trailingComma) {
		indent(json, depth);
		json.append("\"");
		json.append(name);
		json.append("\": ");
		appendQuotedValue(json, value);
		if (trailingComma) {
			json.append(",");
		}
		json.append("\n");
	}

	private static void appendNumericField(StringBuilder json, String name, long value, int depth,
			boolean trailingComma) {
		indent(json, depth);
		json.append("\"");
		json.append(name);
		json.append("\": ");
		json.append(value);
		if (trailingComma) {
			json.append(",");
		}
		json.append("\n");
	}

	private static void appendBooleanField(StringBuilder json, String name, boolean value, int depth,
			boolean trailingComma) {
		indent(json, depth);
		json.append("\"");
		json.append(name);
		json.append("\": ");
		json.append(value);
		if (trailingComma) {
			json.append(",");
		}
		json.append("\n");
	}

	private static void appendQuotedValue(StringBuilder json, String value) {
		json.append('"');
		if (value != null) {
			for (int i = 0; i < value.length(); i++) {
				char c = value.charAt(i);
				switch (c) {
					case '\\' :
						json.append("\\\\");
						break;
					case '"' :
						json.append("\\\"");
						break;
					case '\n' :
						json.append("\\n");
						break;
					case '\r' :
						json.append("\\r");
						break;
					case '\t' :
						json.append("\\t");
						break;
					case '<' :
						json.append("\\u003c");
						break;
					case '>' :
						json.append("\\u003e");
						break;
					case '&' :
						json.append("\\u0026");
						break;
					default :
						if (c < 32) {
							json.append(String.format("\\u%04x", (int) c));
						} else {
							json.append(c);
						}
				}
			}
		}
		json.append('"');
	}

	private static void indent(StringBuilder json, int depth) {
		for (int i = 0; i < depth; i++) {
			json.append("  ");
		}
	}

	public static final class SnapshotDocument {
		private final String json;
		private final List<HistoryEntry> historyEntries;

		private SnapshotDocument(String json, List<HistoryEntry> historyEntries) {
			this.json = json;
			this.historyEntries = historyEntries;
		}

		public String json() {
			return json;
		}

		public List<HistoryEntry> historyEntries() {
			return historyEntries;
		}
	}

	private static final class SnapshotState {
		private final List<ThreadSnapshot> threads = new ArrayList<ThreadSnapshot>();
		private final List<MethodSummary> topMethods = new ArrayList<MethodSummary>();
		private final List<MethodSummary> methodSummary = new ArrayList<MethodSummary>();
		private final List<AllocationSummary> allocations = new ArrayList<AllocationSummary>();

		private long totalObservedTimeNanos;
		private int threadCount;
		private int interactionCount;
		private int frameCount;

		private static SnapshotState capture() {
			SnapshotState state = new SnapshotState();
			LinkedHashMap<String, MethodSummary> summaryMap = new LinkedHashMap<String, MethodSummary>();

			for (Long threadId : Profile.threads()) {
				ThreadSnapshot thread = new ThreadSnapshot(threadId, Profile.getThreadTotalTime(threadId));
				state.totalObservedTimeNanos += thread.totalTimeNanos;
				state.threadCount++;

				for (Frame interaction : Profile.interactions(threadId)) {
					thread.interactions.add(interaction);
					state.interactionCount++;
				}

				state.threads.add(thread);
			}

			for (Frame frame : Profile.frameList()) {
				state.frameCount++;

				MethodSummary topMethod = new MethodSummary(frame.getName(), frame.getClassName(),
						frame.getMethodName(), frame._metrics.getCount(), frame._metrics.getTotalTime(),
						frame.netTime());
				state.topMethods.add(topMethod);

				MethodSummary aggregate = summaryMap.get(frame.getName());
				if (aggregate == null) {
					aggregate = new MethodSummary(frame.getName(), frame.getClassName(), frame.getMethodName(), 0, 0,
							0);
					summaryMap.put(frame.getName(), aggregate);
				}

				aggregate.count += frame._metrics.getCount();
				aggregate.totalTimeNanos += frame._metrics.getTotalTime();
				aggregate.netTimeNanos += frame.netTime();
			}

			state.methodSummary.addAll(summaryMap.values());

			for (ClassAllocation allocation : Profile.allocations()) {
				state.allocations.add(new AllocationSummary(allocation.getClassName(),
						allocation.getInternalClassName(), allocation.getAllocCount()));
			}

			Collections.sort(state.topMethods, new MethodSummaryComparator());
			Collections.sort(state.methodSummary, new MethodSummaryComparator());
			Collections.sort(state.allocations, new AllocationSummaryComparator());

			return state;
		}
	}

	private static final class Insight {
		private final String type;
		private final String severity;
		private final String title;
		private final String summary;
		private final List<String> evidence;

		private Insight(String type, String severity, String title, String summary, List<String> evidence) {
			this.type = type;
			this.severity = severity;
			this.title = title;
			this.summary = summary;
			this.evidence = evidence;
		}
	}

	private static final class ThreadSnapshot {
		private final long threadId;
		private final long totalTimeNanos;
		private final List<Frame> interactions = new ArrayList<Frame>();

		private ThreadSnapshot(long threadId, long totalTimeNanos) {
			this.threadId = threadId;
			this.totalTimeNanos = totalTimeNanos;
		}
	}

	private static final class InsightsAnalyzer {
		private static List<Insight> analyze(SnapshotState state, JfrReport report) {
			List<Insight> insights = new ArrayList<Insight>();
			addDominantHotspotInsight(state, insights);
			addAllocationPressureInsight(state, report, insights);
			addSingleThreadDominanceInsight(state, insights);
			addJfrMismatchInsight(state, report, insights);
			return insights;
		}

		private static void addDominantHotspotInsight(SnapshotState state, List<Insight> insights) {
			if (state.methodSummary.isEmpty() || state.totalObservedTimeNanos <= 0) {
				return;
			}

			MethodSummary hottest = state.methodSummary.get(0);
			long percent = percent(hottest.netTimeNanos, state.totalObservedTimeNanos);
			if (percent < 35) {
				return;
			}

			String severity = percent >= 50 ? "high" : "medium";
			String summary = hottest.name + " accounts for " + percent
					+ "% of the observed net time. Optimize this path before spreading effort across colder methods.";
			List<String> evidence = new ArrayList<String>();
			evidence.add("Net time " + nanosToMillis(hottest.netTimeNanos) + " ms across " + hottest.count + " calls");
			evidence.add("Total observed " + nanosToMillis(state.totalObservedTimeNanos) + " ms");
			insights.add(new Insight("dominant-hotspot", severity, "Dominant hotspot", summary, evidence));
		}

		private static void addAllocationPressureInsight(SnapshotState state, JfrReport report, List<Insight> insights) {
			if (state.allocations.isEmpty()) {
				return;
			}

			long totalAllocations = 0;
			for (AllocationSummary allocation : state.allocations) {
				totalAllocations += allocation.count;
			}

			if (totalAllocations < 8) {
				return;
			}

			AllocationSummary hottest = state.allocations.get(0);
			long percent = percent(hottest.count, totalAllocations);
			if (percent < 60) {
				return;
			}

			String severity = percent >= 80 || totalAllocations >= 100 ? "high" : "medium";
			String summary = hottest.className + " drives " + percent
					+ "% of tracked allocations. This is a likely allocation pressure hotspot.";
			List<String> evidence = new ArrayList<String>();
			evidence.add(hottest.count + " allocations out of " + totalAllocations + " tracked allocations");
			if (report.allocationSampleCount() > 0) {
				evidence.add("JFR also captured " + report.allocationSampleCount() + " allocation sampling events");
			}
			insights.add(new Insight("allocation-pressure", severity, "Allocation pressure", summary, evidence));
		}

		private static void addSingleThreadDominanceInsight(SnapshotState state, List<Insight> insights) {
			if (state.threads.size() < 2 || state.totalObservedTimeNanos <= 0) {
				return;
			}

			ThreadSnapshot hottest = null;
			ThreadSnapshot second = null;
			for (ThreadSnapshot thread : state.threads) {
				if (hottest == null || thread.totalTimeNanos > hottest.totalTimeNanos) {
					second = hottest;
					hottest = thread;
				} else if (second == null || thread.totalTimeNanos > second.totalTimeNanos) {
					second = thread;
				}
			}

			if (hottest == null) {
				return;
			}

			long percent = percent(hottest.totalTimeNanos, state.totalObservedTimeNanos);
			if (percent < 70) {
				return;
			}

			String severity = percent >= 85 ? "high" : "medium";
			String summary = "Thread " + hottest.threadId + " accounts for " + percent
					+ "% of observed time. The profile is effectively dominated by one execution path.";
			List<String> evidence = new ArrayList<String>();
			evidence.add("Thread " + hottest.threadId + " observed " + nanosToMillis(hottest.totalTimeNanos) + " ms");
			if (second != null) {
				evidence.add("Next busiest thread " + second.threadId + " observed "
						+ nanosToMillis(second.totalTimeNanos) + " ms");
			}
			insights.add(new Insight("single-thread-dominance", severity, "Single-thread dominance", summary,
					evidence));
		}

		private static void addJfrMismatchInsight(SnapshotState state, JfrReport report, List<Insight> insights) {
			if (!report.enabled() || report.topSampledMethods().isEmpty() || state.methodSummary.isEmpty()) {
				return;
			}

			List<String> topInstrumented = new ArrayList<String>();
			for (int i = 0; i < state.methodSummary.size() && i < 5; i++) {
				topInstrumented.add(state.methodSummary.get(i).name);
			}

			List<String> topSampled = new ArrayList<String>();
			for (int i = 0; i < report.topSampledMethods().size() && i < 5; i++) {
				topSampled.add(report.topSampledMethods().get(i).name());
			}

			boolean overlap = false;
			for (String sampled : topSampled) {
				if (topInstrumented.contains(sampled)) {
					overlap = true;
					break;
				}
			}

			if (overlap) {
				return;
			}

			String summary = "Top sampled hotspots do not overlap with top instrumented methods. Investigate blocking,"
					+ " native work, or include and exclude filters.";
			List<String> evidence = new ArrayList<String>();
			evidence.add("Top sampled hotspot: " + topSampled.get(0));
			evidence.add("Top instrumented hotspot: " + topInstrumented.get(0));
			insights.add(new Insight("jfr-instrumentation-mismatch", "medium", "Sampled mismatch", summary,
					evidence));
		}

		private static long percent(long numerator, long denominator) {
			if (denominator <= 0) {
				return 0;
			}
			return Math.round((numerator * 100.0d) / denominator);
		}

		private static String nanosToMillis(long nanos) {
			return String.format("%.3f", nanos / 1_000_000.0d);
		}
	}

	private static final class MethodSummary {
		private final String name;
		private final String className;
		private final String methodName;
		private long count;
		private long totalTimeNanos;
		private long netTimeNanos;

		private MethodSummary(String name, String className, String methodName, long count, long totalTimeNanos,
				long netTimeNanos) {
			this.name = name;
			this.className = className;
			this.methodName = methodName;
			this.count = count;
			this.totalTimeNanos = totalTimeNanos;
			this.netTimeNanos = netTimeNanos;
		}
	}

	private static final class AllocationSummary {
		private final String className;
		private final String internalClassName;
		private final int count;

		private AllocationSummary(String className, String internalClassName, int count) {
			this.className = className;
			this.internalClassName = internalClassName;
			this.count = count;
		}
	}

	private static final class MethodSummaryComparator implements Comparator<MethodSummary> {
		@Override
		public int compare(MethodSummary left, MethodSummary right) {
			int byNetTime = Long.compare(right.netTimeNanos, left.netTimeNanos);
			if (byNetTime != 0) {
				return byNetTime;
			}
			return left.name.compareTo(right.name);
		}
	}

	private static final class AllocationSummaryComparator implements Comparator<AllocationSummary> {
		@Override
		public int compare(AllocationSummary left, AllocationSummary right) {
			int byCount = Integer.compare(right.count, left.count);
			if (byCount != 0) {
				return byCount;
			}
			return left.className.compareTo(right.className);
		}
	}
}
