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
#   ./installer/cli/build.sh [options]
#
# Options:
#   --dry-run, -n    Show what would be done without making changes
#   --verbose, -v    Enable verbose output for debugging
#
# Output:
#   output/.claude/agents/       - Flat agent definitions
#   output/.claude/settings.json - Settings with absolute paths

set -eu

# ============================================================================
# CONFIGURATION
# ============================================================================

# Parse command line arguments
DRY_RUN=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--dry-run] [--verbose]"
            echo "  --dry-run, -n    Show what would be done without making changes"
            echo "  --verbose, -v    Enable verbose output for debugging"
            echo "  --help, -h       Show this help message"
            exit 0
            ;;
        *)
            echo "Error: Unknown option: $1" >&2
            echo "Use --help for usage information" >&2
            exit 1
            ;;
    esac
done

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

# Validate required directories exist
validate_prerequisites() {
    local errors=0

    # Check required commands
    if ! command -v jq >/dev/null 2>&1; then
        echo "Error: Required command 'jq' not found. Please install jq." >&2
        errors=$((errors + 1))
    fi

    if [ ! -d "$AGENTS_DIR" ]; then
        echo "Error: Agents directory not found: $AGENTS_DIR" >&2
        errors=$((errors + 1))
    fi

    if [ ! -d "$PLUGINS_DIR" ]; then
        echo "Error: Plugins directory not found: $PLUGINS_DIR" >&2
        errors=$((errors + 1))
    fi

    if [ ! -f "$MARKETPLACE_FILE" ]; then
        echo "Error: Marketplace file not found: $MARKETPLACE_FILE" >&2
        errors=$((errors + 1))
    fi

    if [ $errors -gt 0 ]; then
        echo "Error: $errors prerequisite(s) failed. Aborting." >&2
        exit 1
    fi
}

# Cleanup handler for interrupts
cleanup_on_interrupt() {
    local exit_code=$?
    echo

    if [ $exit_code -eq 0 ]; then
        echo "Build interrupted"
        exit 130  # SIGINT standard exit code
    else
        echo "Build failed (exit code: $exit_code)"

        # Clean up partial output if directory exists and has files
        if [ -d "$OUTPUT_AGENTS_DIR" ] && [ -n "$(ls -A "$OUTPUT_AGENTS_DIR" 2>/dev/null)" ]; then
            echo "Cleaning up partial output..."
            rm -rf "$OUTPUT_AGENTS_DIR"/*
        fi

        exit $exit_code
    fi
}

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

# Log debug messages (only when VERBOSE=true)
log_debug() {
    if [ "$VERBOSE" = "true" ]; then
        echo "[DEBUG] $*" >&2
    fi
}

# Process a single agent file (handles both regular files and symlinks)
# Args: source_file, output_dir
# Returns: 0 on success, 1 on failure (broken symlink)
process_agent_file() {
    local source_file="$1"
    local output_dir="$2"
    local filename
    filename=$(basename "$source_file")

    log_debug "Processing file: $source_file"

    if [ "$DRY_RUN" = "true" ]; then
        echo "  [DRY RUN] Would copy: $filename"
        return 0
    fi

    if [ -L "$source_file" ]; then
        # Resolve and copy symlink target
        local target_file
        target_file=$(readlink -f "$source_file")

        if [ -f "$target_file" ]; then
            cp "$target_file" "$output_dir/$filename"
            echo "  → Resolved symlink and copied: $filename"
            log_debug "  Symlink target: $target_file"
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
# Args: plugins_dir, marketplace_file, output_file
generate_settings_file() {
    local plugins_dir="$1"
    local marketplace_file="$2"
    local output_file="$3"

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
    # Set up interrupt handler
    trap cleanup_on_interrupt INT

    # Validate prerequisites
    validate_prerequisites

    print_header "cc-lib Build"
    print_info "Source: $AGENTS_DIR"
    print_info "Output: $OUTPUT_DIR"

    if [ "$DRY_RUN" = "true" ]; then
        print_info "Mode: DRY RUN (no changes will be made)"
    fi

    if [ "$VERBOSE" = "true" ]; then
        print_info "Mode: VERBOSE (debug output enabled)"
    fi

    echo

    # Ensure output directory exists first (idempotent: create if needed)
    if [ "$DRY_RUN" = "false" ]; then
        mkdir -p "$OUTPUT_AGENTS_DIR"

        # Clear agents output directory (now safe since directory exists)
        rm -rf "$OUTPUT_AGENTS_DIR"/*
    fi

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
    if [ "$DRY_RUN" = "true" ]; then
        echo "[DRY RUN] Would generate: $settings_file"
        log_debug "Plugins dir: $PLUGINS_DIR"
        log_debug "Marketplace file: $MARKETPLACE_FILE"
    else
        echo "Generating settings.json..."
        generate_settings_file "$PLUGINS_DIR" "$MARKETPLACE_FILE" "$settings_file"
        echo "  → Created: $settings_file"
    fi

    # Print completion
    print_header "✓ Build Complete!"
    print_info "Output directory: $OUTPUT_DIR"
    print_statistics "$total_files" "$copied_files" "$skipped_files"
    echo
    echo "Generated files:"
    ls -la "$OUTPUT_DIR"
}

main "$@"
