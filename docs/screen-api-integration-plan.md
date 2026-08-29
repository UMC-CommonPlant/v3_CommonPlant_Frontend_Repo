# 화면·모델·API 실연동 전환 계획

이 문서는 화면 퍼블리싱 이후 남아 있는 mock 흐름을 실제 상태와 API 계층으로 전환하는 순서와 완료 기준을 관리합니다. 배포 자동화와 원격 E2E 준비는 필요한 외부 조건이 충족될 때까지 유지하되, 현재 MVP 최우선 작업은 사용자 동선별 수직 슬라이스 완성입니다.

2026-08-29 기준 문서 정리 #247 / PR #257부터 식물 수정 장소 code 검증 #252 / PR #262까지 병합됐습니다(`5fc0140`). #253 주소 선택 결과 연결은 구현·검증 후 사용자 병합을 기다립니다. 실제 주소 검색 서비스는 미연결이며 API 모드의 샘플 사용은 차단합니다. 병합 후 [개발 감사·개선 체크리스트](development-audit-checklist.md)의 #254 파서 수정을 진행합니다. 아래의 병합 상태는 연결 PR의 이력이며, 실제 인증 E2E나 모든 입력·오류 경로가 완료됐다는 의미는 아닙니다.

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

## 수직 슬라이스 구현 현황

P0~P7은 기존 구현 순서를 보존한 표입니다. 다음 작업 순서는 개발 감사 체크리스트를 따릅니다.

| 순서 | 수직 슬라이스 | 범위 | 상태 |
| --- | --- | --- | --- |
| P0 | Auth 로그인·회원가입 | 로그인 화면, 인증 세션, 프로필 등록, route redirect, `/auth/login`, `/auth/register` | #227 / PR #228 병합 완료 |
| P1 | Home 초기 데이터 | 인증 사용자 정보와 장소·식물 요약을 화면 상태로 연결 | #232 / PR #233 병합 완료 |
| P2 | Plant 핵심 동선 | 목록, 상세, 생성, 수정 API와 각 화면 상태 연결 | #229, #231 병합 완료 |
| P3 | User 프로필 | 내 정보 조회·수정과 프로필 화면 연결 | #237 / PR #238 병합 완료, 이미지 파일 선택 정책과 분리 |
| P4 | Place 목록·상세 | Home 장소 목록, 상세 owner·멤버·식물 실데이터 연결 | #239 / PR #240 병합 완료 |
| P5 | Friend 수신 요청 | 요청 목록, 수락, 거절 API와 화면 상태 연결 | #241 / PR #242 병합 완료 |
| P6 | Place 생성·수정 후속 흐름 | 생성 code·수정 결과와 친구 요청 전송 연결 | #243 / PR #244 병합 완료 |
| P7 | Place 친구 관리 조회 | 실제 멤버 목록·이미지·닉네임 필터와 상태 UI | #245 / PR #246 병합 완료 |
| 보류 | Image, Memo | 성공 response 또는 endpoint가 불충분한 영역 | 백엔드 확인 필요 |

P1은 Home 화면이 실제 로그인 직후 첫 진입점이라는 점을 기준으로 했습니다. #239는 live Swagger에 누락된 Place schema를 백엔드 main `7d572cb`의 Controller·DTO와 대조해 목록·상세 응답 계약을 연결했고, #241은 같은 source에서 확인한 Friend 수신 요청 계약을 화면까지 연결합니다.

## 화면 연결 매트릭스

`부분 연결`은 화면에서 endpoint를 호출하지만 일부 표시값이나 입력값이 fixture·고정값으로 남아 있다는 의미입니다. Swagger에 성공 response 또는 endpoint가 없는 항목은 구현 편의를 위해 추정하지 않습니다.

