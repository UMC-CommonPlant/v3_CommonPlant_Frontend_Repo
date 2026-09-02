# 후속 결정 체크리스트

이 문서는 팀 결정·외부 승인·백엔드 답변이 필요한 항목을 관리한다. 즉시 수정할 동작 문제와 실행 순서는 [개발 감사·개선 체크리스트](development-audit-checklist.md), 화면 연결 상태는 [화면·API 매트릭스](screen-api-integration-plan.md)에서 관리한다. 아래 미결정 항목을 현재 최우선 작업으로 해석하지 않는다.

## 관리 기준

- 상태는 `Open`, `Ready`, `Partial`, `Decided`, `Blocked`, `Done` 중 하나로 관리한다. `Partial`은 일부 계약·구현만 완료된 상태다.
- 외부 답변이나 팀 결정이 필요한 항목은 임의로 확정하지 않는다.
- 결론이 나면 이 문서와 원본 문서를 함께 갱신한다.
- 구현 작업이 필요한 결론은 별도 GitHub 이슈로 분리한다.

## 2026-09-02 소셜 로그인 SDK 재개

- 사용자가 #285에서 Kakao·Google·Apple SDK 연결을 재개했다.
- 별도 회원가입 진입은 만들지 않고 `/auth/login`의 실제 `isNewUser` 값으로 가입 완료 흐름을 분기한다.
- Apple 버튼과 SDK 호출은 iOS에서만 노출하며 Android용 Apple 웹 로그인은 추가하지 않는다.
- backend `main`은 Apple verifier가 없어 실제 Apple 로그인은 backend #152 dev 배포 전까지 Blocked다.
- 실제 provider credential과 개인 계정 원격 E2E는 저장소에 임의로 추가하지 않는다.

## 2026-08-30 사용자 실행·보류 결정

