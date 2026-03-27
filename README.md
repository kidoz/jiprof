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

Modern output modes:

* `output=json` writes a versioned snapshot next to the requested output file.
* `output=modern` writes both the JSON snapshot and a self-contained HTML report.
* `jfr=on` enables a companion Java Flight Recorder capture for the active profiling window.
* `jfr.sample.period.ms=20` controls the JFR execution/native sampling period in milliseconds.

The built-in sampled profiling companion is JFR. `async-profiler` is not bundled into this repository.

The built agent jar now also exposes `Agent-Class` and `Can-Retransform-Classes`, so it can be attached to a live JVM with the standard Java Attach API and then retransform already loaded eligible classes.

Attach hardening:

* `attach.retransform=eligible` keeps the default attach behavior.
* `attach.retransform=include-only` only retransforms already loaded classes that also match `include=...`.
* `attach.retransform=off` installs the agent without retransformation.