| 도메인 | 화면·route | 현재 상태 | 남은 연결 | API·선행 조건 | 판정 |
| --- | --- | --- | --- | --- | --- |
| Home | Home `/` | User·Place·Plant 목록·Friend 요청 수 연결, #249 계정별 캐시 격리 병합 | 배지 조회 실패 표현 | Friend 요청 목록 source 계약 #241 반영 | 연결·세션 격리 PR 병합 |
| User | 마이페이지 `/me`, 설정 `/me/settings`, 회원 정보 수정 `/me/edit` | 조회·이름 수정·탈퇴와 세 화면 연결, #249 세션 격리·#250 제출 잠금 병합 | 이미지 파일 선택·알림 영속화 | `GET/PUT/DELETE /users` 연결, Image·알림 API/정책 필요 | 연결·세션 격리·제출 잠금 PR 병합 |
| Place | 장소 친구 요청 | API 목록·프로필·loading/empty/error와 수락·거절 연결, fixture 모드 유지 | 원격 인증 smoke | `GET /friends/requests`, `POST /friends/accept`, `POST /friends/decline` #241 반영 | #241 연결 |
| Place | 장소 등록 | create API·생성 code·친구 추가 route 연결, #250 잠금 병합, #253 주소 결과·검증·요청 연결 | #253 병합, 실제 주소 검색·이미지 | 결과 계약은 테스트로 검증, API 모드 fixture 주소 차단 | 실제 검색 미연결로 새 주소가 필요한 생성 동선 미완료 |
| Place | 주소 검색 | #253 typed 결과 반환·취소 보존, 로컬 fixture 검색·empty, API 모드 미연결 안내 | #253 병합, 외부 검색 서비스·키·과금·adapter | `AddressSearchResult` 출처와 세션·화면 수명 검증 | 결과 전달 수정, 실서비스 검색은 미연결 |
| Place | 장소 등록 중 친구 추가 | User 검색, 생성된 place code, 선택 사용자 요청 submit 연결 | 고유 사용자 식별자와 대상별 결과 검증 | `GET /users/{keyword}`, `POST /friends/request`; 동명이인 위험은 별도 등록 | #243 위험 수용 연결 |
| Place | 장소 수정 | #248 사진 수정 차단·#250 잠금 병합, #253 주소 결과 연결·취소 시 서버 주소 보존 | #253 병합, key 계약 후 제한 해제, 실제 주소 검색 | imageKey 생략은 삭제 의미, 상세에는 key 미제공 | 기존 주소 수정 유지, 새 주소 검색·사진 있는 장소 수정은 제한 |
| Place | 장소 상세 | API 장소·owner·멤버·식물 연결, fixture 병합 제거 | 서버 미제공 환경 수치와 물주기 액션 | `GET /place/{code}` source 계약 #239 반영 | #239 / PR #240 병합 완료 |
| Place | 친구 관리 | 실제 멤버·이미지 조회, 닉네임 필터, loading/empty/error/retry 연결 | 멤버 추가·삭제·권한 변경 | `GET /place/{code}/members` 연결, 고유 member id와 변경 endpoint 없음 | #245 조회 전용 연결 |
| Place | 장소 나가기·삭제 | API 모드는 owner 삭제만 노출 | 구성원 나가기 | delete는 owner 전용 전체 삭제, leave endpoint 없음 | 삭제 #239, 나가기 Blocked |
| Plant | 식물 등록 검색 | fixture 검색 | 실제 검색 모델과 상태 | 식물 종 검색 endpoint 필요 | 보류 |
| Plant | 식물 등록 | 장소·애칭·날짜와 create submit 연결, #250 잠금·#251 실제 장소·loading/error/empty·재시도·제출 보호 병합 | 학명/이미지·장소 사진 | `GET /place/user`, `POST /plants`; 실제 목록 code만 사용 | #251 / PR #261 병합, 인증 E2E 별도 |
| Plant | 식물 수정 | #248 이미지 key 보존·#250 제출 잠금 병합, #252 / PR #262 code 누락 안내·차단과 성공 후 관련 캐시 갱신 병합 | Home 식물 목록의 code 확보(PLANT-01), 이미지 선택·삭제 UI | `GET /plants/{id}/edit`, `PUT /plants/{id}?placeCode=...`; 현재는 장소 경유 code 필요 | code 누락 시 재진입 안내, 거짓 성공 회귀 검증 완료 |
| Plant | 식물 상세 | detail/delete, 등록일 계산과 실제 값 연결, remote fixture 제거 | Memo CRUD·물주기 액션 | `GET/DELETE /plants/{id}` 연결; Memo·물주기 API 없음 | #231 연결 완료 |
| Memo | 메모 작성 | 로컬 Provider 저장 | DTO, repository, submit, 실제 image file | Memo 생성 endpoint 필요 | Blocked |
| Memo | 메모 목록·수정·삭제 | 로컬 fixture·상태 | 목록, pagination, 수정·삭제, 상세 갱신 | Memo CRUD endpoint 필요 | Blocked |
| Onboarding | 온보딩 | 정적 화면 완료 | 필요 시 최초 실행 여부 로컬 저장 | 서버 API 불필요 | 연결 제외 |

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

