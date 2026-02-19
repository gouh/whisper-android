# Publicación de whisper-android en Maven Central

Guía paso a paso para publicar la librería en Maven Central.

## Requisitos Previos

1. **Cuenta en Sonatype**
   - Crear cuenta en https://issues.sonatype.org/
   - Crear un ticket JIRA para reclamar el groupId `mx.valdora`
   - Esperar aprobación (1-2 días hábiles)

2. **GPG Key para firmar artefactos**
   ```bash
   # Generar key
   gpg --gen-key
   
   # Listar keys
   gpg --list-keys
   
   # Publicar key al servidor
   gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID
   ```

3. **Credenciales de Sonatype**
   - Username y password de tu cuenta Sonatype
   - Token de acceso (recomendado)

## Paso 1: Configurar Gradle

### 1.1 Actualizar `library/build.gradle.kts`

```kotlin
plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
    id("maven-publish")
    id("signing")
}

// ... configuración existente ...

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
            name = "sonatype"
            val releasesRepoUrl = uri("https://s01.oss.sonatype.org/service/local/staging/deploy/maven2/")
            val snapshotsRepoUrl = uri("https://s01.oss.sonatype.org/content/repositories/snapshots/")
            url = if (version.toString().endsWith("SNAPSHOT")) snapshotsRepoUrl else releasesRepoUrl
            
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
```

### 1.2 Crear `gradle.properties` local (NO subir a Git)

```properties
# ~/.gradle/gradle.properties o project/gradle.properties (en .gitignore)

ossrhUsername=tu_usuario_sonatype
ossrhPassword=tu_password_sonatype

signing.keyId=LAST_8_CHARS_OF_KEY_ID
signing.password=tu_gpg_password
signing.secretKeyRingFile=/Users/hugh/.gnupg/secring.gpg
```

### 1.3 Actualizar `.gitignore`

```
# Credentials
gradle.properties
local.properties
```

## Paso 2: Preparar el Release

### 2.1 Verificar que todo compila

```bash
./gradlew clean :library:assembleRelease
```

### 2.2 Generar documentación (opcional)

```bash
./gradlew :library:dokkaHtml
```

### 2.3 Verificar POM

```bash
./gradlew :library:generatePomFileForReleasePublication
cat library/build/publications/release/pom-default.xml
```

## Paso 3: Publicar a Staging

### 3.1 Publicar artefactos

```bash
./gradlew :library:publishReleasePublicationToSonatypeRepository
```

### 3.2 Verificar en Sonatype Nexus

1. Ir a https://s01.oss.sonatype.org/
2. Login con tus credenciales
3. Click en "Staging Repositories"
4. Buscar `mxvaldora-XXXX`
5. Verificar contenido:
   - `.aar` file
   - `.pom` file
   - `-sources.jar`
   - `-javadoc.jar` (si aplica)
   - Todos los archivos `.asc` (firmas GPG)

## Paso 4: Release a Maven Central

### 4.1 Cerrar el Staging Repository

```bash
# Opción 1: Desde Nexus UI
# - Seleccionar el repository
# - Click "Close"
# - Esperar validación (~5 minutos)

# Opción 2: Con Gradle plugin
./gradlew closeAndReleaseRepository
```

### 4.2 Release

```bash
# Desde Nexus UI:
# - Seleccionar el repository cerrado
# - Click "Release"
# - Confirmar

# O con Gradle:
./gradlew releaseRepository
```

### 4.3 Esperar sincronización

- Maven Central: 10-30 minutos
- Búsqueda en Maven Central: 2-4 horas
- Disponible en: https://repo1.maven.org/maven2/mx/valdora/whisper-android/

## Paso 5: Verificar Publicación

### 5.1 Buscar en Maven Central

```
https://search.maven.org/artifact/mx.valdora/whisper-android/1.0.0/aar
```

### 5.2 Probar en un proyecto

```gradle
repositories {
    mavenCentral()
}

dependencies {
    implementation 'mx.valdora:whisper-android:1.0.0'
}
```

## Paso 6: Crear Release en GitHub

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

En GitHub:
1. Ir a "Releases"
2. "Create a new release"
3. Seleccionar tag `v1.0.0`
4. Título: "v1.0.0 - Initial Release"
5. Descripción: Changelog
6. Adjuntar `.aar` file
7. Publicar

## Troubleshooting

### Error: "No valid key found"

```bash
# Exportar key en formato legacy
gpg --export-secret-keys -o ~/.gnupg/secring.gpg
```

### Error: "401 Unauthorized"

- Verificar credenciales en `gradle.properties`
- Verificar que el ticket JIRA esté aprobado
- Usar token en lugar de password

### Error: "Signature validation failed"

```bash
# Verificar que la key esté publicada
gpg --keyserver keyserver.ubuntu.com --recv-keys YOUR_KEY_ID

# Re-publicar si es necesario
gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID
```

### Error: "Repository already exists"

- Eliminar el staging repository fallido en Nexus UI
- Incrementar versión o usar `-SNAPSHOT`

## Automatización con GitHub Actions

Crear `.github/workflows/publish.yml`:

```yaml
name: Publish to Maven Central

on:
  release:
    types: [created]

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'corretto'
      
      - name: Setup Android SDK
        uses: android-actions/setup-android@v2
      
      - name: Publish to Maven Central
        env:
          OSSRH_USERNAME: ${{ secrets.OSSRH_USERNAME }}
          OSSRH_PASSWORD: ${{ secrets.OSSRH_PASSWORD }}
          SIGNING_KEY_ID: ${{ secrets.SIGNING_KEY_ID }}
          SIGNING_PASSWORD: ${{ secrets.SIGNING_PASSWORD }}
          SIGNING_KEY: ${{ secrets.SIGNING_KEY }}
        run: |
          echo "$SIGNING_KEY" | base64 -d > ~/.gnupg/secring.gpg
          ./gradlew publishReleasePublicationToSonatypeRepository
```

## Recursos

- [Sonatype OSSRH Guide](https://central.sonatype.org/publish/publish-guide/)
- [Maven Central Requirements](https://central.sonatype.org/publish/requirements/)
- [GPG Signing Guide](https://central.sonatype.org/publish/requirements/gpg/)
- [Gradle Maven Publish Plugin](https://docs.gradle.org/current/userguide/publishing_maven.html)

## Checklist Final

- [ ] Cuenta Sonatype creada y aprobada
- [ ] GPG key generada y publicada
- [ ] `build.gradle.kts` configurado con POM completo
- [ ] Credenciales en `gradle.properties` (local, no en Git)
- [ ] Compilación exitosa
- [ ] Publicación a staging exitosa
- [ ] Validación en Nexus UI
- [ ] Release a Maven Central
- [ ] Verificación en Maven Central Search
- [ ] Tag y release en GitHub
- [ ] Actualizar README con instrucciones de Maven Central
