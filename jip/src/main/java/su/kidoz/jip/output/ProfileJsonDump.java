package su.kidoz.jip.output;

import com.mentorgen.tools.profile.Controller;
import com.mentorgen.tools.profile.runtime.ClassAllocation;
import com.mentorgen.tools.profile.runtime.Frame;
import com.mentorgen.tools.profile.runtime.Profile;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public final class ProfileJsonDump {
    public static void dump(ProfileOutputFiles files) throws IOException {
        String json = buildSnapshot(files);

        FileWriter out = new FileWriter(files.jsonFileName());
        BufferedWriter bufferedWriter = new BufferedWriter(out);
        PrintWriter writer = new PrintWriter(bufferedWriter);
        writer.print(json);
        writer.flush();
        out.close();
    }

    public static String buildSnapshot(ProfileOutputFiles files) {
        SnapshotState state = SnapshotState.capture();
        StringBuilder json = new StringBuilder(64 * 1024);

        json.append("{\n");
        appendQuotedField(json, "schemaVersion", "jip-modern-v1", 1, true);
        appendQuotedField(json, "generatedAt", files.snapshotTimestamp(), 1, true);
        appendQuotedField(json, "clockResolution", Controller._timeResoltion.name(), 1, true);
        appendSummary(json, state, 1);
        json.append(",\n");
        appendThreads(json, state, 1);
        json.append(",\n");
        appendMethodSummaries(json, "topMethods", state.topMethods, 1);
        json.append(",\n");
        appendMethodSummaries(json, "methodSummary", state.methodSummary, 1);
        json.append(",\n");
        appendAllocations(json, state.allocations, 1);
        json.append(",\n");
        indent(json, 1);
        json.append("\"artifacts\": {\n");
        appendQuotedField(json, "text", files.textFileName(), 2, true);
        appendQuotedField(json, "xml", files.xmlFileName(), 2, true);
        appendQuotedField(json, "json", files.jsonFileName(), 2, true);
        appendQuotedField(json, "html", files.htmlFileName(), 2, false);
        json.append("\n");
        indent(json, 1);
        json.append("}\n");
        json.append("}\n");

        return json.toString();
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

    private static void appendMethodSummaries(StringBuilder json, String fieldName, List<MethodSummary> summaries, int depth) {
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

    private static void appendAllocations(StringBuilder json, List<AllocationSummary> allocations, int depth) {
        indent(json, depth);
        json.append("\"allocations\": [\n");

        for (int i = 0; i < allocations.size(); i++) {
            AllocationSummary allocation = allocations.get(i);
            indent(json, depth + 1);
            json.append("{\n");
            appendQuotedField(json, "className", allocation.className, depth + 2, true);
            appendQuotedField(json, "internalClassName", allocation.internalClassName, depth + 2, true);
            appendNumericField(json, "count", allocation.count, depth + 2, false);
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

    private static void appendQuotedField(StringBuilder json, String name, String value, int depth, boolean trailingComma) {
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

    private static void appendNumericField(StringBuilder json, String name, long value, int depth, boolean trailingComma) {
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
                    case '\\':
                        json.append("\\\\");
                        break;
                    case '"':
                        json.append("\\\"");
                        break;
                    case '\n':
                        json.append("\\n");
                        break;
                    case '\r':
                        json.append("\\r");
                        break;
                    case '\t':
                        json.append("\\t");
                        break;
                    case '<':
                        json.append("\\u003c");
                        break;
                    case '>':
                        json.append("\\u003e");
                        break;
                    case '&':
                        json.append("\\u0026");
                        break;
                    default:
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

                MethodSummary topMethod = new MethodSummary(
                        frame.getName(),
                        frame.getClassName(),
                        frame.getMethodName(),
                        frame._metrics.getCount(),
                        frame._metrics.getTotalTime(),
                        frame.netTime()
                );
                state.topMethods.add(topMethod);

                MethodSummary aggregate = summaryMap.get(frame.getName());
                if (aggregate == null) {
                    aggregate = new MethodSummary(
                            frame.getName(),
                            frame.getClassName(),
                            frame.getMethodName(),
                            0,
                            0,
                            0
                    );
                    summaryMap.put(frame.getName(), aggregate);
                }

                aggregate.count += frame._metrics.getCount();
                aggregate.totalTimeNanos += frame._metrics.getTotalTime();
                aggregate.netTimeNanos += frame.netTime();
            }

            state.methodSummary.addAll(summaryMap.values());

            for (ClassAllocation allocation : Profile.allocations()) {
                state.allocations.add(new AllocationSummary(
                        allocation.getClassName(),
                        allocation.getInternalClassName(),
                        allocation.getAllocCount()
                ));
            }

            Collections.sort(state.topMethods, new MethodSummaryComparator());
            Collections.sort(state.methodSummary, new MethodSummaryComparator());
            Collections.sort(state.allocations, new AllocationSummaryComparator());

            return state;
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

    private static final class MethodSummary {
        private final String name;
        private final String className;
        private final String methodName;
        private long count;
        private long totalTimeNanos;
        private long netTimeNanos;

        private MethodSummary(
                String name,
                String className,
                String methodName,
                long count,
                long totalTimeNanos,
                long netTimeNanos
        ) {
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