#227은 기존 #216의 Auth datasource/repository를 실제 화면과 앱 세션에 연결합니다.

- 소셜 로그인 버튼은 `LoginController`를 통해 provider credential과 `/auth/login`을 연결합니다.
- 실제 Kakao/Google/Apple SDK가 준비되지 않은 현재는 `SocialAuthCredentialGateway` 기본 구현이 설정 안내 오류를 반환합니다. SDK 도입 시 이 gateway 구현만 교체합니다.
- 신규 사용자는 `signupToken`, 추천 이름, 추천 이미지 URL을 세션에 보존하고 프로필·약관 화면으로 이동합니다.
- 약관 동의 후 프로필 이름과 `signupToken`으로 `/auth/register`를 호출하고 인증 세션으로 전환합니다.
- 프로필 샘플 이미지는 로컬 UI 상태이므로 서버 multipart 이미지로 임의 전송하지 않습니다. 실제 파일 선택 결과가 준비될 때 optional image 경계에 연결합니다.
- API 모드는 secure storage의 access/refresh token 쌍으로 세션을 복원합니다. refresh와 서버 로그아웃은 endpoint 확정 전까지 추가하지 않습니다.
- #249에서 로그인·회원가입 결과마다 사용자 데이터 세션을 교체합니다. 늦은 SDK·API 결과는 이전 세션에 반영하지 않으며 token 저장·삭제는 같은 큐에서 순서대로 처리합니다.
- #250에서 가입 프로필 입력 중에도 제출 잠금을 유지하고 세션 확인 전 닉네임을 캡처합니다. 실패 후 새 입력값으로 재시도하며, 인증·이미지 계약은 바꾸지 않습니다.
- 라우터는 `unauthenticated`, `signupRequired`, `authenticated` 세션에 따라 접근을 제어하고 로그인 전 target을 보존합니다.

## 계정별 데이터 격리 #249

기존 User/Place/Plant/Friend endpoint와 DTO 계약은 변경하지 않습니다. 같은 `ProviderScope`에서 사용자별 조회와 파생 정보 14개 경로를 세션에 연결하고, 비인증 상태에서는 새 요청을 시작하지 않습니다. 화면 loading/error에서는 이전 계정의 `AsyncValue` 데이터를 숨깁니다.

프로필·Place·Plant 폼, 친구 선택·처리 상태, 알림 설정과 로컬 추가 데이터도 API 모드에서 초기화합니다. 늦은 변경 응답은 현재 세션을 확인한 뒤에만 상태·캐시·이동 결과를 반영하며, 탈퇴 응답으로 새 계정을 로그아웃시키지 않습니다. API 비사용 fixture는 유지합니다.

검증은 fake repository·token store·Dio adapter와 widget test로 수행했습니다. 서버에 이미 전달된 변경의 취소·롤백, OS 저장소 장애, 실제 인증 E2E는 [작업 이력의 제한](work-history/session-cache-isolation-249.md#남은-제한과-위험)과 구분합니다. 중복 제출은 [#250 별도 이력](work-history/form-submit-lock-250.md), 원격 식물 등록의 fixture 혼입은 [#251 이력](work-history/remote-plant-places-251.md), code 없는 수정의 거짓 성공은 [#252 이력](work-history/plant-edit-place-code-252.md)에서 보완합니다. #253 주소 선택 결과에도 같은 세션·폼 수명 검증을 적용했고 #254~#256은 남아 있습니다.

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
| #253 | `d54d3e4` | PR #262 병합 확인(`5fc0140`), 주소 결과·출처·폼 연결과 세션·화면 수명 보호, API fixture 차단 | [주소 연결 이력](work-history/place-address-result-253.md), 전체 502개 통과·기존 skip 1개 |

문서 이력만 갱신하는 커밋은 자기 자신의 해시를 생략할 수 있습니다.
