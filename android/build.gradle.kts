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
// Ensure KGP is applied to all Android library subprojects.
// This is needed because some FlutterFire plugins (e.g. firebase_analytics 12.4.1)
// conditionally skip applying kotlin-android for AGP 9+, expecting built-in Kotlin.
// With builtInKotlin=false, their Kotlin sources would not be compiled otherwise.
// Flutter's own detection also misses these because it regex-matches the conditional
// apply statement and assumes the plugin handles KGP itself.
subprojects {
    project.pluginManager.withPlugin("com.android.library") {
        if (!project.pluginManager.hasPlugin("kotlin-android")) {
            project.pluginManager.apply("kotlin-android")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
