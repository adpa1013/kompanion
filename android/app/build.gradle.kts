import java.io.FileInputStream
import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

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
    namespace = "com.adpa1013.kompanion"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.adpa1013.kompanion"
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
            // F-Droid's build pipeline strips the signingConfigs block entirely before
            // building, so "release" may not exist there - findByName instead of
            // getByName avoids a hard failure in that case.
            val releaseConfig = signingConfigs.findByName("release")
            signingConfig = if (releaseConfig?.storeFile != null && releaseConfig.storePassword != null) {
                releaseConfig
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }

    // AGP embeds a "Dependency metadata" block (Gradle dependency names/versions,
    // meant for Play Console) directly into the APK's signing block by default.
    // F-Droid's scanner rejects any unrecognized signing block, so disable it.
    dependenciesInfo {
        includeInApk = false
        includeInBundle = false
    }
}

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

