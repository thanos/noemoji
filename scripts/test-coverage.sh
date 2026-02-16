#!/usr/bin/env bash
# Test coverage script using kcov

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COVERAGE_DIR="${PROJECT_ROOT}/coverage"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                              ║${NC}"
echo -e "${BLUE}║          noemoji Test Coverage Report                        ║${NC}"
echo -e "${BLUE}║                                                              ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo

# Check if kcov is installed
if ! command -v kcov &> /dev/null; then
    echo -e "${YELLOW}⚠ kcov is not installed${NC}"
    echo
    echo "Install kcov:"
    echo "  macOS:   brew install kcov"
    echo "  Linux:   apt-get install kcov  (Debian/Ubuntu)"
    echo "           dnf install kcov      (Fedora)"
    echo
    echo "Or build from source: https://github.com/SimonKagstrom/kcov"
    echo
    echo "Running tests without coverage..."
    cd "$PROJECT_ROOT"
    zig build test
    exit 0
fi

echo -e "${GREEN}✓ kcov found${NC}"
echo

# Clean previous coverage
echo "Cleaning previous coverage..."
rm -rf "$COVERAGE_DIR"
mkdir -p "$COVERAGE_DIR"

# Build tests in Debug mode for coverage
echo "Building tests..."
cd "$PROJECT_ROOT"
zig build test -Doptimize=Debug

# Find test binary in .zig-cache
echo "Locating test binary..."
TEST_BINARY=$(find .zig-cache -name "test" -type f -executable | head -1)

if [ -z "$TEST_BINARY" ]; then
    echo -e "${RED}Error: Test binary not found${NC}"
    echo
    echo "The test binary might not be available after running 'zig build test'."
    echo "This is a limitation of Zig's test system."
    echo
    echo "Alternative: Run tests without coverage tracking:"
    echo "  zig build test"
    echo
    echo "Or build the test binary manually and run with kcov."
    exit 1
fi

echo -e "${GREEN}✓ Test binary: $TEST_BINARY${NC}"
echo

# Run tests with kcov
echo "Running tests with coverage..."
kcov \
    --exclude-pattern=/usr,/Library,/zig-cache,/.zig-cache \
    --include-pattern="$PROJECT_ROOT/src" \
    "$COVERAGE_DIR" \
    "$TEST_BINARY" 2>&1 | grep -v "^kcov:" || true

echo
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}║          Coverage Report Generated!                          ║${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo
echo "Coverage report: $COVERAGE_DIR/index.html"
echo

# Try to open in browser
if command -v open &> /dev/null; then
    echo "Opening coverage report in browser..."
    open "$COVERAGE_DIR/index.html"
elif command -v xdg-open &> /dev/null; then
    echo "Opening coverage report in browser..."
    xdg-open "$COVERAGE_DIR/index.html"
else
    echo "Open this file in your browser:"
    echo "  file://$COVERAGE_DIR/index.html"
fi
