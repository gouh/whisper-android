# Guía Rápida: Publicar en Maven Central

## ✅ Configuración Completada

- [x] Credenciales en `gradle.properties` (local, no en Git)
- [x] `.gitignore` protege credenciales
- [x] `build.gradle.kts` configurado con POM y signing
- [x] Makefile con comandos automatizados

## 📋 Pasos para Publicar

### Paso 1: Setup GPG (Solo una vez)

```bash
make gpg-setup
```

Sigue las instrucciones para:
1. Generar GPG key
2. Publicar key al servidor
3. Actualizar `gradle.properties` con los datos de la key

### Paso 2: Verificar Configuración

```bash
make verify-pom
```

Revisa que toda la información del POM sea correcta.

### Paso 3: Publicar a Staging (Automatizado)

```bash
make publish-staging
```

Este comando:
- Limpia el proyecto
- Compila release AAR
- Firma con GPG
- Publica a Sonatype staging

### Paso 4: Release en Sonatype (Manual)

1. Ir a https://s01.oss.sonatype.org/
2. Login con:
   - Username: `xA2pRb`
   - Password: `O9Dp5uU7FfjsXhe5luehxHdyR2YxsLgUj`
3. Click "Staging Repositories"
4. Buscar `mxvaldora-XXXX`
5. Seleccionar y click "Close"
6. Esperar validación (~5 minutos)
7. Click "Release"

### Paso 5: Verificar Publicación

Esperar 30 minutos y verificar en:
```
https://repo1.maven.org/maven2/mx/valdora/whisper-android/1.0.0/
```

Buscar en Maven Central:
```
https://search.maven.org/artifact/mx.valdora/whisper-android/1.0.0/aar
```

## 🔐 Seguridad

**NUNCA subir a Git:**
- `gradle.properties` - Contiene credenciales
- `*.gpg` - Keys GPG
- `secring.gpg` - Secret keyring

Estos archivos están protegidos en `.gitignore`.

## 🛠️ Comandos Útiles

```bash
# Desarrollo local
make build          # Compilar debug
make release        # Compilar release
make publish        # Publicar a Maven Local

# Maven Central
make gpg-setup      # Configurar GPG
make verify-pom     # Verificar POM
make publish-staging # Publicar a staging

# Info
make info           # Info de la librería
make size           # Tamaño del AAR
```

## 📝 Notas

- Las credenciales ya están en `gradle.properties` (local)
- Solo falta configurar GPG key para firmar
- Los pasos 4 y 5 son manuales desde Sonatype UI
- Primera publicación puede tardar más en ser aprobada
