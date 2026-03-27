package su.kidoz.jip.agent;

import com.mentorgen.tools.profile.Controller;
import com.mentorgen.tools.profile.instrument.clfilter.ClassLoaderFilter;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import su.kidoz.jip.testfixtures.TransformFixture;

import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.Instrumentation;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertSame;
import static org.junit.Assert.assertTrue;

public class AgentSupportTest {
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

    @Before
    public void setUp() {
        controllerState = ControllerState.capture();
        Controller._includeList = new String[0];
        Controller._excludeList = new String[0];
        Controller._filter = ACCEPT_ALL_FILTER;
        Controller._attachRetransformMode = Controller.AttachRetransformMode.Eligible;
        AgentSupport.resetForTests();
    }

    @After
    public void tearDown() {
        AgentSupport.resetForTests();
        controllerState.restore();
    }

    @Test
    public void premainInstallsNonRetransformingTransformer() {
        InstrumentationProbe probe = new InstrumentationProbe();

        AgentSupport.installAtStartup(null, probe.instrumentation());

        assertEquals(1, probe.addTransformerCalls.size());
        assertFalse(probe.addTransformerCalls.get(0).canRetransform);
    }

    @Test
    public void agentmainUpgradesToRetransformingTransformerAndRetransformsEligibleClasses() {
        InstrumentationProbe probe = new InstrumentationProbe();
        probe.retransformSupported = true;
        probe.loadedClasses = new Class<?>[] {
                TransformFixture.class,
                String.class,
                AgentSupportTest.class
        };
        probe.modifiableClasses.add(TransformFixture.class);
        probe.modifiableClasses.add(AgentSupportTest.class);
        Controller._excludeList = new String[] {"su/kidoz/jip/agent"};

        AgentSupport.installAtStartup(null, probe.instrumentation());
        AgentSupport.installIntoRunningJvm(null, probe.instrumentation());

        assertEquals(2, probe.addTransformerCalls.size());
        assertFalse(probe.addTransformerCalls.get(0).canRetransform);
        assertTrue(probe.addTransformerCalls.get(1).canRetransform);
        assertEquals(1, probe.removedTransformers.size());
        assertSame(probe.addTransformerCalls.get(0).transformer, probe.removedTransformers.get(0));
        assertEquals(1, probe.retransformCalls.size());
        assertEquals(Collections.singletonList(TransformFixture.class), probe.retransformCalls.get(0));
    }

    @Test
    public void skipsNonModifiableHiddenAndFilteredClassesDuringRetransformSelection() {
        InstrumentationProbe probe = new InstrumentationProbe();
        probe.retransformSupported = true;
        probe.loadedClasses = new Class<?>[] {
                TransformFixture.class,
                String.class,
                HiddenHolder.hiddenClass()
        };
        probe.modifiableClasses.add(TransformFixture.class);
        Controller._includeList = new String[] {"su/kidoz/jip/testfixtures"};

        assertTrue(AgentSupport.isRetransformCandidate(probe.instrumentation(), TransformFixture.class));
        assertFalse(AgentSupport.isRetransformCandidate(probe.instrumentation(), String.class));
        assertFalse(AgentSupport.isRetransformCandidate(probe.instrumentation(), HiddenHolder.hiddenClass()));
    }

    @Test
    public void includeOnlyModeRequiresExplicitIncludeMatch() {
        InstrumentationProbe probe = new InstrumentationProbe();
        probe.retransformSupported = true;
        probe.modifiableClasses.add(TransformFixture.class);
        Controller._attachRetransformMode = Controller.AttachRetransformMode.IncludeOnly;
        Controller._includeList = new String[] {"other/package"};

        assertFalse(AgentSupport.isRetransformCandidate(probe.instrumentation(), TransformFixture.class));

        Controller._includeList = new String[] {"su/kidoz/jip/testfixtures"};

        assertTrue(AgentSupport.isRetransformCandidate(probe.instrumentation(), TransformFixture.class));
    }

    private static final class HiddenHolder {
        private static final Class<?> HIDDEN_CLASS = new Runnable() {
            @Override
            public void run() {
            }
        }.getClass();

        private static Class<?> hiddenClass() {
            return HIDDEN_CLASS;
        }
    }

    private static final class InstrumentationProbe implements InvocationHandler {
        private final List<AddTransformerCall> addTransformerCalls = new ArrayList<AddTransformerCall>();
        private final List<ClassFileTransformer> removedTransformers = new ArrayList<ClassFileTransformer>();
        private final List<List<Class<?>>> retransformCalls = new ArrayList<List<Class<?>>>();
        private final List<Class<?>> modifiableClasses = new ArrayList<Class<?>>();

        private boolean retransformSupported;
        private Class<?>[] loadedClasses = new Class<?>[0];

        private Instrumentation instrumentation() {
            return (Instrumentation) Proxy.newProxyInstance(
                    Instrumentation.class.getClassLoader(),
                    new Class<?>[] {Instrumentation.class},
                    this
            );
        }

        @Override
        public Object invoke(Object proxy, Method method, Object[] args) {
            String name = method.getName();

            if ("addTransformer".equals(name)) {
                ClassFileTransformer transformer = (ClassFileTransformer) args[0];
                boolean canRetransform = args.length > 1 && Boolean.TRUE.equals(args[1]);
                addTransformerCalls.add(new AddTransformerCall(transformer, canRetransform));
                return null;
            }

            if ("removeTransformer".equals(name)) {
                removedTransformers.add((ClassFileTransformer) args[0]);
                return true;
            }

            if ("isRetransformClassesSupported".equals(name)) {
                return retransformSupported;
            }

            if ("getAllLoadedClasses".equals(name)) {
                return loadedClasses;
            }

            if ("isModifiableClass".equals(name)) {
                return modifiableClasses.contains((Class<?>) args[0]);
            }

            if ("retransformClasses".equals(name)) {
                retransformCalls.add(Arrays.asList((Class<?>[]) args[0]));
                return null;
            }

            if ("toString".equals(name)) {
                return "InstrumentationProbe";
            }

            if ("hashCode".equals(name)) {
                return System.identityHashCode(this);
            }

            if ("equals".equals(name)) {
                return proxy == args[0];
            }

            throw new UnsupportedOperationException("Unexpected instrumentation method: " + name);
        }
    }

    private static final class AddTransformerCall {
        private final ClassFileTransformer transformer;
        private final boolean canRetransform;

        private AddTransformerCall(ClassFileTransformer transformer, boolean canRetransform) {
            this.transformer = transformer;
            this.canRetransform = canRetransform;
        }
    }

    private static final class ControllerState {
        private final String[] includeList;
        private final String[] excludeList;
        private final ClassLoaderFilter filter;
        private final Controller.AttachRetransformMode attachRetransformMode;

        private ControllerState() {
            includeList = cloneArray(Controller._includeList);
            excludeList = cloneArray(Controller._excludeList);
            filter = Controller._filter;
            attachRetransformMode = Controller._attachRetransformMode;
        }

        private static ControllerState capture() {
            return new ControllerState();
        }

        private void restore() {
            Controller._includeList = cloneArray(includeList);
            Controller._excludeList = cloneArray(excludeList);
            Controller._filter = filter;
            Controller._attachRetransformMode = attachRetransformMode;
        }

        private static String[] cloneArray(String[] values) {
            return values == null ? null : values.clone();
        }
    }
}
