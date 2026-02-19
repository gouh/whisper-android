#!/bin/bash
# GPG Setup for Maven Central signing

echo "🔐 GPG Key Setup for Maven Central"
echo "===================================="
echo ""

# Check if GPG is installed
if ! command -v gpg &> /dev/null; then
    echo "❌ GPG not found. Install with: brew install gnupg"
    exit 1
fi

echo "Current GPG keys:"
gpg --list-keys --keyid-format SHORT

echo ""
echo "📝 Setup Steps:"
echo ""
echo "1. Generate GPG key (if you don't have one):"
echo "   gpg --gen-key"
echo ""
echo "2. Get your key ID:"
echo "   gpg --list-keys --keyid-format SHORT"
echo "   (Use the 8-character ID after 'rsa3072/')"
echo ""
echo "3. Publish key to server:"
echo "   gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID"
echo ""
echo "4. Export secret key:"
echo "   gpg --export-secret-keys -o ~/.gnupg/secring.gpg"
echo ""
echo "5. Update gradle.properties with:"
echo "   signing.keyId=YOUR_8_CHAR_KEY_ID"
echo "   signing.password=YOUR_GPG_PASSWORD"
echo "   signing.secretKeyRingFile=$HOME/.gnupg/secring.gpg"
echo ""
echo "Need help? See MAVEN_PUBLISH.md for detailed instructions"
