pluginManagement {
    val flutterSdkPath: String = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val path = properties.getProperty("flutter.sdk")
        check(path != null) { "flutter.sdk not set in local.properties" }
        path
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Android Gradle plugin [version] https://developer.android.com/reference/tools/gradle-api
    id("com.android.application") version "8.11.1" apply false
    // Kotlin [version]
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version "4.4.4" apply false
    // END: FlutterFire Configuration
}

include(":app")
