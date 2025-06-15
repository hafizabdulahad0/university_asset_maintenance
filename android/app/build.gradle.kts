// File: android/app/build.gradle.kts

plugins {
    // Android application plugin
    id("com.android.application")
    // Apply Google services (Firebase) plugin
    id("com.google.gms.google-services")
    // Kotlin support
    id("kotlin-android")
    // Flutter’s Gradle plugin — keep this last
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace   = "com.example.university_asset_maintenance"
    compileSdk  = flutter.compileSdkVersion

    // Use the highest NDK version any plugin needs (they’re backward-compatible)
    ndkVersion  = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.university_asset_maintenance"
        minSdk        = flutter.minSdkVersion
        targetSdk     = flutter.targetSdkVersion
        versionCode   = flutter.versionCode
        versionName   = flutter.versionName
    }

    compileOptions {
        sourceCompatibility            = JavaVersion.VERSION_11
        targetCompatibility            = JavaVersion.VERSION_11
        // Enable Java 8+ API desugaring (required by some plugins)
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        getByName("release") {
            // disable code shrinking (R8) and resource shrinking (needs code shrinking)
            isMinifyEnabled   = false
            isShrinkResources = false
            // debug keys for now; replace with your own keystore
            signingConfig     = signingConfigs.getByName("debug")
        }
        getByName("debug") {
            isMinifyEnabled   = false
            isShrinkResources = false
            signingConfig     = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Firebase BoM for consistent versions
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))
    // Firebase Cloud Messaging
    implementation("com.google.firebase:firebase-messaging")
    // (Optional) other Firebase libraries, e.g. Analytics:
    // implementation("com.google.firebase:firebase-analytics-ktx")

    // Desugaring library (must be ≥ 2.1.4 for flutter_local_notifications ≥ 13)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

// Flutter-specific DSL – do not remove
flutter {
    source = "../.."
}
