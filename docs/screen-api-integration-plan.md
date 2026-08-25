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
| P0 | Auth 로그인·회원가입 | 로그인 화면, 인증 세션, 프로필 등록, route redirect, `/auth/login`, `/auth/register` | #227 구현 및 리뷰 |
| P1 | Home 초기 데이터 | 인증 사용자 정보와 장소·식물 요약을 화면 상태로 연결 | 다음 작업 후보 |
| P2 | Plant 핵심 동선 | 목록, 상세, 생성, 수정 API와 각 화면 상태 연결 | Auth 이후 진행 |
| P3 | User 프로필 | 내 정보 조회·수정과 프로필 화면 연결 | 이미지 파일 선택 정책과 분리 가능 |
| 제한 | Place | response schema가 확인된 동선부터 연결 | 목록·상세 schema 확인 필요 |
| 보류 | Friend, Image, Memo | 성공 response 또는 endpoint가 불충분한 영역 | 백엔드 확인 필요 |

P1은 Home 화면이 실제 로그인 직후 첫 진입점이라는 점을 기준으로 합니다. 다만 Place 성공 response schema가 없으므로, 먼저 schema가 있는 `GET /users`와 `GET /plants`를 사용하고 Place 데이터는 확인된 필드만 별도 작업으로 추가합니다.

## Auth 첫 수직 슬라이스

#227은 기존 #216의 Auth datasource/repository를 실제 화면과 앱 세션에 연결합니다.

- 소셜 로그인 버튼은 `LoginController`를 통해 provider credential과 `/auth/login`을 연결합니다.
- 실제 Kakao/Google/Apple SDK가 준비되지 않은 현재는 `SocialAuthCredentialGateway` 기본 구현이 설정 안내 오류를 반환합니다. SDK 도입 시 이 gateway 구현만 교체합니다.
- 신규 사용자는 `signupToken`, 추천 이름, 추천 이미지 URL을 세션에 보존하고 프로필·약관 화면으로 이동합니다.
- 약관 동의 후 프로필 이름과 `signupToken`으로 `/auth/register`를 호출하고 인증 세션으로 전환합니다.
- 프로필 샘플 이미지는 로컬 UI 상태이므로 서버 multipart 이미지로 임의 전송하지 않습니다. 실제 파일 선택 결과가 준비될 때 optional image 경계에 연결합니다.
- API 모드는 secure storage의 access/refresh token 쌍으로 세션을 복원합니다. refresh와 서버 로그아웃은 endpoint 확정 전까지 추가하지 않습니다.
- 라우터는 `unauthenticated`, `signupRequired`, `authenticated` 세션에 따라 접근을 제어하고 로그인 전 target을 보존합니다.

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

문서 이력만 갱신하는 커밋은 자기 자신의 해시를 생략할 수 있습니다.
