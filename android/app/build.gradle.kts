import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.bufferedReader().use { reader ->
        localProperties.load(reader)
    }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode")?.toInt() ?: 1
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { stream ->
        keystoreProperties.load(stream)
    }
}

val keystorePath_ = keystoreProperties["storeFile"] as? String
    ?: System.getenv("KEYSTORE_PATH")
val storePassword_ = keystoreProperties["storePassword"] as? String
    ?: System.getenv("KEYSTORE_PASSWORD")
val keyAlias_ = keystoreProperties["keyAlias"] as? String
    ?: System.getenv("KEY_ALIAS")
val keyPassword_ = keystoreProperties["keyPassword"] as? String
    ?: System.getenv("KEY_PASSWORD")

android {
    namespace = "com.sn8z.poddr"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.14206865"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.sn8z.poddr"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode
        versionName = flutterVersionName
    }

    signingConfigs {
        register("release") {
            val storePath = keystorePath_
            if (storePath != null && file(storePath).exists()) {
                storeFile = file(storePath)
                storePassword = storePassword_
                keyAlias = keyAlias_
                keyPassword = keyPassword_
            }
        }
    }

    buildTypes {
        release {
            if (signingConfigs.getByName("release").storeFile != null) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
