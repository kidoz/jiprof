package su.kidoz.jip.output;

import com.mentorgen.tools.profile.Controller;
import com.mentorgen.tools.profile.instrument.clfilter.ClassLoaderFilter;
import com.mentorgen.tools.profile.output.ProfileDump;
import com.mentorgen.tools.profile.runtime.Profile;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Comparator;
import java.util.stream.Stream;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

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

	@Before
	public void setUp() throws IOException {
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
	}

	@After
	public void tearDown() throws IOException {
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
		assertTrue(json.contains(jfrFile.toString()));
		assertTrue(html.contains("JFR Sampled Hotspots"));
		assertTrue(html.contains(jfrFile.toString()));
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

	private void burnCpu() {
		long start = System.nanoTime();
		long value = 0;
		while (System.nanoTime() - start < 150_000_000L) {
			value += System.nanoTime() & 7;
		}
		assertTrue(value >= 0);
	}

	private Path findGeneratedFile(String extension) throws IOException {
		try (Stream<Path> stream = Files.list(tempDirectory)) {
			return stream.filter(path -> path.getFileName().toString().endsWith(extension)).findFirst()
					.orElseThrow(() -> new IOException("Missing generated file with extension " + extension));
		}
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
		}

		private static String[] cloneArray(String[] values) {
			return values == null ? null : values.clone();
		}
	}
}
