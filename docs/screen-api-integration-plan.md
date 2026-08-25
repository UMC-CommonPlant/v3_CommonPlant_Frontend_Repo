# 화면·모델·API 실연동 전환 계획

이 문서는 화면 퍼블리싱 이후 남아 있는 mock 흐름을 실제 상태와 API 계층으로 전환하는 순서와 완료 기준을 관리합니다. 배포 자동화와 원격 E2E 준비는 필요한 외부 조건이 충족될 때까지 유지하되, 현재 MVP 최우선 작업은 사용자 동선별 수직 슬라이스 완성입니다.

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
- Swagger에 response schema가 없는 기능은 화면 모델을 추측해 연결하지 않습니다.
- loading, success, empty, error 상태를 해당 화면과 Controller 테스트에서 함께 검증합니다.

## 우선순위

| 순서 | 수직 슬라이스 | 범위 | 상태 |
| --- | --- | --- | --- |
| P0 | Auth 로그인·회원가입 | 로그인 화면, 인증 세션, 프로필 등록, route redirect, `/auth/login`, `/auth/register` | #227 / PR #228 병합 완료 |
| P1 | Home 초기 데이터 | 인증 사용자 정보와 장소·식물 요약을 화면 상태로 연결 | #232 / PR #233 병합 완료 |
| P2 | Plant 핵심 동선 | 목록, 상세, 생성, 수정 API와 각 화면 상태 연결 | #229, #231 병합 완료 |
| P3 | User 프로필 | 내 정보 조회·수정과 프로필 화면 연결 | #237 / PR #238 In Review, 이미지 파일 선택 정책과 분리 |
| 제한 | Place | response schema가 확인된 동선부터 연결 | 목록·상세 schema 확인 필요 |
| 보류 | Friend, Image, Memo | 성공 response 또는 endpoint가 불충분한 영역 | 백엔드 확인 필요 |

P1은 Home 화면이 실제 로그인 직후 첫 진입점이라는 점을 기준으로 합니다. 다만 Place 성공 response schema가 없으므로, 먼저 schema가 있는 `GET /users`와 `GET /plants`를 사용하고 Place 데이터는 확인된 필드만 별도 작업으로 추가합니다.

## 화면 연결 매트릭스

`부분 연결`은 화면에서 endpoint를 호출하지만 일부 표시값이나 입력값이 fixture·고정값으로 남아 있다는 의미입니다. Swagger에 성공 response 또는 endpoint가 없는 항목은 구현 편의를 위해 추정하지 않습니다.

| 도메인 | 화면·route | 현재 상태 | 남은 연결 | API·선행 조건 | 판정 |
| --- | --- | --- | --- | --- | --- |
| Home | Home `/` | Place·Plant 목록 API 모드 연결, 사용자명·초대 수 고정 | 현재 사용자 Provider, hero 상태, 목록 재시도 정책, 고정값 제거 | `GET /users`, `GET /plants`; Place·Friend response schema 확인 필요 | #232 즉시 진행 |
| User | 마이페이지 `/me`, 설정 `/me/settings`, 회원 정보 수정 `/me/edit` | 조회·이름 수정·탈퇴 Controller와 세 화면 연결 | 실제 이미지 파일 선택, 알림 설정 영속화 | `GET/PUT/DELETE /users` 연결, Image·알림 API/정책 필요 | #237 / PR #238 In Review |
| Place | 장소 친구 요청 | fixture 목록과 로컬 수락·거절 | 목록 DTO, loading/empty/error, 수락·거절 submit | Friend response schema와 `friendId` 의미 확인 | 제한 |
| Place | 장소 등록 | 이름·주소 create API 연결 | 생성된 장소 code, 실제 이미지, 친구 추가 후속 흐름 | `POST /place/create` response schema 필요 | 부분 연결 |
| Place | 주소 검색 | fixture 검색 | 검색 adapter와 선택 결과 | 백엔드 endpoint 또는 외부 주소 서비스 결정 필요 | 보류 |
| Place | 장소 등록 중 친구 추가 | User 검색만 API 모드 연결 | 선택 사용자 요청 submit, 장소 초대와 친구 요청 관계 | `GET /users/{keyword}`, `POST /friends/request`; 도메인 관계 확인 | 제한 |
| Place | 장소 수정 | 상세 조회와 update API 연결 | 전체 수정 필드, image key/file, 응답 후 갱신 | `GET /place/{code}`, `PUT /place/update/{code}` response schema 필요 | 부분 연결 |
| Place | 장소 상세 | API의 이름·주소와 fixture 상세를 혼합 | 역할, 환경 정보, 멤버, 장소 식물 목록 | Place detail/members schema와 장소별 식물 조회 기준 필요 | 제한 |
| Place | 친구 관리 | fixture 검색·선택·삭제 | 멤버 목록과 추가·삭제 submit | members response와 멤버 변경 endpoint 필요 | 보류 |
| Place | 장소 나가기·삭제 | delete 호출 연결 | 소유자 삭제와 구성원 나가기 분리 | `DELETE /place/delete/{code}` 의미 확인 | 제한 |
| Plant | 식물 등록 검색 | fixture 검색 | 실제 검색 모델과 상태 | 식물 종 검색 endpoint 필요 | 보류 |
| Plant | 식물 등록 | create API 부분 연결, 물주기 날짜 고정 | 날짜 상태·request, 학명/별칭 분리, image file | `POST /plants` 사용 가능; 검색·이미지 정책 별도 | #229 즉시 진행 |
| Plant | 식물 수정 | edit info와 update API 부분 연결 | 기존/변경 물주기 날짜, image key/file | `GET /plants/{id}/edit`, `PUT /plants/{id}` 사용 가능 | #229 즉시 진행 |
| Plant | 식물 상세 | detail/delete API와 fixture 표시값 혼합 | 등록일 계산, 실제 값/미제공 값 분리, fixture memo 제거 | `GET/DELETE /plants/{id}` 사용 가능; Memo·물주기 API 없음 | #231 즉시 진행 |
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
- 라우터는 `unauthenticated`, `signupRequired`, `authenticated` 세션에 따라 접근을 제어하고 로그인 전 target을 보존합니다.

## User 프로필 수직 슬라이스

#237은 Home에서 마련한 `currentUserProvider`를 수정 가능한 현재 사용자 상태로 확장하고, Figma의 마이페이지·설정·회원 정보 수정 화면을 연결합니다.

- 마이페이지는 `GET /users`의 loading/error/success 상태를 표시하고 Home 하단 My 탭에서 진입합니다.
- 이름 수정은 2~10자 검증과 변경 여부를 기준으로 `PUT /users`를 호출하며, 성공 응답으로 현재 사용자 상태를 즉시 교체합니다.
- 회원 탈퇴는 확인 dialog 뒤 `DELETE /users` 성공 시 secure token과 인증 세션을 제거합니다.
- 서버 logout endpoint가 없어 로그아웃은 secure token과 로컬 인증 세션만 제거합니다.
- 알림 설정 endpoint가 없어 토글은 설정 화면이 유지되는 동안의 로컬 Provider 상태로 둡니다.
- 프로필 이미지는 기존 optional multipart 경계를 유지하지만, 파일 선택기와 플랫폼 권한 정책이 확정되지 않아 현재 이미지와 카메라 진입 안내까지만 제공합니다.

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

문서 이력만 갱신하는 커밋은 자기 자신의 해시를 생략할 수 있습니다.
