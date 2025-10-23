buildscript {
    // FIX: Define kotlinVersion before using it
    val kotlinVersion = "1.9.22"

    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://maven.google.com") }
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.2.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
        classpath("com.google.gms:google-services:4.4.3")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://maven.google.com") }
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}