.PHONY: help build clean install test publish release

help:
	@echo "Whisper Android Library - Make Commands"
	@echo ""
	@echo "Build:"
	@echo "  make build          - Build debug AAR"
	@echo "  make release        - Build release AAR"
	@echo "  make clean          - Clean build artifacts"
	@echo ""
	@echo "Install:"
	@echo "  make install        - Install AAR to local Maven (~/.m2)"
	@echo "  make install-local  - Copy AAR to libs/ folder"
	@echo ""
	@echo "Test:"
	@echo "  make test           - Run unit tests"
	@echo "  make lint           - Run Android lint"
	@echo ""
	@echo "Publish:"
	@echo "  make publish        - Publish to Maven Local"
	@echo "  make jitpack        - Prepare for JitPack release"
	@echo ""
	@echo "Info:"
	@echo "  make info           - Show library info"
	@echo "  make size           - Show AAR size"

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
	@echo "✅ Installed to ~/.m2/repository/com/whispercpp/android/"

install-local:
	@echo "Copying AAR to libs/ folder..."
	@mkdir -p libs
	@cp library/build/outputs/aar/library-release.aar libs/whisper-android.aar
	@echo "✅ Copied to libs/whisper-android.aar"
	@ls -lh libs/whisper-android.aar

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

jitpack:
	@echo "Preparing for JitPack..."
	@echo "1. Commit and push all changes"
	@echo "2. Create a git tag: git tag v1.0.0"
	@echo "3. Push tag: git push origin v1.0.0"
	@echo "4. Visit: https://jitpack.io/#yourusername/whisper-android"
	@echo ""
	@echo "Usage in other projects:"
	@echo "  repositories { maven { url 'https://jitpack.io' } }"
	@echo "  dependencies { implementation 'com.github.yourusername:whisper-android:v1.0.0' }"

info:
	@echo "Whisper Android Library Info"
	@echo "=============================="
	@echo "Package: com.whispercpp.android"
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

# Quick commands
all: clean release

.DEFAULT_GOAL := help
