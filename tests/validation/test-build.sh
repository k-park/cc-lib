#!/bin/bash
# test-build.sh - Validate build script execution and output
# Usage: ./tests/validation/test-build.sh

# Don't exit on error, we'll track failures manually
# set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT=$(pwd)
BUILD_SCRIPT="$PROJECT_ROOT/installer/cli/build.sh"
OUTPUT_DIR="$PROJECT_ROOT/output/.claude"

echo "========================================="
echo "  Build Script Validation"
echo "========================================="
echo ""

# Check if running from project root
if [ ! -f "README.md" ]; then
  echo -e "${RED}Error: Please run from project root directory${NC}"
  exit 1
fi

# =============================================================================
# Pre-build Checks
# =============================================================================

echo -e "${BLUE}Step 1: Pre-build Checks${NC}"
echo ""

# Check if build script exists
if [ ! -f "$BUILD_SCRIPT" ]; then
  echo -e "${RED}❌ FAIL${NC}: Build script not found at $BUILD_SCRIPT"
  exit 1
fi
echo -e "${GREEN}✅ PASS${NC}: Build script exists"

# Check if build script is executable
if [ -x "$BUILD_SCRIPT" ]; then
  echo -e "${GREEN}✅ PASS${NC}: Build script is executable"
else
  echo -e "${YELLOW}⚠️  WARN${NC}: Build script is not executable"
  echo "  Run: chmod +x $BUILD_SCRIPT"
fi

# Check for shebang
if head -1 "$BUILD_SCRIPT" | grep -q "^#!"; then
  echo -e "${GREEN}✅ PASS${NC}: Build script has shebang"
else
  echo -e "${RED}❌ FAIL${NC}: Build script missing shebang"
  exit 1
fi

echo ""

# =============================================================================
# Clean previous build
# =============================================================================

echo -e "${BLUE}Step 2: Clean Previous Build${NC}"
echo ""

if [ -d "$OUTPUT_DIR" ]; then
  echo "Removing previous build output..."
  rm -rf "$OUTPUT_DIR"
  echo -e "${GREEN}✅ Done${NC}"
else
  echo "No previous build to clean"
fi

echo ""

# =============================================================================
# Run build script
# =============================================================================

echo -e "${BLUE}Step 3: Run Build Script${NC}"
echo ""

# Capture build output
if BUILD_OUTPUT=$("$BUILD_SCRIPT" 2>&1); then
  BUILD_EXIT_CODE=0
  echo -e "${GREEN}✅ PASS${NC}: Build script executed successfully"
else
  BUILD_EXIT_CODE=$?
  echo -e "${RED}❌ FAIL${NC}: Build script failed with exit code $BUILD_EXIT_CODE"
  echo ""
  echo "Build output:"
  echo "$BUILD_OUTPUT"
  exit 1
fi

echo ""

# =============================================================================
# Post-build Validation
# =============================================================================

echo -e "${BLUE}Step 4: Post-build Validation${NC}"
echo ""

# Check if output directory was created
if [ -d "$OUTPUT_DIR" ]; then
  echo -e "${GREEN}✅ PASS${NC}: Output directory created at $OUTPUT_DIR"
else
  echo -e "${RED}❌ FAIL${NC}: Output directory not created"
  exit 1
fi

# Check for agents directory
if [ -d "$OUTPUT_DIR/agents" ]; then
  echo -e "${GREEN}✅ PASS${NC}: Agents directory exists in output"

  # Count agent files
  AGENT_COUNT=$(find "$OUTPUT_DIR/agents" -name "*.md" -type f | wc -l)
  echo "  Found $AGENT_COUNT agent files"

  if [ "$AGENT_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  WARN${NC}: No agent files in output"
  else
    echo -e "${GREEN}✅ PASS${NC}: Agent files copied to output"
  fi
else
  echo -e "${RED}❌ FAIL${NC}: Agents directory not found in output"
  exit 1
fi

# Check for settings.json
if [ -f "$OUTPUT_DIR/settings.json" ]; then
  echo -e "${GREEN}✅ PASS${NC}: settings.json created"

  # Validate JSON
  if command -v python3 &> /dev/null; then
    if python3 -m json.tool "$OUTPUT_DIR/settings.json" > /dev/null 2>&1; then
      echo -e "${GREEN}✅ PASS${NC}: settings.json is valid JSON"
    else
      echo -e "${RED}❌ FAIL${NC}: settings.json has invalid JSON"
    fi
  elif command -v jq &> /dev/null; then
    if jq empty "$OUTPUT_DIR/settings.json" 2>/dev/null; then
      echo -e "${GREEN}✅ PASS${NC}: settings.json is valid JSON"
    else
      echo -e "${RED}❌ FAIL${NC}: settings.json has invalid JSON"
    fi
  fi
else
  echo -e "${RED}❌ FAIL${NC}: settings.json not found in output"
  exit 1
fi

echo ""

# =============================================================================
# Content Validation
# =============================================================================

echo -e "${BLUE}Step 5: Content Validation${NC}"
echo ""

# Check that agent files have valid frontmatter
INVALID_AGENTS=0
for agent_file in "$OUTPUT_DIR/agents"/*.md; do
  if [ -f "$agent_file" ]; then
    agent_name=$(basename "$agent_file")

    # Check for YAML frontmatter
    if grep -q "^---$" "$agent_file"; then
      # Extract and check for name field
      frontmatter=$(awk '/^---$/{flag=!flag;next}flag' "$agent_file")
      if echo "$frontmatter" | grep -q "^name:"; then
        : # Valid
      else
        echo -e "${YELLOW}⚠️  WARN${NC}: $agent_name missing 'name' field in frontmatter"
        ((INVALID_AGENTS++))
      fi
    else
      echo -e "${RED}❌ FAIL${NC}: $agent_name missing YAML frontmatter"
      ((INVALID_AGENTS++))
    fi
  fi
done

if [ $INVALID_AGENTS -eq 0 ]; then
  echo -e "${GREEN}✅ PASS${NC}: All agent files have valid frontmatter"
else
  echo -e "${RED}❌ FAIL${NC}: $INVALID_AGENTS agent files have invalid frontmatter"
fi

echo ""

# =============================================================================
# Summary
# =============================================================================

echo "========================================="
echo "  Build Summary"
echo "========================================="
echo ""
echo "Build script: $BUILD_SCRIPT"
echo "Output directory: $OUTPUT_DIR"
echo "Agent files: $AGENT_COUNT"
echo ""

if [ $BUILD_EXIT_CODE -eq 0 ] && [ $INVALID_AGENTS -eq 0 ]; then
  echo -e "${GREEN}=========================================${NC}"
  echo -e "${GREEN}  🎉 Build Validation Successful! 🎉${NC}"
  echo -e "${GREEN}=========================================${NC}"
  echo ""
  echo "Build output is ready in:"
  echo "  $OUTPUT_DIR"
  exit 0
else
  echo -e "${RED}=========================================${NC}"
  echo -e "${RED}  ❌ Build Validation Failed ❌${NC}"
  echo -e "${RED}=========================================${NC}"
  exit 1
fi
