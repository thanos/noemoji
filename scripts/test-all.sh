#!/usr/bin/env bash
# Run all tests: unit + integration

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                              ║${NC}"
echo -e "${BLUE}║          noemoji Complete Test Suite                         ║${NC}"
echo -e "${BLUE}║                                                              ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo

cd "$PROJECT_ROOT"

# Step 1: Build in debug mode
echo -e "${YELLOW}[1/4] Building debug binary...${NC}"
zig build
echo -e "${GREEN}✓ Debug build complete${NC}"
echo

# Step 2: Run unit tests
echo -e "${YELLOW}[2/4] Running unit tests...${NC}"
zig build test
echo -e "${GREEN}✓ Unit tests passed${NC}"
echo

# Step 3: Build optimized binary for integration tests
echo -e "${YELLOW}[3/4] Building optimized binary...${NC}"
zig build -Doptimize=ReleaseFast
echo -e "${GREEN}✓ Optimized build complete${NC}"
echo

# Step 4: Run integration tests
echo -e "${YELLOW}[4/4] Running integration tests...${NC}"
"$PROJECT_ROOT/tests/integration_test.sh" "$PROJECT_ROOT/zig-out/bin/noemoji"
echo

echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}║          All Tests Passed! ✓                                 ║${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
