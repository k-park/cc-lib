#!/bin/bash
# run-all.sh - Master test runner for all validation scripts
# Usage: ./tests/validation/run-all.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

PROJECT_ROOT=$(pwd)
TESTS_DIR="$PROJECT_ROOT/tests/validation"

# Test results
declare -a TEST_RESULTS=()

# Helper functions
print_header() {
  echo ""
  echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║${NC} ${BOLD}$1${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
  echo ""
}

print_section() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

run_test() {
  local test_name=$1
  local test_script=$2
  local test_description=$3

  print_section "$test_name"

  echo "$test_description"
  echo ""

  # Check if script exists
  if [ ! -f "$test_script" ]; then
    echo -e "${RED}❌ SKIP${NC}: Test script not found: $test_script"
    TEST_RESULTS+=("$test_name:SKIP")
    return 1
  fi

  # Check if script is executable
  if [ ! -x "$test_script" ]; then
    echo -e "${YELLOW}⚠️  Making script executable...${NC}"
    chmod +x "$test_script"
  fi

  # Run the test
  if "$test_script"; then
    echo ""
    echo -e "${GREEN}✅ $test_name PASSED${NC}"
    TEST_RESULTS+=("$test_name:PASS")
    return 0
  else
    echo ""
    echo -e "${RED}❌ $test_name FAILED${NC}"
    TEST_RESULTS+=("$test_name:FAIL")
    return 1
  fi
}

# Print header
print_header "CC-LIB Validation Test Suite"

echo "Project Root: $PROJECT_ROOT"
echo "Tests Directory: $TESTS_DIR"
echo ""

# Check if we're in the right directory
if [ ! -f "$PROJECT_ROOT/README.md" ]; then
  echo -e "${RED}Error: Please run from project root directory${NC}"
  echo ""
  echo "Usage: ./tests/validation/run-all.sh"
  exit 1
fi

# =============================================================================
# Run Tests
# =============================================================================

# Test 1: Plugin Structure Validation
run_test \
  "Plugin Structure" \
  "$TESTS_DIR/test-plugins.sh" \
  "Validates plugin directory structure, required files, and marketplace configuration."

# Test 2: YAML Frontmatter Validation
run_test \
  "YAML Frontmatter" \
  "$TESTS_DIR/yaml-lint.sh" \
  "Validates YAML syntax in agent file frontmatter."

# Test 3: Markdown Linting
run_test \
  "Markdown Linting" \
  "$TESTS_DIR/markdown-lint.sh" \
  "Checks Markdown formatting and style issues."

# Test 4: Link Validation
run_test \
  "Documentation Links" \
  "$TESTS_DIR/check-links.sh" \
  "Validates internal and external documentation links."

# Test 5: Build Script Validation
run_test \
  "Build Script" \
  "$TESTS_DIR/test-build.sh" \
  "Tests build script execution and validates output structure."

# =============================================================================
# Summary
# =============================================================================

print_header "Test Summary"

echo ""
echo "Test Results:"
echo ""

PASSED=0
FAILED=0
SKIPPED=0

for result in "${TEST_RESULTS[@]}"; do
  IFS=':' read -r name status <<< "$result"

  case $status in
    PASS)
      echo -e "  ${GREEN}✅ PASS${NC} $name"
      ((PASSED++))
      ;;
    FAIL)
      echo -e "  ${RED}❌ FAIL${NC} $name"
      ((FAILED++))
      ;;
    SKIP)
      echo -e "  ${YELLOW}⚠️  SKIP${NC} $name"
      ((SKIPPED++))
      ;;
  esac
done

echo ""
echo "─────────────────────────────────────────────────────────"
echo "  Total:   $((PASSED + FAILED + SKIPPED))"
echo -e "  ${GREEN}Passed:  $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
  echo -e "  ${RED}Failed:  $FAILED${NC}"
else
  echo "  Failed:  $FAILED"
fi
if [ $SKIPPED -gt 0 ]; then
  echo -e "  ${YELLOW}Skipped: $SKIPPED${NC}"
fi
echo "─────────────────────────────────────────────────────────"
echo ""

# Exit with appropriate code
if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║${NC} ${BOLD}🎉 ALL TESTS PASSED! 🎉${NC}"
  echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
  echo ""
  exit 0
else
  echo -e "${RED}╔══════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║${NC} ${BOLD}❌ SOME TESTS FAILED ❌${NC}"
  echo -e "${RED}╚══════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo "To run individual tests:"
  echo "  ./tests/validation/test-plugins.sh"
  echo "  ./tests/validation/yaml-lint.sh"
  echo "  ./tests/validation/markdown-lint.sh"
  echo "  ./tests/validation/check-links.sh"
  echo "  ./tests/validation/test-build.sh"
  echo ""
  exit 1
fi
