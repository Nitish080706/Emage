plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter Gradle Plugin
}

android {
    namespace = "com.example.emage"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.emage"
        minSdkVersion(23) // Correct Kotlin DSL syntax
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true // Enable code shrinking
            isShrinkResources = true // Enable resource shrinking
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

// Flutter plugin configuration should be outside android block
flutter {
    source = "../.."
}
