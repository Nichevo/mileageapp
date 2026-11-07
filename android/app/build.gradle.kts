import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing. The keystore and its passwords never live in the repo:
// locally they come from android/key.properties (gitignored); in CI from
// environment variables set from repository secrets. If neither is present
// the release build falls back to the debug key so the project still builds,
// but such an APK will NOT install over a properly signed one.
val keyProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) load(FileInputStream(f))
}
fun signingValue(name: String): String? =
    keyProperties.getProperty(name) ?: System.getenv("MILEAGELOG_" + name.uppercase())

val hasReleaseKey = signingValue("storeFile") != null

android {
    // Fixed for the life of the app: changing either makes Android treat the
    // next build as a different app and the old data is left behind.
    namespace = "nz.mileagelog.app"
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
        applicationId = "nz.mileagelog.app"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        // versionCode must go up on every build that is installed as an
        // update; CI passes the run number as --build-number.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = file(signingValue("storeFile")!!)
                storePassword = signingValue("storePassword")
                keyAlias = signingValue("keyAlias")
                keyPassword = signingValue("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) signingConfigs.getByName("release")
                            else signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
