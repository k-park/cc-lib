# Architecture

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              cc-lib System                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                         User Layer                               │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │   │
│  │  │   Claude     │  │   Terminal   │  │   GitHub     │          │   │
│  │  │   Code       │  │   (CLI)      │  │   (PR/Issues) │          │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘          │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                 │                                     │
│                                 ▼                                     │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                      Interface Layer                            │   │
│  │  ┌────────────────────────────────────────────────────────────┐  │   │
│  │  │           Marketplace Catalog (marketplace.json)          │  │   │
│  │  │  - Plugin metadata                                         │  │   │
│  │  │  - Source locations                                        │  │   │
│  │  │  - Version information                                     │  │   │
│  │  └────────────────────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                 │                                     │
│                                 ▼                                     │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                        Plugin Layer                             │   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌────────────────┐  │   │
│  │  │   plugins/      │  │    agents/      │  │   installer/   │  │   │
│  │  │   (Source)      │◀─┤    (Symlinks)   │    │   (Build)      │  │   │
│  │  │                 │  │                 │  │                 │  │   │
│  │  │ orchestration/  │  │ orchestration/  │  │ cli/sync.sh    │  │   │
│  │  │ code-review/    │  │ code-review/    │  │ sets/          │  │   │
│  │  │ testing/        │  │ testing/        │  │ templates/     │  │   │
│  │  └─────────────────┘  └─────────────────┘  └────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                 │                                     │
│                                 ▼                                     │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                        Build Layer                              │   │
│  │  ┌────────────────────────────────────────────────────────────┐  │   │
│  │  │              sync.sh (Build Script)                        │  │   │
│  │  │  1. Scan agents/ for .md files                             │  │   │
│  │  │  2. Resolve symlinks → copy target                         │  │   │
│  │  │  3. Copy regular files                                     │  │   │
│  │  │  4. Output to output/.claude/agents/ (flat)               │  │   │
│  │  └────────────────────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                 │                                     │
│                                 ▼                                     │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                       Output Layer                              │   │
│  │  ┌────────────────────────────────────────────────────────────┐  │   │
│  │  │          output/.claude/agents/ (gitignored)               │  │   │
│  │  │  - Flat structure                                         │  │   │
│  │  │  - Resolved symlinks (real files)                         │  │   │
│  │  │  - Ready for Claude Code                                   │  │   │
│  │  └────────────────────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                 │                                     │
└─────────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
                    ┌─────────────────────────────────┐
                    │         User's .claude/agents/    │
                    │  (Copied from output/.claude/)   │
                    └─────────────────────────────────┘
```

## Component Relationships

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Component Relationships                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  marketplace.json ───defines──> Plugin Catalog                          │
│       │                                                                │
│       ├──references──> plugins/{name}/                                 │
│       │                                                                  │
│       └──consumed by──> Claude Code (Plugin API)                       │
│                                                                          │
│  plugins/{name}/agents/ ───symlinks──> agents/{category}/                │
│       │                                                                  │
│       └──copied by──> sync.sh ───produces──> output/.claude/agents/      │
│                                │                                        │
│                                └──copied by user──> .claude/agents/       │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Data Flow

### Plugin Discovery Flow

```
1. User adds marketplace
   /plugin marketplace add k-park/cc-lib
       ↓
2. Claude Code fetches marketplace.json
   GET https://github.com/k-park/cc-lib/raw/main/.claude-plugin/marketplace.json
       ↓
3. Parse plugin catalog
   plugins: [{ name: "orchestration", source: "./plugins/orchestration" }]
       ↓
4. Display available plugins to user
```

### Plugin Installation Flow

```
1. User requests installation
   /plugin install orchestration@cc-lib
       ↓
2. Claude Code fetches plugin files
   Download from ./plugins/orchestration/
       ↓
3. Install to local .claude directory
   Copy to ~/.claude/plugins/orchestration/
       ↓
4. Enable plugin in settings.json
   "enabledPlugins": { "orchestration@cc-lib": true }
       ↓
5. Auto-discovery
   Claude Code scans and loads agents
```

### Build Flow (Development)

```
1. Developer creates plugin
   plugins/orchestration/agents/task-orchestrator.md
       ↓
2. Create category symlink
   ln -s ../../plugins/orchestration/agents/task-orchestrator.md
       ↓
3. Run build script
   ./installer/cli/sync.sh
       ↓
4. Generate flat structure
   output/.claude/agents/task-orchestrator.md (resolved, copied)
       ↓
5. Deploy to project
   cp -r output/.claude/agents/ .claude/agents/
```

## Directory Structure Detail

```
cc-lib/
│
├── .claude-plugin/                  # Marketplace root
│   └── marketplace.json            # Plugin catalog
│
├── plugins/                        # Plugin source (per plugin)
│   └── orchestration/              # Plugin: orchestration
│       ├── .claude-plugin/
│       │   └── plugin.json         # Plugin manifest
│       └── agents/                 # Agent definitions
│           ├── task-orchestrator.md
│           └── parallel-task-orchestrator.md
│
├── agents/                         # Category symlinks (by category)
│   ├── orchestration/              # → plugins/orchestration/agents/
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
    ├── task-orchestrator.md       # Resolved & copied
    └── parallel-task-orchestrator.md
```

## Key Design Decisions

### Decision 1: Symbolic Links for Categories

**Problem**: 플러그인을 어떻게 조직할 것인가?

**Options**:
1. 플랫 구조: 모든 에이전트를 하나의 디렉토리에
2. 플러그인별 구조: plugins/ 아래에만 두기
3. **카테고리별 심볼릭 링크** (선택)

**Rationale**:
- 플러그인 단위로 관리 (plugins/)
- 카테고리별로 참조 (agents/)
- 두 가지 관점 모두 지원

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
| Plugin Format | Markdown + YAML |
| Build Script | Bash |
| Validation | JSON Schema |
| Distribution | Git |

## Security Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Security Layers                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Plugin Validation                                           │
│     - JSON Schema validation                                   │
│     - Required fields check                                     │
│     - Format validation (kebab-case, etc.)                     │
│                                                                  │
│  2. Sandbox Execution                                          │
│     - Plugins run in Claude Code sandbox                        │
│     - No direct system access                                   │
│     - Resource limits                                           │
│                                                                  │
│  3. User Control                                               │
│     - Explicit enable/disable                                   │
│     - Source transparency (GitHub)                               │
│     - No auto-execution                                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
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
