plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.music_app"
    compileSdk = flutter.compileSdkVersion

    // BARIS INI YANG DIUBAH & DITAMBAH
    ndkVersion = "27.0.12077973"        // ← fix NDK warning
    // ndkVersion = flutter.ndkVersion // ← di-comment / dihapus

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.music_app"
        
        // BARIS INI YANG DIUBAH
        minSdk = 23                         // ← WAJIB diubah dari 21 jadi 23 (Firebase baru)
        // minSdk = flutter.minSdkVersion   // ← di-comment / dihapus
        
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}