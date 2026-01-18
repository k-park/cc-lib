#!/bin/bash
# markdown-lint.sh - Lint Markdown files using markdownlint
# Usage: ./tests/validation/markdown-lint.sh

# Don't exit on error, we'll track failures manually
# set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_ROOT=$(pwd)
CONFIG="$PROJECT_ROOT/tests/validation/.markdownlint.json"

# Check if markdownlint-cli2 is available
if command -v markdownlint-cli2 &> /dev/null; then
  LINTER="markdownlint-cli2"
elif command -v markdownlint &> /dev/null; then
  LINTER="markdownlint"
elif command -v npx &> /dev/null; then
  LINTER="npx markdownlint-cli2"
else
  echo -e "${YELLOW}⚠️  markdownlint not found${NC}"
  echo ""
  echo "To install markdownlint-cli2:"
  echo "  npm install -g markdownlint-cli2"
  echo ""
  echo "Or use npx (will auto-install):"
  echo "  npx markdownlint-cli2"
  echo ""
  echo "Skipping Markdown linting (markdownlint-cli2 required)"
  echo ""
  echo -e "${GREEN}=========================================${NC}"
  echo -e "${GREEN}  ✅ SKIPPED (markdownlint-cli2 not installed) ✅${NC}"
  echo -e "${GREEN}=========================================${NC}"
  exit 0
fi

echo "========================================="
echo "  Markdown Lint"
echo "========================================="
echo ""
echo "Using: $LINTER"
echo "Config: $CONFIG"
echo ""

# Run markdownlint
if $LINTER --config "$CONFIG" \
  --ignore node_modules \
  --ignore output \
  --ignore ".claude" \
  "**/*.md"; then

  echo ""
  echo -e "${GREEN}=========================================${NC}"
  echo -e "${GREEN}  ✅ No Markdown Issues Found ✅${NC}"
  echo -e "${GREEN}=========================================${NC}"
  exit 0
else
  echo ""
  echo -e "${RED}=========================================${NC}"
  echo -e "${RED}  ❌ Markdown Issues Detected ❌${NC}"
  echo -e "${RED}=========================================${NC}"
  echo ""
  echo "To fix issues automatically:"
  echo "  $LINTER --fix --config $CONFIG '**/*.md'"
  exit 1
fi
