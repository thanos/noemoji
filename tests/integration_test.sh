#!/usr/bin/env bash
# Integration tests for noemoji CLI

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BINARY="${1:-zig-out/bin/noemoji}"
TEST_DIR="/tmp/noemoji-integration-test-$$"
PASSED=0
FAILED=0

# Convert binary path to absolute path before changing directories
if [[ "$BINARY" != /* ]]; then
    BINARY="$(cd "$(dirname "$BINARY")" && pwd)/$(basename "$BINARY")"
fi

# Cleanup function
cleanup() {
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

# Test helper functions
assert_file_contains() {
    local file="$1"
    local expected="$2"
    local actual=$(cat "$file")
    
    if [ "$actual" = "$expected" ]; then
        echo -e "${GREEN}✓${NC} $3"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $3"
        echo "  Expected: '$expected'"
        echo "  Got:      '$actual'"
        ((FAILED++))
        return 1
    fi
}

assert_file_exists() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $2"
        echo "  File not found: $1"
        ((FAILED++))
        return 1
    fi
}

assert_file_not_exists() {
    if [ ! -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $2"
        echo "  File should not exist: $1"
        ((FAILED++))
        return 1
    fi
}

assert_success() {
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $1"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $1 (exit code: $exit_code)"
        ((FAILED++))
        return 1
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  noemoji Integration Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Check binary exists
if [ ! -f "$BINARY" ]; then
    echo -e "${RED}Error: Binary not found: $BINARY${NC}"
    echo "Build the project first: zig build -Doptimize=ReleaseFast"
    echo "Current directory: $(pwd)"
    echo "Looking for: $BINARY"
    ls -la zig-out/bin/ 2>/dev/null || echo "zig-out/bin/ directory not found"
    exit 1
fi

if [ ! -x "$BINARY" ]; then
    echo -e "${YELLOW}Warning: Binary is not executable, making it executable${NC}"
    chmod +x "$BINARY"
fi

# Create test directory
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "Test Environment: $TEST_DIR"
echo "Binary: $BINARY"
echo

# Test 1: Help flag
echo "Test Group: Help & Version"
echo "───────────────────────────"
$BINARY --help > /dev/null 2>&1
assert_success "Help flag works" || true

$BINARY -h > /dev/null 2>&1
assert_success "Short help flag works" || true

$BINARY --version > /dev/null 2>&1
assert_success "Version flag works" || true

$BINARY -v > /dev/null 2>&1
assert_success "Short version flag works" || true
echo

# Test 2: Single file processing
echo "Test Group: Single File Processing"
echo "───────────────────────────────────"
echo "Test 👋 with emoji 🎉" > test1.txt
$BINARY test1.txt > /dev/null 2>&1
assert_file_contains test1.txt "Test  with emoji " "Single file emoji removal" || true

echo "No emoji here" > test2.txt
$BINARY test2.txt > /dev/null 2>&1
assert_file_contains test2.txt "No emoji here" "File without emoji unchanged" || true
echo

# Test 3: Glob patterns
echo "Test Group: Glob Patterns"
echo "─────────────────────────"
echo "File1 🚀" > file1.md
echo "File2 💯" > file2.md
echo "File3 ✨" > file3.txt

$BINARY "*.md" > /dev/null 2>&1
assert_file_contains file1.md "File1 " "Glob pattern *.md (file 1)" || true
assert_file_contains file2.md "File2 " "Glob pattern *.md (file 2)" || true
assert_file_contains file3.txt "File3 ✨" "Non-matching file unchanged" || true
echo

# Test 3b: Multiple files (shell expansion)
echo "Test Group: Multiple Files (Shell Expansion)"
echo "─────────────────────────────────────────────"
echo "Multi1 🎯" > multi1.txt
echo "Multi2 🌟" > multi2.txt
echo "Multi3 💡" > multi3.txt

# Note: In the test script, the shell expands *.txt before passing to binary
$BINARY multi*.txt > /dev/null 2>&1
assert_file_contains multi1.txt "Multi1 " "Shell expansion (file 1)" || true
assert_file_contains multi2.txt "Multi2 " "Shell expansion (file 2)" || true
assert_file_contains multi3.txt "Multi3 " "Shell expansion (file 3)" || true
echo

# Test 4: Recursive glob
echo "Test Group: Recursive Glob"
echo "──────────────────────────"
mkdir -p subdir/nested
echo "Deep 🔥 file" > subdir/nested/deep.txt

$BINARY "**/*.txt" > /dev/null 2>&1
assert_file_contains subdir/nested/deep.txt "Deep  file" "Recursive glob pattern" || true
echo

# Test 5: Dry-run mode
echo "Test Group: Dry-run Mode"
echo "────────────────────────"
echo "Dryrun test 🎯" > dryrun.txt
$BINARY --dry-run dryrun.txt > /dev/null 2>&1
assert_file_contains dryrun.txt "Dryrun test 🎯" "Dry-run doesn't modify file" || true
echo

# Test 6: Backup mode
echo "Test Group: Backup Mode"
echo "───────────────────────"
echo "Backup test 💡" > backup.txt
$BINARY --backup backup.txt > /dev/null 2>&1
assert_file_exists backup.txt.bak "Backup file created" || true
assert_file_contains backup.txt "Backup test " "Original file cleaned" || true
assert_file_contains backup.txt.bak "Backup test 💡" "Backup preserved emoji" || true
echo

# Test 7: Output directory mode
echo "Test Group: Output Directory"
echo "────────────────────────────"
echo "Output 🌟 test" > output.txt
$BINARY --output-dir cleaned output.txt > /dev/null 2>&1
assert_file_exists cleaned/output.txt "Output directory created" || true
assert_file_contains output.txt "Output 🌟 test" "Original file unchanged" || true
assert_file_contains cleaned/output.txt "Output  test" "Cleaned file in output dir" || true
echo

# Test 8: Error handling
echo "Test Group: Error Handling"
echo "──────────────────────────"
$BINARY nonexistent.txt 2>&1 | grep -q "Error reading file"
assert_success "FileNotFound error handled" || true

$BINARY "no-matches-*.xyz" 2>&1 | grep -q "No files matched"
assert_success "No matches message displayed" || true
echo

# Test 9: UTF-8 handling
echo "Test Group: UTF-8 Handling"
echo "──────────────────────────"
echo "Unicode 语言 🦎 test" > utf8.txt
$BINARY utf8.txt > /dev/null 2>&1
assert_file_contains utf8.txt "Unicode 语言  test" "Unicode text preserved" || true

echo "Multi-line 🎉
Second line 💯
Third line ✨" > multiline.txt
$BINARY multiline.txt > /dev/null 2>&1
cat multiline.txt | grep -q "Multi-line " && grep -q "Second line " multiline.txt && grep -q "Third line " multiline.txt
assert_success "Multi-line file processed correctly" || true
echo

# Test 10: Edge cases
echo "Test Group: Edge Cases"
echo "──────────────────────"
echo "" > empty.txt
$BINARY empty.txt > /dev/null 2>&1
assert_file_contains empty.txt "" "Empty file handled" || true

echo "🎉🚀💯✨" > only-emoji.txt
$BINARY only-emoji.txt > /dev/null 2>&1
assert_file_contains only-emoji.txt "" "File with only emoji" || true

echo "Start🎉Middle💯End" > no-spaces.txt
$BINARY no-spaces.txt > /dev/null 2>&1
assert_file_contains no-spaces.txt "StartMiddleEnd" "Emoji without spaces" || true
echo

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}Passed: $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Failed: $FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed! ✓${NC}"
    exit 0
fi
