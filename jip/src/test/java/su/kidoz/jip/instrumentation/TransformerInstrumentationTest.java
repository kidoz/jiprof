package su.kidoz.jip.instrumentation;

import com.mentorgen.tools.profile.Controller;
import com.mentorgen.tools.profile.instrument.clfilter.ClassLoaderFilter;
import com.mentorgen.tools.profile.instrument.Transformer;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Arrays;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertInstanceOf;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class TransformerInstrumentationTest {
	private static final String FIXTURE_BINARY_NAME = "su.kidoz.jip.testfixtures.TransformFixture";
	private static final String FIXTURE_INTERNAL_NAME = "su/kidoz/jip/testfixtures/TransformFixture";

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

	@BeforeEach
	void setUp() {
		controllerState = ControllerState.capture();
		System.clearProperty("jiprof.transform.fixture.initialized");
		TestProfiler.reset();
		configureController(false);
	}

	@AfterEach
	void tearDown() {
		TestProfiler.reset();
		System.clearProperty("jiprof.transform.fixture.initialized");
		controllerState.restore();
	}

	@Test
	public void doesNotInstrumentStaticInitializers() throws Exception {
		Class<?> fixtureClass = loadTransformedFixture();

		Class.forName(FIXTURE_BINARY_NAME, true, fixtureClass.getClassLoader());

		assertEquals("true", System.getProperty("jiprof.transform.fixture.initialized"));
		assertTrue(TestProfiler.events().isEmpty());
	}

	@Test
	public void instrumentsConstructorsAndMethodReturns() throws Exception {
		Controller._trackObjectAlloc = true;
		Class<?> fixtureClass = loadTransformedFixture();

		Object fixture = fixtureClass.getConstructor().newInstance();
		Method echo = fixtureClass.getMethod("echo", String.class);

		assertEquals("value-ok", echo.invoke(fixture, "value"));
		assertEquals(Arrays.asList("alloc:" + FIXTURE_INTERNAL_NAME, "start:" + FIXTURE_INTERNAL_NAME + "#<init>",
				"end:" + FIXTURE_INTERNAL_NAME + "#<init>", "start:" + FIXTURE_INTERNAL_NAME + "#echo",
				"end:" + FIXTURE_INTERNAL_NAME + "#echo"), TestProfiler.events());
	}

	@Test
	public void recordsUnwindWhenExceptionHandlerRuns() throws Exception {
		Class<?> fixtureClass = loadTransformedFixture();
		Object fixture = fixtureClass.getConstructor().newInstance();
		Method catchesException = fixtureClass.getMethod("catchesException");

		TestProfiler.reset();

		assertEquals("caught", catchesException.invoke(fixture));
		assertEquals(Arrays.asList("start:" + FIXTURE_INTERNAL_NAME + "#catchesException",
				"end:" + FIXTURE_INTERNAL_NAME + "#catchesException",
				"unwind:" + FIXTURE_INTERNAL_NAME + "#catchesException#java/lang/IllegalStateException",
				"end:" + FIXTURE_INTERNAL_NAME + "#catchesException"), TestProfiler.events());
	}

	@Test
	public void recordsMethodExitWhenExceptionEscapes() throws Exception {
		Class<?> fixtureClass = loadTransformedFixture();
		Object fixture = fixtureClass.getConstructor().newInstance();
		Method throwsException = fixtureClass.getMethod("throwsException");

		TestProfiler.reset();

		InvocationTargetException exception = assertThrows(InvocationTargetException.class,
				() -> throwsException.invoke(fixture));

		assertInstanceOf(IllegalArgumentException.class, exception.getCause());
		assertEquals(Arrays.asList("start:" + FIXTURE_INTERNAL_NAME + "#throwsException",
				"end:" + FIXTURE_INTERNAL_NAME + "#throwsException"), TestProfiler.events());
	}

	@Test
	public void instrumentsMonitorEnterBoundaries() throws Exception {
		Class<?> fixtureClass = loadTransformedFixture();
		Object fixture = fixtureClass.getConstructor().newInstance();
		Method synchronizedBlock = fixtureClass.getMethod("synchronizedBlock");

		TestProfiler.reset();

		assertEquals("sync", synchronizedBlock.invoke(fixture));
		assertEquals(Arrays.asList("start:" + FIXTURE_INTERNAL_NAME + "#synchronizedBlock",
				"beginWait:" + FIXTURE_INTERNAL_NAME + "#synchronizedBlock",
				"endWait:" + FIXTURE_INTERNAL_NAME + "#synchronizedBlock",
				"end:" + FIXTURE_INTERNAL_NAME + "#synchronizedBlock"), TestProfiler.events());
	}

	@Test
	public void instrumentsObjectWaitCalls() throws Exception {
		Class<?> fixtureClass = loadTransformedFixture();
		Object fixture = fixtureClass.getConstructor().newInstance();
		Method waitOnMonitor = fixtureClass.getMethod("waitOnMonitor");

		TestProfiler.reset();

		waitOnMonitor.invoke(fixture);
		assertEquals(Arrays.asList("start:" + FIXTURE_INTERNAL_NAME + "#waitOnMonitor",
				"beginWait:" + FIXTURE_INTERNAL_NAME + "#waitOnMonitor",
				"endWait:" + FIXTURE_INTERNAL_NAME + "#waitOnMonitor",
				"beginWait:" + FIXTURE_INTERNAL_NAME + "#waitOnMonitor",
				"endWait:" + FIXTURE_INTERNAL_NAME + "#waitOnMonitor",
				"end:" + FIXTURE_INTERNAL_NAME + "#waitOnMonitor"), TestProfiler.events());
	}

	@Test
	public void instrumentsThreadSleepCalls() throws Exception {
		Class<?> fixtureClass = loadTransformedFixture();
		Object fixture = fixtureClass.getConstructor().newInstance();
		Method sleepBriefly = fixtureClass.getMethod("sleepBriefly");

		TestProfiler.reset();

		sleepBriefly.invoke(fixture);
		assertEquals(Arrays.asList("start:" + FIXTURE_INTERNAL_NAME + "#sleepBriefly",
				"beginWait:" + FIXTURE_INTERNAL_NAME + "#sleepBriefly",
				"endWait:" + FIXTURE_INTERNAL_NAME + "#sleepBriefly", "end:" + FIXTURE_INTERNAL_NAME + "#sleepBriefly"),
				TestProfiler.events());
	}

	@Test
	public void constructorFailureStillEmitsAllocationAndEnd() throws Exception {
		Controller._trackObjectAlloc = true;
		Class<?> fixtureClass = loadTransformedFixture();

		TestProfiler.reset();

		InvocationTargetException exception = assertThrows(InvocationTargetException.class,
				() -> fixtureClass.getConstructor(boolean.class).newInstance(true));

		assertInstanceOf(IllegalArgumentException.class, exception.getCause());
		assertEquals(Arrays.asList("alloc:" + FIXTURE_INTERNAL_NAME, "start:" + FIXTURE_INTERNAL_NAME + "#<init>",
				"end:" + FIXTURE_INTERNAL_NAME + "#<init>"), TestProfiler.events());
	}

	private static void configureController(boolean trackObjectAlloc) {
		Controller._profile = true;
		Controller._includeList = new String[0];
		Controller._excludeList = new String[0];
		Controller._filter = ACCEPT_ALL_FILTER;
		Controller._debug = false;
		Controller._profiler = TestProfiler.class.getName().replace('.', '/');
		Controller._outputMethodSignatures = false;
		Controller._trackObjectAlloc = trackObjectAlloc;
		Controller._instrumentCount = 0;
	}

	private static Class<?> loadTransformedFixture() throws Exception {
		ByteArrayClassLoader loader = new ByteArrayClassLoader(TransformerInstrumentationTest.class.getClassLoader(),
				FIXTURE_BINARY_NAME);
		byte[] original = readFixtureBytes();
		byte[] transformed = new Transformer().transform(loader, FIXTURE_INTERNAL_NAME, null, null, original);

		loader.setFixtureBytes(transformed);
		return loader.loadClass(FIXTURE_BINARY_NAME);
	}

	private static byte[] readFixtureBytes() throws IOException {
		String resource = FIXTURE_INTERNAL_NAME + ".class";

		try (InputStream inputStream = TransformerInstrumentationTest.class.getClassLoader()
				.getResourceAsStream(resource)) {
			if (inputStream == null) {
				throw new IOException("Missing test fixture class bytes: " + resource);
			}
			return inputStream.readAllBytes();
		}
	}

	private static final class ByteArrayClassLoader extends ClassLoader {
		private final String fixtureBinaryName;
		private byte[] fixtureBytes;

		private ByteArrayClassLoader(ClassLoader parent, String fixtureBinaryName) {
			super(parent);
			this.fixtureBinaryName = fixtureBinaryName;
		}

		private void setFixtureBytes(byte[] fixtureBytes) {
			this.fixtureBytes = fixtureBytes;
		}

		@Override
		protected synchronized Class<?> loadClass(String name, boolean resolve) throws ClassNotFoundException {
			if (!fixtureBinaryName.equals(name)) {
				return super.loadClass(name, resolve);
			}

			Class<?> loadedClass = findLoadedClass(name);
			if (loadedClass == null) {
				if (fixtureBytes == null) {
					throw new ClassNotFoundException(name);
				}
				loadedClass = defineClass(name, fixtureBytes, 0, fixtureBytes.length);
			}

			if (resolve) {
				resolveClass(loadedClass);
			}

			return loadedClass;
		}
	}

	private static final class ControllerState {
		private final boolean profile;
		private final String[] includeList;
		private final String[] excludeList;
		private final boolean trackObjectAlloc;
		private final ClassLoaderFilter filter;
		private final boolean debug;
		private final String profiler;
		private final boolean outputMethodSignatures;
		private final int instrumentCount;

		private ControllerState() {
			profile = Controller._profile;
			includeList = cloneArray(Controller._includeList);
			excludeList = cloneArray(Controller._excludeList);
			trackObjectAlloc = Controller._trackObjectAlloc;
			filter = Controller._filter;
			debug = Controller._debug;
			profiler = Controller._profiler;
			outputMethodSignatures = Controller._outputMethodSignatures;
			instrumentCount = Controller._instrumentCount;
		}

		private static ControllerState capture() {
			return new ControllerState();
		}

		private void restore() {
			Controller._profile = profile;
			Controller._includeList = cloneArray(includeList);
			Controller._excludeList = cloneArray(excludeList);
			Controller._trackObjectAlloc = trackObjectAlloc;
			Controller._filter = filter;
			Controller._debug = debug;
			Controller._profiler = profiler;
			Controller._outputMethodSignatures = outputMethodSignatures;
			Controller._instrumentCount = instrumentCount;
		}

		private static String[] cloneArray(String[] values) {
			return values == null ? null : values.clone();
		}
	}
}
