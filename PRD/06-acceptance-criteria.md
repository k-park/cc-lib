# Acceptance Criteria

**Version**: 1.0.0
**Last Updated**: 2026-01-11
**Status**: Draft

## Overview

각 기능에 대한 수락 기준을 정의합니다. 이는 기능이 완료되었는지 확인하는 데 사용됩니다.

## AC-1: Marketplace Catalog

### AC-1.1: marketplace.json 형식 검증

**Given**: `.claude-plugin/marketplace.json` 파일이 존재한다
**When**: 파일을 읽는다
**Then**:
- [ ] JSON 형식이 유효해야 한다
- [ ] `name` 필드가 존재하고 kebab-case 형식이어야 한다
- [ ] `owner.name` 필드가 존재해야 한다
- [ ] `plugins` 배열이 존재해야 한다
- [ ] 각 플러그인 엔트리에 `name`과 `source` 필드가 있어야 한다

### AC-1.2: GitHub에서 마켓플레이스 로드

**Given**: GitHub 저장소에 marketplace.json이 있다
**When**: `/plugin marketplace add <repo>`를 실행한다
**Then**:
- [ ] marketplace.json을 성공적으로 다운로드해야 한다
- [ ] 플러그인 목록을 표시해야 한다
- [ ] 에러 발생 시 명확한 메시지를 보여줘야 한다

## AC-2: 플러그인 발견

### AC-2.1: 플러그인 목록 표시

**Given**: cc-lib 마켓플레이스가 추가되어 있다
**When**: `/plugin list`를 실행한다
**Then**:
- [ ] 설치 가능한 모든 플러그인을 목록으로 표시해야 한다
- [ ] 각 플러그인의 이름, 설명, 버전을 보여줘야 한다
- [ ] 이미 설치된 플러그인은 표시해야 한다

### AC-2.2: 플러그인 상세 정보

**Given**: 플러그인이 존재한다
**When**: `/plugin info <plugin>`을 실행한다
**Then**:
- [ ] 플러그인의 전체 설명을 표시해야 한다
- [ ] 버전 정보를 표시해야 한다
- [ ] 카테고리와 태그를 표시해야 한다
- [ ] 작성자 정보를 표시해야 한다

## AC-3: 플러그인 설치

### AC-3.1: 일반 설치

**Given**: 설치하지 않은 플러그인이 있다
**When**: `/plugin install <plugin>@cc-lib`를 실행한다
**Then**:
- [ ] 설치 진행 상태를 표시해야 한다
- [ ] 플러그인 파일을 다운로드해야 한다
- [ ] 플러그인을 적절한 위치에 배치해야 한다
- [ ] "Successfully installed" 메시지를 표시해야 한다

### AC-3.2: 이미 설치된 플러그인

**Given**: 이미 설치된 플러그인이 있다
**When**: `/plugin install <plugin>@cc-lib`를 실행한다
**Then**:
- [ ] "Already installed" 메시지를 표시해야 한다
- [ ] 최신 버전이 있으면 업데이트 제안을 해야 한다

### AC-3.3: 설치 실패

**Given**: 존재하지 않는 플러그인이다
**When**: `/plugin install nonexistent@cc-lib`를 실행한다
**Then**:
- [ ] 에러 메시지를 표시해야 한다
- [ ] 사용 가능한 플러그인 목록을 제안해야 한다

## AC-4: 플러그인 제거

### AC-4.1: 정상 제거

**Given**: 설치된 플러그인이 있다
**When**: `/plugin remove <plugin>@cc-lib`를 실행한다
**Then**:
- [ ] 제거 확인 프롬프트를 표시해야 한다
- [ ] 확인 시 플러그인 파일을 삭제해야 한다
- [ ] "Successfully removed" 메시지를 표시해야 한다

### AC-4.2: 제거 취소

**Given**: 설치된 플러그인이 있다
**When**: `/plugin remove <plugin>@cc-lib`를 실행하고 거부한다
**Then**:
- [ ] 플러그인이 유지되어야 한다
- [ ] "Removal cancelled" 메시지를 표시해야 한다

## AC-5: 빌드 시스템

### AC-5.1: sync.sh 실행

