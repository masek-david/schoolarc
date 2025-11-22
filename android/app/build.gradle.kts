plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // Compose [version]
    // this version matches your Kotlin version
    id("org.jetbrains.kotlin.plugin.compose") version "2.1.0"
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "cz.masci.schoolarc"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "cz.masci.schoolarc"
        // in home widget, LocalDate needs api 26, but it has to be defined here, not in local.properties
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    flavorDimensions += "default"

    productFlavors {
        create("dev") {
            dimension = "default"
            applicationIdSuffix = ".dev"
        }
        create("prod") {
            dimension = "default"
            applicationIdSuffix = ""
        }
    }
}

composeCompiler {
    reportsDestination = layout.buildDirectory.dir("compose_compiler")
    stabilityConfigurationFiles.addAll(rootProject.layout.projectDirectory.file("stability_config.conf"))
}

dependencies {
    implementation("androidx.glance:glance-appwidget:1.1.1")
    implementation("com.google.code.gson:gson:2.13.2")
    implementation("androidx.compose.material3:material3-android:1.4.0")
    implementation("androidx.core:core-splashscreen:1.0.1")
    implementation("com.materialkolor:material-color-utilities:4.0.2")
    implementation("androidx.glance:glance-preview:1.1.1")
    debugImplementation("androidx.glance:glance-preview:1.1.1")
    debugImplementation("androidx.glance:glance-appwidget-preview:1.1.1")
}

flutter {
    source = "../.."
}
