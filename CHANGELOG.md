# Changelog

## [Unreleased]

### BREAKING CHANGE: agent frontmatter `name` 정규화

plugin agent 프론트매터 `name` 을 파일명(= sub-name)과 일치시켜 Claude Code 가 노출하는 식별자를 `{plugin}:{sub}` 로 통일했다. 기존에는 commands 는 `{plugin}:{sub}` 였지만 agents 는 `docu-gen`, `review-code`, `task-orchestrator` 등 하이픈/임의 네이밍이라 실제 호출 식별자가 `docu:docu-gen`, `revu:review-code`, `orch:task-orchestrator` 로 불일치했다.

#### 매핑 (구 → 신 identifier)

| 구 identifier | 신 identifier |
|---|---|
| `docu:docu-gen` | `docu:gen` |
| `docu:docu-readme` | `docu:readme` |
| `docu:docu-explain` | `docu:explain` |
| `revu:review-code` | `revu:code` |
| `revu:review-arch` | `revu:arch` |
| `revu:review-sec` | `revu:sec` |
| `revu:review-doc` | `revu:doc` |
| `revu:review-commit` | `revu:commit` |
| `orch:task-orchestrator` | `orch:task` |
| `orch:parallel-task-orchestrator` | `orch:parallel` |
| `orch:context` | `orch:context` (변경 없음) |
| `feat:feat-design` | `feat:design` |
| `feat:feat-impl` | `feat:impl` |
| `feat:feat-scaffold` | `feat:scaffold` |
| `fix:fix-clean` | `fix:clean` |
| `fix:fix-debug` | `fix:debug` |
| `test:test-gen` | `test:gen` |
| `test:test-run` | `test:run` |
| `test:test-fix` | `test:fix` |

#### 마이그레이션

기존 식별자로 agent 를 호출하던 스킬·워크플로·문서는 위 표대로 교체해야 한다. Alias 는 제공하지 않는다.

#### 범위 밖

- `installer/` 의 `task-orchestrator`·`parallel-task-orchestrator` 이름은 의미(meaning-first) 기반 원본 식별자이므로 유지.
- 파일명 자체는 변경 없음 (예: `agents/orchestration/task.md` 그대로).