**Given**: agents/ 디렉토리에 파일이 있다
**When**: `./installer/cli/sync.sh`를 실행한다
**Then**:
- [ ] output/.claude/agents/ 디렉토리를 생성해야 한다
- [ ] 모든 .md 파일을 처리해야 한다
- [ ] 심볼릭 링크는 타겟을 복사해야 한다
- [ ] 일반 파일은 그대로 복사해야 한다
- [ ] 최종적으로 플랫 구조여야 한다

### AC-5.2: 빌드 결과 검증

**Given**: sync.sh를 실행했다
**When**: output/.claude/agents/를 확인한다
**Then**:
- [ ] 모든 에이전트 파일이 존재해야 한다
- [ ] 파일 이름이 중복되지 않아야 한다
- [ ] 각 파일이 유효한 YAML frontmatter를 가져야 한다

### AC-5.3: .gitignore

**Given**: .gitignore 파일이 있다
**When**: .gitignore를 읽는다
**Then**:
- [ ] `/output/` 또는 `output/`가 포함되어야 한다
- [ ] 빌드 결과가 git 추적되지 않아야 한다

## AC-6: 플러그인 형식

### AC-6.1: plugin.json 유효성

**Given**: 플러그인 디렉토리가 있다
**When**: .claude-plugin/plugin.json을 읽는다
**Then**:
- [ ] JSON 형식이 유효해야 한다
- [ ] `name` 필드가 kebab-case여야 한다
- [ ] `name`에 공백이 없어야 한다

### AC-6.2: 에이전트 파일 형식

**Given**: 에이전트 .md 파일이 있다
**When**: 파일을 읽는다
**Then**:
- [ ] YAML frontmatter로 시작해야 한다 (`---`)
- [ ] `name` 필드가 있어야 한다
- [ ] `description` 필드가 있어야 한다 (50-1000자)
- [ ] `model` 필드가 있어야 하며 sonnet/haiku/opus 중 하나여야 한다

## AC-7: Claude Code 통합

### AC-7.1: 에이전트 자동 발견

**Given**: output/.claude/agents/에 에이전트가 있다
**When**: Claude Code를 실행한다
**Then**:
- [ ] 에이전트가 자동으로 발견되어야 한다
- [ ] `/Task` 메뉴에 에이전트가 표시되어야 한다
- [ ] 에이전트를 실행할 수 있어야 한다

### AC-7.2: settings.json 설정

**Given**: settings.json에 cc-lib 마켓플레이스가 추가되어 있다
**When**: Claude Code를 시작한다
**Then**:
- [ ] 마켓플레이스가 자동으로 로드되어야 한다
- [ ] 플러그인을 사용할 수 있어야 한다

## Definition of Done

각 스토리는 다음 조건을 모두 충족해야 "완료"로 간주됩니다:

- [ ] 모든 수락 기준 충족
- [ ] 코드 리뷰 완료
- [ ] 테스트 통과
- [ ] 문서 업데이트
- [ ] PRD에 반영

## Test Scenarios

### Scenario 1: 처음 사용자

1. cc-lib 저장소를 클론한다
2. `./installer/cli/sync.sh`를 실행한다
3. `output/.claude/agents/`를 프로젝트의 `.claude/agents/`로 복사한다
4. Claude Code를 실행한다
5. **Expected**: 에이전트가 작동한다

### Scenario 2: 마켓플레이스 사용자

1. `/plugin marketplace add k-park/cc-lib`를 실행한다
2. `/plugin list`를 실행한다
3. `/plugin install orchestration@cc-lib`를 실행한다
4. **Expected**: 플러그인이 설치되고 사용 가능하다

### Scenario 3: 플러그인 개발자

1. `plugins/my-plugin/.claude-plugin/plugin.json`을 생성한다
2. `plugins/my-plugin/agents/my-agent.md`를 생성한다
3. `agents/my-category/`에 심볼릭 링크를 만든다
4. `./installer/cli/sync.sh`를 실행한다
5. **Expected**: 새 에이전트가 빌드되고 사용 가능하다

## References

- [Acceptance Criteria Guide](https://www.atlassian.com/work-management/project-management/acceptance-criteria)

---

## Document Navigation

**[← Technical Specifications](./05-technical-specifications.md)** | **[PRD Index](./00-index.md)** | **[Next: Architecture →](./07-architecture.md)**