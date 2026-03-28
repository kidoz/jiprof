package su.kidoz.jip.jfr;

import com.mentorgen.tools.profile.Controller;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import su.kidoz.jip.output.ProfileOutputFiles;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Comparator;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.LockSupport;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class JfrProfileSupportTest {
	private boolean jfrEnabled;
	private int jfrSamplePeriodMs;
	private boolean trackObjectAlloc;
	private String fileName;
	private Path tempDirectory;

	@BeforeEach
	void setUp() throws IOException {
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

	@AfterEach
	void tearDown() throws IOException {
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
		assertTrue(report.metadata().samplePeriodMs() == 1);
	}

	@Test
	public void capturesContentionAndExtendedMetadata() throws Exception {
		JfrProfileSupport.startProfileSession();
		induceContention();
		JfrProfileSupport.stopProfileSession();

		ProfileOutputFiles files = ProfileOutputFiles.create();
		JfrProfileSupport.JfrReport report = JfrProfileSupport.prepareReport(files);

		assertTrue(report.enabled());
		assertTrue(report.metadata().executionSamplingEnabled());
		assertTrue(report.metadata().monitorEnterEventsEnabled() || report.metadata().monitorWaitEventsEnabled()
				|| report.metadata().threadParkEventsEnabled());
		assertTrue(report.cpuTimeSampleCount() >= 0);
		assertTrue(report.contentionEventCount() > 0);
		assertTrue(report.contentionDurationNanos() >= 0);
		assertTrue(report.topAllocationPaths() != null);
		assertTrue(!report.topContentionSamples().isEmpty());
		assertTrue(report.timelineBucketSizeMs() > 0);
		assertTrue(!report.timelineBuckets().isEmpty());
	}

	private static void burnCpu() {
		long start = System.nanoTime();
		long value = 0;
		while (System.nanoTime() - start < 150_000_000L) {
			value += System.nanoTime() & 3;
		}
		assertTrue(value >= 0);
	}

	private static void induceContention() throws Exception {
		Object monitor = new Object();
		CountDownLatch lockHeld = new CountDownLatch(1);
		CountDownLatch contentionDone = new CountDownLatch(1);

		Thread owner = new Thread(() -> {
			synchronized (monitor) {
				lockHeld.countDown();
				sleepMillis(180);
			}
		}, "jfr-owner");

		Thread contender = new Thread(() -> {
			await(lockHeld);
			synchronized (monitor) {
				contentionDone.countDown();
			}
		}, "jfr-contender");

		owner.start();
		contender.start();
		assertTrue(contentionDone.await(2, TimeUnit.SECONDS));
		owner.join();
		contender.join();

		synchronized (monitor) {
			monitor.wait(120L);
		}

		LockSupport.parkNanos(TimeUnit.MILLISECONDS.toNanos(120));
	}

	private static void await(CountDownLatch latch) {
		try {
			assertTrue(latch.await(2, TimeUnit.SECONDS));
		} catch (InterruptedException e) {
			Thread.currentThread().interrupt();
			throw new RuntimeException(e);
		}
	}

	private static void sleepMillis(long millis) {
		try {
			Thread.sleep(millis);
		} catch (InterruptedException e) {
			Thread.currentThread().interrupt();
			throw new RuntimeException(e);
		}
	}
}
