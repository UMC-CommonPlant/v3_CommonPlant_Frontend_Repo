# 후속 결정 체크리스트

이 문서는 `docs/remaining-work-plan.md`의 0~15번 작업이 끝난 뒤 남은 결정/확인 항목을 새 이슈나 Epic으로 분리하기 쉽게 모아둔 체크리스트이다.

## 관리 기준

- 상태는 `Open`, `Ready`, `Decided`, `Blocked`, `Done` 중 하나로 관리한다.
- 외부 답변이나 팀 결정이 필요한 항목은 임의로 확정하지 않는다.
- 결론이 나면 이 문서와 원본 문서를 함께 갱신한다.
- 구현 작업이 필요한 결론은 별도 GitHub 이슈로 분리한다.

## 품질과 테스트

| 체크 | ID | 결정 항목 | 출처 | 다음 액션 | 상태 |
| --- | --- | --- | --- | --- | --- |
| [x] | QA-01 | Figma 기준 해상도 외 QA 필수 디바이스 목록 | `docs/screen-publishing-rules.md`, `docs/testing-guide.md`, `docs/quality-testing-follow-up-plan.md` | 네 QA profile을 적용한다. 확인된 compact overflow와 대상 회귀 테스트는 #197에서 완료했다. | Decided |
| [x] | TEST-01 | full-screen golden test 기준 크기 | `docs/testing-guide.md`, `docs/quality-testing-follow-up-plan.md` | #199에서 `OnboardingPage`, `375×812`, DPR 1, Ubuntu canonical, exact comparator와 workflow 기반 baseline 갱신 규칙을 적용한다. | Decided |
| [x] | TEST-02-A | API 비사용 integration smoke와 runner | `docs/testing-guide.md`, `docs/quality-testing-follow-up-plan.md` | #203에서 실제 앱의 Home → 장소 친구 요청 Android smoke, 명시적 device 실행, 수동 workflow와 required check 승격 조건을 적용한다. | Decided |
| [ ] | TEST-02-B | remote API integration 실행 환경과 workflow | `docs/testing-guide.md`, `docs/quality-testing-follow-up-plan.md` | #213에서 dev API URL은 확인했다. 테스트 계정, seed/cleanup, secret과 데이터 격리 정책이 준비될 때까지 remote end-to-end workflow를 보류한다. | Blocked |

## 릴리즈와 환경

| 체크 | ID | 결정 항목 | 출처 | 다음 액션 | 상태 |
| --- | --- | --- | --- | --- | --- |
| [x] | RELEASE-01 | MVP 앱명, application id, bundle id, 아이콘, flavor와 Firebase 범위 | `docs/release-workflow.md` | #209에서 단일 prod 앱, `커먼플랜트`, `com.plant.common`, 기존 브랜드 아이콘을 적용했다. dev/staging flavor와 Firebase는 실제 분리 요구가 생길 때 도입한다. | Decided |
| [x] | RELEASE-02-A | 앱 version과 build number 관리 방식 | `docs/release-workflow.md` | #211에서 `pubspec.yaml`의 `X.Y.Z+N`을 단일 원본으로 두고 release 브랜치에서 수동 증가하며 CI override를 금지한다. | Decided |
| [ ] | RELEASE-02-B | 최초 store build number 기준값 | `docs/release-workflow.md` | #215에서 Play 계정에 등록 앱이 없음을 확인했지만 Apple과 기존 package 소유 이력은 미확인이다. 양쪽 store의 실제 최대 업로드 번호 확인 후 공통 `N`을 확정한다. | Blocked |
| [ ] | RELEASE-03 | Android Play Console과 Apple Developer/App Store Connect 계정 준비 여부 | `docs/release-workflow.md` | #215에서 Play 접근과 미인증·미등록 상태를 확인했다. 계정 소유자의 Play 인증과 Apple 로그인이 완료되면 Team/app/role/signing 준비 여부를 이어서 확인한다. | Blocked |
| [ ] | RELEASE-04 | 내부 테스트 배포 안정화 후 production 제출 자동화 범위 | `docs/release-workflow.md` | manual approval 유지 범위와 자동 제출 허용 범위를 정한다. | Open |
| [x] | ENV-01-A | dev backend, API base URL과 Swagger endpoint | `docs/release-workflow.md`, `docs/api-swagger-reference.md`, `docs/backend-api-open-questions.md` | #213에서 dev origin, `/api/v1`, Swagger UI와 OpenAPI JSON/config 접속을 확인했다. | Decided |
| [ ] | ENV-01-B | staging/prod full base URL과 API versioning 정책 | `docs/release-workflow.md`, `docs/api-swagger-reference.md`, `docs/backend-api-open-questions.md` | 백엔드 답변을 받아 CI/CD 환경값과 release 검증 기준에 반영한다. | Open |

## 디자인과 에셋

