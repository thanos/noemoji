#!/usr/bin/env bash
# Script to update the Homebrew formula with a new release

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 0.1.0"
    exit 1
fi

VERSION="$1"
FORMULA="noemoji.rb"
GITHUB_USER="thanos"
REPO="noemoji"

echo "Updating Homebrew formula for version v${VERSION}..."

# Construct the tarball URL
TARBALL_URL="https://github.com/${GITHUB_USER}/${REPO}/archive/refs/tags/v${VERSION}.tar.gz"

echo "Downloading tarball from: ${TARBALL_URL}"

# Download and calculate SHA256
SHA256=$(curl -sL "${TARBALL_URL}" | shasum -a 256 | awk '{print $1}')

if [ -z "$SHA256" ]; then
    echo "Error: Failed to download tarball or calculate SHA256"
    exit 1
fi

echo "Calculated SHA256: ${SHA256}"

# Update the formula file
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|url \".*\"|url \"${TARBALL_URL}\"|g" "${FORMULA}"
    sed -i '' "s|sha256 \".*\"|sha256 \"${SHA256}\"|g" "${FORMULA}"
else
    # Linux
    sed -i "s|url \".*\"|url \"${TARBALL_URL}\"|g" "${FORMULA}"
    sed -i "s|sha256 \".*\"|sha256 \"${SHA256}\"|g" "${FORMULA}"
fi

echo "✓ Formula updated successfully!"
echo ""
echo "Next steps:"
echo "1. Review the changes: git diff ${FORMULA}"
echo "2. Test the formula: brew install --build-from-source ./${FORMULA}"
echo "3. Run tests: brew test noemoji"
echo "4. Commit the changes: git add ${FORMULA} && git commit -m 'Update formula to v${VERSION}'"
echo "5. Push to your tap repository"
