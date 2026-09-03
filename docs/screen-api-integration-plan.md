# 화면·모델·API 실연동 전환 계획

이 문서는 화면 퍼블리싱 이후 남아 있는 mock 흐름을 실제 상태와 API 계층으로 전환하는 순서와 완료 기준을 관리합니다. 배포 자동화와 원격 E2E 준비는 필요한 외부 조건이 충족될 때까지 유지하되, 현재 MVP 최우선 작업은 사용자 동선별 수직 슬라이스 완성입니다.

2026-08-31 기준 후속 범위 정리 #267 / PR #268, 대체된 과거 계획 제거 #269 / PR #270, Home 배지 오류 구분 #271 / PR #272, Plant 장소 code 복원 #273 / PR #274, 공통 API 오류·인증 만료 #275 / PR #276까지 병합됐습니다(`5426768`). 상위 Epic #226은 하위 이슈 20/20 완료로 종료했습니다. 아래의 병합 상태는 연결 PR의 이력이며, 실제 인증 E2E나 모든 입력·오류 경로가 완료됐다는 의미는 아닙니다. 후속 실행·보류 범위는 사용자 결정에 따라 #267에서 다시 고정합니다.

## 목표

각 작업은 하나의 사용자 동선을 아래 순서까지 끊김 없이 연결합니다.

```text
화면 입력/상태 UI
  -> Riverpod Controller
  -> 화면용 상태·도메인 모델
  -> Repository/DataSource
  -> dev Swagger API
  -> unit/widget/router test
```

- 화면 위젯은 JSON 파싱이나 Dio 호출을 직접 수행하지 않습니다.
- API 사용 여부는 기존 `COMMONPLANT_USE_API` 환경값으로 분리합니다.
- API 비사용 모드는 화면 개발과 Android smoke의 결정적 mock 흐름을 유지합니다.
- Swagger에 response schema가 없는 기능은 화면 모델을 추측하지 않고, 배포 기준과 일치하는 백엔드 Controller·DTO·Service 근거까지 확인한 뒤 연결합니다.
- loading, success, empty, error 상태를 해당 화면과 Controller 테스트에서 함께 검증합니다.

## 후속 개발 실행 순서 #267

아래 항목은 순서대로 별도 이슈·브랜치·PR에서 진행합니다. 확인되지 않은 endpoint·필드·식별자는 구현하지 않으며, 계약이 필요한 단계는 [백엔드 질문](backend-api-open-questions.md)의 해당 항목을 `Answered`로 갱신한 뒤 화면 → 상태·모델 → repository·API → 회귀 테스트 순서로 연결합니다.

| 순서 | 작업 | 선행 조건 | 완료 결과 |
| --- | --- | --- | --- |
| 1 | #267 완료 상태·후속 범위 문서 동기화 | PR #266 병합·Epic #226 20/20 확인 | #267 / PR #268에서 완료 |
| 2 | #271 Home 친구 요청 배지 조회 실패 상태 | 현재 `placeInvitationRequestCountProvider` 오류가 0건으로 보이는 동작 재현 | #271 / PR #272에서 완료 |
| 3 | #273 Plant 소속 장소 code·식물 검색 잔여 동선 | `PLANT-01`, `SEARCH-02` 확인 | Place API의 정확한 plant ID로 Home 진입 code 복원 완료. 검색은 backend #92까지 API mode 차단·미연결 안내 |
| 4 | #275 공통 API 오류 메시지·토큰 만료 처리 | `ERROR-01~02` 확인, `TOKEN-01~02` endpoint 부재 확인 | 표준 오류·field 메시지와 `A003/A004/A009` 로컬 세션 종료 완료. refresh·서버 logout은 backend #149 대기 |
| 5 | #277 Place 멤버·Friend 식별자 기반 쓰기 | `PLACE-05~06`, `FRIEND-05`, 멤버 고유 ID·변경 endpoint, Friend 고유 대상·부분 결과 계약 | backend #150 답변 전 Blocked. 조회 전용·member 나가기 숨김·이름 기반 위험 수용 경계 유지 |
| 6 | #283 Memo 텍스트 CRUD·목록 상태 API 연결 | backend #50~#55 구현·OpenAPI 동기화와 `MEMO-01`, `MEMO-03` 답변. 이미지 첨부 제외 | backend #50 계약 확인 답변 전 Blocked. 로컬 화면 유지, 추정 DTO·pagination·권한 모델 추가 금지 |

선행 계약이 없는 단계는 편의를 위해 fixture·첫 항목·표시 이름을 원격 값으로 사용하지 않습니다. 답변 대기 중인 사실을 기록하고 다음 단계의 계약 확인을 병행할 수는 있지만, 순서를 완료한 것으로 표시하지 않습니다.

2026-09-01 #283에서 live OpenAPI 19개 path와 backend main `7d572cb`를 다시 확인했으며 Memo path/schema와 구현 파일은 없었습니다. backend #50~#55는 endpoint 초안이지만 본문 최대 200/500자, 이미지 생략 시 유지/삭제, 작성자·권한, pagination, 성공 wrapper가 확정되지 않았습니다. [backend #50 계약 확인 코멘트](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/50#issuecomment-5488630254)의 텍스트 CRUD 조건과 live OpenAPI가 일치한 뒤 별도 Feature 이슈를 생성합니다.

### 소셜 로그인 SDK 재개 #285

2026-09-02 사용자 결정으로 소셜 로그인 SDK를 보류 범위에서 꺼냈습니다. 별도 회원가입
진입은 만들지 않고 Kakao·Google·iOS Apple SDK token을 `/auth/login`에 전달한 뒤 실제
`isNewUser` 값으로 기존 사용자 인증과 신규 사용자 프로필·약관·`/auth/register` 흐름을
분기합니다. Apple 버튼은 iOS에서만 표시하며 실제 Apple 서버 검증은 backend #152 배포
전까지 Blocked입니다. 상세 계약은 [소셜 로그인 연동 가이드](social-login-integration-guide.md)를
단일 기준으로 사용합니다.

