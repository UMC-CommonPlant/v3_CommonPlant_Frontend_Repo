# 소셜 로그인 연동 가이드

이 문서는 CommonPlant의 Kakao·Google·Apple 로그인 진입, 백엔드 가입 판별,
플랫폼 노출과 SDK 설정을 관리하는 단일 기준이다. 화면·상태·API 연결은 #227에서
완료했고 실제 provider credential 획득은 #285 / PR #286에서 연결했다. #293은 응답 검증,
SDK 취소 오류 처리, iPhone 제한과 로그인 후 이동을 보완한다.

## 사용자 흐름

CommonPlant에는 이메일/비밀번호 회원가입이나 별도 회원가입 시작 버튼이 없다. 세 소셜
로그인 버튼이 로그인과 신규 사용자 확인의 공통 진입점이다.

```text
Kakao / Google / Apple SDK 인증
  -> provider별 token 획득
  -> POST /auth/login { provider, token }
  -> result.isNewUser 분기
     -> false: accessToken + refreshToken 저장 -> authenticated -> Home
     -> true: signupToken 보존 -> 프로필·약관 -> POST /auth/register
              -> accessToken + refreshToken 저장 -> authenticated -> Home
```

`isNewUser`는 서버 가입 여부이고 앱이 별도로 추론하지 않는다. `signupToken` 존재 여부,
추천 이름 또는 token 문자열 형태를 신규 사용자 판별에 사용하지 않는다.

## Auth 응답 계약

### 기존 사용자

```json
{
  "result": {
    "isNewUser": false,
    "accessToken": "...",
    "refreshToken": "..."
  }
}
```

- `accessToken`과 `refreshToken`이 모두 비어 있지 않은 문자열이어야 인증 완료로 처리한다.
  숫자·bool·공백을 token으로 변환하지 않으며 로그인과 가입 완료에 같은 검증을 적용한다.
- 두 token은 `AuthTokenWriter`를 통해 순서대로 secure storage에 저장한다.
- 저장과 현재 인증 시도가 모두 유효할 때만 앱 세션을 `authenticated`로 전환한다.

### 신규 사용자

```json
{
  "result": {
    "isNewUser": true,
    "signupToken": "...",
    "suggestedName": "...",
    "suggestedImgUrl": "..."
  }
}
```

- `signupToken`은 비어 있지 않은 문자열이어야 하며 프로필 설정 메모리 세션에만 보존한다.
- 신규 응답에 access/refresh token이 함께 있어도 secure storage에 저장하지 않는다.
  가입을 끝내기 전에 앱 프로세스를 종료하면 소셜 로그인부터 다시 시작한다.
- `suggestedName`과 `suggestedImgUrl`은 선택적인 초기 표시값이다.
- 약관 동의와 프로필 입력 뒤 `/auth/register`에 `signupToken`과 사용자 입력을 보낸다.
- 가입 완료 응답의 `accessToken`과 `refreshToken`을 저장한 뒤 Home으로 이동한다.
- 가입 완료 응답은 token 존재로 인증 성공을 판단한다. 응답에 `isNewUser: true`가 포함돼도
  로그인용 신규 사용자 분기를 다시 적용하지 않는다.
- signup token 만료·중복 가입·이메일 충돌은 가입 완료 실패이며 로그인 완료로 간주하지
  않는다.

live OpenAPI schema에는 `newUser`가 남아 있지만 실제 확인한 응답은 `isNewUser`다. #285의
프론트 파서는 실제 키를 기준으로 테스트하고, 배포가 혼재된 동안만 `newUser`를 호환
입력으로 허용한다. 두 키 모두 JSON bool만 허용하며, `isNewUser`가 있으면 그 값이
잘못돼도 `newUser`로 대체하지 않고 실패 처리한다. 내부 상태는 `SignupRequiredResult`와 `AuthenticatedResult` 타입으로
이미 분리되므로 동일 의미의 boolean을 다시 보존하지 않는다.

## Provider별 전달 token

| Provider | 노출 플랫폼 | SDK에서 읽는 값 | `/auth/login.provider` | 백엔드 상태 |
| --- | --- | --- | --- | --- |
| Kakao | Android, iOS | `OAuthToken.accessToken` | `KAKAO` | `KakaoTokenVerifier` 제공 |
| Google | Android, iOS | `GoogleSignInAuthentication.idToken` | `GOOGLE` | `GoogleTokenVerifier` 제공 |
| Apple | iPhone 네이티브 앱만 | `AuthorizationCredentialAppleID.identityToken` | `APPLE` | #152 구현·dev 배포 전 Blocked |

Kakao는 카카오톡 설치 시 Talk 로그인을 먼저 시도하고, 카카오톡을 사용할 수 없거나 Talk
호출이 실패한 경우에만 Account 로그인을 사용한다. 사용자가 취소한 경우 Account 로그인으로
강제 전환하지 않는다.

Google 백엔드는 ID token을 Google token info endpoint로 검증하므로 OAuth access token이나
server auth code를 대신 전송하지 않는다.

