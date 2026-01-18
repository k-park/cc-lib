# CC-LIB Validation Tests

This directory contains validation scripts for the cc-lib Claude Code plugin marketplace.

## Overview

Since cc-lib is a Markdown-based plugin distribution (not executable code), traditional unit tests don't apply. Instead, these scripts validate:

- **Plugin Structure**: Ensures all plugins have required files and configuration
- **YAML Frontmatter**: Validates agent metadata syntax
- **Markdown Quality**: Checks formatting and style consistency
- **Documentation Links**: Validates internal and external links
- **Build Process**: Tests the build script and output structure

## Prerequisites

### Required Tools

| Tool | Purpose | Install |
|------|---------|---------|
| `bash` | Script execution | Usually pre-installed |
| `python3` or `jq` | JSON validation | `pip install python3` or package manager |
| `yamllint` | YAML validation | `pip install yamllint` |
| `markdownlint-cli2` | Markdown linting | `npm install -g markdownlint-cli2` |
| `markdown-link-check` | Link validation | `npm install -g markdown-link-check` |

### Quick Install

```bash
# Install Python tools
pip3 install yamllint

# Install Node.js tools
npm install -g markdownlint-cli2 markdown-link-check
```

## Test Scripts

### Master Test Runner

```bash
./tests/validation/run-all.sh
```

Runs all validation tests in sequence and provides a summary report.

### Individual Tests

| Script | Description |
|--------|-------------|
| `test-plugins.sh` | Validates plugin structure, required files, and configuration |
| `yaml-lint.sh` | Validates YAML frontmatter in agent files |
| `markdown-lint.sh` | Checks Markdown formatting and style |
| `check-links.sh` | Validates documentation links |
| `test-build.sh` | Tests build script execution and output |

## Usage

### Run All Tests

```bash
# From project root
./tests/validation/run-all.sh
```

### Run Individual Tests

```bash
# Plugin structure validation
./tests/validation/test-plugins.sh

# YAML frontmatter validation
./tests/validation/yaml-lint.sh

# Markdown linting
./tests/validation/markdown-lint.sh

# Link checking
./tests/validation/check-links.sh

# Build validation
./tests/validation/test-build.sh
```

### CI/CD Integration

```bash
# In your CI pipeline
- ./tests/validation/run-all.sh
```

## Test Details

### 1. Plugin Structure Validation (`test-plugins.sh`)

Validates:
- Each plugin has `plugin.json` and `marketplace.json`
- Agent files have valid YAML frontmatter
- Required fields are present (name, description)
- Name format follows conventions
- Documentation is complete (README, LICENSE)
- Symbolic links are valid

### 2. YAML Frontmatter Validation (`yaml-lint.sh`)

Validates:
- YAML syntax is correct
- Indentation is consistent
- No trailing spaces
- Line length limits

### 3. Markdown Linting (`markdown-lint.sh`)

Checks:
- Line length (max 120 characters)
- Heading hierarchy
- Code block formatting
- List formatting
- Inconsistent styling

Configuration: `.markdownlint.json`

### 4. Link Validation (`check-links.sh`)

Validates:
- Internal markdown links
- External HTTP/HTTPS links
- No broken links
- Excludes localhost and anchor links

Configuration: `.markdown-link-check.json`

### 5. Build Validation (`test-build.sh`)

Tests:
- Build script exists and is executable
- Build script runs successfully
- Output directory structure is correct
- Agent files are copied properly
- `settings.json` is valid JSON
- Output files have valid frontmatter

## Configuration Files

### `.markdownlint.json`

Markdown linting rules and exceptions.

### `.markdownlink-check.json`

Link checking configuration:
- Ignore patterns for localhost
- Timeout settings
- Retry configuration
- Valid HTTP status codes

## Adding New Tests

To add a new validation test:

1. Create a new script in `tests/validation/`
2. Make it executable: `chmod +x tests/validation/your-test.sh`
3. Add it to `run-all.sh`:

```bash
run_test \
  "Your Test Name" \
  "$TESTS_DIR/your-test.sh" \
  "Description of what the test does."
```

## Troubleshooting

### Permission Denied

If you get "Permission denied" errors:

```bash
chmod +x tests/validation/*.sh
```

### Command Not Found

If a tool is not found, install it using the instructions in the Prerequisites section.

### False Positives

If a test reports false positives:

1. **Markdown linting**: Add exceptions to `.markdownlint.json`
2. **Link checking**: Add ignore patterns to `.markdown-link-check.json`
3. **YAML linting**: Adjust rule configurations in the script

## Output

All scripts provide color-coded output:

- 🟢 **Green**: Passed
- 🔴 **Red**: Failed
- 🟡 **Yellow**: Warning/Skipped

### Example Output

```
╔══════════════════════════════════════════════════════╗
║  CC-LIB Validation Test Suite                        ║
╚══════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Plugin Structure
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ PASS: orch has plugin.json
✅ PASS: test has plugin.json
...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Test Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✅ PASS Plugin Structure
  ✅ PASS YAML Frontmatter
  ✅ PASS Markdown Linting
  ✅ PASS Documentation Links
  ✅ PASS Build Script

─────────────────────────────────────────────────────────
  Total:   5
  Passed:  5
  Failed:  0
─────────────────────────────────────────────────────────

╔══════════════════════════════════════════════════════╗
║  🎉 ALL TESTS PASSED! 🎉                             ║
╚══════════════════════════════════════════════════════╝
```

## Contributing

When adding new plugins or agents:

1. Run the full test suite before committing
2. Fix any issues reported
3. Ensure all tests pass in CI/CD

## License

MIT License - see [LICENSE](../../LICENSE) for details.
