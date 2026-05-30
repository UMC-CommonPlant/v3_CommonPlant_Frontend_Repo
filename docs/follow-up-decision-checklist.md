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
| [ ] | QA-01 | Figma 기준 해상도 외 QA 필수 디바이스 목록 | `docs/screen-publishing-rules.md`, `docs/testing-guide.md` | QA 기준 디바이스와 화면 폭을 정리한다. | Open |
| [ ] | TEST-01 | full-screen golden test 기준 크기 | `docs/testing-guide.md` | QA 디바이스 목록 확정 후 full-screen golden 범위를 정한다. | Open |
| [ ] | TEST-02 | integration test 실행 환경과 workflow 연결 방식 | `docs/testing-guide.md` | staging API, 테스트 계정, runner 준비 여부를 확인한다. | Open |

## 릴리즈와 환경

| 체크 | ID | 결정 항목 | 출처 | 다음 액션 | 상태 |
| --- | --- | --- | --- | --- | --- |
| [ ] | RELEASE-01 | `dev`, `staging`, `prod` flavor별 앱명, application id, bundle id, 아이콘, Firebase 설정값 | `docs/release-workflow.md` | flavor가 실제로 필요한 배포 시점과 앱 식별값을 확정한다. | Open |
| [ ] | RELEASE-02 | 앱 버전과 build number 자동 증가 방식 | `docs/release-workflow.md` | 수동 증가, GitHub run number, 별도 versioning action 중 선택한다. | Open |
| [ ] | RELEASE-03 | Android Play Console과 Apple Developer/App Store Connect 계정 준비 여부 | `docs/release-workflow.md` | 계정, 앱 등록, 권한, secret 등록 가능 여부를 확인한다. | Open |
| [ ] | RELEASE-04 | 내부 테스트 배포 안정화 후 production 제출 자동화 범위 | `docs/release-workflow.md` | manual approval 유지 범위와 자동 제출 허용 범위를 정한다. | Open |
| [ ] | ENV-01 | staging/prod 서버 full base URL과 API versioning 정책 | `docs/release-workflow.md`, `docs/api-swagger-reference.md`, `docs/backend-api-open-questions.md` | 백엔드 답변을 받아 CI/CD 환경값과 release 검증 기준에 반영한다. | Open |

## 디자인과 에셋

| 체크 | ID | 결정 항목 | 출처 | 다음 액션 | 상태 |
| --- | --- | --- | --- | --- | --- |
| [ ] | FIGMA-01 | Home/Memo Figma frame의 실제 node-id | `docs/figma-frame-map.md` | Figma node-specific URL 또는 metadata를 확보해 frame map을 갱신한다. | Open |
| [ ] | ASSET-01 | Figma export 시 SVG 최적화 도구 사용 여부 | `docs/asset-icon-rules.md` | SVGO 등 최적화 도구 도입 여부와 설정 기준을 정한다. | Open |

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
| [ ] | API-AUTH | Auth 회원가입 전송 정책 | AUTH-01, AUTH-02, MULTIPART-01 | 프로필 설정 회원가입 API 연결 | Open |
| [ ] | API-PLACE | Place response와 식별자 정책 | PLACE-01, PLACE-02, PLACE-03 | 장소 목록/상세/생성/수정/삭제 실데이터 연결 | Open |
| [ ] | API-FRIEND | Friend 요청 목록과 액션 정책 | FRIEND-01, FRIEND-02, FRIEND-03, FRIEND-04 | 장소 친구 요청/추가 화면 API 연결 | Open |
| [ ] | API-IMAGE | Image upload/download/update/delete 정책 | IMAGE-01, IMAGE-02, IMAGE-03, IMAGE-04 | 프로필/장소/식물/메모 이미지 key/url 매핑 | Open |
| [ ] | API-ERROR | 공통/도메인 에러 response 정책 | ERROR-01, ERROR-02 | 사용자 메시지와 field error 매핑 | Open |
| [ ] | API-TOKEN | refresh token과 로그아웃 정책 | TOKEN-01, TOKEN-02 | 인증 만료 복구와 세션 종료 처리 | Open |
| [ ] | API-SEARCH | 주소/식물/사용자 검색 정책 | SEARCH-01, SEARCH-02, SEARCH-03 | 주소 검색, 식물 검색, 친구 추가 검색 UX | Open |
| [ ] | API-MEMO | Memo CRUD와 이미지 첨부 정책 | MEMO-01, MEMO-02, MEMO-03 | 메모 화면 실데이터 연결 | Open |
| [ ] | API-ENV | 서버 환경값과 API versioning | ENV-01 | staging/prod release 검증 | Open |

## 다음 이슈화 기준

- 백엔드 답변이 필요한 항목은 먼저 백엔드 확인 이슈 또는 커뮤니케이션으로 묶는다.
- 팀 내부 결정만 필요한 항목은 `Story` category의 `[Task]` 이슈로 분리한다.
- 실제 코드 변경이 뒤따르는 항목은 결정 이슈와 구현 이슈를 분리한다.
- 하나의 이슈에는 한 영역의 결정만 담는다.
