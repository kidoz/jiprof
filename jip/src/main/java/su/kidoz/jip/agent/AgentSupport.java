package su.kidoz.jip.agent;

import com.mentorgen.tools.profile.Controller;
import com.mentorgen.tools.profile.instrument.Transformer;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.lang.instrument.Instrumentation;
import java.lang.instrument.UnmodifiableClassException;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

public final class AgentSupport {
    private static final Object LOCK = new Object();
    private static final Transformer TRANSFORMER = new Transformer();

    private static boolean transformerInstalled;
    private static boolean transformerRetransformCapable;

    private AgentSupport() {
    }

    public static void installAtStartup(String args, Instrumentation instrumentation) {
        warnAboutLegacyAgentArgs(args);
        loadPropertiesIfPresent(args);
        installTransformer(instrumentation, false);
    }

    public static void installIntoRunningJvm(String args, Instrumentation instrumentation) {
        loadPropertiesIfPresent(args);
        installTransformer(instrumentation, instrumentation.isRetransformClassesSupported());

        if (!instrumentation.isRetransformClassesSupported()) {
            System.err.println("Attached agent installed, but this JVM does not support class retransformation.");
            return;
        }

        retransformEligibleLoadedClasses(instrumentation);
    }

    static int retransformEligibleLoadedClasses(Instrumentation instrumentation) {
        if (Controller._attachRetransformMode == Controller.AttachRetransformMode.Off) {
            System.err.println("Attach retransformation is disabled by attach.retransform=off.");
            return 0;
        }

        Class<?>[] loadedClasses = instrumentation.getAllLoadedClasses();
        List<Class<?>> candidates = new ArrayList<Class<?>>();

        for (Class<?> loadedClass : loadedClasses) {
            if (isRetransformCandidate(instrumentation, loadedClass)) {
                candidates.add(loadedClass);
            }
        }

        if (candidates.isEmpty()) {
            System.err.println("No already loaded classes matched the profiler filters for retransformation.");
            return 0;
        }

        try {
            instrumentation.retransformClasses(candidates.toArray(new Class[0]));
            System.err.println("Retransformed " + candidates.size() + " already loaded classes.");
            return candidates.size();
        } catch (UnmodifiableClassException e) {
            throw new IllegalStateException("Unable to retransform already loaded classes.", e);
        }
    }

    static boolean isRetransformCandidate(Instrumentation instrumentation, Class<?> loadedClass) {
        if (loadedClass == null || !instrumentation.isModifiableClass(loadedClass)) {
            return false;
        }

        if (loadedClass.isArray() || loadedClass.isPrimitive() || loadedClass.isHidden()) {
            return false;
        }

        String className = loadedClass.getName();
        if (className == null || className.length() == 0 || className.indexOf('/') != -1) {
            return false;
        }

        String internalName = className.replace('.', '/');
        if (!matchesAttachMode(internalName)) {
            return false;
        }

        return TRANSFORMER.shouldTransformClass(loadedClass.getClassLoader(), internalName);
    }

    static synchronized void resetForTests() {
        transformerInstalled = false;
        transformerRetransformCapable = false;
    }

    private static void installTransformer(Instrumentation instrumentation, boolean requestRetransform) {
        synchronized (LOCK) {
            boolean canRetransform = requestRetransform && instrumentation.isRetransformClassesSupported();

            if (!transformerInstalled) {
                instrumentation.addTransformer(TRANSFORMER, canRetransform);
                transformerInstalled = true;
                transformerRetransformCapable = canRetransform;
                return;
            }

            if (!transformerRetransformCapable && canRetransform) {
                instrumentation.removeTransformer(TRANSFORMER);
                instrumentation.addTransformer(TRANSFORMER, true);
                transformerRetransformCapable = true;
            }
        }
    }

    private static void warnAboutLegacyAgentArgs(String args) {
        if (args != null && args.length() != 0 && !args.equals("null")) {
            System.err.println("The -javaagent:foo=bar syntax is no longer supported.");
            System.err.println("Use the VM property profile.properties instead.");
            System.err.println("Continuing using the defaults.");
        }
    }

    private static Properties loadPropertiesIfPresent(String args) {
        Properties props = new Properties();

        if (args == null || args.length() == 0 || args.equals("null")) {
            return props;
        }

        if (!new File(args).exists()) {
            return props;
        }

        try {
            props.load(new FileInputStream(args));
        } catch (IOException e) {
            e.printStackTrace();
        }

        return props;
    }

    private static boolean matchesAttachMode(String internalClassName) {
        if (Controller._attachRetransformMode != Controller.AttachRetransformMode.IncludeOnly) {
            return true;
        }

        String[] includeList = Controller._includeList == null ? new String[0] : Controller._includeList;
        if (includeList.length == 0) {
            return false;
        }

        for (String include : includeList) {
            if (internalClassName.startsWith(include)) {
                return true;
            }
        }

        return false;
    }
}
