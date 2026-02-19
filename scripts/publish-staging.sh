#!/bin/bash
# Publish to Sonatype staging repository

echo "Publishing to Sonatype Staging"
echo "=================================="
echo ""

# Check prerequisites
echo "Prerequisites:"
echo "  Sonatype account created and approved"
echo "  Credentials in gradle.properties"
echo "  GPG key generated and published"
echo ""

# Check if gradle.properties exists
if [ ! -f "gradle.properties" ]; then
    echo "gradle.properties not found"
    echo "Create it with your Sonatype credentials"
    exit 1
fi

# Check if credentials are set
if ! grep -q "ossrhUsername" gradle.properties; then
    echo "ossrhUsername not found in gradle.properties"
    exit 1
fi

if ! grep -q "ossrhPassword" gradle.properties; then
    echo "ossrhPassword not found in gradle.properties"
    exit 1
fi

# Confirm
read -p "Continue with publishing? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 0
fi

# Build and sign
echo ""
echo "Building and signing..."
./gradlew clean :library:assembleRelease

if [ $? -ne 0 ]; then
    echo "Build failed"
    exit 1
fi

# Publish
echo ""
echo "Publishing to staging..."
./gradlew :library:publishReleasePublicationToSonatypeRepository

if [ $? -ne 0 ]; then
    echo "Publishing failed"
    exit 1
fi

# Success
echo ""
echo "Published to staging!"
echo ""
echo "Next steps (MANUAL):"
echo "  1. Go to https://s01.oss.sonatype.org/"
echo "  2. Login with your credentials"
echo "  3. Click 'Staging Repositories'"
echo "  4. Find 'mxvaldora-XXXX'"
echo "  5. Select it and click 'Close'"
echo "  6. Wait for validation (~5 min)"
echo "  7. Click 'Release'"
echo "  8. Wait for sync to Maven Central (~30 min)"
echo ""
echo "Verify at: https://repo1.maven.org/maven2/mx/valdora/whisper-android/"
