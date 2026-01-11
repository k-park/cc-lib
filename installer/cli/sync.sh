#!/bin/bash
# sync.sh - Build agents/ directory to output/.claude/agents/
#
# This script builds a flat agent structure from the categorized source files.
#
# Directory Structure:
#   agents/{category}/           - Real source files (by category)
#   plugins/{name}/agents/       - Symlinks to agents/ (for plugin distribution)
#   output/.claude/agents/       - Flat build output (gitignored)
#
# The script:
#   - Scans agents/ for all .md files (real source files)
#   - Copies files to output/.claude/agents/ (flat structure)
#   - Handles both regular files and symbolic links for compatibility
#
# Usage:
#   ./installer/cli/sync.sh
#
# Output:
#   Creates output/.claude/agents/ with all agent definitions in a flat structure
#   Ready for deployment to .claude/agents/ or distribution via marketplace

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AGENTS_DIR="$PROJECT_ROOT/agents"
OUTPUT_DIR="$PROJECT_ROOT/output/.claude/agents"

echo "=========================================="
echo "  cc-lib Agent Build Script"
echo "=========================================="
echo "Source: $AGENTS_DIR"
echo "Output: $OUTPUT_DIR"
echo

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Clear output directory
rm -rf "$OUTPUT_DIR"/*
mkdir -p "$OUTPUT_DIR"

# Counter for statistics
total_files=0
copied_files=0
skipped_files=0

# Process all .md files in agents/ directory tree
find "$AGENTS_DIR" -name "*.md" -print0 | while IFS= read -r -d '' source_file; do
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
            cp "$target_file" "$OUTPUT_DIR/$filename"
            echo "  → Resolved symlink and copied: $filename"
            copied_files=$((copied_files + 1))
        else
            echo "  ⚠ Warning: Broken symlink, skipping: $filename"
            skipped_files=$((skipped_files + 1))
        fi
    else
        # Regular file, copy as-is
        cp "$source_file" "$OUTPUT_DIR/$filename"
        echo "  → Copied: $filename"
        copied_files=$((copied_files + 1))
    fi
done

echo
echo "=========================================="
echo "  ✓ Build Complete!"
echo "=========================================="
echo "Output directory: $OUTPUT_DIR"
echo
echo "To deploy to your project:"
echo "  cp -r output/.claude/agents/ ~/.claude/agents/"
echo
ls -la "$OUTPUT_DIR"
