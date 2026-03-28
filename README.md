# JIP — Java Interactive Profiler

[![Java](https://img.shields.io/badge/Java-17%2B-blue)](https://openjdk.org/)
[![License](https://img.shields.io/badge/License-BSD-green)](LICENSE)
[![Build](https://img.shields.io/badge/Build-Gradle-orange)](https://gradle.org/)

JIP is a lightweight, pure-Java code profiler that instruments bytecode at the classloader level. Unlike hprof it can be toggled at runtime, filters by package, and produces real-world timing measurements with very low overhead.

## Quick Start

```bash
# Build
./gradlew :jip:jar

# Run the included demo with profiling
./gradlew :example:profileRun

# Report is written to example/build/profile-output/
```

Or with [just](https://just.systems):

```bash
just demo
```

## Usage

```bash
java -javaagent:jip/build/libs/profile.jar \
     -Dprofile.properties=profile.properties \
     your.MainClass
```

### profile.properties

```properties
profiler=on
output=html
file=output
include=com.example
track.object.alloc=on
clock-resolution=ns
```

## Output Modes

| Setting | Description |
|---------|-------------|
| `output=html` (default) | JSON snapshot + self-contained HTML report |
| `output=json` | JSON snapshot only |

The HTML report is a single file that works offline — open it directly in a browser.

### HTML Report Features

- Method hotspot tables with timing bars and search
- Automated insights (dominant hotspot, allocation pressure, single-thread dominance)
- Icicle chart and method heatmap visualizations
- Baseline comparison — load a second snapshot to see regressions and improvements
- Allocation analysis with JFR-sampled bytes and hot paths
- Thread call trees with per-frame timing
- Timeline with coarse runtime buckets and JFR overlay
- Recording history when `file` points to a directory

## JFR Companion

```properties
jfr=on
jfr.sample.period.ms=20
```

When enabled, JIP captures a companion Java Flight Recording that adds CPU-time samples, lock/contention events (`JavaMonitorEnter`, `JavaMonitorWait`, `ThreadPark`), and allocation sampling to the report.

## Async-Profiler Integration

```properties
async-profiler.collapsed=/path/to/profile.collapsed
async-profiler.artifacts=/path/to/flamegraph.html,/path/to/profile.jfr
```

Import external async-profiler captures into the report without bundling the native profiler.

## Live Attach

The agent JAR exposes `Agent-Class` and `Can-Retransform-Classes`, so it can be attached to a running JVM via the Attach API:

```properties
attach.retransform=eligible    # default: retransform loaded classes
attach.retransform=include-only # only retransform classes matching include=
attach.retransform=off          # install without retransformation
```

## Build

```bash
./gradlew build          # build + test everything
./gradlew :jip:test      # run profiler tests only
./gradlew :jip:jar       # build the agent JAR
```

## License

[BSD License](LICENSE)

## Author

Aleksandr Pavlov <ckidoz@gmail.com>
