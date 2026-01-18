#!/bin/bash
# test-plugins.sh - Validate cc-lib plugin structure and quality
# Usage: ./tests/validation/test-plugins.sh

# Don't exit on error, we'll track failures manually
# set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
pass() {
  echo -e "${GREEN}✅ PASS${NC}: $1"
  ((TESTS_PASSED++)) || true
  ((TESTS_RUN++)) || true
}

fail() {
  echo -e "${RED}❌ FAIL${NC}: $1"
  ((TESTS_FAILED++)) || true
  ((TESTS_RUN++)) || true
}

info() {
  echo -e "${YELLOW}ℹ️  INFO${NC}: $1"
}

header() {
  echo ""
  echo "========================================="
  echo "  $1"
  echo "========================================="
  echo ""
}

# Check if running from project root
if [ ! -f "README.md" ] || [ ! -d "plugins" ]; then
  echo "Error: Please run from project root directory"
  exit 1
fi

# Get project root
PROJECT_ROOT=$(pwd)

header "CC-LIB Plugin Validation Tests"

# =============================================================================
# Test 1: Plugin Structure Validation
# =============================================================================
header "Test 1: Plugin Structure"

PLUGINS_DIR="$PROJECT_ROOT/plugins"
# Only check for plugin.json, marketplace.json is in root
REQUIRED_PLUGIN_FILES=(".claude-plugin/plugin.json")

for plugin_dir in "$PLUGINS_DIR"/*/; do
  plugin_name=$(basename "$plugin_dir")

  # Check if plugin is not a hidden directory
  if [[ "$plugin_name" == .* ]]; then
    continue
  fi

  info "Checking plugin: $plugin_name"

  # Check for required files
  for required_file in "${REQUIRED_PLUGIN_FILES[@]}"; do
    required_path="$plugin_dir$required_file"
    if [ -f "$required_path" ]; then
      pass "$plugin_name has $required_file"
    else
      fail "$plugin_name missing $required_file"
    fi
  done

  # Check for commands directory (most plugins should have this)
  if [ -d "$plugin_dir/commands" ]; then
    pass "$plugin_name has commands directory"
  else
    info "$plugin_name has no commands directory (may be documentation-only)"
  fi
done

# =============================================================================
# Test 2: Agent File Validation
# =============================================================================
header "Test 2: Agent File Validation"

AGENTS_DIR="$PROJECT_ROOT/agents"
TOTAL_AGENTS=0
AGENTS_WITH_VALID_FRONTMATTER=0

for agent_file in "$AGENTS_DIR"/*/*.md; do
  if [ -f "$agent_file" ]; then
    ((TOTAL_AGENTS++)) || true
    agent_name=$(basename "$agent_file")

    # Check for YAML frontmatter (starts and ends with ---)
    if grep -q "^---$" "$agent_file"; then
      ((AGENTS_WITH_VALID_FRONTMATTER++)) || true
      pass "$agent_name has YAML frontmatter delimiter"

      # Extract frontmatter and validate with basic checks
      frontmatter=$(awk '/^---$/{flag=!flag;next}flag' "$agent_file")

      # Check for required fields
      if echo "$frontmatter" | grep -q "^name:"; then
        pass "$agent_name has 'name' field"
      else
        fail "$agent_name missing 'name' field"
      fi

      if echo "$frontmatter" | grep -q "^description:"; then
        pass "$agent_name has 'description' field"
      else
        fail "$agent_name missing 'description' field"
      fi

      # Check name format (should be lowercase with hyphens/colons)
      name_value=$(echo "$frontmatter" | grep "^name:" | sed 's/name: *//')
      if [[ "$name_value" =~ ^[a-z:_-]+$ ]]; then
        pass "$agent_name has valid name format"
      else
        fail "$agent_name has invalid name format: $name_value"
      fi

    else
      fail "$agent_name missing YAML frontmatter delimiters"
    fi
  fi
done

info "Total agents found: $TOTAL_AGENTS"
info "Agents with valid frontmatter: $AGENTS_WITH_VALID_FRONTMATTER"

# =============================================================================
# Test 3: Marketplace.json Validation
# =============================================================================
header "Test 3: Marketplace Configuration"

MARKETPLACE_FILE="$PROJECT_ROOT/.claude-plugin/marketplace.json"

if [ -f "$MARKETPLACE_FILE" ]; then
  pass "marketplace.json exists"

  # Check if it's valid JSON (prefer jq, fallback to python3)
  JSON_VALID=0
  if command -v jq &> /dev/null; then
    if jq empty "$MARKETPLACE_FILE" 2>/dev/null; then
      pass "marketplace.json is valid JSON"
      JSON_VALID=1
    else
      fail "marketplace.json has invalid JSON syntax"
    fi
  elif command -v python3 &> /dev/null; then
    if python3 -m json.tool "$MARKETPLACE_FILE" > /dev/null 2>&1; then
      pass "marketplace.json is valid JSON"
      JSON_VALID=1
    else
      fail "marketplace.json has invalid JSON syntax"
    fi
  else
    info "No JSON validator available (jq or python3 required)"
  fi

  # Check for required fields
  if grep -q '"name"' "$MARKETPLACE_FILE"; then
    pass "marketplace.json has 'name' field"
  else
    fail "marketplace.json missing 'name' field"
  fi

  if grep -q '"metadata"' "$MARKETPLACE_FILE"; then
    pass "marketplace.json has 'metadata' field"
  else
    fail "marketplace.json missing 'metadata' field"
  fi

  if grep -q '"plugins"' "$MARKETPLACE_FILE"; then
    pass "marketplace.json has 'plugins' field"
  else
    fail "marketplace.json missing 'plugins' field"
  fi
