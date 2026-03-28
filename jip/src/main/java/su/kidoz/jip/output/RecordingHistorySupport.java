package su.kidoz.jip.output;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Stream;

public final class RecordingHistorySupport {
	private static final String INDEX_FILE_NAME = "recordings-index.json";
	private static final int MAX_HISTORY_ENTRIES = 20;
	private static final int EMBEDDED_HISTORY_ENTRIES = 8;

	private static final Pattern SNAPSHOT_LABEL_PATTERN = Pattern.compile("\"snapshotLabel\"\\s*:\\s*\"([^\"]*)\"");
	private static final Pattern GENERATED_AT_PATTERN = Pattern.compile("\"generatedAt\"\\s*:\\s*\"([^\"]*)\"");
	private static final Pattern THREAD_COUNT_PATTERN = Pattern.compile("\"threadCount\"\\s*:\\s*(\\d+)");
	private static final Pattern OBSERVED_TIME_PATTERN = Pattern.compile("\"totalObservedTimeNanos\"\\s*:\\s*(\\d+)");
	private static final Pattern TOP_METHOD_PATTERN = Pattern.compile(
			"\"topMethods\"\\s*:\\s*\\[\\s*\\{\\s*\"name\"\\s*:\\s*\"([^\"]*)\"", Pattern.DOTALL);
	private static final Pattern ARTIFACTS_BLOCK_PATTERN = Pattern.compile("\"artifacts\"\\s*:\\s*\\{(.*?)\\}",
			Pattern.DOTALL);
	private static final Pattern JSON_ARTIFACT_PATTERN = Pattern.compile("\"json\"\\s*:\\s*\"([^\"]*)\"");
	private static final Pattern HTML_ARTIFACT_PATTERN = Pattern.compile("\"html\"\\s*:\\s*\"([^\"]*)\"");
	private static final Pattern JFR_ARTIFACT_PATTERN = Pattern.compile("\"jfr\"\\s*:\\s*\"([^\"]*)\"");

	private RecordingHistorySupport() {
	}

	public static HistoryEntry createCurrentEntry(ProfileOutputFiles files, String topMethodName, int threadCount,
			long totalObservedTimeNanos, boolean htmlGenerated, String jfrArtifactPath) {
		return new HistoryEntry(files.snapshotLabel(), files.snapshotTimestamp(), threadCount, totalObservedTimeNanos,
				topMethodName == null ? "" : topMethodName, files.jsonFileName(), htmlGenerated ? files.htmlFileName() : "",
				jfrArtifactPath == null ? "" : jfrArtifactPath, true);
	}

	public static List<HistoryEntry> collectHistory(ProfileOutputFiles files, HistoryEntry currentEntry) {
		if (!files.historyEnabled()) {
			return Collections.singletonList(currentEntry);
		}

		LinkedHashMap<String, HistoryEntry> entriesByJsonPath = new LinkedHashMap<String, HistoryEntry>();
		entriesByJsonPath.put(currentEntry.jsonPath(), currentEntry);

		Path directory = Path.of(files.recordingDirectory());
		try (Stream<Path> stream = Files.list(directory)) {
			stream.filter(Files::isRegularFile)
					.filter(path -> path.getFileName().toString().endsWith(".json"))
					.filter(path -> !INDEX_FILE_NAME.equals(path.getFileName().toString()))
					.filter(path -> !path.toAbsolutePath().toString().equals(files.jsonFileName()))
					.forEach(path -> {
						HistoryEntry parsed = parseSnapshot(path);
						if (parsed != null && !entriesByJsonPath.containsKey(parsed.jsonPath())) {
							entriesByJsonPath.put(parsed.jsonPath(), parsed);
						}
					});
		} catch (IOException ignored) {
		}

		List<HistoryEntry> entries = new ArrayList<HistoryEntry>(entriesByJsonPath.values());
		Collections.sort(entries, new HistoryEntryComparator());
		if (entries.size() > MAX_HISTORY_ENTRIES) {
			entries = new ArrayList<HistoryEntry>(entries.subList(0, MAX_HISTORY_ENTRIES));
		}
		return entries;
	}

	public static List<HistoryEntry> embeddedPreview(List<HistoryEntry> entries) {
		if (entries.size() <= EMBEDDED_HISTORY_ENTRIES) {
			return entries;
		}
		return new ArrayList<HistoryEntry>(entries.subList(0, EMBEDDED_HISTORY_ENTRIES));
	}

	public static void writeIndex(ProfileOutputFiles files, List<HistoryEntry> entries) throws IOException {
		if (!files.historyEnabled()) {
			return;
		}

		StringBuilder json = new StringBuilder(16 * 1024);
		json.append("{\n");
		appendQuotedField(json, "schemaVersion", "jip-recording-index-v1", 1, true);
		appendQuotedField(json, "generatedAt", files.snapshotTimestamp(), 1, true);
		appendQuotedField(json, "directory", files.recordingDirectory(), 1, true);
		appendEntries(json, "entries", entries, 1);
		json.append("\n");
		json.append("}\n");

		Files.writeString(Path.of(files.recordingIndexFileName()), json.toString(), StandardCharsets.UTF_8);
	}