| 체크 | ID | 결정 항목 | 출처 | 다음 액션 | 상태 |
| --- | --- | --- | --- | --- | --- |
| [x] | FIGMA-01 | Home/Memo Figma frame의 실제 node-id | `docs/figma-frame-map.md` | #205에서 Home 기본 `1:2332`, Memo 기본 `1:3749`, 메뉴 `1:3852`, 삭제 alert `1:3964`를 Figma 원본 metadata와 screenshot으로 확인해 반영했다. | Decided |
| [x] | ASSET-01 | Figma export 시 SVG 최적화 도구 사용 여부 | `docs/asset-icon-rules.md` | #207에서 SVGO `4.0.1` 보수 allowlist, 신규/변경 SVG 후보 우선 적용, 기존 asset 일괄 변경 금지와 parse/rasterize·최소/최대 표시 크기 검증을 확정했다. | Decided |

## UX와 공통 구조

| 체크 | ID | 결정 항목 | 출처 | 다음 액션 | 상태 |
| --- | --- | --- | --- | --- | --- |
| [ ] | UX-01 | 백엔드 에러 코드와 앱 사용자 메시지 매핑표 | `docs/form-validation-error-guide.md`, `docs/state-management-guide.md` | 백엔드 에러 코드 표준 확인 후 공통 메시지 매핑표를 만든다. | Open |
| [ ] | UX-02 | Toast, Snackbar, Dialog 피드백 사용 기준 | `docs/form-validation-error-guide.md` | 성공, 경고, 차단 오류, 복구 가능 오류별 UI 피드백 정책을 정한다. | Open |
| [ ] | STATE-01 | API 공통 에러 타입과 사용자 메시지 매핑 기준 | `docs/state-management-guide.md` | `ApiException` 계층과 화면 노출 메시지 변환 경계를 정한다. | Open |
| [ ] | ROUTING-01 | 하단 탭 도입 시 `ShellRoute`와 단순 탭 상태 중 선택 | `docs/routing-guide.md` | bottom navigation 화면 범위가 확정되면 라우팅 구조를 결정한다. | Open |
| [ ] | GIT-01 | PR template 파일 추가 여부 | `docs/git-workflow.md` | 현재 PR 본문 기준을 `.github/pull_request_template.md`로 고정할지 결정한다. | Open |

## 백엔드 확인 질문

상세 질문과 답변 칸은 `docs/backend-api-open-questions.md`에서 관리한다. 아래 표는 새 이슈로 분리할 때 쓰는 요약 체크리스트이다.

| 체크 | ID | 범위 | 관련 질문 ID | 현재 막힌 작업 | 상태 |
| --- | --- | --- | --- | --- | --- |
| [x] | API-AUTH | Auth 회원가입 전송 정책 | AUTH-01, AUTH-02 | dev Swagger의 `RegisterRequest`와 image optional multipart 기준으로 datasource 구현을 분리한다. | Ready |
| [ ] | API-MULTIPART | Place multipart JSON part 정책 | MULTIPART-01 | Auth/User/Plant의 `application/json` encoding은 확인됐고 Place encoding은 백엔드 확인이 필요하다. | Open |
| [ ] | API-PLACE | Place response와 식별자 정책 | PLACE-01, PLACE-02, PLACE-03, PLACE-04 | 장소 목록/상세/멤버/생성/수정/삭제 실데이터 연결 | Open |
| [ ] | API-FRIEND | Friend 요청 목록과 액션 정책 | FRIEND-01, FRIEND-02, FRIEND-03, FRIEND-04 | 장소 친구 요청/추가 화면 API 연결 | Open |
| [ ] | API-IMAGE | Image upload/download/update/delete 정책 | IMAGE-01, IMAGE-02, IMAGE-03, IMAGE-04 | 프로필/장소/식물/메모 이미지 key/url 매핑 | Open |
| [ ] | API-ERROR | 공통/도메인 에러 response 정책 | ERROR-01, ERROR-02 | 사용자 메시지와 field error 매핑 | Open |
| [ ] | API-TOKEN | refresh token과 로그아웃 정책 | TOKEN-01, TOKEN-02 | 인증 만료 복구와 세션 종료 처리 | Open |
| [ ] | API-SEARCH | 주소/식물/사용자 검색 정책 | SEARCH-01, SEARCH-02, SEARCH-03 | 주소 검색, 식물 검색, 친구 추가 검색 UX | Open |
| [ ] | API-MEMO | Memo CRUD와 이미지 첨부 정책 | MEMO-01, MEMO-02, MEMO-03 | 메모 화면 실데이터 연결 | Open |
| [x] | API-ENV-DEV | dev 서버 환경값과 Swagger | ENV-01-A | #213에서 dev origin, API base URL과 문서 endpoint를 확인했다. | Decided |
| [ ] | API-ENV-RELEASE | staging/prod 환경값과 versioning | ENV-01-B | staging/prod release 검증은 백엔드 답변 전까지 미확정이다. | Open |

## 다음 이슈화 기준

- 백엔드 답변이 필요한 항목은 먼저 백엔드 확인 이슈 또는 커뮤니케이션으로 묶는다.
- 팀 내부 결정만 필요한 항목은 `Story` category의 `[Task]` 이슈로 분리한다.
- 실제 코드 변경이 뒤따르는 항목은 결정 이슈와 구현 이슈를 분리한다.
- 하나의 이슈에는 한 영역의 결정만 담는다.