[Epic #226](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/226) 하위 이슈 20/20 완료 뒤 #267에서 후속 범위를 다시 정했습니다. 즉시 실행 순서는 [화면·API 계획](screen-api-integration-plan.md#후속-개발-실행-순서-267)을 단일 원본으로 사용합니다.

| 구분 | 항목 | 처리 |
| --- | --- | --- |
| 실행 | 완료 상태 문서, Home 배지 오류, Plant 잔여 동선, 공통 오류·토큰, Place·Friend 쓰기, Memo API | 표의 순서대로 계약 확인과 별도 구현 이슈 진행 |
| 실행 재개 | 로그인 SDK | #285에서 credential 주입 경계와 Kakao·Google·iOS Apple SDK를 연결. Apple 서버 검증은 backend #152 대기 |
| 보류 | 실제 주소 검색 서비스 | 서비스·키·과금·adapter 결정을 다음 작업으로 이동 |
| 보류 | 이미지 흐름 | 업로드 방식 변경 확정 전 구현하지 않고 #248 안전 경계 유지 |
| 보류 | 인증된 원격 E2E | TEST-02-B 준비 계약과 Environment를 유지하되 이번 실행 큐에서 제외 |
| 보류 | 스토어·릴리즈 | #215와 RELEASE-02-B/03, ENV-01-B를 유지하되 이번 실행 큐에서 제외 |

보류는 `Done`이나 질문 해결을 뜻하지 않습니다. 아래 상태와 원본 질문을 그대로 유지하고 사용자가 재개할 때 준비 조건부터 다시 확인합니다. 주소를 제외한 Plant 검색·사용자 식별자 검색은 실행 범위의 해당 도메인 단계에서 다룹니다. Memo의 이미지 첨부는 이미지 보류에 포함하고, 먼저 텍스트 CRUD·목록 계약을 대상으로 합니다.

## 품질과 테스트

| 체크 | ID | 결정 항목 | 출처 | 다음 액션 | 상태 |
| --- | --- | --- | --- | --- | --- |
| [x] | QA-01 | Figma 기준 해상도 외 QA 필수 디바이스 목록 | `docs/screen-publishing-rules.md`, `docs/testing-guide.md`, `docs/quality-testing-follow-up-plan.md` | 네 QA profile을 적용한다. 확인된 compact overflow와 대상 회귀 테스트는 #197에서 완료했다. | Decided |
| [x] | TEST-01 | full-screen golden test 기준 크기 | `docs/testing-guide.md`, `docs/quality-testing-follow-up-plan.md` | #199에서 `OnboardingPage`, `375×812`, DPR 1, Ubuntu canonical, exact comparator와 workflow 기반 baseline 갱신 규칙을 적용한다. | Decided |
| [x] | TEST-02-A | API 비사용 integration smoke와 runner | `docs/testing-guide.md`, `docs/quality-testing-follow-up-plan.md` | #203에서 실제 앱의 Home → 장소 친구 요청 Android smoke와 수동 workflow를 도입했고, #218에서 `develop` 3회 연속 성공을 확인했다. | Decided |
| [x] | TEST-02-A-GATE | Android smoke의 PR required check 승격 | `docs/testing-guide.md`, `docs/quality-testing-follow-up-plan.md` | #224에서 기본 `Flutter CI / quality`만 `develop` required check로 설정하고 Android smoke는 관련 변경과 release candidate에서 선택 실행하는 수동 workflow로 유지하기로 결정했다. | Decided |
| [ ] | TEST-02-B | remote API integration 실행 환경과 workflow | `docs/testing-guide.md`, `docs/quality-testing-follow-up-plan.md`, `docs/remote-integration-test-readiness.md` | #220에서 준비 계약을 정리했다. 인증 bootstrap·token lifecycle·fixture 격리/cleanup·GitHub Environment 승인 후 read-only probe부터 별도 구현한다. | Blocked |

## 릴리즈와 환경

| 체크 | ID | 결정 항목 | 출처 | 다음 액션 | 상태 |
| --- | --- | --- | --- | --- | --- |
| [x] | RELEASE-01 | MVP 앱명, application id, bundle id, 아이콘, flavor와 Firebase 범위 | `docs/release-workflow.md` | #209에서 단일 prod 앱, `커먼플랜트`, `com.plant.common`, 기존 브랜드 아이콘을 적용했다. dev/staging flavor와 Firebase는 실제 분리 요구가 생길 때 도입한다. | Decided |
| [x] | RELEASE-02-A | 앱 version과 build number 관리 방식 | `docs/release-workflow.md` | #211에서 `pubspec.yaml`의 `X.Y.Z+N`을 단일 원본으로 두고 release 브랜치에서 수동 증가하며 CI override를 금지한다. | Decided |
| [ ] | RELEASE-02-B | 최초 store build number 기준값 | `docs/release-workflow.md` | 같은 식별자를 쓴 v2와 Play/App Store의 최대 업로드 번호를 RELEASE-03에서 확인한 뒤 공통 `N`을 확정한다. | Blocked |
| [ ] | RELEASE-03 | Android Play Console과 Apple Developer/App Store Connect 계정 준비 여부 | `docs/release-workflow.md` | #215는 계정 소유자 확인과 승인이 필요해 Backlog로 보류한다. 앱/role/signing/store 이력은 소유자 협의 후 재개한다. | Blocked |
| [x] | RELEASE-04 | 내부 테스트 배포 안정화 후 production 제출 자동화 범위 | `docs/release-workflow.md` | #222에서 동일 artifact 승격, 비실행자 승인, 최초 출시 수동 공개, 후속 staged/phased rollout과 hotfix 경계를 확정했다. workflow 구현은 외부 준비 후 별도 진행한다. | Decided |
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
| [x] | UX-01 | 백엔드 에러 코드와 앱 사용자 메시지 매핑표 | `docs/form-validation-error-guide.md`, `docs/state-management-guide.md` | #275에서 HTTP·전송 범주와 확인된 field/auth code만 안전 메시지로 매핑했다. 새 code는 계약 확인 뒤 추가한다. | Decided |
| [x] | UX-02 | Toast, Snackbar, Dialog 피드백 사용 기준 | `docs/form-validation-error-guide.md`, `docs/shared-widget-guide.md` | #279에서 inline 상태, Snackbar, Dialog의 역할을 정하고 최소 Snackbar helper만 공유했다. | Decided |
| [x] | STATE-01 | API 공통 에러 타입과 사용자 메시지 매핑 기준 | `docs/state-management-guide.md` | #275에서 표준 오류·field reason을 typed 상태로 분리하고 rejected value와 raw top-level message 노출을 차단했다. | Decided |
| [ ] | ROUTING-01 | 하단 탭 도입 시 `ShellRoute`와 단순 탭 상태 중 선택 | `docs/routing-guide.md` | bottom navigation 화면 범위가 확정되면 라우팅 구조를 결정한다. | Open |
| [x] | GIT-01 | PR template 파일 추가 여부 | `docs/git-workflow.md`, `.github/pull_request_template.md` | #281에서 현재 PR 본문 기준을 단일 기본 template으로 고정했다. | Decided |

## 백엔드 확인 질문

상세 질문과 답변 칸은 `docs/backend-api-open-questions.md`에서 관리한다. 아래 표는 새 이슈로 분리할 때 쓰는 요약 체크리스트이다.

| 체크 | ID | 범위 | 관련 질문 ID | 현재 막힌 작업 | 상태 |
| --- | --- | --- | --- | --- | --- |
| [ ] | API-AUTH | Auth 로그인·회원가입과 provider 검증 정책 | AUTH-01, AUTH-02, AUTH-03 | #216·#227의 화면/API 연결 뒤 #285에서 SDK를 연결한다. Apple 실제 로그인은 backend #152 대기 | Partial |
| [ ] | API-MULTIPART | Place multipart JSON part 정책 | MULTIPART-01 | Auth/User/Plant의 `application/json` encoding은 확인됐고 Place encoding은 백엔드 확인이 필요하다. | Open |
| [ ] | API-PLACE | Place response와 식별자 정책 | PLACE-01, PLACE-02, PLACE-03, PLACE-04 | #239·#243 목록/상세/생성/수정, #245 멤버 조회 연결 완료; 멤버 변경은 보류 | Partial |
| [ ] | API-FRIEND | Friend 요청 목록과 액션 정책 | FRIEND-01, FRIEND-02, FRIEND-03, FRIEND-04 | #241 수신 처리와 #243 발신 연결 완료, 이름 오매칭은 수용 위험으로 추적 | Partial |
| [ ] | API-IMAGE | Image upload/download/update/delete 정책 | IMAGE-01, IMAGE-02, IMAGE-03, IMAGE-04 | #248에서 Plant key 보존·Place 사진 수정 차단을 구현했다. 독립 Image 응답·Place key 조회·동시 수정 보호 계약은 미확정이다. | Partial |
| [x] | API-ERROR | 공통/도메인 에러 response 정책 | ERROR-01, ERROR-02 | #275 typed 오류·field error·안전 메시지 연결. 인증 쓰기 validation smoke는 원격 E2E 보류 범위 | Done |
| [ ] | API-TOKEN | refresh token과 로그아웃 정책 | TOKEN-01, TOKEN-02 | #275 확인 code의 로컬 세션 종료 완료. refresh·server invalidation은 backend #149 대기 | Partial |
| [ ] | API-SEARCH | 주소/식물/사용자 검색 정책 | SEARCH-01, SEARCH-02, SEARCH-03 | 주소 검색, 식물 검색, 친구 추가 검색 UX | Open |
| [ ] | API-MEMO | Memo CRUD와 이미지 첨부 정책 | MEMO-01, MEMO-02, MEMO-03 | #283에서 backend #50에 텍스트 CRUD 계약을 요청했다. 구현·OpenAPI 전까지 원격 연결 금지, 이미지는 사용자 보류 | Blocked |
| [x] | API-ENV-DEV | dev 서버 환경값과 Swagger | ENV-01-A | #213에서 dev origin, API base URL과 문서 endpoint를 확인했다. | Decided |
| [ ] | API-TESTENV | remote integration 테스트 환경 | TESTENV-01~05 | #220에서 최소 준비 계약을 정리했다. 백엔드 인증·fixture·cleanup 답변과 저장소 설정 승인 전까지 TEST-02-B를 보류한다. | Blocked |
| [ ] | API-ENV-RELEASE | staging/prod 환경값과 versioning | ENV-01-B | staging/prod release 검증은 백엔드 답변 전까지 미확정이다. | Open |

## 다음 이슈화 기준

- 백엔드 답변이 필요한 항목은 먼저 백엔드 확인 이슈 또는 커뮤니케이션으로 묶는다.
- 팀 내부 결정만 필요한 항목은 `Story` category의 `[Task]` 이슈로 분리한다.
- 실제 코드 변경이 뒤따르는 항목은 결정 이슈와 구현 이슈를 분리한다.
- 하나의 이슈에는 한 영역의 결정만 담는다.
