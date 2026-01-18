#!/bin/bash
# check-links.sh - Validate internal and external documentation links
# Usage: ./tests/validation/check-links.sh

# Don't exit on error, we'll track failures manually
# set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT=$(pwd)
TOTAL_LINKS=0
VALID_LINKS=0
INVALID_LINKS=0
SKIPPED_LINKS=0

echo "========================================="
echo "  Documentation Link Checker"
echo "========================================="
echo ""

# Check if markdown-link-check is available
if command -v markdown-link-check &> /dev/null; then
  LINK_CHECKER="markdown-link-check"
elif command -v npx &> /dev/null; then
  LINK_CHECKER="npx markdown-link-check"
else
  echo -e "${YELLOW}⚠️  markdown-link-check not found${NC}"
  echo ""
  echo "To install markdown-link-check:"
  echo "  npm install -g markdown-link-check"
  echo ""
  echo "Or use npx (will auto-install):"
  echo "  npx markdown-link-check"
  echo ""
  echo "Skipping link validation (markdown-link-check required)"
  echo ""
  echo -e "${GREEN}=========================================${NC}"
  echo -e "${GREEN}  ✅ SKIPPED (markdown-link-check not installed) ✅${NC}"
  echo -e "${GREEN}=========================================${NC}"
  exit 0
fi

echo "Using: $LINK_CHECKER"
echo ""

# Arrays to store results
declare -a FAILED_FILES=()
declare -a PASSED_FILES=()

# Find all Markdown files (excluding common exclusions)
while IFS= read -r -d '' mdfile; do
  relative_path="${mdfile#$PROJECT_ROOT/}"

  echo -e "${BLUE}Checking:${NC} $relative_path"

  # Run markdown-link-check
  if $LINK_CHECKER "$mdfile" \
    --config "$PROJECT_ROOT/tests/validation/.markdown-link-check.json" \
    2>&1; then
    echo -e "${GREEN}✅ PASS${NC}: $relative_path"
    PASSED_FILES+=("$relative_path")
    ((VALID_LINKS++))
  else
    echo -e "${RED}❌ FAIL${NC}: $relative_path (broken links)"
    FAILED_FILES+=("$relative_path")
    ((INVALID_LINKS++))
  fi

  ((TOTAL_LINKS++))
  echo ""

done < <(find "$PROJECT_ROOT" -name "*.md" \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/output/*" \
  -not -path "*/.claude/*" \
  -print0)

echo "========================================="
echo "  Summary"
echo "========================================="
echo ""
echo "Files Checked:   $TOTAL_LINKS"
echo -e "${GREEN}Passed:          $VALID_LINKS${NC}"
if [ $INVALID_LINKS -gt 0 ]; then
  echo -e "${RED}Failed:          $INVALID_LINKS${NC}"
else
  echo "Failed:          $INVALID_LINKS"
fi
echo ""

# Show failed files if any
if [ ${#FAILED_FILES[@]} -gt 0 ]; then
  echo -e "${RED}Files with broken links:${NC}"
  for file in "${FAILED_FILES[@]}"; do
    echo "  - $file"
  done
  echo ""
fi

if [ $INVALID_LINKS -eq 0 ]; then
  echo -e "${GREEN}=========================================${NC}"
  echo -e "${GREEN}  ✅ All Links Valid ✅${NC}"
  echo -e "${GREEN}=========================================${NC}"
  exit 0
else
  echo -e "${RED}=========================================${NC}"
  echo -e "${RED}  ❌ Broken Links Detected ❌${NC}"
  echo -e "${RED}=========================================${NC}"
  exit 1
fi
