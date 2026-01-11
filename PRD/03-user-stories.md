# User Stories

**Version**: 1.0.0
**Last Updated**: 2026-01-11
**Status**: Draft

## Overview

사용자 페르소나별로 cc-lib가 해결해야 할 핵심 사용자 스토리를 정의합니다.

## Epic 1: 마켓플레이스에서 에이전트 발견

### Story 1.1: 카테고리별 브라우징

**As a** 프로 개발자 (Alex)
**I want to** 카테고리별로 에이전트를 브라우징할 수 있고
**So that** 내 필요에 맞는 에이전트를 빠르게 찾을 수 있다

**Acceptance Criteria**:
- [ ] 카테고리 목록을 볼 수 있다 (orchestration, code-review, testing, etc.)
- [ ] 각 카테고리에 속한 에이전트 목록을 볼 수 있다
- [ ] 에이전트 설명과 태그를 확인할 수 있다

### Story 1.2: 검색 기능

**As a** 프로 개발자 (Alex)
**I want to** 키워드로 에이전트를 검색할 수 있고
**So that** 특정 기능을 하는 에이전트를 빠르게 찾을 수 있다

**Acceptance Criteria**:
- [ ] 키워드 검색이 가능하다
- [ ] 태그로 필터링할 수 있다
- [ ] 검색 결과에 관련성 순위가 적용된다

### Story 1.3: 에이전트 상세 보기

**As a** 주니어 개발자 (Taylor)
**I want to** 에이전트의 상세 정보와 사용 예시를 볼 수 있고
**So that** 어떤 에이전트를 사용할지 결정할 수 있다

**Acceptance Criteria**:
- [ ] 에이전트 설명을 볼 수 있다
- [ ] 사용 예시를 확인할 수 있다
- [ ] 필요한 모델 (sonnet/haiku/opus)을 알 수 있다
- [ ] 다른 사용자의 피드백을 볼 수 있다 (나중에)

## Epic 2: 원클릭 에이전트 설치

### Story 2.1: 마켓플레이스 추가

**As a** 프로 개발자 (Alex)
**I want to** 명령어 하나로 마켓플레이스를 추가할 수 있고
**So that** 빠르게 cc-lib 생태계에 접근할 수 있다

**Acceptance Criteria**:
- [ ] `/plugin marketplace add k-park/cc-lib` 명령어로 추가 가능
- [ ] 추가된 마켓플레이스를 확인할 수 있다
- [ ] 마켓플레이스 URL로도 추가 가능

### Story 2.2: 에이전트 설치

**As a** 모바일 개발자 (Sam)
**I want to** 명령어 하나로 에이전트를 설치할 수 있고
**So that** 복잡한 설정 없이 바로 사용할 수 있다

**Acceptance Criteria**:
- [ ] `/plugin install orchestration@cc-lib` 명령어로 설치 가능
- [ ] 설치 진행 상태를 확인할 수 있다
- [ ] 설치 실패 시 명확한 에러 메시지를 받는다

### Story 2.3: 에이전트 목록 확인

**As a** 주니어 개발자 (Taylor)
**I want to** 설치된 에이전트 목록을 볼 수 있고
**So that** 무엇을 사용할 수 있는지 알 수 있다

**Acceptance Criteria**:
- [ ] `/plugin list`로 설치된 에이전트를 볼 수 있다
- [ ] 각 에이전트의 활성화 상태를 확인할 수 있다
- [ ] 에이전트를 비활성화/활성화할 수 있다

### Story 2.4: 에이전트 제거

**As a** DevOps 엔지니어 (Jordan)
**I want to** 에이전트를 제거할 수 있고
**So that** 필요 없는 에이전트를 정리할 수 있다

**Acceptance Criteria**:
- [ ] `/plugin remove orchestration@cc-lib`로 제거 가능
- [ ] 제거 전 확인 프롬프트가 표시된다
- [ ] 제거 후 에이전트가 더 이상 실행되지 않는다

## Epic 3: 플러그인 개발 및 배포

### Story 3.1: 플러그인 생성

**As a** 프로 개발자 (Alex)
**I want to** 표준 템플릿으로 플러그인을 생성할 수 있고
**So that** 빠르게 새로운 에이전트를 만들 수 있다

**Acceptance Criteria**:
- [ ] 플러그인 템플릿 명령어가 제공된다
- [ ] 필수 파일 구조가 자동 생성된다
- [ ] 예시 plugin.json이 포함된다

### Story 3.2: 로컬 테스트

**As a** 프로 개발자 (Alex)
**I want to** 로컬에서 플러그인을 테스트할 수 있고
**So that** 배포 전에 동작을 확인할 수 있다

**Acceptance Criteria**:
- [ ] 로컬 경로로 플러그인을 로드할 수 있다
- [ ] 에이전트가 정상적으로 실행되는지 확인할 수 있다
- [ ] 로그를 통해 디버깅할 수 있다

### Story 3.3: 마켓플레이스에 제출

**As a** 프로 개발자 (Alex)
**I want to** 내 플러그인을 cc-lib에 제출할 수 있고
**So that** 커뮤니티와 공유할 수 있다

**Acceptance Criteria**:
- [ ] PR 템플릿이 제공된다
- [ ] 필수 검증이 자동으로 실행된다
- [ ] 리뷰 프로세스가 명확하다

## Epic 4: 환경별 최적화

### Story 4.1: 모바일 최적화된 에이전트

**As a** 모바일 개발자 (Sam)
**I want to** 리소스 소모가 적은 에이전트를 사용할 수 있고
**So that** 모바일 환경에서도 원활하게 작업할 수 있다

**Acceptance Criteria**:
- [ ] 모바일용 에이전트 세트가 제공된다
- [ ] 경량화된 모델(haiku)을 사용하는 에이전트가 있다
- [ ] 배터리 소모가 적다

### Story 4.2: 서버 자동화

**As a** DevOps 엔지니어 (Jordan)
**I want to** CI/CD 파이프라인에서 에이전트를 실행할 수 있고
**So that** 코드 품질 검사를 자동화할 수 있다

**Acceptance Criteria**:
- [ ] CLI 모드에서 에이전트를 실행할 수 있다
- [ ] 결과를 JSON 형식으로 출력할 수 있다
- [ ] 실패 시 적절한 종료 코드를 반환한다

## Story Priority

| Priority | Stories |
|----------|---------|
| **P0 (MVP)** | 1.1, 2.1, 2.2, 2.3 |
| **P1** | 1.2, 1.3, 2.4, 3.1, 3.2 |
| **P2** | 3.3, 4.1, 4.2 |

## References

- [User Story Template](https://www.mountaingoatsoftware.com/blog/user-story-template/)
- [Acceptance Criteria Guide](https://www.atlassian.com/work-management/project-management/acceptance-criteria)

---

## Document Navigation

**[← User Personas](./02-user-personas.md)** | **[PRD Index](./00-index.md)** | **[Next: Functional Requirements →](./04-functional-requirements.md)**