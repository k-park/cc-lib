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

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly AGENTS_DIR="$PROJECT_ROOT/agents"
readonly OUTPUT_DIR="$PROJECT_ROOT/output/.claude"
readonly OUTPUT_AGENTS_DIR="$OUTPUT_DIR/agents"
readonly PLUGINS_DIR="$PROJECT_ROOT/plugins"
readonly MARKETPLACE_FILE="$PROJECT_ROOT/.claude-plugin/marketplace.json"

# ============================================================================
# FUNCTIONS
# ============================================================================

# Print header with title
print_header() {
    local title="$1"
    echo "=========================================="
    echo "  $title"
    echo "=========================================="
}

# Print section info
print_info() {
    echo "$@"
}

# Process a single agent file (handles both regular files and symlinks)
# Args: source_file, output_dir
# Returns: 0 on success, 1 on failure (broken symlink)
process_agent_file() {
    local source_file="$1"
    local output_dir="$2"
    local filename
    filename=$(basename "$source_file")

    if [ -L "$source_file" ]; then
        # Resolve and copy symlink target
        local target_file
        target_file=$(readlink -f "$source_file")

        if [ -f "$target_file" ]; then
            cp "$target_file" "$output_dir/$filename"
            echo "  → Resolved symlink and copied: $filename"
            return 0
        else
            echo "  ⚠ Warning: Broken symlink, skipping: $filename"
            return 1
        fi
    else
        # Copy regular file
        cp "$source_file" "$output_dir/$filename"
        echo "  → Copied: $filename"
        return 0
    fi
}

# Generate settings.json with absolute paths
# Args: project_root, plugins_dir, marketplace_file, output_file
generate_settings_file() {
    local project_root="$1"
    local plugins_dir="$2"
    local marketplace_file="$3"
    local output_file="$4"

    jq -n \
        --arg marketplaces "$marketplace_file" \
        --args \
        '{
        version: "1.0",
        marketplaces: [$marketplaces],
        plugins: [. as $plugins | $ARGS.positional[]
            | select(. != "")
        ]
        }' \
        "$plugins_dir"/*/.claude-plugin > "$output_file"
}

# Print build statistics
print_statistics() {
    local total="$1"
    local copied="$2"
    local skipped="$3"

    echo
    echo "Statistics:"
    echo "  Total files found: $total"
    echo "  Files copied: $copied"
    echo "  Files skipped (broken symlinks): $skipped"
}

# ============================================================================
# MAIN
# ============================================================================

# Main execution
main() {
    print_header "cc-lib Build"
    print_info "Source: $AGENTS_DIR"
    print_info "Output: $OUTPUT_DIR"
    echo

    # Ensure output directory exists first (idempotent: create if needed)
    mkdir -p "$OUTPUT_AGENTS_DIR"

    # Clear agents output directory (now safe since directory exists)
    rm -rf "$OUTPUT_AGENTS_DIR"/*

    # Counter for statistics
    local total_files=0
    local copied_files=0
    local skipped_files=0

    # Process all .md files in agents/ directory tree
    while IFS= read -r -d '' source_file; do
        total_files=$((total_files + 1))
        echo "Processing: $source_file"

        if process_agent_file "$source_file" "$OUTPUT_AGENTS_DIR"; then
            copied_files=$((copied_files + 1))
        else
            skipped_files=$((skipped_files + 1))
        fi
    done < <(find "$AGENTS_DIR" -name "*.md" -print0)

    # Generate settings.json
    local settings_file="$OUTPUT_DIR/settings.json"
    echo
    echo "Generating settings.json..."
    generate_settings_file "$PROJECT_ROOT" "$PLUGINS_DIR" "$MARKETPLACE_FILE" "$settings_file"
    echo "  → Created: $settings_file"

    # Print completion
    print_header "✓ Build Complete!"
    print_info "Output directory: $OUTPUT_DIR"
    print_statistics "$total_files" "$copied_files" "$skipped_files"
    echo
    echo "Generated files:"
    ls -la "$OUTPUT_DIR"
}

main "$@"
