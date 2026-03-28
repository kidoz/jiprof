package su.kidoz.jip.asyncprofiler;

import com.mentorgen.tools.profile.Controller;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

public final class AsyncProfilerSupport {
	private static final int TOP_FRAME_LIMIT = 15;
	private static final int TOP_STACK_LIMIT = 12;

	private AsyncProfilerSupport() {
	}

	public static AsyncProfilerReport prepareReport() {
		String collapsedPath = normalizePath(Controller._asyncProfilerCollapsedFile);
		String warning = "";
		Set<String> seenPaths = new LinkedHashSet<String>();
		List<ArtifactLink> artifacts = new ArrayList<ArtifactLink>();
		boolean configured = false;

		if (collapsedPath.length() > 0) {
			configured = true;
			addArtifact(artifacts, seenPaths, collapsedPath, "collapsed");
		}

		for (String artifactPath : Controller._asyncProfilerArtifactPaths) {
			String normalized = normalizePath(artifactPath);
			if (normalized.length() == 0) {
				continue;
			}
			configured = true;
			addArtifact(artifacts, seenPaths, normalized, detectType(normalized));
			if (collapsedPath.length() == 0 && looksLikeCollapsedArtifact(normalized)) {
				collapsedPath = normalized;
			}
		}

		CollapsedReport collapsed = CollapsedReport.empty("");
		if (collapsedPath.length() > 0) {
			try {
				collapsed = parseCollapsed(Path.of(collapsedPath));
			} catch (IOException e) {
				warning = "Unable to read async-profiler collapsed capture: " + collapsedPath;
				collapsed = CollapsedReport.empty(collapsedPath);
			}
		}

		if (!configured) {
			return AsyncProfilerReport.disabled();
		}

		if (warning.length() == 0) {
			List<String> missingPaths = new ArrayList<String>();
			for (ArtifactLink artifact : artifacts) {
				if (!Files.exists(Path.of(artifact.path()))) {
					missingPaths.add(artifact.path());
				}
			}
			if (!missingPaths.isEmpty()) {
				warning = "Missing async-profiler artifacts: " + String.join(", ", missingPaths);
			}
		}

		return AsyncProfilerReport.enabled(warning, artifacts, collapsed);
	}

	private static void addArtifact(List<ArtifactLink> artifacts, Set<String> seenPaths, String path, String type) {
		if (!seenPaths.add(path)) {
			return;
		}
		String label = new File(path).getName();
		if (label == null || label.trim().length() == 0) {
			label = type;
		}
		artifacts.add(new ArtifactLink(label, type, path));
	}

	private static String normalizePath(String value) {
		if (value == null) {
			return "";
		}
		String trimmed = value.trim();
		if (trimmed.length() == 0) {
			return "";
		}
		return new File(trimmed).getAbsolutePath();
	}

	private static String detectType(String path) {
		String lower = path.toLowerCase(Locale.ROOT);
		if (looksLikeCollapsedArtifact(path)) {
			return "collapsed";
		}
		if (lower.endsWith(".svg")) {
			return "flamegraph-svg";
		}
		if (lower.endsWith(".html") || lower.endsWith(".htm")) {
			return "flamegraph-html";
		}
		if (lower.endsWith(".jfr")) {
			return "jfr";
		}
		return "file";
	}

	private static boolean looksLikeCollapsedArtifact(String path) {
		String lower = path.toLowerCase(Locale.ROOT);
		return lower.endsWith(".collapsed") || lower.endsWith(".folded");
	}

	private static CollapsedReport parseCollapsed(Path path) throws IOException {
		if (!Files.exists(path) || !Files.isRegularFile(path)) {
			return CollapsedReport.empty(path.toAbsolutePath().toString());
		}

		Map<String, Long> frameSamples = new LinkedHashMap<String, Long>();
		Map<String, Long> stackSamples = new LinkedHashMap<String, Long>();
		long totalSamples = 0L;

		BufferedReader reader = Files.newBufferedReader(path, StandardCharsets.UTF_8);
		try {
			for (String line = reader.readLine(); line != null; line = reader.readLine()) {
				String trimmed = line.trim();
				if (trimmed.length() == 0 || trimmed.startsWith("#")) {
					continue;
				}

				int separator = trimmed.lastIndexOf(' ');
				if (separator <= 0 || separator + 1 >= trimmed.length()) {
					continue;
				}

				String stack = trimmed.substring(0, separator).trim();
				long samples;
				try {
					samples = Long.parseLong(trimmed.substring(separator + 1).trim());
				} catch (NumberFormatException e) {
					continue;
				}

				if (stack.length() == 0 || samples <= 0) {
					continue;
				}

				totalSamples += samples;
				increment(stackSamples, stack, samples);
				String leafFrame = extractLeafFrame(stack);
				increment(frameSamples, leafFrame, samples);
			}
		} finally {
			reader.close();
		}

		List<FrameSample> topFrames = new ArrayList<FrameSample>();
		for (Map.Entry<String, Long> entry : frameSamples.entrySet()) {
			topFrames.add(new FrameSample(entry.getKey(), entry.getValue().longValue()));
		}
		Collections.sort(topFrames, new FrameSampleComparator());
		topFrames = trimFrames(topFrames);

		List<StackSample> topStacks = new ArrayList<StackSample>();
		for (Map.Entry<String, Long> entry : stackSamples.entrySet()) {
			topStacks.add(new StackSample(entry.getKey(), extractLeafFrame(entry.getKey()), entry.getValue().longValue()));
		}
		Collections.sort(topStacks, new StackSampleComparator());
		topStacks = trimStacks(topStacks);

		return new CollapsedReport(path.toAbsolutePath().toString(), totalSamples, topFrames, topStacks);
	}

