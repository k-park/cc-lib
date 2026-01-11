# Architecture

**Version**: 1.1.0
**Last Updated**: 2026-01-11
**Status**: Draft

## System Architecture Diagram

```mermaid
graph TB
    subgraph User_Layer ["User Layer"]
        CC["Claude Code"]
        CLI["Terminal (CLI)"]
        GH["GitHub (PR/Issues)"]
    end

    subgraph Interface_Layer ["Interface Layer"]
        MP["Marketplace Catalog (marketplace.json)<br/>- Plugin metadata<br/>- Source locations<br/>- Version information"]
    end

    subgraph Plugin_Layer ["Plugin Layer"]
        subgraph Plugins ["plugins/ (Symlinks)"]
            P1["orchestration/"]
            P2["code-review/"]
            P3["testing/"]
        end
        subgraph Agents ["agents/ (Real Files)"]
            A1["orchestration/"]
            A2["code-review/"]
            A3["testing/"]
        end
        subgraph Installer ["installer/ (Build)"]
            I1["cli/sync.sh"]
            I2["sets/"]
            I3["templates/"]
        end
        Plugins -.->|"symlinks"| Agents
    end

    subgraph Build_Layer ["Build Layer"]
        SYNC["sync.sh (Build Script)<br/>1. Scan agents/ for .md files<br/>2. Copy regular files<br/>3. Output to output/.claude/agents/ (flat)"]
    end

    subgraph Output_Layer ["Output Layer"]
        OUT["output/.claude/agents/ (gitignored)<br/>- Flat structure<br/>- Real files<br/>- Ready for Claude Code"]
    end

    subgraph User_Claude ["User Environment"]
        UC[".claude/agents/<br/>(Copied from output/)"]
    end

    User_Layer --> Interface_Layer
    Interface_Layer --> Plugin_Layer
    Plugin_Layer --> Build_Layer
    Build_Layer --> Output_Layer
    Output_Layer --> User_Claude
```

## Component Relationships

```mermaid
graph LR
    MP["marketplace.json"]
    PC["Plugin Catalog"]
    PLUGINS["plugins/{name}/"]
    AGENTS["agents/{category}/"]
    SYNC["sync.sh"]
    OUTPUT["output/.claude/agents/"]
    USER[".claude/agents/"]
    CLAUDE["Claude Code (Plugin API)"]

    MP -->|"defines"| PC
    MP -->|"references"| PLUGINS
    MP -->|"consumed by"| CLAUDE

    PLUGINS -->|"symlinks to"| AGENTS
    AGENTS -->|"scanned by"| SYNC
    SYNC -->|"produces"| OUTPUT
    OUTPUT -->|"copied by user"| USER
```

**Important**: `plugins/{name}/agents/` contains **symbolic links** to `agents/{category}/`. The `agents/` directory contains the **real source files**.

## Data Flow

### Plugin Discovery Flow

```mermaid
sequenceDiagram
    participant User
    participant ClaudeCode as Claude Code
    participant GitHub as GitHub
    participant Marketplace as marketplace.json

    User->>ClaudeCode: /plugin marketplace add k-park/cc-lib
    ClaudeCode->>GitHub: GET marketplace.json
    GitHub-->>ClaudeCode: marketplace.json
    ClaudeCode->>Marketplace: Parse plugin catalog
    Marketplace-->>ClaudeCode: plugins: [{ name, source, ... }]
    ClaudeCode-->>User: Display available plugins
```

### Plugin Installation Flow

```mermaid
sequenceDiagram
    participant User
    participant ClaudeCode as Claude Code
    participant GitHub as GitHub
    participant Local as .claude/

    User->>ClaudeCode: /plugin install orchestration@cc-lib
    ClaudeCode->>GitHub: Download plugin files
    GitHub-->>ClaudeCode: Plugin files
    ClaudeCode->>Local: Copy to ~/.claude/plugins/orchestration/
    ClaudeCode->>Local: Enable in settings.json
    Note over Local: "enabledPlugins": { "orchestration@cc-lib": true }
    ClaudeCode-->>User: Successfully installed
    ClaudeCode->>ClaudeCode: Auto-discovery & load agents
```

### Build Flow (Development)

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Agents as agents/{category}/
    participant Plugins as plugins/{name}/agents/
    participant Sync as sync.sh
    participant Output as output/.claude/agents/
    participant UserEnv as .claude/agents/

    Dev->>Agents: Create/modify agent .md file
    Note over Agents: Real source files
    Dev->>Plugins: Create symlinks to agents/
    Note over Plugins: ln -s ../../../agents/{category}/file.md
    Dev->>Sync: ./installer/cli/sync.sh
    Sync->>Agents: Scan for .md files
    Sync->>Output: Copy to flat structure
    Note over Output: Resolved files (no symlinks)
    Dev->>UserEnv: cp -r output/.claude/agents/ .claude/agents/
