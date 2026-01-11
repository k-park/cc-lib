# Functional Requirements

**Version**: 1.0.0
**Last Updated**: 2026-01-11
**Status**: Draft

## Overview

cc-lib의 기능적 요구사항을 정의합니다.

## FR-1: Marketplace Catalog

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-1.1 | 시스템은 `.claude-plugin/marketplace.json` 파일을 통해 플러그인 카탈로그를 제공해야 한다 | P0 |
| FR-1.2 | 카탈로그는 플러그인 이름, 설명, 버전, 카테고리, 태그 정보를 포함해야 한다 | P0 |
| FR-1.3 | 카탈로그는 GitHub 저장소로 호스팅되어야 한다 | P0 |
| FR-1.4 | 사용자는 `extraKnownMarketplaces` 설정을 통해 커스텀 마켓플레이스를 추가할 수 있어야 한다 | P1 |

## FR-2: 플러그인 발견

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-2.1 | 사용자는 `/plugin list` 명령어로 사용 가능한 플러그인 목록을 볼 수 있어야 한다 | P0 |
| FR-2.2 | 사용자는 플러그인 이름과 설명을 확인할 수 있어야 한다 | P0 |
| FR-2.3 | 사용자는 플러그인 카테고리로 필터링할 수 있어야 한다 | P1 |
| FR-2.4 | 사용자는 키워드로 플러그인을 검색할 수 있어야 한다 | P2 |

## FR-3: 플러그인 설치

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-3.1 | 사용자는 `/plugin install <plugin>@<marketplace>` 명령어로 플러그인을 설치할 수 있어야 한다 | P0 |
| FR-3.2 | 설치 과정에서 진행 상태를 표시해야 한다 | P0 |
| FR-3.3 | 설치 실패 시 명확한 에러 메시지를 표시해야 한다 | P0 |
| FR-3.4 | 이미 설치된 플러그인을 다시 설치할 경우 업데이트하거나 건너뛰어야 한다 | P1 |
| FR-3.5 | 의존성이 있는 플러그인의 경우 의존성도 함께 설치해야 한다 | P2 |

## FR-4: 플러그인 관리

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-4.1 | 사용자는 `/plugin remove <plugin>@<marketplace>` 명령어로 플러그인을 제거할 수 있어야 한다 | P0 |
| FR-4.2 | 사용자는 `/plugin info <plugin>` 명령어로 플러그인 상세 정보를 볼 수 있어야 한다 | P1 |
| FR-4.3 | 사용자는 플러그인을 활성화/비활성화할 수 있어야 한다 | P1 |
| FR-4.4 | 사용자는 설치된 플러그인을 업데이트할 수 있어야 한다 | P2 |

## FR-5: 플러그인 개발

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-5.1 | 시스템은 표준 플러그인 템플릿을 제공해야 한다 | P1 |
| FR-5.2 | 플러그인은 `.claude-plugin/plugin.json` 메타파일을 포함해야 한다 | P0 |
| FR-5.3 | 플러그인은 에이전트, 명령어, 스킬, 훅을 포함할 수 있어야 한다 | P0 |
| FR-5.4 | 플러그인 개발자는 로컬 경로에서 플러그인을 테스트할 수 있어야 한다 | P1 |
| FR-5.5 | 시스템은 플러그인 유효성을 검증할 수 있어야 한다 | P1 |

## FR-6: 빌드 시스템

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-6.1 | 시스템은 `sync.sh` 스크립트를 통해 플러그인을 빌드해야 한다 | P0 |
| FR-6.2 | 빌드 과정에서 심볼릭 링크를 해결하고 실제 파일을 복사해야 한다 | P0 |
| FR-6.3 | 빌드 결과는 `output/.claude/agents/`에 플랫 구조로 저장되어야 한다 | P0 |
| FR-6.4 | 빌드된 파일은 `.gitignore`로 관리되어야 한다 | P0 |

## FR-7: 에이전트 실행

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-7.1 | 설치된 에이전트는 Claude Code에서 자동으로 발견되어야 한다 | P0 |
| FR-7.2 | 에이전트는 YAML frontmatter에 정의된 메타데이터를 포함해야 한다 | P0 |
| FR-7.3 | 에이전트는 `name`, `description`, `model` 필드를 필수로 포함해야 한다 | P0 |
| FR-7.4 | 에이전트는 `sonnet`, `haiku`, `opus` 모델 중 하나를 지정해야 한다 | P0 |

## FR-8: 환경별 최적화

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-8.1 | 시스템은 모바일, PC, 서버 환경을 지원해야 한다 | P1 |
| FR-8.2 | 각 환경별로 다른 기본 설정을 제공할 수 있어야 한다 | P2 |
| FR-8.3 | CLI 모드에서 에이전트를 실행할 수 있어야 한다 | P2 |

## Non-Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| NFR-1 | 플러그인 설치는 30초 이내에 완료되어야 한다 | P0 |
| NFR-2 | 시스템은 100개 이상의 플러그인을 지원할 수 있어야 한다 | P1 |
| NFR-3 | API 응답 시간은 1초 이내여야 한다 | P1 |
| NFR-4 | 모든 사용자 작업은 로깅되어야 한다 | P1 |
| NFR-5 | 시스템은 MIT 라이선스로 배포되어야 한다 | P0 |

## Requirements Matrix

| Category | P0 | P1 | P2 | Total |
|----------|----|----|----|-------|
| Marketplace | 3 | 1 | 0 | 4 |
| Discovery | 2 | 1 | 1 | 4 |
| Installation | 3 | 1 | 1 | 5 |
| Management | 0 | 3 | 1 | 4 |
| Development | 2 | 3 | 0 | 5 |
| Build | 4 | 0 | 0 | 4 |
| Execution | 4 | 0 | 0 | 4 |
| Environment | 0 | 1 | 2 | 3 |
| **Total** | **18** | **10** | **5** | **33** |

## References

- [Functional Requirements Template](https://www.reqtest.com/functional-requirements/)
