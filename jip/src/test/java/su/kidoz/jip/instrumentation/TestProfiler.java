package su.kidoz.jip.instrumentation;

import java.util.ArrayList;
import java.util.List;

public final class TestProfiler {
    private static final List<String> EVENTS = new ArrayList<String>();

    private TestProfiler() {
    }

    public static synchronized void reset() {
        EVENTS.clear();
    }

    public static synchronized List<String> events() {
        return new ArrayList<String>(EVENTS);
    }

    public static void start(String className, String methodName) {
        record("start:" + className + "#" + methodName);
    }

    public static void end(String className, String methodName) {
        record("end:" + className + "#" + methodName);
    }

    public static void alloc(String className) {
        record("alloc:" + className);
    }

    public static void unwind(String className, String methodName, String exception) {
        record("unwind:" + className + "#" + methodName + "#" + exception);
    }

    public static void beginWait(String className, String methodName) {
        record("beginWait:" + className + "#" + methodName);
    }

    public static void endWait(String className, String methodName) {
        record("endWait:" + className + "#" + methodName);
    }

    private static synchronized void record(String event) {
        EVENTS.add(event);
    }
}
