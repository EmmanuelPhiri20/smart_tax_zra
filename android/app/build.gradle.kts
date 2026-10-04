plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.smartpay.zra"
    compileSdk = 36

    // ✅ NDK version (must match your SDK folder version)
    ndkVersion = "29.0.14206865"

    defaultConfig {
        applicationId = "com.smartpay.zra"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    // ✅ Source folder for MainActivity.kt
    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    buildTypes {
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.22")
    implementation(platform("com.google.firebase:firebase-bom:34.3.0"))
    implementation("com.google.firebase:firebase-analytics")
}

//
// ✅ APK COPY FIX — ensures Flutter detects the APK in correct path
//
afterEvaluate {
    tasks.matching { it.name == "assembleDebug" }.all {
        doLast {
            val source = "$buildDir/outputs/flutter-apk/app-debug.apk"
            val destination = "$rootDir/../build/app/outputs/flutter-apk/"

            val sourceFile = file(source)
            if (sourceFile.exists()) {
                copy {
                    from(source)
                    into(destination)
                }
                println("✅ APK copied to: $destination")
            } else {
                println("⚠️ APK not found at: $source")
            }
        }
    }
}
