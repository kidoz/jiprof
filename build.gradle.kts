import net.ltgt.gradle.errorprone.errorprone

plugins {
    alias(libs.plugins.spotless) apply false
    alias(libs.plugins.errorprone) apply false
}

buildscript {
    repositories {
        mavenCentral()
    }
    dependencies {
        classpath(libs.coveralls.plugin)
    }
}

val projectVersion = libs.versions.project.get()
val gradleWrapperVersion = "9.1.0"
val catalog = libs

description = "JIP is a code profiling tool much like the hprof tool that ships with the JDK"

subprojects {
    apply(plugin = "java")
    apply(plugin = "com.diffplug.spotless")
    apply(plugin = "net.ltgt.errorprone")

    version = projectVersion

    repositories {
        mavenCentral()
    }

    dependencies {
        "errorprone"(catalog.errorprone.core)
    }

    configure<com.diffplug.gradle.spotless.SpotlessExtension> {
        java {
            eclipse()
            removeUnusedImports()
            trimTrailingWhitespace()
            endWithNewline()
        }
    }

    tasks.withType<Test>().configureEach {
        onlyIf {
            !java.lang.Boolean.getBoolean("skip.tests")
        }
    }

    tasks.withType<JavaCompile>().configureEach {
        options.release.set(17)
        options.errorprone.disableWarningsInGeneratedCode.set(true)
        options.compilerArgs.add("-XDshould-stop.ifError=FLOW")
    }
}

tasks.wrapper {
    gradleVersion = gradleWrapperVersion
}

project(":jip") {
    tasks.named<Jar>("jar") {
        archiveBaseName.set("profile")

        manifest {
            attributes(
                "Premain-Class" to "com.mentorgen.tools.profile.Main",
                "Agent-Class" to "com.mentorgen.tools.profile.Main",
                "Can-Retransform-Classes" to "true"
            )
        }

        from(java.util.concurrent.Callable {
            configurations["runtimeClasspath"].map { if (it.isDirectory) it else zipTree(it) }
        })

        archiveVersion.set("")
    }

    dependencies {
        "implementation"(catalog.asm)
        "testImplementation"(catalog.junit)
    }
}

project(":simple-profiler") {
    tasks.named<Jar>("jar") {
        manifest {
            attributes("Premain-Class" to "sample.profiler.Main")
        }
    }

    dependencies {
        "implementation"(catalog.asm)
        "testImplementation"(catalog.junit)
    }
}

project(":verbose-class") {
    tasks.named<Jar>("jar") {
        manifest {
            attributes("Premain-Class" to "sample.verboseclass.Main")
        }
    }

    dependencies {
        "testImplementation"(catalog.junit)
    }
}