else
  fail "marketplace.json not found at $MARKETPLACE_FILE"
fi

# =============================================================================
# Test 4: Plugin JSON Validation
# =============================================================================
header "Test 4: Individual Plugin Configurations"

for plugin_json in "$PLUGINS_DIR"/*/.claude-plugin/plugin.json; do
  if [ -f "$plugin_json" ]; then
    plugin_name=$(dirname "$plugin_json" | xargs basename)

    # Validate JSON using jq (preferred) or python3
    JSON_OK=0
    if command -v jq &> /dev/null; then
      if jq empty "$plugin_json" 2>/dev/null; then
        pass "$plugin_name/plugin.json is valid JSON"
        JSON_OK=1
      else
        fail "$plugin_name/plugin.json has invalid JSON syntax"
      fi
    elif command -v python3 &> /dev/null; then
      if python3 -m json.tool "$plugin_json" > /dev/null 2>&1; then
        pass "$plugin_name/plugin.json is valid JSON"
        JSON_OK=1
      else
        fail "$plugin_name/plugin.json has invalid JSON syntax"
      fi
    fi

    # Check for required fields
    if grep -q '"name"' "$plugin_json"; then
      pass "$plugin_name/plugin.json has 'name' field"
    else
      fail "$plugin_name/plugin.json missing 'name' field"
    fi
  fi
done

# =============================================================================
# Test 5: Documentation Completeness
# =============================================================================
header "Test 5: Documentation Completeness"

# Check for README
if [ -f "$PROJECT_ROOT/README.md" ]; then
  pass "Root README.md exists"

  # Check README has required sections
  if grep -q "^## Installation" "$PROJECT_ROOT/README.md"; then
    pass "README.md has Installation section"
  else
    fail "README.md missing Installation section"
  fi

  if grep -q "^## Plugins" "$PROJECT_ROOT/README.md"; then
    pass "README.md has Plugins section"
  else
    fail "README.md missing Plugins section"
  fi
else
  fail "Root README.md missing"
fi

# Check for LICENSE (check both LICENSE and LICENSE.md)
LICENSE_FOUND=0
if [ -f "$PROJECT_ROOT/LICENSE" ]; then
  pass "LICENSE file exists"
  LICENSE_FOUND=1
elif [ -f "$PROJECT_ROOT/LICENSE.md" ]; then
  pass "LICENSE.md file exists"
  LICENSE_FOUND=1
fi

if [ $LICENSE_FOUND -eq 0 ]; then
  fail "LICENSE file missing (looking for LICENSE or LICENSE.md)"
fi

# =============================================================================
# Test 6: Build Script Validation
# =============================================================================
header "Test 6: Build Script"

BUILD_SCRIPT="$PROJECT_ROOT/installer/cli/build.sh"

if [ -f "$BUILD_SCRIPT" ]; then
  pass "Build script exists at $BUILD_SCRIPT"

  # Check if build script is executable
  if [ -x "$BUILD_SCRIPT" ]; then
    pass "Build script is executable"
  else
    info "Build script is not executable (run: chmod +x $BUILD_SCRIPT)"
  fi

  # Check for shebang
  if head -1 "$BUILD_SCRIPT" | grep -q "^#!"; then
    pass "Build script has shebang"
  else
    fail "Build script missing shebang"
  fi
else
  fail "Build script not found at $BUILD_SCRIPT"
fi

# =============================================================================
# Test 7: Symbolic Link Validation
# =============================================================================
header "Test 7: Symbolic Links"

BROKEN_LINKS=0

for plugin_dir in "$PLUGINS_DIR"/*/; do
  if [ -d "$plugin_dir/commands" ]; then
    for link in "$plugin_dir"/commands/*; do
      if [ -L "$link" ]; then
        # Check if symlink target exists
        if [ -e "$link" ]; then
          link_name=$(basename "$link")
          target=$(readlink -f "$link")
          pass "Symlink $link_name -> $target is valid"
        else
          link_name=$(basename "$link")
          fail "Symlink $link_name is broken"
          ((BROKEN_LINKS++)) || true
        fi
      fi
    done
  fi
done

if [ $BROKEN_LINKS -eq 0 ]; then
  pass "All symlinks are valid"
fi

# =============================================================================
# Test Summary
# =============================================================================
header "Test Summary"

echo "Tests Run:    $TESTS_RUN"
echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
  echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
else
  echo -e "${GREEN}Tests Failed: $TESTS_FAILED${NC}"
fi

echo ""

if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "${GREEN}=========================================${NC}"
  echo -e "${GREEN}  🎉 ALL TESTS PASSED! 🎉${NC}"
  echo -e "${GREEN}=========================================${NC}"
  exit 0
else
  echo -e "${RED}=========================================${NC}"
  echo -e "${RED}  ❌ SOME TESTS FAILED ❌${NC}"
  echo -e "${RED}=========================================${NC}"
  exit 1
fi
