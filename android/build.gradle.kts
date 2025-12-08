import com.android.build.gradle.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    plugins.withId("com.android.library") {
        try {
            configure<LibraryExtension> {
                if (this.namespace.isNullOrEmpty()) {
                    // Provide a safe default namespace based on the project name
                    this.namespace = "dev.flutter.plugins.${project.name.replace('-', '_')}"
                }
            }
        } catch (_: Throwable) {
            // If the Android Gradle plugin isn't available at configuration time, ignore.
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
