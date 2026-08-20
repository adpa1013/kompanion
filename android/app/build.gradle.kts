import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        load(FileInputStream(keystorePropertiesFile))
    }
}

android {
    namespace = "com.example.kompanion"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.kompanion"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val storeFilePath = System.getenv("KEYSTORE_FILE") 
                ?: keystoreProperties.getProperty("storeFile") 
                ?: "release.jks"
            val resolvedFile = rootProject.file(storeFilePath)
            val finalStoreFile = if (resolvedFile.exists()) resolvedFile else file(storeFilePath)

            val pass = System.getenv("KEYSTORE_PASSWORD") 
                ?: System.getenv("STORE_PASSWORD") 
                ?: keystoreProperties.getProperty("storePassword")

            val alias = System.getenv("KEY_ALIAS") 
                ?: keystoreProperties.getProperty("keyAlias") 
                ?: "kompanion"

            val keyPass = System.getenv("KEY_PASSWORD") 
                ?: keystoreProperties.getProperty("keyPassword") 
                ?: pass

            if (finalStoreFile.exists() && !pass.isNullOrEmpty()) {
                storeFile = finalStoreFile
                storePassword = pass
                keyAlias = alias
                keyPassword = keyPass
            }
        }
    }

    buildTypes {
        release {
            val releaseConfig = signingConfigs.getByName("release")
            signingConfig = if (releaseConfig.storeFile != null && releaseConfig.storePassword != null) {
                releaseConfig
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