Apple은 identity token을 전달한다. 2026-09-02 backend `main`은 요청 enum에는 `APPLE`을
허용하지만 실제 verifier가 없어 unsupported provider로 거절한다. 프론트 SDK와 UI는
#285에서 연결했고 실제 로그인 완료 판정은 [backend #152](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/152)의
검증 구현과 dev 배포 뒤 수행한다.

## Apple 노출 정책

- Apple 로그인 버튼과 SDK 진입은 iPhone 네이티브 앱에서만 허용한다.
- `appleLoginSupportedProvider`가 iOS·비웹 여부를 먼저 검사하고 네이티브
  `UIDevice.current.userInterfaceIdiom == .phone` 결과를 읽는다. iOS 앱의 Mac 실행도 제외한다.
- 화면 크기로 iPhone/iPad를 추측하지 않는다. 확인 중·실패·iPad·Mac·Android·웹에서는
  Apple 버튼과 해당 간격·Semantics를 렌더링하지 않는다.
- gateway에도 동일한 판별을 적용해 UI 외 경로의 Apple SDK 접근을 차단한다.
- Apple capability/entitlement 선언은 존재하지만 Developer App ID·provisioning과 실제 SDK
  인증 성공은 별도 검증한다. backend #152는 2026-09-07에도 OPEN이다.

2026-09-07 사용자 결정에 따라 휴대폰 최적화를 1순위로 둔다. iPad·Mac 설치를 제한하는
설정은 추가하지 않고 iPad 전용 레이아웃·최적화는 후순위로 둔다. 기존 iOS 앱의
`TARGETED_DEVICE_FAMILY = "1,2"`를 유지하며, 실제 Mac 배포 가능 여부는 서명·스토어 설정을
확인해야 한다. 이 설치 정책과 iPhone 전용 Apple 로그인 정책은 별개다.

## SDK와 설정 경계

프로젝트는 Flutter `3.35.7`, Dart `3.9.2`를 사용한다. 현재 SDK와 호환되는 패키지를
선택하며 앱 전체 Flutter 업그레이드를 이 작업에 섞지 않는다.

| SDK | 적용 버전 | 선택 근거 |
| --- | --- | --- |
| `kakao_flutter_sdk_user` | `1.10.0` | 최신 2.0.1은 Flutter 3.38 이상 필요 |
| `google_sign_in` | `7.2.0` | 현재 Flutter/Dart에서 해결되는 최신 호환 버전 |
| `sign_in_with_apple` | `7.0.1` | 8.x는 Dart 3.11 이상 필요 |

실제 식별자와 키는 저장소에 임의 값으로 커밋하지 않는다.

| 환경값 | 용도 | 미설정 동작 |
| --- | --- | --- |
| `COMMONPLANT_KAKAO_NATIVE_APP_KEY` | Kakao SDK 초기화 | Kakao 로그인 설정 안내 |
| `COMMONPLANT_GOOGLE_SERVER_CLIENT_ID` | Android/iOS backend용 Google ID token audience | Google 로그인 설정 안내 |
| `COMMONPLANT_GOOGLE_IOS_CLIENT_ID` | iOS Google OAuth client | iOS Google 로그인 설정 안내 |

provider console과 네이티브 프로젝트에는 별도로 아래 설정이 필요하다.

- Kakao: `com.plant.common` Android/iOS 플랫폼 등록, Android key hash, 양 플랫폼의
  `kakao{NATIVE_APP_KEY}://oauth` URL scheme
- Google Android: package name, debug/release signing SHA와 Web OAuth client 등록
- Google iOS: iOS client ID와 reversed client ID URL scheme 등록
- Apple iOS: `com.plant.common` App ID의 Sign in with Apple capability와 갱신된 provisioning
  profile
- Apple backend: identity token의 서명·issuer·audience·만료·nonce 검증과 최초 email 보존

Kakao Android 실행은 Dart 초기화 값과 redirect scheme이 같아야 하므로 네이티브 Gradle
property도 함께 전달한다. API 모드에서는 dev base URL도 반드시 지정한다.

```bash
fvm flutter run \
  --dart-define=COMMONPLANT_USE_API=true \
  --dart-define=COMMONPLANT_API_BASE_URL=https://commonplant-dev.okbear.dev/api/v1 \
  --dart-define=COMMONPLANT_KAKAO_NATIVE_APP_KEY=<native-app-key> \
  --android-project-arg=COMMONPLANT_KAKAO_NATIVE_APP_KEY=<native-app-key>
```

저장소는 Android release에도 필요한 `INTERNET` 권한, `AuthCodeCustomTabsActivity`와 iOS Kakao 앱 조회 allowlist, Apple Sign in
capability/entitlement까지만 포함한다. 값이 있어야 확정되는 Kakao·Google iOS URL scheme은
승인된 client 설정을 받은 뒤 Xcode URL Types에 추가한다. Google client ID를 Dart에서
전달하더라도 reversed client ID URL scheme은 생략할 수 없다.

