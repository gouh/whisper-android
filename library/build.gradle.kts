plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
    id("maven-publish")
    id("signing")
    id("com.gradleup.nmcp") version "0.0.4"
}

android {
    namespace = "mx.valdora.whisper"
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
            groupId = "mx.valdora"
            artifactId = "whisper-android"
            version = "1.0.0"
            
            afterEvaluate {
                from(components["release"])
            }
            
            pom {
                name.set("Whisper Android")
                description.set("Offline speech-to-text library for Android using whisper.cpp")
                url.set("https://github.com/gouh/whisper-android")
                
                licenses {
                    license {
                        name.set("MIT License")
                        url.set("https://opensource.org/licenses/MIT")
                    }
                }
                
                developers {
                    developer {
                        id.set("gouh")
                        name.set("Hugo Hernández Valdez")
                        email.set("hugohv10@gmail.com")
                    }
                }
                
                scm {
                    connection.set("scm:git:git://github.com/gouh/whisper-android.git")
                    developerConnection.set("scm:git:ssh://github.com/gouh/whisper-android.git")
                    url.set("https://github.com/gouh/whisper-android")
                }
            }
        }
    }
    
    repositories {
        maven {
            name = "central"
            url = uri("https://central.sonatype.com/api/v1/publisher/upload")
            
            credentials {
                username = project.findProperty("ossrhUsername") as String? ?: System.getenv("OSSRH_USERNAME")
                password = project.findProperty("ossrhPassword") as String? ?: System.getenv("OSSRH_PASSWORD")
            }
        }
    }
}

signing {
    sign(publishing.publications["release"])
}

nmcp {
    publishAllPublications {
        username = project.findProperty("ossrhUsername") as String? ?: System.getenv("OSSRH_USERNAME")
        password = project.findProperty("ossrhPassword") as String? ?: System.getenv("OSSRH_PASSWORD")
        publicationType = "AUTOMATIC"
    }
}
