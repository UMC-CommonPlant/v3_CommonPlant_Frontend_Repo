# 소셜 로그인 SDK와 가입 분기 연결 이력

## 작업 기준

- 이슈: [#285](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/285)
- 백엔드 blocker: [#152](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/152)
- 작업일: 2026-09-02
- 기준 `develop`: `1847007` (PR #284 병합)
- 브랜치: `feature/social-login-sdk-285`
- 참고: [소셜 로그인](../social-login-integration-guide.md), [Feature](../feature-development-guide.md), [상태관리](../state-management-guide.md), [라우팅](../routing-guide.md), [퍼블리싱](../screen-publishing-rules.md), [테스트](../testing-guide.md), [Swagger](../api-swagger-reference.md), [백엔드 질문](../backend-api-open-questions.md), [Git](../git-workflow.md) 가이드

## 확인한 계약

별도 회원가입 시작점은 만들지 않습니다. Kakao·Google·Apple 인증 결과를
`POST /auth/login`에 보내고 실제 응답의 `isNewUser`로 기존 사용자와 신규 사용자를
나눕니다.

| 경로 | 필수 결과 | 앱 처리 |
| --- | --- | --- |
| 로그인 `isNewUser: false` | `accessToken`, `refreshToken` | token 저장, 인증 세션 시작, Home 이동 |
| 로그인 `isNewUser: true` | `signupToken` | 프로필·약관으로 이동, `/auth/register` 호출 |
| 가입 완료 | `accessToken`, `refreshToken` | 응답 boolean과 무관하게 인증 완료 |

로그인 파서는 실제 `isNewUser`를 우선하며 OpenAPI의 `newUser`는 배포 호환 입력으로만
허용합니다. `signupToken` 존재 여부로 신규 사용자를 추론하지 않습니다. 로그인과 가입
완료 파서를 분리해 가입 응답의 `isNewUser: true` 때문에 프로필 화면으로 되돌아가는
경로도 제거했습니다.

## 구현

### SDK와 token

- Kakao `OAuthToken.accessToken`, Google `idToken`, Apple `identityToken`만 기존
  `SocialAuthCredentialGateway`를 통해 Controller에 전달합니다.
- Kakao는 앱 설치 시 Talk를 먼저 사용하고 취소가 아닌 실패에서만 Account로
  fallback합니다.
- Google은 backend audience용 server client ID를 필수로 하고 iOS에서는 iOS client ID도
  함께 초기화합니다.
- Apple SDK 호출은 `TargetPlatform.iOS`에서만 허용합니다.
- 설정 누락은 API 호출 전 안내하고 사용자 취소는 오류 문구 없이 로그인 화면에
  머무릅니다. 빈 token과 SDK 오류는 안전한 공통 오류로 처리합니다.

현재 Flutter `3.35.7`·Dart `3.9.2`를 올리지 않고 호환되는
`kakao_flutter_sdk_user 1.10.0`, `google_sign_in 7.2.0`,
`sign_in_with_apple 7.0.1`을 사용합니다.

### 플랫폼 UI와 네이티브 설정

- iOS에는 Kakao·Google·Apple 세 버튼을 표시합니다.
- Android에는 Kakao·Google만 표시하고 Apple 버튼·간격·Semantics를 만들지 않습니다.
- Android Kakao redirect activity와 Gradle property 주입 경계를 추가했습니다.
- iOS 최소 버전을 13으로 명시하고 Kakao 앱 조회 allowlist와 Apple Sign in
  capability/entitlement를 추가했습니다.
- 실제 값이 있어야 정할 수 있는 Kakao·Google iOS URL scheme은 저장소에 가짜 값을 넣지
  않고 설정 체크리스트로 남겼습니다.

## 추상화 정리

provider별 Controller, service, repository를 추가하지 않았습니다. SDK 차이는 기존 gateway의
단일 구현에 모으고, 화면은 provider 선택과 플랫폼 노출만 담당합니다. 결과 타입 자체가
가입 필요/인증 완료를 표현하므로 각 타입에 있던 중복 `newUser` 필드와 운영에서 사용하지
않는 미설정 gateway 구현도 제거했습니다. 테스트용 token loader는 SDK 채널 없이 provider별
token 선택을 확인하는 한 가지 주입 경계로만 사용합니다.

## 검증

1. `fvm dart format --output=none --set-exit-if-changed .`: 318개 파일, 변경 0개
2. `fvm flutter analyze`: 문제 없음
3. `fvm flutter test`: 558개 통과, 기존 non-Linux golden skip 1개
4. provider token·설정 누락·빈 token, `isNewUser` true/false·호환 키·가입 완료,
   취소·세션 격리, iOS/Android 버튼 노출 회귀 테스트 통과
5. `fvm flutter build apk --debug`: `app-debug.apk` 생성
6. `fvm flutter build ios --simulator --debug`: `Runner.app` 생성
7. `plutil -lint`로 iOS Info.plist·entitlement, `ruby -c`로 Podfile 검증
8. `git diff --check`: 통과

## 남은 제한

- 실제 Kakao native app key, Google client ID와 provider console 등록은 승인된 값을 받아야
  합니다. iOS Kakao scheme과 Google reversed client ID scheme도 이 값으로 설정해야 합니다.
- Apple Developer의 갱신된 provisioning profile이 필요합니다.
- backend는 `APPLE` 요청 값을 허용하지만 verifier가 없습니다. backend #152 구현·dev 배포
  전까지 Apple 실제 로그인 성공을 검증하거나 완료로 표현하지 않습니다.
- 개인 소셜 계정을 이용한 원격 E2E, refresh token 재발급, 서버 logout은 이번 범위가
  아닙니다.

## 커밋별 작업 이력

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| `7bc3945` | `isNewUser`, provider token, iOS Apple 정책과 backend blocker 문서화 | `git diff --check` |
| `49fb411` | 세 provider SDK gateway·환경값·Android/iOS 네이티브 경계 | gateway test, analyze, Android/iOS debug build |
| `446dbc9` | 로그인/가입 parser 분리, iOS 전용 Apple UI, 취소 처리와 회귀 테스트 | 집중 테스트 22개, 전체 558개·skip 1개 |

문서·PR 이력만 기록하는 마지막 커밋은 자기 자신의 해시를 생략할 수 있습니다.
