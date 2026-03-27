package su.kidoz.jip.jfr;

import com.mentorgen.tools.profile.Controller;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import su.kidoz.jip.output.ProfileOutputFiles;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Comparator;
import java.util.stream.Stream;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

public class JfrProfileSupportTest {
	private boolean jfrEnabled;
	private int jfrSamplePeriodMs;
	private boolean trackObjectAlloc;
	private String fileName;
	private Path tempDirectory;

	@Before
	public void setUp() throws IOException {
		jfrEnabled = Controller._jfrEnabled;
		jfrSamplePeriodMs = Controller._jfrSamplePeriodMs;
		trackObjectAlloc = Controller._trackObjectAlloc;
		fileName = Controller._fileName;
		tempDirectory = Files.createTempDirectory("jip-jfr-support");

		Controller._jfrEnabled = true;
		Controller._jfrSamplePeriodMs = 1;
		Controller._trackObjectAlloc = true;
		Controller._fileName = tempDirectory.toString();
		JfrProfileSupport.resetForTests();
	}

	@After
	public void tearDown() throws IOException {
		JfrProfileSupport.resetForTests();
		Controller._jfrEnabled = jfrEnabled;
		Controller._jfrSamplePeriodMs = jfrSamplePeriodMs;
		Controller._trackObjectAlloc = trackObjectAlloc;
		Controller._fileName = fileName;

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
	public void createsCompanionRecordingArtifact() {
		JfrProfileSupport.startProfileSession();
		burnCpu();
		JfrProfileSupport.stopProfileSession();

		ProfileOutputFiles files = ProfileOutputFiles.create();
		JfrProfileSupport.JfrReport report = JfrProfileSupport.prepareReport(files);

		assertTrue(report.enabled());
		assertNotNull(report.artifactPath());
		assertTrue(Files.exists(Path.of(report.artifactPath())));
		assertTrue(report.executionSampleCount() >= 0);
		assertTrue(report.nativeSampleCount() >= 0);
	}

	private static void burnCpu() {
		long start = System.nanoTime();
		long value = 0;
		while (System.nanoTime() - start < 150_000_000L) {
			value += System.nanoTime() & 3;
		}
		assertTrue(value >= 0);
	}
}
