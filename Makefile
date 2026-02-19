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
	@echo "Release AAR created:"
	@ls -lh library/build/outputs/aar/library-release.aar

clean:
	@echo "Cleaning build artifacts..."
	./gradlew clean
	@rm -rf library/build
	@echo "Clean complete"

install:
	@echo "Installing to Maven Local (~/.m2)..."
	./gradlew :library:publishToMavenLocal
	@echo "Installed to ~/.m2/repository/mx/valdora/whisper-android/"

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
	@./scripts/gpg-setup.sh

verify-pom:
	@./scripts/verify-pom.sh

publish-staging:
	@./scripts/publish-staging.sh

# Quick commands
all: clean release

.DEFAULT_GOAL := help
