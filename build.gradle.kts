buildscript {
    repositories {
        mavenCentral()
    }
    dependencies {
        classpath("org.kt3k.gradle.plugin:coveralls-gradle-plugin:2.8.1")
    }
}

val projectVersion: String by extra("1.2.1")
val gradleWrapperVersion: String by extra("9.1.0")
val coverallsGradlePluginVersion: String by extra("2.8.1")
val asmVersion: String by extra("9.6")
val junitVersion: String by extra("4.13.2")

description = "JIP is a code profiling tool much like the hprof tool that ships with the JDK"

subprojects {
    apply(plugin = "java")

    version = projectVersion

    repositories {
        mavenCentral()
    }

    tasks.withType<Test>().configureEach {
        onlyIf {
            !java.lang.Boolean.getBoolean("skip.tests")
        }
    }

    tasks.withType<JavaCompile>().configureEach {
        options.release.set(17)
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
        "implementation"("org.ow2.asm:asm:$asmVersion")
        "testImplementation"("junit:junit:$junitVersion")
    }
}

project(":jip-plugin") {
    tasks.named<Jar>("jar") {
        manifest {
            attributes(
                "Bundle-ManifestVersion" to 2,
                "Bundle-Name" to "JIP Plug-in",
                "Bundle-SymbolicName" to "com.mentorgen.tools.profile; singleton:=true",
                "Bundle-Version" to "1.0.0",
                "Bundle-Localization" to "plugin",
                "Require-Bundle" to "org.eclipse.core.runtime, org.eclipse.ui",
                "Eclipse-AutoStart" to "true",
                "Import-Package" to "org.eclipse.core.runtime, org.eclipse.ui, org.eclipse.swt, org.eclipse.jface"
            )
        }
    }
    dependencies {
        "implementation"(fileTree(mapOf("dir" to "lib", "include" to listOf("*.jar"))))
    }
}

project(":jip-snapman") {
    dependencies {
        "implementation"(fileTree(mapOf("dir" to "lib", "include" to listOf("*.jar"))))
    }

    tasks.named<Jar>("jar") {
        manifest {
            attributes("Main-Class" to "com.mentorgen.tools.util.profile.Client")
        }
    }
}

project(":jip-viewer") {
    tasks.named<Jar>("jar") {
        manifest {
            attributes("Main-Class" to "com.mentorgen.tools.profile.Main")
        }
    }
}

project(":simple-profiler") {
    tasks.named<Jar>("jar") {
        manifest {
            attributes("Premain-Class" to "sample.profiler.Main")
        }
    }

    dependencies {
        "implementation"("org.ow2.asm:asm:$asmVersion")
        "testImplementation"("junit:junit:$junitVersion")
    }
}

project(":verbose-class") {
    tasks.named<Jar>("jar") {
        manifest {
            attributes("Premain-Class" to "sample.verboseclass.Main")
        }
    }

    dependencies {
        "testImplementation"("junit:junit:$junitVersion")
    }
}