### 사용자 보류 범위

다음 항목은 취소가 아니라 **이번 실행 큐에서 제외하고 다음 작업으로 보류**합니다.

- 실제 주소 검색 서비스 선정, API key·과금 정책과 adapter 연결
- 업로드 방식 변경이 필요한 이미지 선택·업로드·교체·삭제. 새 방식이 확정될 때까지 #248의 기존 key 보존·미확인 key 차단과 사진이 있는 Place 수정 제한 유지
- 인증된 원격 E2E, 테스트 인증·데이터 격리·cleanup과 GitHub Environment
- 스토어 계정·signing·build number와 릴리즈 workflow. 기존 #215는 `Backlog` 유지

보류 항목의 질문과 준비 계약은 삭제하지 않고 [후속 결정 체크리스트](follow-up-decision-checklist.md)에 유지합니다. 보류 해제는 사용자의 명시적 재개 결정과 필요한 외부 조건 확인 후 별도 이슈에서 진행합니다.

## 수직 슬라이스 구현 현황

P0~P7은 기존 구현 순서를 보존한 표입니다. 다음 작업 순서는 위 #267 후속 실행 순서를 따릅니다.

| 순서 | 수직 슬라이스 | 범위 | 상태 |
| --- | --- | --- | --- |
| P0 | Auth 로그인·회원가입 | 로그인 화면, 인증 세션, 프로필 등록, route redirect, `/auth/login`, `/auth/register` | #227 / PR #228 병합, 실제 SDK·`isNewUser` 계약은 #285 / PR #286 리뷰 중 |
| P1 | Home 초기 데이터 | 인증 사용자 정보와 장소·식물 요약을 화면 상태로 연결 | #232 / PR #233 병합 완료 |
| P2 | Plant 핵심 동선 | 목록, 상세, 생성, 수정 API와 각 화면 상태 연결 | #229, #231 병합 완료 |
| P3 | User 프로필 | 내 정보 조회·수정과 프로필 화면 연결 | #237 / PR #238 병합 완료, 이미지 파일 선택 정책과 분리 |
| P4 | Place 목록·상세 | Home 장소 목록, 상세 owner·멤버·식물 실데이터 연결 | #239 / PR #240 병합 완료 |
| P5 | Friend 수신 요청 | 요청 목록, 수락, 거절 API와 화면 상태 연결 | #241 / PR #242 병합 완료 |
| P6 | Place 생성·수정 후속 흐름 | 생성 code·수정 결과와 친구 요청 전송 연결 | #243 / PR #244 병합 완료 |
| P7 | Place 친구 관리 조회 | 실제 멤버 목록·이미지·닉네임 필터와 상태 UI | #245 / PR #246 병합 완료 |
| 후속 | Memo | 텍스트 CRUD·목록 상태를 화면부터 API까지 연결 | #283 계약 경계 정리, backend #50 답변·구현 전 Blocked |
| 보류 | Image | 새 업로드 방식이 필요한 프로필·Place·Plant·Memo 이미지 흐름 | 사용자 재개 결정과 새 계약 필요 |

P1은 Home 화면이 실제 로그인 직후 첫 진입점이라는 점을 기준으로 했습니다. #239는 live Swagger에 누락된 Place schema를 백엔드 main `7d572cb`의 Controller·DTO와 대조해 목록·상세 응답 계약을 연결했고, #241은 같은 source에서 확인한 Friend 수신 요청 계약을 화면까지 연결합니다.

## 화면 연결 매트릭스

`부분 연결`은 화면에서 endpoint를 호출하지만 일부 표시값이나 입력값이 fixture·고정값으로 남아 있다는 의미입니다. Swagger에 성공 response 또는 endpoint가 없는 항목은 구현 편의를 위해 추정하지 않습니다.