Kakao 네이티브 앱 키와 OAuth client ID는 앱 식별 설정값이지만 실제 값은 승인된 환경에서
주입한다. client secret, Apple private key, 개인 계정 token은 앱이나 저장소에 넣지 않는다.

## 코드 책임

| 위치 | 책임 |
| --- | --- |
| `SocialAuthCredentialGateway` | provider SDK 호출과 백엔드에 전달할 token 반환 |
| `LoginController` | 중복 제출, SDK 오류, `/auth/login` 호출과 결과 분기 |
| `AuthRepository` | Auth 응답 파싱과 인증 token 저장 |
| `AuthSessionController` | `signupRequired`/`authenticated` 세션 전환 |
| `LoginPage` | 플랫폼별 버튼·오류·로딩 표시. API 비사용 화면 흐름에서만 직접 이동 |
| 기존 인증 router | API 세션 변경으로 신규 사용자 프로필·기존 사용자 보존 target 또는 Home 이동 |

provider SDK 차이는 gateway 한 곳에만 둔다. 화면별 SDK service, provider별 Controller 또는
가입 여부를 다시 감싸는 상태는 추가하지 않는다.

## 오류와 취소

- 사용자가 provider 화면을 취소하면 로그인 화면을 유지하고 실패 문구를 표시하지 않는다.
  Kakao 네이티브 `PlatformException(CANCELED)`도 취소로 처리하며 Talk → Account를 강제하지 않는다.
- 앱 키·client ID·capability가 없으면 설정 미완료 안내를 표시하고 API를 호출하지 않는다.
- SDK token이 비어 있거나 provider 인증이 실패하면 안전한 공통 로그인 실패 문구를
  표시한다.
- raw SDK 예외, token, backend 상세 메시지는 화면이나 로그에 노출하지 않는다.
- 짧은 휴대폰 화면에서는 오류 문구까지 하단 시스템 영역을 피하도록 버튼 그룹이 위로 확장된다.
- 이전 사용자 세션에서 늦게 도착한 SDK/API 결과는 현재 세션에 반영하지 않는다.

## 검증과 완료 경계

#285 기본 구현 이후 #293에서 보강한 로컬 검증:

- `isNewUser: true/false` 실제 response shape 파싱
- Kakao access token, Google ID token, Apple identity token 선택
- Android의 Apple 버튼·간격·Semantics 미렌더링
- iPhone의 Apple 버튼·SDK 호출과 iPad·Mac·웹 차단 경계
- 취소·미설정·token 누락·중복 탭·계정 전환 회귀
- format, analyze, 전체 unit/widget test와 네이티브 빌드
- Kakao·Google 각각 가짜 응답으로 신규 → 가입 완료 → 재로그인 → 새 ProviderContainer 복원
- 실제 LoginPage·Controller·Repository·DTO·router를 함께 검증하되 SDK·HTTP·저장소는 fake 사용

실제 계정을 사용하는 인증 E2E는 credential, provider console, Apple backend #152와
테스트 계정 정책이 준비된 뒤 별도 검증한다. 로컬 fake SDK test 통과를 실제 소셜 로그인
완료로 표현하지 않는다.

## 실기기 재개

현재 설정·기기 상태, 실제 실행 여부와 순서는 [#293 검증 기록](work-history/social-login-verification-293.md)에
남긴다. `env/social-login.example.json`을 `env/social-login.local.json`으로 복사한 뒤 앱 키와
OAuth client ID를 로컬에만 채운다. 예제 외 `env/*.json`은 Git에서 제외한다. 소셜 사용자 token,
client secret, Apple private key는 이 파일에 넣지 않는다.

```bash
fvm flutter devices
fvm flutter run -d <실제-기기-ID> --dart-define-from-file=env/social-login.local.json
```

Android Kakao는 위 실행 명령에
`--android-project-arg=COMMONPLANT_KAKAO_NATIVE_APP_KEY=<동일한-native-app-key>`를 추가한다.
iOS는 실행 전에 Xcode Runner → Info → URL Types에 `kakao<동일한-native-app-key>`와
Google iOS client의 reversed client ID scheme을 등록해야 한다. Dart 설정만으로 이 네이티브
scheme들이 생성되지 않는다. 실제 값이 없는 현재 파일을 그대로 실행하면 설정 안내가 정상이다.

## 공식 참고

- [Kakao Login Flutter](https://developers.kakao.com/docs/latest/ko/kakaologin/flutter)
- [Kakao Flutter SDK 버전](https://developers.kakao.com/docs/latest/ko/flutter/download)
- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)
- [Google Sign-In Android 설정](https://pub.dev/packages/google_sign_in_android)
- [Google Sign-In iOS 설정](https://pub.dev/packages/google_sign_in_ios)
- [Sign in with Apple Flutter](https://pub.dev/packages/sign_in_with_apple)

- [Flutter platform channels](https://docs.flutter.dev/platform-integration/platform-channels)
- [Apple device idiom](https://developer.apple.com/documentation/uikit/uidevice/userinterfaceidiom)
