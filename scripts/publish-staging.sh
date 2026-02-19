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
echo "Publishing to Central Portal..."
./gradlew publishAllPublicationsToCentralPortal

if [ $? -ne 0 ]; then
    echo "Publishing failed"
    exit 1
fi

# Success
echo ""
echo "Published to Central Portal!"
echo ""
echo "Next steps:"
echo "  1. Go to https://central.sonatype.com/publishing/deployments"
echo "  2. Check deployment status"
echo "  3. If PENDING, it will auto-publish in ~10 minutes"
echo "  4. Wait for sync to Maven Central (~30 min)"
echo ""
echo "Verify at: https://repo1.maven.org/maven2/mx/valdora/whisper-android/"