| 도메인 | 화면·route | 현재 상태 | 남은 연결 | API·선행 조건 | 판정 |
| --- | --- | --- | --- | --- | --- |
| Home | Home `/` | User·Place·Plant 목록·Friend 요청 수 연결, #249 계정별 캐시 격리, #271 배지 loading·오류·0건·성공 수와 재시도 구분 | 인증된 원격 smoke | Friend 요청 목록 source 계약 #241 반영 | #271 Provider·widget 회귀 검증 완료 |
| User | 마이페이지 `/me`, 설정 `/me/settings`, 회원 정보 수정 `/me/edit` | 조회·이름 수정·탈퇴와 세 화면 연결, #249 세션 격리·#250 제출 잠금 병합 | 이미지 파일 선택·알림 영속화 | `GET/PUT/DELETE /users` 연결, Image·알림 API/정책 필요 | 연결·세션 격리·제출 잠금 PR 병합 |
| Place | 장소 친구 요청 | API 목록·프로필·loading/empty/error와 수락·거절 연결, fixture 모드 유지 | 원격 인증 smoke | `GET /friends/requests`, `POST /friends/accept`, `POST /friends/decline` #241 반영 | #241 연결 |
| Place | 장소 등록 | create API·생성 code·친구 추가 route 연결, #250 잠금 병합, #253 / PR #263 주소 결과·검증·요청 연결 | 실제 주소 검색·이미지 | 결과 계약은 테스트로 검증, API 모드 fixture 주소 차단 | 실제 검색 미연결로 새 주소가 필요한 생성 동선 미완료 |
| Place | 주소 검색 | #253 / PR #263 typed 결과 반환·취소 보존, 로컬 fixture 검색·empty, API 모드 미연결 안내 | 외부 검색 서비스·키·과금·adapter | `AddressSearchResult` 출처와 세션·화면 수명 검증 | 결과 전달 수정, 실서비스 검색은 미연결 |
| Place | 장소 등록 중 친구 추가 | User 검색, 생성된 place code, 선택 사용자 요청 submit 연결 | 고유 사용자 식별자와 대상별 결과 검증 | `GET /users/{keyword}`, `POST /friends/request`; 동명이인 위험은 별도 등록 | #243 위험 수용 연결 |
| Place | 장소 수정 | #248 사진 수정 차단·#250 잠금·#253 / PR #263 주소 결과 연결 병합, 취소 시 서버 주소 보존 | key 계약 후 제한 해제, 실제 주소 검색 | imageKey 생략은 삭제 의미, 상세에는 key 미제공 | 기존 주소 수정 유지, 새 주소 검색·사진 있는 장소 수정은 제한 |
| Place | 장소 상세 | API 장소·owner·멤버·식물 연결, fixture 병합 제거 | 서버 미제공 환경 수치와 물주기 액션 | `GET /place/{code}` source 계약 #239 반영 | #239 / PR #240 병합 완료 |
| Place | 친구 관리 | 실제 멤버·이미지 조회, 닉네임 필터, loading/empty/error/retry 연결 | 멤버 추가·삭제·권한 변경 | `GET /place/{code}/members` 연결, 고유 member id와 변경 endpoint 없음 | #245 조회 전용 연결 |
| Place | 장소 나가기·삭제 | API 모드는 owner 삭제만 노출 | 구성원 나가기 | delete는 owner 전용 전체 삭제, leave endpoint 없음 | 삭제 #239, 나가기 Blocked |
| Plant | 식물 등록 검색 | #273에서 API mode fixture 차단·미연결 안내, API 비사용 검색·empty·선택 유지 | 실제 검색 모델과 loading/empty/error/success | 백엔드 #92의 식물 종 검색 endpoint·DTO 필요 | Blocked |
| Plant | 식물 등록 | 장소·애칭·날짜와 create submit 연결, #250 잠금·#251 실제 장소·loading/error/empty·재시도·제출 보호 병합 | 학명/이미지·장소 사진 | `GET /place/user`, `POST /plants`; 실제 목록 code만 사용 | #251 / PR #261 병합, 인증 E2E 별도 |
| Plant | 식물 수정 | #248 이미지 key 보존·#250 제출 잠금, #252 code 누락 차단, #273 Home 진입 code 복원 | 이미지 선택·삭제 UI | `GET /plants/{id}/edit`, `PUT /plants/{id}?placeCode=...`; route·Plant code 우선, 없으면 Place 상세 plant ID 대조 | 실제 code 복원·미발견 차단 회귀 검증 완료 |
| Plant | 식물 상세 | detail/delete, 등록일 계산·실제 값, #273 code resolver loading/error/missing/success·재시도 연결 | Memo CRUD·물주기 액션, resolver N+1 최적화 | `GET/DELETE /plants/{id}`, `GET /place/user`, `GET /place/{code}`; Memo·물주기 API 없음 | #231 상세 연결, #273 code 복원 |
| Memo | 메모 작성 | 로컬 Provider 저장 | 텍스트 DTO, repository, async submit. 이미지는 별도 보류 | backend #50·#51 구현과 OpenAPI request/response·200자 validation 계약 필요 | #283 Blocked |
| Memo | 메모 목록·수정·삭제 | 로컬 fixture·상태 | 작성자·권한·pagination, 수정·삭제, 상세 갱신 | backend #50·#52~#55 구현과 OpenAPI schema·오류 계약 필요 | #283 Blocked |
| Onboarding | 온보딩 | 정적 화면 완료 | #287 로컬 완료 값과 초기 route 연결 | 서버 API 불필요, 재설치·백업 복원 UX는 미결정 | 정책 확정·구현 분리 |

## 병렬 작업 설계

2026-08-25 기준 #227 / PR #228이 `develop`에 병합된 뒤 아래 workstream을 동일한 `develop` 커밋에서 분기했습니다. 각 branch는 별도 git worktree에서 실행합니다.

| Workstream | 이슈·브랜치 | 소유 파일 | 공유 파일 경계 | 병렬 여부 |
| --- | --- | --- | --- | --- |
| 계획 문서 | #230 `docs/screen-api-parallel-plan-230` | `docs/screen-api-integration-plan.md` | 구현 branch는 이 파일을 수정하지 않음 | 독립 |
| Home 사용자 | #232 `feature/home-user-api-state-232` | `lib/features/home/**`, 신규 current-user Provider, 관련 test | Plant와 router 파일 수정 금지 | 독립 |
| Plant Form | #229 `feature/plant-form-api-state-229` | form page/controller/state/edit provider, form 전용 widget·test | detail mapper/model/page 수정 금지 | 독립 |
| Plant Detail | #231 `feature/plant-detail-api-view-231` | detail mapper/model/provider/page, detail 전용 widget·test | form 파일 수정 금지 | 독립 |

병렬 branch에서는 `pubspec.yaml`, `lib/core/network/**`, `app/router/**`, Plant repository interface처럼 여러 workstream이 함께 쓰는 파일을 변경하지 않습니다. 변경이 불가피하면 해당 branch에서 임의로 넓히지 않고 공통 선행 이슈로 분리합니다.

각 구현 branch는 중앙 계획 문서 대신 `docs/work-history/<workstream>-<issue>.md`에 자신의 커밋과 검증 이력을 기록합니다. 따라서 세 PR의 merge 순서는 서로 의존하지 않으며, merge 뒤 User 프로필 작업만 #232의 current-user Provider를 기반으로 시작합니다.

### 병렬 작업 완료 조건

