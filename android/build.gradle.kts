// File: android/build.gradle.kts

plugins {
  // Add the Google services Gradle plugin to the classpath, but don't apply it here:
  id("com.google.gms.google-services") version "4.4.2" apply false
}

allprojects {
  repositories {
    google()
    mavenCentral()
  }
}

// (Optional) Move the build outputs outside your project directory:
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
  project.layout.buildDirectory.value(newBuildDir.dir(project.name))
  evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
  delete(rootProject.layout.buildDirectory)
}
