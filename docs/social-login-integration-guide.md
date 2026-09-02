# 소셜 로그인 연동 가이드

이 문서는 CommonPlant의 Kakao·Google·Apple 로그인 진입, 백엔드 가입 판별,
플랫폼 노출과 SDK 설정을 관리하는 단일 기준이다. 화면·상태·API 연결은 #227에서
완료했고 실제 provider credential 획득은 #285에서 연결한다.

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

- `accessToken`과 `refreshToken`이 모두 있어야 인증 완료로 처리한다.
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

- `signupToken`은 필수이며 프로필 설정 세션에만 보존한다.
- `suggestedName`과 `suggestedImgUrl`은 선택적인 초기 표시값이다.
- 약관 동의와 프로필 입력 뒤 `/auth/register`에 `signupToken`과 사용자 입력을 보낸다.
- 가입 완료 응답의 `accessToken`과 `refreshToken`을 저장한 뒤 Home으로 이동한다.
- 가입 완료 응답은 token 존재로 인증 성공을 판단한다. 응답에 `isNewUser: true`가 포함돼도
  로그인용 신규 사용자 분기를 다시 적용하지 않는다.
- signup token 만료·중복 가입·이메일 충돌은 가입 완료 실패이며 로그인 완료로 간주하지
  않는다.

live OpenAPI schema에는 `newUser`가 남아 있지만 실제 확인한 응답은 `isNewUser`다. #285의
프론트 파서는 실제 키를 기준으로 테스트하고, 배포가 혼재된 동안만 `newUser`를 호환
입력으로 허용한다. 내부 상태는 `SignupRequiredResult`와 `AuthenticatedResult` 타입으로
이미 분리되므로 동일 의미의 boolean을 다시 보존하지 않는다.

## Provider별 전달 token

| Provider | 노출 플랫폼 | SDK에서 읽는 값 | `/auth/login.provider` | 백엔드 상태 |
| --- | --- | --- | --- | --- |
| Kakao | Android, iOS | `OAuthToken.accessToken` | `KAKAO` | `KakaoTokenVerifier` 제공 |
| Google | Android, iOS | `GoogleSignInAuthentication.idToken` | `GOOGLE` | `GoogleTokenVerifier` 제공 |
| Apple | iOS만 | `AuthorizationCredentialAppleID.identityToken` | `APPLE` | #152 구현·dev 배포 전 Blocked |

Kakao는 카카오톡 설치 시 Talk 로그인을 먼저 시도하고, 카카오톡을 사용할 수 없거나 Talk
호출이 실패한 경우에만 Account 로그인을 사용한다. 사용자가 취소한 경우 Account 로그인으로
강제 전환하지 않는다.

Google 백엔드는 ID token을 Google token info endpoint로 검증하므로 OAuth access token이나
server auth code를 대신 전송하지 않는다.

Apple은 identity token을 전달한다. 2026-09-02 backend `main`은 요청 enum에는 `APPLE`을
허용하지만 실제 verifier가 없어 unsupported provider로 거절한다. 프론트 SDK와 iOS UI는
#285에서 준비하고 실제 로그인 완료 판정은 [backend #152](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/152)의
검증 구현과 dev 배포 뒤 수행한다.

## Apple 노출 정책

- Apple 로그인 버튼은 `TargetPlatform.iOS`에서만 렌더링한다.
- Android와 그 밖의 플랫폼에는 Apple 버튼, 버튼 사이 간격과 Apple Semantics를 모두
  렌더링하지 않는다.
- gateway도 iOS가 아닌 환경의 Apple 인증 요청을 거절해 UI 외 경로의 오호출을 막는다.
- widget test는 iOS와 Android를 각각 지정해 버튼 유무와 Kakao·Google 배치를 검증한다.
- Apple Developer의 Sign in with Apple capability와 provisioning profile이 준비되지 않으면
  iOS SDK 호출을 완료 상태로 보지 않는다.

이 문서의 `iOS`는 iPhone/iPad용 iOS 앱을 뜻한다. Android용 Apple 웹 로그인은 MVP에
도입하지 않는다.

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

Kakao 네이티브 앱 키와 OAuth client ID는 앱 식별 설정값이지만 실제 값은 승인된 환경에서
주입한다. client secret, Apple private key, 개인 계정 token은 앱이나 저장소에 넣지 않는다.

## 코드 책임

| 위치 | 책임 |
| --- | --- |
| `SocialAuthCredentialGateway` | provider SDK 호출과 백엔드에 전달할 token 반환 |
| `LoginController` | 중복 제출, SDK 오류, `/auth/login` 호출과 결과 분기 |
| `AuthRepository` | Auth 응답 파싱과 인증 token 저장 |
| `AuthSessionController` | `signupRequired`/`authenticated` 세션 전환 |
| `LoginPage` | 플랫폼별 버튼 노출과 결과에 따른 route 이동 |

provider SDK 차이는 gateway 한 곳에만 둔다. 화면별 SDK service, provider별 Controller 또는
가입 여부를 다시 감싸는 상태는 추가하지 않는다.

## 오류와 취소

- 사용자가 provider 화면을 취소하면 로그인 화면을 유지하고 실패 문구를 표시하지 않는다.
- 앱 키·client ID·capability가 없으면 설정 미완료 안내를 표시하고 API를 호출하지 않는다.
- SDK token이 비어 있거나 provider 인증이 실패하면 안전한 공통 로그인 실패 문구를
  표시한다.
- raw SDK 예외, token, backend 상세 메시지는 화면이나 로그에 노출하지 않는다.
- 이전 사용자 세션에서 늦게 도착한 SDK/API 결과는 현재 세션에 반영하지 않는다.

## 검증과 완료 경계

#285에서 수행하는 로컬 검증:

- `isNewUser: true/false` 실제 response shape 파싱
- Kakao access token, Google ID token, Apple identity token 선택
- Android의 Apple 버튼·간격·Semantics 미렌더링
- iOS의 Apple 버튼과 SDK 호출 경계
- 취소·미설정·token 누락·중복 탭·계정 전환 회귀
- format, analyze, 전체 unit/widget test와 Android/iOS debug build

실제 계정을 사용하는 인증 E2E는 credential, provider console, Apple backend #152와
테스트 계정 정책이 준비된 뒤 별도 검증한다. 로컬 fake SDK test 통과를 실제 소셜 로그인
완료로 표현하지 않는다.

## 공식 참고

- [Kakao Login Flutter](https://developers.kakao.com/docs/latest/ko/kakaologin/flutter)
- [Kakao Flutter SDK 버전](https://developers.kakao.com/docs/latest/ko/flutter/download)
- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)
- [Google Sign-In Android 설정](https://pub.dev/packages/google_sign_in_android)
- [Google Sign-In iOS 설정](https://pub.dev/packages/google_sign_in_ios)
- [Sign in with Apple Flutter](https://pub.dev/packages/sign_in_with_apple)