1. 각 branch가 최신 `develop`에서 파생되었는지 확인합니다.
2. 이슈 본문의 소유 파일 밖을 수정하지 않습니다.
3. API 비사용 화면 흐름과 기존 Android smoke를 유지합니다.
4. 각 PR에서 format, analyze, 전체 test와 required `quality`를 통과합니다.
5. PR merge는 사용자가 수행하며, 후속 branch는 merge된 공통 기반이 필요할 때만 새로 생성합니다.

## Auth 첫 수직 슬라이스

#227은 기존 #216의 Auth datasource/repository를 실제 화면과 앱 세션에 연결했습니다.

- 소셜 로그인 버튼은 `LoginController`를 통해 provider credential과 `/auth/login`을 연결합니다. #285 / PR #286은 Kakao access token, Google ID token과 iOS Apple identity token을 기존 gateway에 공급합니다.
- `/auth/login`의 실제 `isNewUser`가 `true`면 `signupToken`을 보존하고 프로필 설정으로, `false`면 access/refresh token을 저장하고 Home으로 이동합니다. 별도 회원가입 시작 route는 만들지 않습니다.
- Apple 버튼과 SDK 호출은 iOS에서만 제공합니다. Android에서는 버튼·간격·Semantics를 렌더링하지 않으며 backend #152 배포 전까지 실제 Apple 인증은 Blocked입니다.
- 신규 사용자는 `signupToken`, 추천 이름, 추천 이미지 URL을 세션에 보존하고 프로필·약관 화면으로 이동합니다.
- 약관 동의 후 프로필 이름과 `signupToken`으로 `/auth/register`를 호출하고 인증 세션으로 전환합니다.
- 프로필 샘플 이미지는 로컬 UI 상태이므로 서버 multipart 이미지로 임의 전송하지 않습니다. 실제 파일 선택 결과가 준비될 때 optional image 경계에 연결합니다.
- API 모드는 secure storage의 access/refresh token 쌍으로 세션을 복원합니다. #287은 access token 없이 refresh token만 있으면 갱신을 먼저 시도하는 목표를 확정했지만, 현재는 endpoint가 없어 부분 token 삭제를 유지합니다.
- #275에서 active access-token 요청의 `A003`, `A004`, `A009`는 현재 인증·데이터 세션을 종료하고 로그인 만료 안내로 연결합니다. refresh endpoint가 없으므로 자동 갱신·원요청 재시도는 하지 않으며 backend #149에서 계약을 추적합니다. 서버 로그아웃 연동은 현재 우선순위에서 제외합니다.
- 온보딩은 #287에서 비보안 로컬 완료 값을 사용하기로 했습니다. 값이 없으면 온보딩, 있으면 인증 복원으로 진입하며 앱 삭제·재설치 중 OS 백업이 복원된 경우의 재노출 여부는 구현 전 결정합니다.
- #249에서 로그인·회원가입 결과마다 사용자 데이터 세션을 교체합니다. 늦은 SDK·API 결과는 이전 세션에 반영하지 않으며 token 저장·삭제는 같은 큐에서 순서대로 처리합니다.
- #250에서 가입 프로필 입력 중에도 제출 잠금을 유지하고 세션 확인 전 닉네임을 캡처합니다. 실패 후 새 입력값으로 재시도하며, 인증·이미지 계약은 바꾸지 않습니다.
- 라우터는 `unauthenticated`, `signupRequired`, `authenticated` 세션에 따라 접근을 제어하고 로그인 전 target을 보존합니다.

## 계정별 데이터 격리 #249

기존 User/Place/Plant/Friend endpoint와 DTO 계약은 변경하지 않습니다. 같은 `ProviderScope`에서 사용자별 조회와 파생 정보 14개 경로를 세션에 연결하고, 비인증 상태에서는 새 요청을 시작하지 않습니다. 화면 loading/error에서는 이전 계정의 `AsyncValue` 데이터를 숨깁니다.

프로필·Place·Plant 폼, 친구 선택·처리 상태, 알림 설정과 로컬 추가 데이터도 API 모드에서 초기화합니다. 늦은 변경 응답은 현재 세션을 확인한 뒤에만 상태·캐시·이동 결과를 반영하며, 탈퇴 응답으로 새 계정을 로그아웃시키지 않습니다. API 비사용 fixture는 유지합니다.

