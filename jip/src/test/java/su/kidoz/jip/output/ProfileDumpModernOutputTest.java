package su.kidoz.jip.output;

import com.mentorgen.tools.profile.Controller;
import com.mentorgen.tools.profile.instrument.clfilter.ClassLoaderFilter;
import com.mentorgen.tools.profile.output.ProfileDump;
import com.mentorgen.tools.profile.runtime.Profile;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Comparator;
import java.util.concurrent.TimeUnit;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class ProfileDumpModernOutputTest {
	private static final ClassLoaderFilter ACCEPT_ALL_FILTER = new ClassLoaderFilter() {
		@Override
		public boolean canFilter() {
			return true;
		}

		@Override
		public boolean accept(ClassLoader loader) {
			return true;
		}
	};

	private ControllerState controllerState;
	private Path tempDirectory;

	@BeforeEach
	void setUp() throws IOException {
		controllerState = ControllerState.capture();
		tempDirectory = Files.createTempDirectory("jip-modern-output");
		Profile.init();
		Controller._profile = true;
		Controller._filter = ACCEPT_ALL_FILTER;
		Controller._includeList = new String[0];
		Controller._excludeList = new String[0];
		Controller._fileName = tempDirectory.toString();
		Controller._trackObjectAlloc = true;
		Controller._timeResoltion = Controller.TimeResolution.ns;
		Controller._jfrEnabled = false;
		Controller._jfrSamplePeriodMs = 1;
		Controller._asyncProfilerCollapsedFile = "";
		Controller._asyncProfilerArtifactPaths = new String[0];
	}

	@AfterEach
	void tearDown() throws IOException {
		controllerState.restore();
		Profile.init();
		if (tempDirectory != null) {
			try (Stream<Path> walk = Files.walk(tempDirectory)) {
				walk.sorted(Comparator.reverseOrder()).forEach(path -> {
					try {
						Files.deleteIfExists(path);
					} catch (IOException ignored) {
					}
				});
			}
		}
	}

	@Test
	public void writesVersionedJsonSnapshot() throws Exception {
		Controller._outputType = Controller.OutputType.JSON;
		createSampleProfile();

		ProfileDump.dump();

		Path jsonFile = findGeneratedFile(".json");
		String json = Files.readString(jsonFile);

		assertTrue(json.contains("\"schemaVersion\": \"jip-modern-v1\""));
		assertTrue(json.contains("\"snapshotLabel\":"));
		assertTrue(json.contains("\"timeline\": {"));
		assertTrue(json.contains("\"threads\": ["));
		assertTrue(json.contains("\"methodSummary\": ["));
		assertTrue(json.contains("\"allocations\": ["));
		assertTrue(json.contains("sample.Service:run"));
	}

	@Test
	public void writesSelfContainedModernHtmlReport() throws Exception {
		Controller._outputType = Controller.OutputType.Modern;
		createSampleProfile();

		ProfileDump.dump();

		Path jsonFile = findGeneratedFile(".json");
		Path htmlFile = findGeneratedFile(".html");
		String html = Files.readString(htmlFile);

		assertTrue(Files.exists(jsonFile));
		assertTrue(html.contains("JIP Modern Viewer"));
		assertTrue(html.contains("application/json"));
		assertTrue(html.contains("sample.Service:run"));
		assertTrue(html.contains(jsonFile.toString()));
		assertTrue(html.contains("Timeline"));
		assertTrue(html.contains("Advanced Visualizations"));
		assertTrue(html.contains("Icicle View"));
		assertTrue(html.contains("Method Heatmap"));
		assertTrue(html.contains("Download Snapshot"));
		assertTrue(html.contains("Load Baseline Snapshot"));
		assertTrue(html.contains("Regression Candidates"));
	}

	@Test
	public void writesJfrCompanionArtifactWhenEnabled() throws Exception {
		Controller._outputType = Controller.OutputType.Modern;
		Controller._jfrEnabled = true;

		createSampleProfile();
		ProfileDump.dump();

		Path jsonFile = findGeneratedFile(".json");
		Path htmlFile = findGeneratedFile(".html");
		Path jfrFile = findGeneratedFile(".jfr");
		String json = Files.readString(jsonFile);
		String html = Files.readString(htmlFile);

		assertTrue(Files.exists(jfrFile));
		assertTrue(json.contains("\"jfr\": {"));
		assertTrue(json.contains("\"enabled\": true"));
		assertTrue(json.contains("\"metadata\": {"));
		assertTrue(json.contains("\"cpuTimeSampleCount\":"));
		assertTrue(json.contains("\"topContentionSamples\": ["));
		assertTrue(json.contains("\"topAllocationPaths\": ["));
		assertTrue(json.contains("\"jfrBuckets\": ["));
		assertTrue(json.contains(jfrFile.toString()));
		assertTrue(html.contains("JFR Sampled Hotspots"));
		assertTrue(html.contains("Allocation Hot Paths"));
		assertTrue(html.contains("Contention Site"));
		assertTrue(html.contains("CPU-time samples:"));
		assertTrue(html.contains("JFR Contention"));
		assertTrue(html.contains(jfrFile.toString()));
	}

	@Test
	public void writesAutomatedInsightsIntoSnapshotAndHtml() throws Exception {
		Controller._outputType = Controller.OutputType.Modern;
		createInsightHeavyProfile();

		ProfileDump.dump();

		Path jsonFile = findGeneratedFile(".json");
		Path htmlFile = findGeneratedFile(".html");
		String json = Files.readString(jsonFile);
		String html = Files.readString(htmlFile);

		assertTrue(json.contains("\"insights\": ["));
		assertTrue(json.contains("\"title\": \"Dominant hotspot\""));
		assertTrue(json.contains("\"title\": \"Allocation pressure\""));
		assertTrue(json.contains("\"title\": \"Single-thread dominance\""));
		assertTrue(html.contains("Automated Insights"));
		assertTrue(html.contains("Dominant hotspot"));
	}

	@Test
	public void importsAsyncProfilerArtifactsIntoSnapshotAndHtml() throws Exception {
		Controller._outputType = Controller.OutputType.Modern;

		Path collapsedFile = tempDirectory.resolve("cpu.collapsed");
		Path flamegraphFile = tempDirectory.resolve("cpu-flamegraph.html");
		Files.writeString(collapsedFile,
				"java/lang/Thread.run;sample/Service.run 7\n"
						+ "java/lang/Thread.run;sample/Worker.step 3\n");
		Files.writeString(flamegraphFile, "<html><body>async-profiler flame graph</body></html>");

		Controller._asyncProfilerCollapsedFile = collapsedFile.toString();
		Controller._asyncProfilerArtifactPaths = new String[] { flamegraphFile.toString() };

		createSampleProfile();
		ProfileDump.dump();

		Path jsonFile = findGeneratedFile(".json");
		Path htmlFile = findGeneratedFile(".html");
		String json = Files.readString(jsonFile);
		String html = Files.readString(htmlFile);

		assertTrue(json.contains("\"asyncProfiler\": {"));
		assertTrue(json.contains("\"enabled\": true"));
		assertTrue(json.contains(collapsedFile.toString()));
		assertTrue(json.contains(flamegraphFile.toString()));
		assertTrue(json.contains("\"topLeafFrames\": ["));
		assertTrue(json.contains("sample/Service.run"));
		assertTrue(html.contains("Async-Profiler Imports"));
		assertTrue(html.contains("cpu-flamegraph.html"));
		assertTrue(html.contains("sample/Worker.step"));
	}

	@Test
	public void generatesJfrInstrumentationMismatchInsightWhenTopMethodsDisagree() throws Exception {
		Controller._outputType = Controller.OutputType.Modern;
		Controller._jfrEnabled = true;

		createSampleProfile();
		ProfileDump.dump();

		Path jsonFile = findGeneratedFile(".json");
		String json = Files.readString(jsonFile);

		if (json.contains("\"topSampledMethods\": [\n")
				&& !json.contains("\"topSampledMethods\": []")) {
			assertTrue(json.contains("\"jfr-instrumentation-mismatch\""),
					"Expected mismatch insight when JFR-sampled hotspots differ from instrumented methods");
			assertTrue(json.contains("\"title\": \"Sampled mismatch\""));
		}
	}

	@Test
	public void writesRecordingIndexAndEmbedsRecentHistory() throws Exception {
		Controller._outputType = Controller.OutputType.Modern;

		createSampleProfile();
		ProfileDump.dump();

		TimeUnit.MILLISECONDS.sleep(10L);
		resetForAdditionalProfile();
		createSampleProfile();
		ProfileDump.dump();

		Path latestJson = findLatestGeneratedSnapshotFile(".json");
		Path htmlFile = findLatestGeneratedSnapshotFile(".html");
		Path indexFile = tempDirectory.resolve("recordings-index.json");
		String json = Files.readString(latestJson);
		String html = Files.readString(htmlFile);
		String index = Files.readString(indexFile);

		assertTrue(Files.exists(indexFile));
		assertTrue(json.contains("\"history\": {"));
		assertTrue(json.contains("\"recordingIndex\":"));
		assertTrue(json.contains("\"entries\": ["));
		assertTrue(json.contains(latestJson.toString()));
		assertTrue(index.contains("\"schemaVersion\": \"jip-recording-index-v1\""));
		assertTrue(index.contains("\"entries\": ["));
		assertTrue(html.contains("Recent Recordings"));
		assertTrue(html.contains("current)"));
	}

	private void createSampleProfile() {
		if (Controller._jfrEnabled) {
			su.kidoz.jip.jfr.JfrProfileSupport.startProfileSession();
		}
		Profile.start("sample/Service", "run");
		Profile.start("sample/Worker", "step");
		Profile.end("sample/Worker", "step");
		Profile.alloc("sample/Widget");
		Profile.end("sample/Service", "run");
		if (Controller._jfrEnabled) {
			burnCpu();
		}
		Profile.shutdown();
		assertFalse(Controller._profile);
	}

	private void createInsightHeavyProfile() throws InterruptedException {
		Profile.start("sample/Service", "run");
		Profile.start("sample/Worker", "step");
		Profile.end("sample/Worker", "step");
		for (int i = 0; i < 12; i++) {
			Profile.alloc("sample/Widget");
		}
		Profile.alloc("sample/Noise");
		Thread backgroundThread = new Thread(() -> {
			Profile.start("sample/Background", "tick");
			Profile.end("sample/Background", "tick");
		});
		backgroundThread.start();
		backgroundThread.join();
		Profile.end("sample/Service", "run");
		Profile.shutdown();
		assertFalse(Controller._profile);
	}

	private void burnCpu() {
		long start = System.nanoTime();
		long value = 0;
		byte[][] churn = new byte[64][];
		while (System.nanoTime() - start < 150_000_000L) {
			value += System.nanoTime() & 7;
			churn[(int) (value & 63)] = new byte[256];
		}
		assertTrue(value >= 0);
		assertTrue(churn.length == 64);
	}

	private void resetForAdditionalProfile() {
		Profile.init();
		Controller._profile = true;
	}

	private Path findGeneratedFile(String extension) throws IOException {
		try (Stream<Path> stream = Files.list(tempDirectory)) {
			return stream.filter(path -> path.getFileName().toString().endsWith(extension))
					.filter(path -> !path.getFileName().toString().equals("recordings-index.json"))
					.filter(this::isGeneratedSnapshotArtifact)
					.findFirst()
					.orElseThrow(() -> new IOException("Missing generated file with extension " + extension));
		}
	}

	private Path findLatestGeneratedSnapshotFile(String extension) throws IOException {
		try (Stream<Path> stream = Files.list(tempDirectory)) {
			return stream.filter(path -> path.getFileName().toString().endsWith(extension))
					.filter(path -> !path.getFileName().toString().equals("recordings-index.json"))
					.filter(this::isGeneratedSnapshotArtifact)
					.max(Comparator.comparing(path -> path.getFileName().toString()))
					.orElseThrow(() -> new IOException("Missing generated file with extension " + extension));
		}
	}

	private boolean isGeneratedSnapshotArtifact(Path path) {
		return path.getFileName().toString().matches("\\d{8}-\\d{6}(-\\d+)?\\..+");
	}

	private static final class ControllerState {
		private final boolean profile;
		private final String[] includeList;
		private final String[] excludeList;
		private final ClassLoaderFilter filter;
		private final String fileName;
		private final boolean trackObjectAlloc;
		private final Controller.OutputType outputType;
		private final Controller.TimeResolution timeResolution;
		private final boolean jfrEnabled;
		private final int jfrSamplePeriodMs;
		private final String asyncProfilerCollapsedFile;
		private final String[] asyncProfilerArtifactPaths;

		private ControllerState() {
			profile = Controller._profile;
			includeList = cloneArray(Controller._includeList);
			excludeList = cloneArray(Controller._excludeList);
			filter = Controller._filter;
			fileName = Controller._fileName;
			trackObjectAlloc = Controller._trackObjectAlloc;
			outputType = Controller._outputType;
			timeResolution = Controller._timeResoltion;
			jfrEnabled = Controller._jfrEnabled;
			jfrSamplePeriodMs = Controller._jfrSamplePeriodMs;
			asyncProfilerCollapsedFile = Controller._asyncProfilerCollapsedFile;
			asyncProfilerArtifactPaths = cloneArray(Controller._asyncProfilerArtifactPaths);
		}

		private static ControllerState capture() {
			return new ControllerState();
		}

		private void restore() {
			Controller._profile = profile;
			Controller._includeList = cloneArray(includeList);
			Controller._excludeList = cloneArray(excludeList);
			Controller._filter = filter;
			Controller._fileName = fileName;
			Controller._trackObjectAlloc = trackObjectAlloc;
			Controller._outputType = outputType;
			Controller._timeResoltion = timeResolution;
			Controller._jfrEnabled = jfrEnabled;
			Controller._jfrSamplePeriodMs = jfrSamplePeriodMs;
			Controller._asyncProfilerCollapsedFile = asyncProfilerCollapsedFile;
			Controller._asyncProfilerArtifactPaths = cloneArray(asyncProfilerArtifactPaths);
		}

		private static String[] cloneArray(String[] values) {
			return values == null ? null : values.clone();
		}
	}
}
