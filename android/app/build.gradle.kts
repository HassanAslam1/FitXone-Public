plugins {
    id("com.android.application")
    // ADD THIS LINE: This enables the kotlinOptions block
    id("org.jetbrains.kotlin.android")
    // Depending on your Flutter version, this might be "com.example.flutter.pigeon" or "dev.flutter.flutter-gradle-plugin"
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.thefitxone" // Make sure this matches your package!
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        // Ensure this ID matches your Firebase Console
        applicationId = "com.example.thefitxone"

        // Firebase usually requires MinSDK 21 or higher
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 1. ENABLE MULTIDEX HERE
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// 2. ADD THIS DEPENDENCIES BLOCK AT THE BOTTOM
dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