검증은 fake repository·token store·Dio adapter와 widget test로 수행했습니다. 서버에 이미 전달된 변경의 취소·롤백, OS 저장소 장애, 실제 인증 E2E는 [작업 이력의 제한](work-history/session-cache-isolation-249.md#남은-제한과-위험)과 구분합니다. 중복 제출은 [#250 별도 이력](work-history/form-submit-lock-250.md), 원격 식물 등록의 fixture 혼입은 [#251 이력](work-history/remote-plant-places-251.md), code 없는 수정의 거짓 성공은 [#252 이력](work-history/plant-edit-place-code-252.md)에서 보완합니다. #253 주소 선택 결과에도 같은 세션·폼 수명 검증을 적용했고 #254 목록 항목 검증과 #255 비활성 입력 clear 차단은 병합됐습니다. #256은 이 세션 경계를 유지하면서 수정 정보의 중간 원격 Provider를 제거했습니다.

## 목록 응답 검증 #254

공용 목록 파서는 direct 목록과 확인된 nested wrapper, 정상 빈 배열을 유지합니다. 비-Map 항목이 하나라도 있으면 해당 항목을 버려 빈 목록이나 부분 성공으로 바꾸지 않고 context와 위치가 포함된 `ApiException`을 반환합니다. 이 오류는 기존 repository·Provider의 오류 경계로 전달되며 화면에서 정상 empty 상태로 취급하지 않습니다.

검증은 fake 응답과 실제 Plant mapper, Place·User repository를 사용했습니다. 항목 내부 필드의 유효성은 각 도메인 mapper 책임으로 유지하고 범용 파서 프레임워크·codegen·새 패키지는 도입하지 않았습니다. 실제 인증 서버의 비정상 응답과 원격 E2E는 [#254 작업 이력](work-history/api-list-item-validation-254.md)의 남은 범위로 구분합니다.

## 공용 입력 비활성 경계 #255

`CommonTextField`의 clear는 validation을 반영한 실제 enabled 상태를 따릅니다. `forceFocusedDecoration`은 line·counter 같은 장식만 유지하며 `enabled: false` 또는 disabled state를 입력 가능 상태로 바꾸지 않습니다. 비활성 필드는 clear를 표시하거나 실행하지 않아 값과 `onChanged`를 보존하고, 활성 clear·trailing·counter public API는 유지합니다.

검증은 공용 위젯에서 활성 clear와 두 비활성 경계를 직접 탭·상태로 확인했습니다. `CommonSearchTextField`와 `CommonAddressOrPlaceField`의 별도 삭제 정책, 화면 Controller, API payload는 변경하지 않았으며 실제 Android/iOS 입력·접근성 smoke는 [#255 작업 이력](work-history/disabled-text-field-clear-255.md)의 남은 범위로 구분합니다.

## 수정 정보 Provider 경계 #256

Plant·Place 수정 폼은 API 비사용 fixture 분기와 공개 폼 진입 Provider를 유지합니다. API 모드에서는 Plant의 `remotePlantEditInfoProvider`, Place의 `placeSummaryProvider`가 실제 fetch·오류·재시도를 소유하고, 폼 진입 Provider가 원본 `AsyncValue`를 nullable 수정 정보로 순수 변환합니다. 같은 상태를 `.future`로 다시 포장하던 중간 원격 Provider 두 개는 제거했습니다.

Controller의 조회 재시도는 원본 하나만 무효화합니다. 원본 Provider override, repository 위임, 빈 정보·오류 복구와 기존 loading/error/notFound, 계정 전환·제출 잠금 회귀를 함께 확인했습니다. API endpoint·요청 횟수·DTO·repository·화면은 변경하지 않았으며 실제 인증 API와 플랫폼 수동 smoke는 [#256 작업 이력](work-history/form-edit-provider-flow-256.md)의 남은 범위로 구분합니다.

## User 프로필 수직 슬라이스

#237은 Home에서 마련한 `currentUserProvider`를 수정 가능한 현재 사용자 상태로 확장하고, Figma의 마이페이지·설정·회원 정보 수정 화면을 연결합니다.

- 마이페이지는 `GET /users`의 loading/error/success 상태를 표시하고 Home 하단 My 탭에서 진입합니다.
- 이름 수정은 2~10자 검증과 변경 여부를 기준으로 `PUT /users`를 호출하며, 성공 응답으로 현재 사용자 상태를 즉시 교체합니다.
- 회원 탈퇴는 확인 dialog 뒤 `DELETE /users` 성공 시 인증·데이터 세션을 먼저 닫고 secure token 삭제를 기다립니다.
- 서버 logout endpoint가 없어 로그아웃은 로컬 인증·데이터 세션과 secure token만 제거합니다.
- 알림 설정 endpoint가 없어 토글은 로컬 Provider 상태로 둡니다. 화면 폐기 또는 API 모드의 계정 전환 때 초기화합니다.
- 프로필 이미지는 기존 optional multipart 경계를 유지하지만, 파일 선택기와 플랫폼 권한 정책이 확정되지 않아 현재 이미지와 카메라 진입 안내까지만 제공합니다.

## Place 목록·상세 수직 슬라이스

#239는 live Swagger에 노출되지 않은 Place 성공 타입을 백엔드 main `7d572cb`의 Controller·DTO와 대조한 뒤, Home 장소 목록과 장소 상세의 remote fixture 병합을 제거합니다.

- Home 장소 목록은 `GET /place/myGarden`의 `result.placeList`에서 code, 이름, 대표 이미지, 멤버 수, 식물 수를 파싱합니다.
- 장소 상세는 `GET /place/{code}`를 별도 `PlaceDetail` 도메인 모델로 변환하고 owner, 멤버, 식물을 화면 ViewData로 연결합니다.
- API 모드에서는 서버가 제공하지 않는 햇빛·습도, 물주기 예정값, fixture 멤버·식물을 표시하지 않습니다.
- 마지막 물주기 날짜가 있으면 확인 가능한 이력으로 표시하고, 물주기 action은 endpoint가 없어 활성화하지 않습니다.
- `DELETE /place/delete/{code}`는 owner 전용 전체 삭제이므로 owner에게만 삭제 문구와 영향 범위 경고를 표시합니다.
- 구성원 leave endpoint가 없어 API 모드의 구성원에게는 동작하지 않는 나가기 action을 노출하지 않습니다.
- API 비사용 모드는 Android smoke와 화면 개발을 위해 기존 fixture 흐름을 유지합니다.

## Place 생성·수정 결과 수직 슬라이스

#243은 백엔드 source에서 확인한 생성·수정 성공 result를 Form의 후속 흐름까지
보존합니다.

- `POST /place/create`의 result 문자열을 생성된 place code로 파싱합니다.
- `PUT /place/update/{code}`의 `{ code, name, address, imgUrl }`를
  `PlaceSummary`로 파싱합니다.
- Form Controller는 API·fixture 모드 모두 생성된 장소 식별자를 submit 결과에
  저장합니다.
- 장소 생성 뒤 친구 추가 route는 `placeCode` query로 생성된 장소 문맥을
  전달합니다.
- 수정 성공은 서버가 반환한 canonical code를 보존하고 기존 목록·상세 Provider
  invalidate 정책을 유지합니다.
- 선택한 프로필의 표시 이름과 생성된 place code로 `POST /friends/request`를
  호출하고 전송 중 중복 submit과 실패 재시도를 처리합니다.
- 이름 기반 오초대와 일괄 요청의 부분 성공 위험은
  `docs/accepted-implementation-risks.md`에 수용 상태와 중단 조건을 기록합니다.
- 실제 주소 검색 adapter와 이미지 선택은 정책·endpoint가 준비될 때까지 분리합니다. 주소 선택 결과 전달은 #253에서 구현·검증했지만 API 모드의 실제 검색은 미연결입니다. 샘플 결과를 원격 폼에 반영하지 않고 기존 주소를 보존합니다([검증·제한](work-history/place-address-result-253.md)). #248은 사진이 있는 장소의 수정 요청을 차단하며, key 조회 계약 확보 후 별도 작업에서 제한을 해제합니다.

## Friend 수신 요청 수직 슬라이스

#241은 백엔드 main `7d572cb`에서 확인한 Friend 요청 계약을 typed entity와
장소 친구 요청 화면에 연결합니다.

- `GET /friends/requests`의 `result.requests`를 요청 PK, 발신자 프로필,
  장소 code·이름·주소, 상태를 가진 `FriendInvitation`으로 변환합니다.
- 요청 화면은 API 모드에서 loading·empty·error·success를 구분하고 조회 오류의
  재시도 action을 제공합니다.
- 수락·거절은 목록의 `friendId`를 `POST /friends/accept` 또는
  `POST /friends/decline`에 전달하며 항목별 중복 submit을 막습니다.
- 성공한 원격 요청은 화면에서 제거하고 목록을 invalidate하며, Home 요청 배지도
  동일한 미처리 요청 수로 갱신합니다.
- API 비사용 모드는 Figma 처리 결과와 Android smoke를 위해 기존 fixture 흐름을
  유지합니다.
- 신규 요청 전송은 #243에서 우선 연결했습니다. 표시 이름 부분 검색의 첫 결과를
  사용하는 서버 정책으로 인한 오초대 위험은 해결되지 않았으며 별도 위험 등록부의
  `FRIEND-RISK-01`로 추적합니다.

#271은 Home의 파생 요청 수가 가진 `AsyncValue` 상태를 그대로 렌더링합니다. 최초
loading은 진행 표시, 조회 오류는 정상 0건과 다른 재시도 버튼, 정상 응답은 0건과
양수 count로 구분합니다. 재시도는 요청 목록 화면과 같은 원격 Provider를
무효화하며 API 비사용 fixture와 수락·거절 뒤 count 갱신은 유지합니다.

## Place 친구 관리 조회 수직 슬라이스

#245는 `GET /place/{code}/members`의 가입 순서 멤버 목록을 친구 관리 화면에
연결합니다. 2026-08-28 live OpenAPI와 backend main `7d572cb`의 계약을 재확인했습니다.

- `result` 배열을 기존 `PlaceMember`로 변환하고 이름과 프로필 이미지 URL을
  화면에 전달합니다. 동명이인 항목은 합치지 않습니다.
- 서버 조회와 검색 query를 분리해 필터 입력 시 재요청하지 않고, 오류 재시도 시
  현재 query를 유지합니다.
- API 모드는 조회 전용 안내, 실제 멤버 목록과 확인 버튼을 표시합니다. 서버에
  반영되지 않는 선택·삭제 UI는 노출하지 않습니다.
- fixture 모드의 기존 선택·삭제 흐름은 그대로 유지합니다.
- 멤버 고유 ID·변경 endpoint와 실제 인증 응답 검증의 한계는
  `docs/accepted-implementation-risks.md`에 기록합니다.

## Plant 장소 code 조회와 검색 경계 #273

#273은 Plant 응답에 없는 소속 장소 code를 기존 Place 계약으로 복원합니다.
`GET /place/user`의 실제 code 목록을 읽고 각 `GET /place/{code}`의
`plantList[].plantId`를 대상 식물 ID와 정확히 비교합니다. route 또는 향후 Plant
응답의 code를 우선하며, 장소명·학명·첫 장소는 추정값으로 사용하지 않습니다.

resolver는 식물 상세의 loading·오류·미발견·성공과 재시도에 합쳐집니다. 계정 전환
뒤 늦은 이전 조회는 사용자 데이터 세션 경계에서 폐기합니다. direct code가 없는
동안의 순차 장소 상세 조회 비용과 한 장소 조회 실패가 상세 오류가 되는 동작은
[위험 등록부](accepted-implementation-risks.md#plant-소속-장소-code-조회)에서
추적합니다.

2026-08-31 live OpenAPI와 backend main `7d572cb`에는 식물 검색 endpoint가 없고
백엔드 #92도 `Open / Backlog`입니다. API 모드는 fixture를 원격 결과로 사용하지
않고 미연결 안내와 선택 차단을 표시합니다. API 비사용 모드의 로컬 검색·empty·선택
동작은 유지하며 실제 검색 상태 연결은 백엔드 #92 완료 후 별도 이슈로 진행합니다.

## Memo API 계약 경계 #283

2026-09-01 live OpenAPI에는 Memo path와 schema가 없고 backend main `7d572cb`에도
Memo 구현 파일이 없습니다. backend #50~#55는 생성·조회·수정·삭제·validation의
계획 이슈이며 배포 계약으로 사용하지 않습니다.

- 생성 #51의 content 최대 200자와 validation #55의 최대 500자가 충돌합니다.
- 수정 #53은 이미지 생략 시 삭제와 null이 아닌 필드만 갱신한다는 문구가 충돌합니다.
- 조회 #52의 draft response에는 목록 화면에 필요한 작성자 식별자·이름·프로필,
  수정·삭제 권한과 pagination이 없습니다.
- 삭제 #54의 `204 No Content`가 현재 공통 `JsonResponse` 방식과 같은지 미확정입니다.
- 이미지 흐름은 사용자 보류 범위이므로 텍스트 CRUD 선행 조건과 분리합니다.

[backend #50](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/50#issuecomment-5488630254)에
식별자·권한, 이미지 없는 multipart 요청, response wrapper, pagination·날짜,
텍스트 수정 시 기존 이미지 유지, validation·오류 code를 요청했습니다. 답변과 구현이
live OpenAPI에 반영되기 전에는 Memo DTO, repository, 원격 Provider와 임의
pagination/result wrapper를 추가하지 않습니다. 현재 API 비사용 로컬 화면과 사진
상태만 유지합니다.

## 공통 API 오류와 인증 만료 #275

dev 401 응답과 backend main의 `ErrorResponse`·도메인 error enum을 대조해 공통 오류 경계를 확정했습니다. `ApiException`은 status·code·traceId와 validation field reason을 분리하고 rejected value를 폐기합니다. 주요 생성·수정·삭제 Controller는 raw 서버 상세 대신 HTTP·전송 범주의 안전한 메시지를 사용하며 Place·Plant·User·가입 프로필 폼은 확인된 field error를 입력에 연결합니다.

active access-token 요청의 `A003`, `A004`, `A009`는 한 세션에서 한 번만 만료를 알리고 현재 인증·데이터 세션과 로컬 token을 정리합니다. 라우터는 로그인으로 이동하고 만료 이유를 표시하며, 계정 전환 뒤 늦은 이전 응답은 새 세션을 종료하지 않습니다. live OpenAPI와 backend Controller에 refresh·logout endpoint가 없어 자동 갱신·원요청 재시도·서버 invalidation은 구현하지 않았고 backend #149로 분리했습니다.

## Place 멤버·Friend 식별자 쓰기 #277

2026-08-31 live OpenAPI와 backend main `7d572cb`를 다시 대조했습니다. `GET /place/{code}/members`는 성공 schema 없이 `{ name, image }[]`만 반환하고 멤버 고유 ID·역할, 구성원 나가기, owner의 멤버 제거·권한 변경 endpoint가 없습니다. `POST /friends/request`도 `receiverName[]`을 받아 부분 검색 첫 결과를 사용하며 대상별 결과나 전체 원자성 계약을 제공하지 않습니다.

[백엔드 #150](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/150)에 멤버와 Friend의 고유 식별자·권한·성공/실패·멱등 계약을 요청했습니다. 답변과 live OpenAPI 반영 전에는 임시 화면 key, 표시 이름, fixture, 목록 첫 항목을 원격 쓰기 값으로 사용하지 않습니다. #245의 API 멤버 조회 전용 UI, #239의 구성원 나가기 숨김, #243의 사용자 승인 아래 수용한 이름 기반 요청 경계를 그대로 유지하며 5번 단계를 완료로 표시하지 않습니다.

## 완료 기준

각 수직 슬라이스는 아래 항목을 모두 충족해야 완료로 판단합니다.

1. 화면이 Controller 상태만 관찰하고 loading/error/empty/success를 구분합니다.
2. DTO와 화면 모델 변환이 data/domain 경계에 있습니다.
3. API 비사용 mock 흐름과 API 사용 흐름이 섞이지 않습니다.
4. Swagger와 다른 필드를 추정하지 않고 불명확한 항목을 문서에 남깁니다.
5. Controller unit test와 핵심 widget/router test를 추가합니다.
6. `fvm dart format`, `fvm flutter analyze`, `fvm flutter test`를 통과합니다.

## 작업 이력

| 이슈 | 커밋 | 변경 범위 | 검증 |
| --- | --- | --- | --- |
| #227 | `111373a` | Auth 세션 상태, secure token 복원, 소셜 credential gateway 경계 | Auth session/controller test |
| #227 | `a065188` | 로그인·프로필·약관 화면 상태와 login/register repository 연결 | login/profile unit·widget test |
| #227 | `e9543fc` | 인증 상태 기반 route 접근 정책과 redirect target 복원 | router redirect test |
| #227 | `9c21d24` | 화면·모델·API 수직 슬라이스 우선순위와 Auth 작업 이력 문서화 | format 270개, analyze, 전체 test 280개·기존 skip 1개 |
| #230 | - | 남은 화면 연결 매트릭스, 병렬 workstream과 파일 소유권 문서화 | `git diff --check` |
| #237 | `684d55b` | 마이페이지·설정·회원 정보 수정 UI와 User 조회·수정·탈퇴 상태 연결 | format 284개, analyze, 전체 test 314개·기존 skip 1개 |
| #237 | `3063230` | Figma frame map, route, Swagger 연결 상태와 User 구현 경계 문서화 | `git diff --check` |
| #239 | `893d201` | Place 목록·상세 모델, mapper, Provider와 remote 실데이터 UI 연결 | Place test 81개, analyze |
| #239 | `7ac4bc1` | owner 전체 삭제와 구성원 나가기 미지원 경계 분리 | format 286개, analyze, 전체 test 321개·기존 skip 1개 |
| #241 | `24079a6` | Friend 요청 entity·mapper와 typed repository 연결 | Friend data test 13개 |
| #241 | `a1761a8` | 요청 상태·수락·거절과 Home 동적 요청 수 연결 | Provider·Home test 9개 |
| #241 | `0141f74` | 요청 화면 loading·empty·error·submit UI 연결 | 관련 test 17개, analyze |
| #241 | - | API 문서 상태와 전체 검증 이력 갱신 | format 289개, analyze, 전체 test 332개·기존 skip 1개 |
| #243 | `c5fbca2` | Place 생성 code·수정 요약 mapper와 typed repository | Place data test 18개 |
| #243 | `d38e031` | Form 결과와 친구 추가 route의 place code 전달 | 관련 test 19개 |
| #243 | `3b2198c` | 선택 친구 이름과 place code 요청 submit, 중복 전송·실패 처리 | Controller·widget test 14개 |
| #243 | - | OpenAPI 재확인, 위험 수용 기록과 전체 검증 이력 갱신 | format 291개, analyze, 전체 test 344개·기존 skip 1개 |
| #245 | `b090581` | 장소 멤버 datasource·mapper·typed repository | Place data test 24개 |
| #245 | `8e46fd8` | 조회 Provider·검색 상태와 친구 관리 API 화면 | 관련 test 28개, analyze |
| #245 | `1611fd0` | 최신 API·위험·매트릭스와 전체 검증 기록 | format 294개, analyze, 전체 test 362개·기존 skip 1개 |
| #245 | - | PR #246·Project In Review 연결 기록 | `git diff --check` |
| #247 | - | PR #246 병합 확인(`2a01bab`), API 연결과 미완료 동선·감사 이슈 분리 | [문서 정리 이력](development-audit-checklist.md) |
| #248 | `7aee5e8`, `cda0aa2` | Plant 이미지 key 보존·불완전 정보 차단, Place 사진 수정 요청 차단과 회귀 테스트 | [이미지 보존 이력](work-history/form-image-preservation-248.md), 전체 376개 통과·기존 skip 1개 |
| #249 | `59c7d7d`, `a3e9711` | PR #258 병합 확인(`a630c66`), 인증·토큰 저장과 사용자별 캐시·늦은 후처리 격리 | [계정 격리 이력](work-history/session-cache-isolation-249.md), 전체 410개 통과·기존 skip 1개 |
| #250 | `2103498`, `8ff9cf5` | PR #259 병합 확인(`b15cdd7`), Place·Plant·User·가입 프로필 입력 중 제출 잠금과 회귀 테스트 | [제출 잠금 이력](work-history/form-submit-lock-250.md), 전체 436개 통과·기존 skip 1개 |
| #251 | `8e08457`, `d0ce294` | PR #260 병합 확인(`bc6e68d`), 원격 식물 등록의 실제 장소·비동기 상태·재시도·제출 보호 | [원격 장소 이력](work-history/remote-plant-places-251.md), 전체 457개 통과·기존 skip 1개 |
| #252 | `464b9b3`, `4dcb910` | PR #261 병합 확인(`ebf6dc4`), 식물 수정 code 누락 차단·성공 후 관련 캐시 갱신과 route 회귀 | [수정 장소 코드 이력](work-history/plant-edit-place-code-252.md), 전체 476개 통과·기존 skip 1개 |
| #253 | `d54d3e4`, `e3a5797` | 주소 결과·출처·폼 연결과 세션·화면 수명 보호, API fixture 차단, PR #263 병합 완료(`ded4fe2`) | [주소 연결 이력](work-history/place-address-result-253.md), 전체 502개 통과·기존 skip 1개, PR #263 CI 503개 통과 |
| #254 | `6cae790`, `74a1426` | 공용 목록의 비-Map 항목을 위치가 드러나는 오류로 처리하고 빈 목록·부분 성공 은폐 차단, PR #264 병합 완료(`f723825`) | [목록 검증 이력](work-history/api-list-item-validation-254.md), 대상 39개·전체 508개 통과·기존 skip 1개, PR #264 CI 509개 통과 |
| #255 | `008bbc6`, `20e2acc` | PR #264 병합 확인(`f723825`), 비활성 `CommonTextField` clear 미노출·실행 차단과 활성 clear 보존, PR #265 병합 완료(`894dd5f`) | [비활성 입력 이력](work-history/disabled-text-field-clear-255.md), 전체 511개·기존 skip 1개, PR #265 CI 512개 통과 |
| #256 | `63b96b2`, `dd21e26` | PR #265 병합 확인(`894dd5f`), Plant·Place 중간 원격 수정 정보 Provider 제거와 원본 조회·재시도·override 경계 유지, PR #266 병합 완료(`011ef7d`) | [Provider 단순화 이력](work-history/form-edit-provider-flow-256.md), 전체 513개·기존 skip 1개, PR #266 CI 514개 통과 |
| #267 | 이 문서의 최종 커밋 | Epic #226 완료 상태, 실행 6단계와 사용자 보류 5개 범위 정리 | [후속 로드맵 이력](work-history/follow-up-development-roadmap-267.md), 문서 링크·인덱스·diff 검사 |
| #271 | `e15de3f` | Home 친구 요청 배지의 loading·오류·재시도·정상 count UI와 파생 Provider 상태 보존 | 대상 15개·전체 519개 통과, 기존 non-Linux golden skip 1개, analyze·format·diff 검사 |
| #273 | `8a51642`, `ec34ea8`, `dbff448` | 정확한 plant ID 기반 장소 code resolver·상세 상태와 API mode 식물 검색 fixture 차단 | 관련 40개·전체 531개 통과, 기존 non-Linux golden skip 1개, analyze·format·diff 검사 |
| #275 | `e507656`, `022e8ba` | 표준 API 오류·field 메시지와 확인된 인증 만료의 세션 종료·로그인 안내 연결 | 전체 547개 통과, 기존 non-Linux golden skip 1개, analyze·format·diff 검사 |
| #277 | 이 문서의 최종 커밋 | Place 멤버·Friend 쓰기 계약 재검증, backend #150 의존성과 기존 안전 경계 유지 | live OpenAPI·backend main·중복 이슈 확인, `git diff --check` |

문서 이력만 갱신하는 커밋은 자기 자신의 해시를 생략할 수 있습니다.
