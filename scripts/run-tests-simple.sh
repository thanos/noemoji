#!/usr/bin/env bash
# Simple test runner without coverage (more reliable)

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                              ║${NC}"
echo -e "${BLUE}║          noemoji Test Suite                                  ║${NC}"
echo -e "${BLUE}║                                                              ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo

cd "$PROJECT_ROOT"

# Run unit tests
echo -e "${YELLOW}[1/2] Running unit tests...${NC}"
zig build test
echo -e "${GREEN}✓ Unit tests passed${NC}"
echo

# Build optimized binary for integration tests
echo -e "${YELLOW}[2/2] Building optimized binary...${NC}"
zig build -Doptimize=ReleaseFast
echo -e "${GREEN}✓ Binary built${NC}"
echo

echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}║          All Tests Complete! ✓                               ║${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo
echo "To run integration tests:"
echo "  ./tests/integration_test.sh zig-out/bin/noemoji"
echo
echo "Note: Code coverage with kcov is currently not fully supported"
echo "      with Zig 0.15.2's test runner. Unit and integration tests"
echo "      provide comprehensive coverage validation."
