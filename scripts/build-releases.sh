#!/usr/bin/env bash
# Script to build noemoji for multiple platforms

set -e

# Configuration
VERSION="${1:-dev}"
PROJECT_NAME="noemoji"
BUILD_DIR="releases"
OPTIMIZE="ReleaseFast"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Platform targets (platform:zig-target)
PLATFORMS=(
    "macos-x86_64:x86_64-macos"
    "macos-arm64:aarch64-macos"
    "linux-x86_64:x86_64-linux-musl"
    "linux-arm64:aarch64-linux-musl"
    "windows-x86_64:x86_64-windows"
)

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                               ║${NC}"
echo -e "${BLUE}║          Building ${PROJECT_NAME} v${VERSION} for all platforms          ║${NC}"
echo -e "${BLUE}║                                                               ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo

# Clean and create build directory
echo -e "${YELLOW}[1/4] Cleaning build directory...${NC}"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Build for each target
echo -e "${YELLOW}[2/4] Building binaries...${NC}"
for entry in "${PLATFORMS[@]}"; do
    platform="${entry%%:*}"
    target="${entry##*:}"
    output_dir="${BUILD_DIR}/${PROJECT_NAME}-${VERSION}-${platform}"
    binary_name="${PROJECT_NAME}"
    
    # Add .exe extension for Windows
    if [[ "$platform" == *"windows"* ]]; then
        binary_name="${binary_name}.exe"
    fi
    
    echo -e "${GREEN}  → Building for ${platform} (${target})...${NC}"
    
    # Create output directory
    mkdir -p "${output_dir}"
    
    # Build with Zig
    zig build -Doptimize=${OPTIMIZE} -Dtarget=${target} 2>&1 | grep -v "^info:" || true
    
    # Copy binary to output directory
    if [[ "$platform" == *"windows"* ]]; then
        cp "zig-out/bin/${PROJECT_NAME}.exe" "${output_dir}/${binary_name}"
    else
        cp "zig-out/bin/${PROJECT_NAME}" "${output_dir}/${binary_name}"
    fi
    
    # Copy additional files
    cp README.md "${output_dir}/" 2>/dev/null || true
    cp LICENSE "${output_dir}/" 2>/dev/null || echo "# License file not found" > "${output_dir}/LICENSE"
    
    # Get binary size
    size=$(du -h "${output_dir}/${binary_name}" | cut -f1)
    echo -e "    ${GREEN}✓${NC} Built: ${output_dir}/${binary_name} (${size})"
done

# Create archives
echo -e "${YELLOW}[3/4] Creating archives...${NC}"
cd "${BUILD_DIR}"

for entry in "${PLATFORMS[@]}"; do
    platform="${entry%%:*}"
    dir_name="${PROJECT_NAME}-${VERSION}-${platform}"
    
    if [[ "$platform" == *"windows"* ]]; then
        # Create ZIP for Windows
        archive_name="${dir_name}.zip"
        echo -e "${GREEN}  → Creating ${archive_name}...${NC}"
        zip -q -r "${archive_name}" "${dir_name}"
    else
        # Create tar.gz for Unix systems
        archive_name="${dir_name}.tar.gz"
        echo -e "${GREEN}  → Creating ${archive_name}...${NC}"
        tar -czf "${archive_name}" "${dir_name}"
    fi
    
    size=$(du -h "${archive_name}" | cut -f1)
    echo -e "    ${GREEN}✓${NC} Created: ${archive_name} (${size})"
done

cd ..

# Generate checksums
echo -e "${YELLOW}[4/4] Generating checksums...${NC}"
cd "${BUILD_DIR}"

# SHA256 checksums
{
    echo "# SHA256 Checksums for ${PROJECT_NAME} v${VERSION}"
    echo "# Generated on $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    echo ""
    
    for archive in *.tar.gz *.zip; do
        if [ -f "$archive" ]; then
            if command -v shasum &> /dev/null; then
                shasum -a 256 "$archive"
            else
                sha256sum "$archive"
            fi
        fi
    done
} > "SHA256SUMS.txt"

echo -e "${GREEN}  ✓ SHA256 checksums saved to SHA256SUMS.txt${NC}"

cd ..

# Summary
echo
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                               ║${NC}"
echo -e "${BLUE}║                    BUILD COMPLETE! 🎉                         ║${NC}"
echo -e "${BLUE}║                                                               ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo
echo -e "${GREEN}Build artifacts:${NC}"
ls -lh "${BUILD_DIR}"/*.tar.gz "${BUILD_DIR}"/*.zip 2>/dev/null || true
echo
echo -e "${YELLOW}Checksums:${NC}"
cat "${BUILD_DIR}/SHA256SUMS.txt"
echo
echo -e "${GREEN}All release files are in: ${BUILD_DIR}/${NC}"
echo -e "${GREEN}Ready to publish! 🚀${NC}"
