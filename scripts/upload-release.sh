#!/usr/bin/env bash
# Script to upload release artifacts to GitHub using gh CLI

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 0.1.0"
    exit 1
fi

VERSION="$1"
TAG="v${VERSION}"
RELEASES_DIR="releases"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed"
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Check if releases directory exists
if [ ! -d "$RELEASES_DIR" ]; then
    echo "Error: Releases directory not found"
    echo "Run './scripts/build-releases.sh ${VERSION}' first"
    exit 1
fi

echo "Uploading release artifacts for version ${VERSION}..."
echo

# Check if tag exists
if ! git rev-parse "${TAG}" >/dev/null 2>&1; then
    echo "Creating tag ${TAG}..."
    git tag -a "${TAG}" -m "Release version ${VERSION}"
    git push origin "${TAG}"
    echo "Tag ${TAG} created and pushed"
else
    echo "Tag ${TAG} already exists"
fi

# Check if release exists
if gh release view "${TAG}" >/dev/null 2>&1; then
    echo "Release ${TAG} already exists. Uploading additional assets..."
    gh release upload "${TAG}" \
        "${RELEASES_DIR}"/*.tar.gz \
        "${RELEASES_DIR}"/*.zip \
        "${RELEASES_DIR}"/SHA256SUMS.txt \
        --clobber
else
    echo "Creating new release ${TAG}..."
    
    # Create release notes
    NOTES="## Installation

### Homebrew (macOS/Linux)
\`\`\`bash
brew tap thanos/tap
brew install noemoji
\`\`\`

### Manual Installation

Download the appropriate archive for your platform from the assets below.

#### Verify checksums:
\`\`\`bash
sha256sum -c SHA256SUMS.txt
\`\`\`

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for details.
"
    
    gh release create "${TAG}" \
        "${RELEASES_DIR}"/*.tar.gz \
        "${RELEASES_DIR}"/*.zip \
        "${RELEASES_DIR}"/SHA256SUMS.txt \
        --title "Release ${VERSION}" \
        --notes "${NOTES}" \
        --draft=false \
        --latest
fi

echo
echo "✓ Release ${TAG} published successfully!"
echo "View at: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/releases/tag/${TAG}"
