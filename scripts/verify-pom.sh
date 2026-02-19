#!/bin/bash
# Verify POM configuration before publishing

echo "Verifying POM Configuration"
echo "==============================="
echo ""

# Generate POM
echo "Generating POM file..."
./gradlew :library:generatePomFileForReleasePublication

if [ ! -f "library/build/publications/release/pom-default.xml" ]; then
    echo "POM file not found"
    exit 1
fi

echo ""
echo "POM Content:"
echo "============"
cat library/build/publications/release/pom-default.xml

echo ""
echo ""
echo "Checklist:"
echo "  [ ] groupId: mx.valdora"
echo "  [ ] artifactId: whisper-android"
echo "  [ ] version: 1.0.0"
echo "  [ ] name and description present"
echo "  [ ] url: https://github.com/gouh/whisper-android"
echo "  [ ] license: MIT"
echo "  [ ] developer info correct"
echo "  [ ] SCM info correct"
echo ""
echo "If everything looks good, proceed with: make publish-staging"