	private static HistoryEntry parseSnapshot(Path jsonPath) {
		try {
			String json = Files.readString(jsonPath, StandardCharsets.UTF_8);
			String artifactsBlock = extract(ARTIFACTS_BLOCK_PATTERN, json);
			String snapshotLabel = defaultIfBlank(extract(SNAPSHOT_LABEL_PATTERN, json), stripExtension(jsonPath));
			String generatedAt = defaultIfBlank(extract(GENERATED_AT_PATTERN, json), stripExtension(jsonPath));
			int threadCount = (int) extractLong(THREAD_COUNT_PATTERN, json);
			long totalObservedTimeNanos = extractLong(OBSERVED_TIME_PATTERN, json);
			String topMethod = extract(TOP_METHOD_PATTERN, json);
			String parsedJsonPath = defaultIfBlank(extract(JSON_ARTIFACT_PATTERN, artifactsBlock),
					jsonPath.toAbsolutePath().toString());
			String htmlPath = extract(HTML_ARTIFACT_PATTERN, artifactsBlock);
			String jfrPath = extract(JFR_ARTIFACT_PATTERN, artifactsBlock);

			return new HistoryEntry(snapshotLabel, generatedAt, threadCount, totalObservedTimeNanos, topMethod,
					parsedJsonPath, htmlPath, jfrPath, false);
		} catch (IOException ignored) {
			return null;
		}
	}

	private static String stripExtension(Path path) {
		String fileName = path.getFileName().toString();
		int extensionIndex = fileName.lastIndexOf('.');
		if (extensionIndex <= 0) {
			return fileName;
		}
		return fileName.substring(0, extensionIndex);
	}

	private static String defaultIfBlank(String value, String fallback) {
		if (value == null || value.trim().length() == 0) {
			return fallback;
		}
		return value;
	}

	private static String extract(Pattern pattern, String source) {
		if (source == null || source.length() == 0) {
			return "";
		}
		Matcher matcher = pattern.matcher(source);
		if (!matcher.find()) {
			return "";
		}
		return unescape(matcher.group(1));
	}

	private static long extractLong(Pattern pattern, String source) {
		String value = extract(pattern, source);
		if (value.length() == 0) {
			return 0L;
		}
		try {
			return Long.parseLong(value);
		} catch (NumberFormatException ignored) {
			return 0L;
		}
	}

	private static String unescape(String value) {
		return value.replace("\\\\", "\\")
				.replace("\\\"", "\"")
				.replace("\\n", "\n")
				.replace("\\r", "\r")
				.replace("\\t", "\t")
				.replace("\\u003c", "<")
				.replace("\\u003e", ">")
				.replace("\\u0026", "&");
	}

	private static void appendEntries(StringBuilder json, String fieldName, List<HistoryEntry> entries, int depth) {
		indent(json, depth);
		json.append("\"");
		json.append(fieldName);
		json.append("\": [\n");

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

	private static void appendQuotedField(StringBuilder json, String name, String value, int depth,
			boolean trailingComma) {
		indent(json, depth);
		json.append("\"");
		json.append(name);
		json.append("\": ");
		appendQuotedValue(json, value == null ? "" : value);
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
				default :
					json.append(c);
			}
		}
		json.append('"');
	}

	private static void indent(StringBuilder json, int depth) {
		for (int i = 0; i < depth; i++) {
			json.append("  ");
		}
	}

	public static final class HistoryEntry {
		private final String snapshotLabel;
		private final String generatedAt;
		private final int threadCount;
		private final long totalObservedTimeNanos;
		private final String topMethod;
		private final String jsonPath;
		private final String htmlPath;
		private final String jfrPath;
		private final boolean current;

		public HistoryEntry(String snapshotLabel, String generatedAt, int threadCount, long totalObservedTimeNanos,
				String topMethod, String jsonPath, String htmlPath, String jfrPath, boolean current) {
			this.snapshotLabel = snapshotLabel;
			this.generatedAt = generatedAt;
			this.threadCount = threadCount;
			this.totalObservedTimeNanos = totalObservedTimeNanos;
			this.topMethod = topMethod == null ? "" : topMethod;
			this.jsonPath = jsonPath == null ? "" : jsonPath;
			this.htmlPath = htmlPath == null ? "" : htmlPath;
			this.jfrPath = jfrPath == null ? "" : jfrPath;
			this.current = current;
		}

		public String snapshotLabel() {
			return snapshotLabel;
		}

		public String generatedAt() {
			return generatedAt;
		}

		public int threadCount() {
			return threadCount;
		}

		public long totalObservedTimeNanos() {
			return totalObservedTimeNanos;
		}

		public String topMethod() {
			return topMethod;
		}

		public String jsonPath() {
			return jsonPath;
		}

		public String htmlPath() {
			return htmlPath;
		}

		public String jfrPath() {
			return jfrPath;
		}

		public boolean current() {
			return current;
		}
	}

	private static final class HistoryEntryComparator implements Comparator<HistoryEntry> {
		@Override
		public int compare(HistoryEntry left, HistoryEntry right) {
			int timeCompare = right.generatedAt().compareTo(left.generatedAt());
			if (timeCompare != 0) {
				return timeCompare;
			}
			if (left.current() != right.current()) {
				return left.current() ? -1 : 1;
			}
			return right.jsonPath().compareTo(left.jsonPath());
		}
	}
}
