# cc-lib

A curated plugin marketplace for Claude Code, providing specialized AI agents for development productivity.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Compatible-orange.svg)](https://claude.com/claude-code)

## Overview

**cc-lib** is a collection of production-ready plugins that extend Claude Code's capabilities. Each plugin contains specialized agents designed for specific development tasks - from code reviews and testing to documentation generation and autonomous development loops.

### What It Provides

| Category | Plugins | Agents |
|----------|---------|--------|
| **Orchestration** | `orch` | Task orchestration, parallel execution, context management |
| **Testing** | `test` | Test generation, execution, and failure resolution |
| **Code Review** | `revu` | Code, architecture, security, documentation, and commit reviews |
| **Feature Dev** | `feat` | Design, implementation planning, and scaffolding |
| **Documentation** | `docu` | API docs, README generation, code explanation |
| **Debugging** | `fix` | Code cleaning and systematic debugging |
| **Autonomous** | `ralph` | RALPH - iterative autonomous development loop |

## Installation

### Add the Marketplace

```bash
/plugin marketplace add k-park/cc-lib
```

### Install Plugins

```bash
# Orchestration - complex task coordination
/plugin install orch@cc-lib

# Testing - complete test workflow
/plugin install test@cc-lib

# Code Review - multi-dimensional code analysis
/plugin install revu@cc-lib

# Feature Development - from design to implementation
/plugin install feat@cc-lib

# Documentation - generate docs automatically
/plugin install docu@cc-lib

# Debugging - clean and fix code
/plugin install fix@cc-lib

# RALPH - autonomous iterative development
/plugin install ralph@cc-lib
```

### Manage Plugins

```bash
/plugin list                    # List installed plugins
/plugin info orch               # Show plugin details
/plugin remove orch@cc-lib      # Remove a plugin
```

## Plugins

### orch - Orchestration

Agent orchestration for complex multi-faceted tasks with parallel execution and context management.

| Agent | Description |
|-------|-------------|
| `orch:task` | Complex task delegation and multi-agent coordination |
| `orch:parallel` | Break down tasks into parallel executable subtasks |
| `orch:context` | Context management for multi-step workflows |

### test - Testing

Complete testing workflow - generate tests, run them, and fix failures automatically.

| Agent | Description |
|-------|-------------|
| `test:gen` | Generate comprehensive tests (unit, integration, edge cases) |
| `test:run` | Execute tests and analyze results with actionable feedback |
| `test:fix` | Fix failing tests by analyzing root causes and implementing corrections |

### revu - Code Review

Multi-dimensional code review covering quality, security, architecture, and documentation.

| Agent | Description |
|-------|-------------|
| `revu:code` | Code quality, style, potential bugs, performance, and maintainability |
| `revu:arch` | Architecture review for design patterns and SOLID principles |
| `revu:sec` | Security vulnerabilities and OWASP Top 10 compliance |
| `revu:doc` | Documentation completeness, clarity, and accuracy |
| `revu:commit` | Commit message quality and conventional compliance |

### feat - Feature Development

Feature development agents covering design, implementation, and scaffolding.

| Agent | Description |
|-------|-------------|
| `feat:design` | Feature planning, requirements analysis, and API design |
| `feat:impl` | Implementation planning with code structure and integration points |
| `feat:scaffold` | Project scaffolding with file structure and boilerplate |

### docu - Documentation

Documentation generation for APIs, READMEs, and code explanations.

| Agent | Description |
|-------|-------------|
| `docu:gen` | Generate API documentation from code |
| `docu:readme` | Create comprehensive project README files |
| `docu:explain` | Explain code logic and architecture |

### fix - Debugging

Code cleaning and systematic debugging agents.

| Agent | Description |
|-------|-------------|
| `fix:clean` | Refactor code, remove technical debt, improve maintainability |
| `fix:debug` | Systematic debugging with root cause analysis |

### ralph - Autonomous Loop

RALPH (Recursively Adaptive Loop for Progressive Habitability) - autonomous iterative development.

| Command | Description |
|---------|-------------|
| `ralph:go` | Start autonomous iterative development loop |
| `ralph:stop` | Stop the RALPH loop gracefully with completion summary |

## Usage Examples

### Orchestrate Complex Tasks

```bash
# Delegate complex feature to orchestrator
"Build a user authentication system with OAuth2, login UI, and backend APIs"
# Claude automatically delegates to specialized sub-agents in parallel
```

### Complete Testing Workflow

```bash
/test:gen        # Generate tests for new feature
/test:run        # Run tests and see results
/test:fix        # Automatically fix any failing tests
```

### Code Review

```bash
/revu:code       # Review code quality
/revu:sec        # Check for security issues
/revu:arch       # Evaluate architecture decisions
```

### Feature Development

```bash
/feat:design     # Plan the feature architecture
/feat:impl       # Get implementation steps
/feat:scaffold   # Generate project structure
```

### Autonomous Development

```bash
/ralph:go        # Let Claude work until completion
/ralph:stop      # Stop and get summary
```

## For Developers

### Project Structure

```
cc-lib/
├── agents/              # Source agent definitions
│   ├── debugging/       # Debugging agents
│   ├── documentation/   # Documentation agents
│   ├── feature/         # Feature development agents
│   ├── orchestration/   # Orchestration agents
│   ├── ralph/           # RALPH agents
│   ├── reviews/         # Review agents
│   └── testing/         # Testing agents
│
├── plugins/             # Plugin distribution structure
│   ├── docu/           # Documentation plugin
│   ├── feat/           # Feature development plugin
│   ├── fix/            # Debugging plugin
│   ├── orch/           # Orchestration plugin
│   ├── ralph/          # RALPH plugin
│   ├── revu/           # Code review plugin
│   └── test/           # Testing plugin
│
├── installer/          # Build and installation tools
│   ├── cli/build.sh    # Build script
│   ├── sets/           # Installation presets
│   └── templates/      # Settings templates
│
└── output/.claude/     # Build output (flat structure)
```

### Building

```bash
# Run the build script
./installer/cli/build.sh

# Output is generated in output/.claude/
```

The build process:
1. Scans `agents/` for all `.md` files
2. Resolves symbolic links from plugins
3. Copies files to `output/.claude/agents/` (flat structure)
4. Generates `output/.claude/settings.json` with absolute paths

### Creating Agents

Each agent is a Markdown file with YAML frontmatter:

```yaml
---
name: agent-id
description: What this agent does (50-1000 characters)
model: sonnet  # sonnet|haiku|opus
color: blue    # optional
tags: [category, keywords]
examples:
  - context: When to use this agent
    input: Example input
    output: Expected output
    explanation: Why it works
---
```

## Installation Presets

Pre-configured agent sets for different environments:

| Preset | Environment | Description |
|--------|-------------|-------------|
| `minimal` | PC | Minimal set for basic usage |
| `developer` | PC | Full-featured development environment |
| `mobile-basic` | Mobile | Lightweight agents for mobile |
| `server-ci` | Server | CI/CD pipeline automation |

## Documentation

- [Product Requirements](./PRD/) - Complete PRD
- [Troubleshooting](./docs/troubleshooting/) - Common issues and fixes
- [Plans](./docs/plans/) - Working and draft plans

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please see our contributing guidelines for details.

---

Made with [Claude Code](https://claude.com/claude-code)
