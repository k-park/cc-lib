#!/bin/bash
# build.sh - Build cc-lib output structure
#
# This script generates the output structure from source files.
#
# Directory Structure:
#   agents/{category}/           - Source agent files
#   plugins/{name}/.claude-plugin/ - Plugin definitions
#   output/.claude/              - Generated output directory
#
# The script:
#   - Scans agents/ for all .md files
#   - Copies to output/.claude/agents/ (flat structure)
#   - Generates output/.claude/settings.json with absolute paths
#
# Usage:
#   ./installer/cli/build.sh
#
# Output:
#   output/.claude/agents/       - Flat agent definitions
#   output/.claude/settings.json - Settings with absolute paths

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AGENTS_DIR="$PROJECT_ROOT/agents"
OUTPUT_DIR="$PROJECT_ROOT/output/.claude"
OUTPUT_AGENTS_DIR="$OUTPUT_DIR/agents"

echo "=========================================="
echo "  cc-lib Build"
echo "=========================================="
echo "Source: $AGENTS_DIR"
echo "Output: $OUTPUT_DIR"
echo

# Ensure output directory exists first (idempotent: create if needed)
mkdir -p "$OUTPUT_AGENTS_DIR"

# Clear agents output directory (now safe since directory exists)
rm -rf "$OUTPUT_AGENTS_DIR"/*

# Counter for statistics
total_files=0
copied_files=0
skipped_files=0

# Process all .md files in agents/ directory tree
# Using process substitution to avoid subshell and keep variables
while IFS= read -r -d '' source_file; do
    # Get the filename (without path)
    filename=$(basename "$source_file")
    total_files=$((total_files + 1))

    echo "Processing: $source_file"

    # Check if it's a symbolic link
    if [ -L "$source_file" ]; then
        # Resolve the symbolic link
        target_file=$(readlink -f "$source_file")

        if [ -f "$target_file" ]; then
            # Copy the target file
            cp "$target_file" "$OUTPUT_AGENTS_DIR/$filename"
            echo "  → Resolved symlink and copied: $filename"
            copied_files=$((copied_files + 1))
        else
            echo "  ⚠ Warning: Broken symlink, skipping: $filename"
            skipped_files=$((skipped_files + 1))
        fi
    else
        # Regular file, copy as-is
        cp "$source_file" "$OUTPUT_AGENTS_DIR/$filename"
        echo "  → Copied: $filename"
        copied_files=$((copied_files + 1))
    fi
done < <(find "$AGENTS_DIR" -name "*.md" -print0)

# Generate settings.json with absolute paths for local marketplace and plugins
SETTINGS_FILE="$OUTPUT_DIR/settings.json"

echo
echo "Generating settings.json..."

# Create settings.json with absolute paths using jq for proper formatting
jq -n \
  --arg marketplaces "$PROJECT_ROOT/.claude-plugin/marketplace.json" \
  --args \
  '{
    version: "1.0",
    marketplaces: [$marketplaces],
    plugins: [. as $plugins | $ARGS.positional[]
      | select(. != "")
    ]
  }' \
  "$PROJECT_ROOT"/plugins/*/.claude-plugin > "$SETTINGS_FILE"

echo "  → Created: $SETTINGS_FILE"

echo
echo "=========================================="
echo "  ✓ Build Complete!"
echo "=========================================="
echo "Output directory: $OUTPUT_DIR"
echo
echo "Statistics:"
echo "  Total files found: $total_files"
echo "  Files copied: $copied_files"
echo "  Files skipped (broken symlinks): $skipped_files"
echo
echo "Generated files:"
ls -la "$OUTPUT_DIR"