```

## Directory Structure Detail

```
cc-lib/
│
├── .claude-plugin/                  # Marketplace root
│   └── marketplace.json            # Plugin catalog
│
├── plugins/                        # Plugin structure (symlinks to agents/)
│   └── orchestration/              # Plugin: orchestration
│       ├── .claude-plugin/
│       │   └── plugin.json         # Plugin manifest
│       └── agents/                 # Symbolic links to agents/
│           ├── task-orchestrator.md → ../../../agents/orchestration/task-orchestrator.md
│           └── parallel-task-orchestrator.md → ../../../agents/orchestration/parallel-task-orchestrator.md
│
├── agents/                         # Real agent source files (by category)
│   ├── orchestration/              # Real files
│   │   ├── task-orchestrator.md
│   │   └── parallel-task-orchestrator.md
│   ├── code-review/                # (future)
│   ├── testing/                    # (future)
│   └── ...
│
├── installer/                      # Build & installation tools
│   ├── cli/
│   │   └── sync.sh                # Build script
│   ├── sets/                      # Predefined installation sets
│   │   ├── mobile-basic.json
│   │   ├── developer.json
│   │   └── server-ci.json
│   ├── templates/                 # settings.json templates
│   └── schemas/                   # JSON schemas for validation
│
└── output/.claude/agents/          # Build output (flat, gitignored)
    ├── task-orchestrator.md       # Copied from agents/
    └── parallel-task-orchestrator.md
```

## Key Design Decisions

### Decision 1: Symbolic Links for Plugin Organization

**Problem**: 플러그인을 어떻게 조직할 것인가?

**Options**:
1. 플랫 구조: 모든 에이전트를 하나의 디렉토리에
2. 플러그인별 구조: plugins/ 아래에만 두기
3. **카테고리별 심볼릭 링크** (선택)

**Rationale**:
- `agents/` 에 실제 소스 파일 위치 (카테고리별 조직)
- `plugins/{name}/agents/` 에 심볼릭 링크로 참조
- 두 가지 관점 모두 지원:
  - 카테고리별 검색 (`agents/orchestration/`)
  - 플러그인별 배포 (`plugins/orchestration/`)

### Decision 2: Build Output in Separate Directory

**Problem**: 빌드 결과를 어디에 둘 것인가?

**Options**:
1. 제자리에 덮어쓰기
2. **output/ 디렉토리에 저장** (선택)
3. 사용자 홈 디렉토리에 저장

**Rationale**:
- Git 추적 방지 (gitignore)
- 원본 소스 보존
- 사용자가 선택적으로 복사

### Decision 3: GitHub as Marketplace

**Problem**: 마켓플레이스를 어떻게 호스팅할 것인가?

**Options**:
1. 전용 마켓플레이스 서버
2. **GitHub 저장소** (선택)
3. NPM 레지스트리

**Rationale**:
- 별도 인프라 불필요
- Git으로 버전 관리
- Claude Code가 기본 지원

## Technology Stack

| Layer | Technology |
|-------|------------|
| Marketplace | GitHub + JSON |
| Plugin Format | Markdown + YAML frontmatter |
| Build Script | Bash |
| Validation | JSON Schema |
| Distribution | Git |

## Security Architecture

```mermaid
graph TB
    subgraph Security ["Security Layers"]
        V["Plugin Validation<br/>- JSON Schema validation<br/>- Required fields check<br/>- Format validation (kebab-case)"]
        S["Sandbox Execution<br/>- Plugins run in Claude Code sandbox<br/>- No direct system access<br/>- Resource limits"]
        U["User Control<br/>- Explicit enable/disable<br/>- Source transparency (GitHub)<br/>- No auto-execution"]
    end

    V --> S --> U
```

## Scalability Considerations

| Aspect | Current Limit | Future Scale |
|--------|---------------|--------------|
| Plugins | 1 | 100+ |
| Agents per Plugin | 2 | 10+ |
| Marketplace Load | N/A | CDN |
| Concurrent Users | 1 | Team/Enterprise |

## References

- [Claude Code Plugin Architecture](https://code.claude.com/docs/en/plugins)
- [Microservices Architecture Patterns](https://martinfowler.com/articles/microservices.html)