	private static void increment(Map<String, Long> target, String key, long delta) {
		Long current = target.get(key);
		target.put(key, Long.valueOf((current == null ? 0L : current.longValue()) + delta));
	}

	private static String extractLeafFrame(String stack) {
		int separator = stack.lastIndexOf(';');
		if (separator < 0 || separator + 1 >= stack.length()) {
			return stack;
		}
		return stack.substring(separator + 1);
	}

	private static List<FrameSample> trimFrames(List<FrameSample> samples) {
		if (samples.size() <= TOP_FRAME_LIMIT) {
			return samples;
		}
		return new ArrayList<FrameSample>(samples.subList(0, TOP_FRAME_LIMIT));
	}

	private static List<StackSample> trimStacks(List<StackSample> samples) {
		if (samples.size() <= TOP_STACK_LIMIT) {
			return samples;
		}
		return new ArrayList<StackSample>(samples.subList(0, TOP_STACK_LIMIT));
	}

	public static final class AsyncProfilerReport {
		private final boolean enabled;
		private final String warning;
		private final List<ArtifactLink> artifacts;
		private final CollapsedReport collapsed;

		private AsyncProfilerReport(boolean enabled, String warning, List<ArtifactLink> artifacts,
				CollapsedReport collapsed) {
			this.enabled = enabled;
			this.warning = warning;
			this.artifacts = artifacts;
			this.collapsed = collapsed;
		}

		public static AsyncProfilerReport disabled() {
			return new AsyncProfilerReport(false, "", Collections.<ArtifactLink>emptyList(),
					CollapsedReport.empty(""));
		}

		public static AsyncProfilerReport enabled(String warning, List<ArtifactLink> artifacts,
				CollapsedReport collapsed) {
			return new AsyncProfilerReport(true, warning == null ? "" : warning, artifacts, collapsed);
		}

		public boolean enabled() {
			return enabled;
		}

		public String warning() {
			return warning;
		}

		public List<ArtifactLink> artifacts() {
			return artifacts;
		}

		public CollapsedReport collapsed() {
			return collapsed;
		}
	}

	public static final class ArtifactLink {
		private final String label;
		private final String type;
		private final String path;

		public ArtifactLink(String label, String type, String path) {
			this.label = label;
			this.type = type;
			this.path = path;
		}

		public String label() {
			return label;
		}

		public String type() {
			return type;
		}

		public String path() {
			return path;
		}
	}

	public static final class CollapsedReport {
		private final String path;
		private final long totalSamples;
		private final List<FrameSample> topLeafFrames;
		private final List<StackSample> topStacks;

		private CollapsedReport(String path, long totalSamples, List<FrameSample> topLeafFrames,
				List<StackSample> topStacks) {
			this.path = path;
			this.totalSamples = totalSamples;
			this.topLeafFrames = topLeafFrames;
			this.topStacks = topStacks;
		}

		public static CollapsedReport empty(String path) {
			return new CollapsedReport(path, 0L, Collections.<FrameSample>emptyList(),
					Collections.<StackSample>emptyList());
		}

		public String path() {
			return path;
		}

		public long totalSamples() {
			return totalSamples;
		}

		public List<FrameSample> topLeafFrames() {
			return topLeafFrames;
		}

		public List<StackSample> topStacks() {
			return topStacks;
		}
	}

	public static final class FrameSample {
		private final String name;
		private final long samples;

		public FrameSample(String name, long samples) {
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

	public static final class StackSample {
		private final String stack;
		private final String leafFrame;
		private final long samples;

		public StackSample(String stack, String leafFrame, long samples) {
			this.stack = stack;
			this.leafFrame = leafFrame;
			this.samples = samples;
		}

		public String stack() {
			return stack;
		}

		public String leafFrame() {
			return leafFrame;
		}

		public long samples() {
			return samples;
		}
	}

	private static final class FrameSampleComparator implements Comparator<FrameSample> {
		@Override
		public int compare(FrameSample left, FrameSample right) {
			int sampleCompare = Long.compare(right.samples(), left.samples());
			if (sampleCompare != 0) {
				return sampleCompare;
			}
			return left.name().compareTo(right.name());
		}
	}

	private static final class StackSampleComparator implements Comparator<StackSample> {
		@Override
		public int compare(StackSample left, StackSample right) {
			int sampleCompare = Long.compare(right.samples(), left.samples());
			if (sampleCompare != 0) {
				return sampleCompare;
			}
			return left.stack().compareTo(right.stack());
		}
	}
}
