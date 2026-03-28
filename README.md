JIP is a code profiling tool much like the hprof tool that ships with the JDK. There are, however, a few differences:

* **Interactivity.** hprof is not an interactive profiler. It starts when your program starts and ends when the JVM exits. In many cases this doesn't give you a true measure of performance since the Just In Time compiler doesn't compile code on the first pass. In addition, this type of profiler is not useable at all in web applications since you end up profiling the web container as well as the web application. JIP, on the other hand, allows you to turn the profiler on and off while the JVM is running.
* **No native code.** Most profilers have some native component. This is because most profilers use the JVMPI (Java Virtual Machine Profiling Interface) which requires the use of native components. JIP, however, is pure Java. It takes advantage of the Java5™ feature which allows you to hook the classloader. JIP adds aspects to every method of every class that you want to profile. These aspects allow it to capture performance data.
* **Very low overhead.** Most profilers are very slow. In many cases hprof will cause a program to run 20 times slower. JIP, on the other hand, is lightweight. A VM with profiling turned on is about twice as slow as one without a profiler. When the profiler is turned off, there is almost no overhead associated with using JIP.
* **Performance Timings.** JIP gathers performance data. You cannot use most profilers to do timings of your application. hprof, for example, will show you the relative amount of time that is spent in different parts of your code, but hprof has so much overhead, that you cannot use it to get real world timing measurements. JIP, on the other hand, actually tracks the amount of time used to gather performance data and factors that time out of its analysis. This allows you to get close to real world timings for every class in your code. So there is no need to litter your code with System.currentTimeMillis()!
* **Filters by package/class name.** One of the annoying things about hprof is that there is no way to filter out classes by class or package name. JIP allows you to do just that (for more information, look at the profile.properties file). This in not to say that the execution time is not included. It is included but can only be seen in the execution time of the calling routine.
-----------------------------------------------------------------------------

Setup / Usage
-------------

Build profiler: ./gradlew :jip:clean :jip:jar

Usage: java -javaagent:lib/profile.jar -Dprofile.properties=properties-file-name

Output modes:

* `output=json` writes a versioned snapshot next to the requested output file.
* `output=html` (default) writes both the JSON snapshot and a self-contained HTML report.
* The HTML report can load a second JSON snapshot locally and show regression-focused diffs for methods, allocations, and JFR sampled hotspots.
* The snapshot also carries automated insights for dominant hotspots, allocation pressure, single-thread dominance, and sampled-vs-instrumented mismatch.
* `jfr=on` enables a companion Java Flight Recorder capture for the active profiling window.
* `jfr.sample.period.ms=20` controls the JFR execution/native sampling period in milliseconds.
* `async-profiler.collapsed=/path/to/profile.collapsed` imports an external async-profiler collapsed stack capture into the snapshot.
* `async-profiler.artifacts=/path/to/flamegraph.html,/path/to/profile.jfr` links external async-profiler outputs in the HTML report without bundling the native profiler.
* When the JDK supports it, the JFR companion also records CPU-time samples plus lock/contention signals (`JavaMonitorEnter`, `JavaMonitorWait`, `ThreadPark`) and exposes them in the JSON/HTML report.
* Snapshots include a coarse timeline with runtime buckets, per-thread peak windows, and JFR overlay counts for time-oriented analysis.
* Snapshot artifacts now carry a stable `snapshotLabel`, and the HTML report can download its embedded snapshot JSON plus an exported compare summary after a baseline is loaded.
* Allocation analysis now combines runtime allocation counts with JFR sampled allocation bytes and exposes JFR-backed allocation hot paths plus sampled-byte regressions in compare mode.
* External async-profiler imports now surface collapsed top leaf frames, top stacks, and linked flame graph artifacts alongside JIP and JFR data.
* When `file` points to a directory, JIP now keeps a rolling `recordings-index.json` sidecar and embeds a recent-recordings history block into each snapshot/report.
* The self-contained HTML report now includes an icicle-style hottest-interaction view plus a method heatmap for faster visual hotspot scanning.

The built-in sampled profiling companion is JFR. `async-profiler` is not bundled into this repository; interoperability is import/link based.

The built agent jar now also exposes `Agent-Class` and `Can-Retransform-Classes`, so it can be attached to a live JVM with the standard Java Attach API and then retransform already loaded eligible classes.

Attach hardening:

* `attach.retransform=eligible` keeps the default attach behavior.
* `attach.retransform=include-only` only retransforms already loaded classes that also match `include=...`.
* `attach.retransform=off` installs the agent without retransformation.
