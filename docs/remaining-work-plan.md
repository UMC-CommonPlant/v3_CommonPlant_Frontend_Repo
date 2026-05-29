# 남은 작업 진행 계획

이 문서는 #47 API 연계 보강과 #49 폼 UX 보강이 `develop`에 병합된 뒤 남은 작업을 하나씩 진행하기 위한 실행 순서 문서이다.
각 항목은 별도 GitHub 이슈, Project 10 항목, 브랜치, PR로 분리한다.

## 진행 규칙

- 작업 전 `README.md`의 프로젝트 문서 섹션과 작업 유형별 필수 문서를 확인한다.
- 모든 작업 브랜치는 최신 `develop`에서 생성한다.
- 한 브랜치는 아래 표의 한 행만 다룬다.
- 이슈 제목은 `[Task]`, `[Feature]`, `[Bug]` 중 하나로 시작한다.
- 신규 이슈와 PR은 `ywkim95`, `allmanLee`를 assignee로 지정한다.
- 신규 이슈와 PR은 `v1.0.0 - MVP (핵심 기능 개발)` milestone을 지정한다.
- Project 10 status는 작업 시작 시 `In Progress`, PR 생성 후 `In Review`, 병합 후 `Done`으로 맞춘다.
- GitHub 이슈, PR, 코멘트 본문은 실제 줄바꿈 보존을 위해 `--body-file -` 또는 heredoc 입력을 사용한다.
- 문서만 바꾸면 `git diff --check`를 실행한다.
- Flutter 코드가 바뀌면 `fvm dart format --output=none --set-exit-if-changed .`, `fvm flutter analyze`, `fvm flutter test`, `git diff --check`를 실행한다.

## 작업 순서

| 순서 | 이슈 제목 | 권장 브랜치 | Project category | 범위 | 완료 기준 |
| --- | --- | --- | --- | --- | --- |
| 0 | `[Task] 남은 작업 순서 문서화` | `docs/remaining-work-order-50` | Story | README의 진행 작업 항목과 이 문서 추가 | 문서가 병합되고 이후 작업 순서가 확인 가능 |
| 1 | `[Task] Figma 프레임 매핑 최신화` | `docs/figma-frame-node-map` | Story | `docs/figma-frame-map.md`의 Home, Memo `확인 필요` node-id 정리 | Home/Memo node-id 또는 확인 불가 사유가 문서에 반영 |
| 2 | `[Task] 프로필 설정 이미지 UX 보강` | `feature/profile-image-ux` | User | 프로필 설정 화면의 이미지 선택/삭제/상태 표시를 화면 내부 로컬 UX로 보강 | 이미지 선택 전/후/삭제 상태 widget test 통과 |
| 3 | `[Task] 식물 검색 로컬 UX 보강` | `feature/plant-search-local-ux` | Plant | 식물 검색 화면의 정적 후보, 빈 결과, 선택 흐름을 정리 | 검색어 없음/결과 있음/결과 없음/선택 이동 테스트 통과 |
| 4 | `[Task] 메모 화면 로컬 UX 보강` | `feature/memo-local-ux` | Memo | 메모 목록/작성 화면의 로컬 작성, 삭제, empty 상태를 정리 | 작성 후 목록 복귀, 삭제 후 empty 상태 테스트 통과 |
| 5 | `[Task] 장소 상세 상태 UI 정리` | `feature/place-detail-state-ui` | Place | 장소 상세 화면의 mock fallback, remote loading, empty, error 표시 정리 | API mode별 상태 UI 테스트 통과 |
| 6 | `[Task] 식물 상세 상태 UI 정리` | `feature/plant-detail-state-ui` | Plant | 식물 상세/수정 화면의 mock fallback, remote loading, empty, error 표시 정리 | 상세/수정 정보 상태 UI 테스트 통과 |
| 7 | `[Task] 공통 폼 제출 상태 패턴 정리` | `refactor/form-submit-state` | Story | 중복된 submit/loading/error 처리 방식을 공통 helper 또는 controller 패턴으로 정리 | 장소/식물/프로필 폼 회귀 테스트 통과 |
| 8 | `[Feature] User API 화면 연결` | `feature/user-api-ui-binding` | User | User 조회/수정/검색 repository를 프로필 또는 친구 검색 화면에 연결 | API mode provider 테스트와 화면 상태 테스트 통과 |
| 9 | `[Task] 환경 flavor 전략 문서화` | `docs/flavor-env-strategy` | Story | flavor는 앱 정체성, API mode/base URL은 CI/CD 주입으로 분리하는 기준 정리 | release/API 문서에 하이브리드 전략 반영 |
| 10 | `[Feature] Place API 화면 연결` | `feature/place-api-ui-binding` | Place | 장소 수정, 상세 조회, 삭제 흐름을 repository/provider에 연결 | Place create/update/detail/delete 관련 테스트 통과 |
| 11 | `[Feature] Plant API 화면 연결` | `feature/plant-api-ui-binding` | Plant | 식물 상세, 수정 정보, 수정, 삭제 흐름을 repository/provider에 연결 | Plant detail/edit/update/delete 관련 테스트 통과 |
| 12 | `[Feature] Image API 화면 연결` | `feature/image-api-ui-binding` | Story | 프로필, 장소, 식물, 메모 이미지 선택 흐름과 image repository 연결 가능 지점 정리 | 이미지 key/url 정책 확인 범위 내 테스트 통과 |
| 13 | `[Task] 백엔드 확인 항목 이슈 분리` | `docs/backend-api-open-questions` | Story | `docs/api-swagger-reference.md`의 백엔드 확인 필요 항목을 질문 단위로 정리 | Auth/Friend/Image/Error/Token/검색/Memo 질문 목록 반영 |
| 14 | `[Task] 테스트 전략 확정` | `docs/test-strategy-follow-up` | Story | Golden test, integration test 도입 범위와 실행 환경 결정 문서화 | 테스트 종류별 적용/보류 기준 문서화 |
| 15 | `[Task] 릴리즈 정책 확정` | `docs/release-policy-follow-up` | Story | signing secret, store 계정, release 자동화 결정 항목 정리 | 배포 전 확인 항목과 보류 사유 문서화 |

## 백엔드 확인이 필요한 항목

아래 항목은 Swagger만 보고 화면 동작을 확정하지 않는다. 질문 단위 상세 목록은 `docs/backend-api-open-questions.md`에서 관리한다.

- `POST /auth/register` request schema와 multipart JSON part 필드
- multipart JSON part의 `Content-Type: application/json` 필요 여부
- Place 조회/생성/수정/삭제 성공 response body schema
- Friend 요청 목록, 요청 전송, 수락, 거절 response schema
- `sendFriendReq.receiverName`과 `friendDecisionReq.friendId`의 실제 의미
- Image upload/download/update/delete 성공 response의 image key/url 필드
- 에러 response body의 `code`, `message` 필드명
- refresh token 재발급과 로그아웃 API 제공 여부
- 주소 검색, 식물 검색, 메모 API 제공 계획
- 서버 staging/prod full base URL과 API versioning 정책

## 다음 작업 후보

#67 User API 화면 연결이 병합된 뒤, Place/Plant API 화면 연결 전 환경과 flavor 전략을 먼저 정리한다.
순서 9번 `[Task] 환경 flavor 전략 문서화`가 병합되면 순서 10번 `[Feature] Place API 화면 연결`로 돌아간다.
