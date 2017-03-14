[![Build Status][travis-image]][travis-url] [![Coverage Status][coveralls-image]][coveralls-url]

[travis-image]: https://travis-ci.org/kidoz/jiprof.svg?branch=master
[travis-url]: https://travis-ci.org/kidoz/jiprof

[coveralls-image]: https://coveralls.io/repos/github/kidoz/jiprof/badge.svg?branch=master
[coveralls-url]: https://coveralls.io/github/kidoz/jiprof?branch=master

-----------------------------------------------------------------------------
JIP is a code profiling tool much like the hprof tool that ships with the JDK. There are, however, a few differences:

* **Interactivity.** hprof is not an interactive profiler. It starts when your program starts and ends when the JVM exits. In many cases this doesn't give you a true measure of performance since the Just In Time compiler doesn't compile code on the first pass. In addition, this type of profiler is not useable at all in web applications since you end up profiling the web container as well as the web application. JIP, on the other hand, allows you to turn the profiler on and off while the JVM is running.
* **No native code.** Most profilers have some native component. This is because most profilers use the JVMPI (Java Virtual Machine Profiling Interface) which requires the use of native components. JIP, however, is pure Java. It takes advantage of the Java5™ feature which allows you to hook the classloader. JIP adds aspects to every method of every class that you want to profile. These aspects allow it to capture performance data.
* **Very low overhead.** Most profilers are very slow. In many cases hprof will cause a program to run 20 times slower. JIP, on the other hand, is lightweight. A VM with profiling turned on is about twice as slow as one without a profiler. When the profiler is turned off, there is almost no overhead associated with using JIP.
* **Performance Timings.** JIP gathers performance data. You cannot use most profilers to do timings of your application. hprof, for example, will show you the relative amount of time that is spent in different parts of your code, but hprof has so much overhead, that you cannot use it to get real world timing measurements. JIP, on the other hand, actually tracks the amount of time used to gather performance data and factors that time out of its analysis. This allows you to get close to real world timings for every class in your code. So there is no need to litter your code with System.currentTimeMillis()!
* **Filters by package/class name.** One of the annoying things about hprof is that there is no way to filter out classes by class or package name. JIP allows you to do just that (for more information, look at the profile.properties file). This in not to say that the execution time is not included. It is included but can only be seen in the execution time of the calling routine.
-----------------------------------------------------------------------------

Setup / Usage
-------------

Build profiler: gradle jip:clean jip:jar

Usage: java -javaagent:lib/profile.jar -Dprofile.properties=properties-file-name