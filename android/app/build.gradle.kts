import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

/**
 * Loads environment properties from a project-level env file and overlays select system environment variables.
 *
 * Reads the first existing file among "../.env.local" and "../.env", parses lines of the form `KEY=VALUE`
 * (ignoring blank lines and lines starting with `#`), and then overrides or adds values for `AUTH0_DOMAIN`
 * and `APP_SCHEME` from the process environment if present and non-blank. Keys and values are trimmed.
 *
 * @return A map of environment property names to their string values. Values from system environment for
 * `AUTH0_DOMAIN` and `APP_SCHEME` take precedence over values loaded from the env file.
 */
fun loadEnv(): Map<String, String> {
    val properties = mutableMapOf<String, String>()

    val envFiles = listOf(
        rootProject.file("../.env.local"),
        rootProject.file("../.env")
    )

    for (envFile in envFiles) {
        if (envFile.exists()) {
            envFile.inputStream().use { stream ->
                stream.bufferedReader().forEachLine { line ->
                    if (line.isNotBlank() && !line.startsWith("#") && line.contains("=")) {
                        val (key, value) = line.split("=", limit = 2)
                        properties[key.trim()] = value.trim()
                    }
                }
            }
            break
        }
    }

    listOf("AUTH0_DOMAIN", "APP_SCHEME").forEach { key ->
        System.getenv(key)?.let { value ->
            if (value.isNotBlank()) {
                properties[key] = value
            }
        }
    }

    return properties
}

val envProperties = loadEnv()

android {
    namespace = "com.kin.kin"
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
        applicationId = "com.kin.kin"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Auth0 configuration - loaded from env vars or .env file
        val auth0Domain = envProperties["AUTH0_DOMAIN"] ?: ""
        val auth0Scheme = envProperties["APP_SCHEME"] ?: applicationId!!

        manifestPlaceholders["auth0Domain"] = auth0Domain
        manifestPlaceholders["auth0Scheme"] = auth0Scheme
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