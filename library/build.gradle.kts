plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
    id("maven-publish")
}

android {
    namespace = "com.whispercpp.android"
    compileSdk = 34

    defaultConfig {
        minSdk = 24
        
        externalNativeBuild {
            cmake {
                cppFlags += "-std=c++17"
                arguments += listOf(
                    "-DANDROID_STL=c++_shared"
                )
            }
        }
        
        ndk {
            abiFilters += listOf("arm64-v8a", "x86_64")
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }
    
    externalNativeBuild {
        cmake {
            path = file("src/main/jni/CMakeLists.txt")
            version = "3.22.1"
        }
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
}

publishing {
    publications {
        create<MavenPublication>("release") {
            groupId = "com.whispercpp"
            artifactId = "whisper-android"
            version = "1.0.0"
            
            afterEvaluate {
                from(components["release"])
            }
            
            pom {
                name.set("Whisper Android")
                description.set("Offline speech-to-text library for Android using whisper.cpp")
                url.set("https://github.com/yourusername/whisper-android")
                
                licenses {
                    license {
                        name.set("MIT License")
                        url.set("https://opensource.org/licenses/MIT")
                    }
                }
                
                developers {
                    developer {
                        id.set("yourusername")
                        name.set("Your Name")
                    }
                }
            }
        }
    }
}
