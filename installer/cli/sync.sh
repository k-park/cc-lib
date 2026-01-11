#!/bin/bash
# sync.sh - Build agents/ directory to output/.claude/agents/
#
# This script:
# - Resolves symbolic links and copies the target file
# - Copies regular files as-is
# - Outputs to flat structure in output/.claude/agents/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AGENTS_DIR="$PROJECT_ROOT/agents"
OUTPUT_DIR="$PROJECT_ROOT/output/.claude/agents"

echo "Building agents..."
echo "Source: $AGENTS_DIR"
echo "Output: $OUTPUT_DIR"
echo

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Clear output directory
rm -rf "$OUTPUT_DIR"/*
mkdir -p "$OUTPUT_DIR"

# Process all .md files in agents/ directory tree
find "$AGENTS_DIR" -name "*.md" -print0 | while IFS= read -r -d '' source_file; do
    # Get the filename (without path)
    filename=$(basename "$source_file")

    echo "Processing: $source_file"

    # Check if it's a symbolic link
    if [ -L "$source_file" ]; then
        # Resolve the symbolic link
        target_file=$(readlink -f "$source_file")

        if [ -f "$target_file" ]; then
            # Copy the target file
            cp "$target_file" "$OUTPUT_DIR/$filename"
            echo "  → Resolved symlink and copied: $filename"
        else
            echo "  ⚠ Warning: Broken symlink, skipping: $filename"
        fi
    else
        # Regular file, copy as-is
        cp "$source_file" "$OUTPUT_DIR/$filename"
        echo "  → Copied: $filename"
    fi
done

echo
echo "✓ Build complete!"
echo "Files in output/.claude/agents/:"
ls -la "$OUTPUT_DIR"
