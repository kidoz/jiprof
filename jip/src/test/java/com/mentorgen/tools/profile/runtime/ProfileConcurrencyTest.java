package com.mentorgen.tools.profile.runtime;

import com.mentorgen.tools.profile.Controller;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class ProfileConcurrencyTest {
	private static final int THREADS = 4;
	private static final int ITERATIONS = 75;

	private boolean profile;

	@BeforeEach
	void setUp() {
		profile = Controller._profile;
		Profile.init();
		Controller._profile = true;
	}

	@AfterEach
	void tearDown() {
		Controller._profile = profile;
		Profile.init();
	}

	@Test
	public void recordsConcurrentInteractionsWithoutGlobalLockState() throws Exception {
		ExecutorService executor = Executors.newFixedThreadPool(THREADS);
		CountDownLatch startGate = new CountDownLatch(1);
		List<Future<Void>> futures = new ArrayList<Future<Void>>();

		for (int worker = 0; worker < THREADS; worker++) {
			final int workerId = worker;
			futures.add(executor.submit(new Callable<Void>() {
				@Override
				public Void call() throws Exception {
					startGate.await();

					for (int iteration = 0; iteration < ITERATIONS; iteration++) {
						String className = "sample/Worker" + workerId;
						Profile.start(className, "run");
						Profile.start(className, "nested");
						Profile.end(className, "nested");
						Profile.alloc(className + "$Allocation");
						Profile.end(className, "run");
					}

					return null;
				}
			}));
		}

		startGate.countDown();

		for (Future<Void> future : futures) {
			future.get();
		}

		executor.shutdown();
		Profile.shutdown();

		int threadCount = 0;
		int interactionCount = 0;
		long totalAllocationCount = 0;

		for (Long threadId : Profile.threads()) {
			threadCount++;

			for (Frame frame : Profile.interactions(threadId)) {
				interactionCount++;
				assertEquals("run", frame.getMethodName());
			}
		}

		for (ClassAllocation allocation : Profile.allocations()) {
			totalAllocationCount += allocation.getAllocCount();
		}

		assertEquals(THREADS, threadCount);
		assertEquals(THREADS * ITERATIONS, interactionCount);
		assertEquals(THREADS * ITERATIONS * 2, countFrames());
		assertEquals(THREADS * ITERATIONS, totalAllocationCount);
	}

	@Test
	public void clearDropsStaleThreadLocalFramesBeforeNextRun() {
		Profile.start("sample/Service", "run");
		Profile.clear();
		Controller._profile = true;

		Profile.start("sample/Service", "fresh");
		Profile.end("sample/Service", "fresh");
		Profile.shutdown();

		int interactionCount = 0;

		for (Long threadId : Profile.threads()) {
			for (Frame frame : Profile.interactions(threadId)) {
				interactionCount++;
				assertEquals("fresh", frame.getMethodName());
			}
		}

		assertEquals(1, interactionCount);
		assertEquals(1, countFrames());
	}

	private static int countFrames() {
		int count = 0;

		for (Frame frame : Profile.frameList()) {
			count++;
		}

		return count;
	}
}
