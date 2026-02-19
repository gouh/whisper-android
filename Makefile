.PHONY: help build clean install test publish release gpg-setup verify-pom publish-staging

help:
	@echo "Whisper Android Library - Make Commands"
	@echo ""
	@echo "Build:"
	@echo "  make build           - Build debug AAR"
	@echo "  make release         - Build release AAR"
	@echo "  make clean           - Clean build artifacts"
	@echo ""
	@echo "Local Publishing:"
	@echo "  make install         - Install AAR to local Maven (~/.m2)"
	@echo "  make publish         - Publish to Maven Local"
	@echo ""
	@echo "Maven Central Publishing:"
	@echo "  make gpg-setup       - Setup GPG key for signing"
	@echo "  make verify-pom      - Verify POM configuration"
	@echo "  make publish-staging - Publish to Sonatype staging (Step 3)"
	@echo ""
	@echo "Test:"
	@echo "  make test            - Run unit tests"
	@echo "  make lint            - Run Android lint"
	@echo ""
	@echo "Info:"
	@echo "  make info            - Show library info"
	@echo "  make size            - Show AAR size"

build:
	@echo "Building debug AAR..."
	./gradlew :library:assembleDebug

release:
	@echo "Building release AAR..."
	./gradlew :library:assembleRelease
	@echo ""
	@echo "✅ Release AAR created:"
	@ls -lh library/build/outputs/aar/library-release.aar

clean:
	@echo "Cleaning build artifacts..."
	./gradlew clean
	@rm -rf library/build
	@echo "✅ Clean complete"

install:
	@echo "Installing to Maven Local (~/.m2)..."
	./gradlew :library:publishToMavenLocal
	@echo "✅ Installed to ~/.m2/repository/mx/valdora/whisper-android/"

test:
	@echo "Running unit tests..."
	./gradlew :library:testDebugUnitTest

lint:
	@echo "Running Android lint..."
	./gradlew :library:lintDebug
	@echo "Report: library/build/reports/lint-results-debug.html"

publish:
	@echo "Publishing to Maven Local..."
	./gradlew :library:publishToMavenLocal
	@echo ""
	@echo "To use in other projects:"
	@echo "  repositories { mavenLocal() }"
	@echo "  dependencies { implementation 'mx.valdora:whisper-android:1.0.0' }"

info:
	@echo "Whisper Android Library Info"
	@echo "=============================="
	@echo "Package: mx.valdora.whisper"
	@echo "Maven: mx.valdora:whisper-android:1.0.0"
	@echo "Min SDK: 24 (Android 7.0)"
	@echo "Compile SDK: 34"
	@echo "Architectures: arm64-v8a, x86_64"
	@echo ""
	@echo "Main Classes:"
	@echo "  - WhisperContext (Kotlin wrapper)"
	@echo "  - WhisperLib (JNI interface)"
	@echo ""
	@echo "Native Libraries:"
	@echo "  - libwhisper_android.so"

size:
	@echo "AAR Sizes:"
	@echo "=========="
	@if [ -f library/build/outputs/aar/library-debug.aar ]; then \
		ls -lh library/build/outputs/aar/library-debug.aar | awk '{print "Debug:   " $$5}'; \
	fi
	@if [ -f library/build/outputs/aar/library-release.aar ]; then \
		ls -lh library/build/outputs/aar/library-release.aar | awk '{print "Release: " $$5}'; \
	fi
	@echo ""
	@echo "Native libraries:"
	@if [ -d library/build/intermediates/stripped_native_libs ]; then \
		find library/build/intermediates/stripped_native_libs -name "*.so" -exec ls -lh {} \; | awk '{print $$9 " - " $$5}'; \
	fi

# Maven Central Publishing Commands

gpg-setup:
	@echo "🔐 GPG Key Setup for Maven Central"
	@echo "===================================="
	@echo ""
	@echo "Step 1: Generate GPG key (if you don't have one)"
	@echo "  gpg --gen-key"
	@echo ""
	@echo "Step 2: List your keys"
	@gpg --list-keys --keyid-format SHORT || echo "No GPG keys found. Run: gpg --gen-key"
	@echo ""
	@echo "Step 3: Publish key to server"
	@echo "  gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID"
	@echo ""
	@echo "Step 4: Export secret key"
	@echo "  gpg --export-secret-keys -o ~/.gnupg/secring.gpg"
	@echo ""
	@echo "Step 5: Update gradle.properties with:"
	@echo "  signing.keyId=LAST_8_CHARS_OF_KEY_ID"
	@echo "  signing.password=YOUR_GPG_PASSWORD"
	@echo "  signing.secretKeyRingFile=/Users/hugh/.gnupg/secring.gpg"

verify-pom:
	@echo "📋 Verifying POM Configuration"
	@echo "==============================="
	@echo ""
	@echo "Generating POM file..."
	@./gradlew :library:generatePomFileForReleasePublication
	@echo ""
	@echo "POM Content:"
	@cat library/build/publications/release/pom-default.xml
	@echo ""
	@echo "✅ Check that all information is correct:"
	@echo "  - groupId: mx.valdora"
	@echo "  - artifactId: whisper-android"
	@echo "  - version: 1.0.0"
	@echo "  - name, description, url"
	@echo "  - license (MIT)"
	@echo "  - developer info"
	@echo "  - SCM info"

publish-staging:
	@echo "🚀 Publishing to Sonatype Staging"
	@echo "=================================="
	@echo ""
	@echo "Prerequisites:"
	@echo "  ✓ Sonatype account created and approved"
	@echo "  ✓ Credentials in gradle.properties"
	@echo "  ✓ GPG key generated and published"
	@echo ""
	@read -p "Continue? (y/n) " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "Building and signing..."; \
		./gradlew clean :library:assembleRelease; \
		echo ""; \
		echo "Publishing to staging..."; \
		./gradlew :library:publishReleasePublicationToSonatypeRepository; \
		echo ""; \
		echo "✅ Published to staging!"; \
		echo ""; \
		echo "Next steps (MANUAL):"; \
		echo "  1. Go to https://s01.oss.sonatype.org/"; \
		echo "  2. Login with your credentials"; \
		echo "  3. Click 'Staging Repositories'"; \
		echo "  4. Find 'mxvaldora-XXXX'"; \
		echo "  5. Select it and click 'Close'"; \
		echo "  6. Wait for validation (~5 min)"; \
		echo "  7. Click 'Release'"; \
		echo "  8. Wait for sync to Maven Central (~30 min)"; \
		echo ""; \
		echo "Verify at: https://repo1.maven.org/maven2/mx/valdora/whisper-android/"; \
	fi

# Quick commands
all: clean release

.DEFAULT_GOAL := help
