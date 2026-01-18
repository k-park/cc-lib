#!/bin/bash
# yaml-lint.sh - Validate YAML frontmatter in agent Markdown files
# Usage: ./tests/validation/yaml-lint.sh

# Don't exit on error, we'll track failures manually
# set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_ROOT=$(pwd)
AGENTS_DIR="$PROJECT_ROOT/agents"
TOTAL_FILES=0
VALID_FILES=0
INVALID_FILES=0

echo "========================================="
echo "  YAML Frontmatter Validation"
echo "========================================="
echo ""

# Check if yamllint is available
if ! command -v yamllint &> /dev/null; then
  echo -e "${YELLOW}⚠️  yamllint not found${NC}"
  echo ""
  echo "To install yamllint:"
  echo "  pip install yamllint"
  echo "  or"
  echo "  pip3 install yamllint"
  echo ""
  echo "Skipping YAML validation (yamllint required)"
  echo ""
  echo -e "${GREEN}=========================================${NC}"
  echo -e "${GREEN}  ✅ SKIPPED (yamllint not installed) ✅${NC}"
  echo -e "${GREEN}=========================================${NC}"
  exit 0
fi

# Create temporary directory for extracted frontmatter
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "Extracting YAML frontmatter from agent files..."
echo ""

# Extract and validate frontmatter from each agent file
for agent_file in "$AGENTS_DIR"/*/*.md; do
  if [ -f "$agent_file" ]; then
    ((TOTAL_FILES++)) || true
    agent_name=$(basename "$agent_file")
    category=$(basename "$(dirname "$agent_file")")

    # Extract frontmatter between --- delimiters
    awk '/^---$/{if (p) {exit}; p=1;next} p' "$agent_file" > "$TEMP_DIR/${agent_name}.yaml" 2>/dev/null || true

    # Check if frontmatter was extracted
    if [ -s "$TEMP_DIR/${agent_name}.yaml" ]; then
      # Validate with yamllint
      if yamllint -d "{rules: {line-length: {max: 120}, indentation: {spaces: 2}, trailing-spaces: false}}" "$TEMP_DIR/${agent_name}.yaml" 2>/dev/null; then
        echo -e "${GREEN}✅${NC} $category/$agent_name"
        ((VALID_FILES++)) || true
      else
        echo -e "${RED}❌${NC} $category/$agent_name (YAML syntax error)"
        ((INVALID_FILES++)) || true
      fi
    else
      echo -e "${YELLOW}⚠️ ${NC} $category/$agent_name (no frontmatter)"
      ((INVALID_FILES++)) || true
    fi
  fi
done

echo ""
echo "========================================="
echo "  Summary"
echo "========================================="
echo ""
echo "Total Files:     $TOTAL_FILES"
echo -e "${GREEN}Valid Files:     $VALID_FILES${NC}"
if [ $INVALID_FILES -gt 0 ]; then
  echo -e "${RED}Invalid Files:   $INVALID_FILES${NC}"
else
  echo "Invalid Files:   $INVALID_FILES"
fi
echo ""

if [ $INVALID_FILES -eq 0 ]; then
  echo -e "${GREEN}=========================================${NC}"
  echo -e "${GREEN}  ✅ All YAML Frontmatter Valid ✅${NC}"
  echo -e "${GREEN}=========================================${NC}"
  exit 0
else
  echo -e "${RED}=========================================${NC}"
  echo -e "${RED}  ❌ Some YAML Issues Detected ❌${NC}"
  echo -e "${RED}=========================================${NC}"
  exit 1
fi
