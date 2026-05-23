# Android Configuration Files

## android/build.gradle  (project-level)
```gradle
buildscript {
    ext.kotlin_version = '1.9.0'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath 'com.google.gms:google-services:4.4.0'   // ← ADD THIS
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

---

## android/app/build.gradle  (app-level)
```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id 'com.google.gms.google-services'   // ← ADD THIS
}

android {
    namespace "com.example.studypulse"
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.example.studypulse"
        minSdkVersion 21          // ← Must be 21 or higher for Firebase
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
}
```

---

## Place google-services.json here:
`android/app/google-services.json`

Download this file from:
Firebase Console → Your Project → Project Settings → Your Apps → Android → Download google-services.json
