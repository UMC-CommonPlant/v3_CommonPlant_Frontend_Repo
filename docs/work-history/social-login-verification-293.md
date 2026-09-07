# 소셜 로그인 검증과 누락 보완 #293

## 기준과 판정

- 이슈: [#293](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/293)
- 작업일: 2026-09-07
- 기준 develop: `e3c9e60` (PR #292 병합), 브랜치 `fix/social-login-verification-293`
- 상위 범위: #2, 이전 SDK 구현 #285 / PR #286은 병합 완료
- 코드·설정·자동 검증은 완료했으며 **실계정 소셜 로그인 실기기 검증은 미완료**다.
  실제 기기·provider 설정·사용자 인증을 확보하기 전 이슈를 실기기 검증 완료로 닫지 않는다.
- 휴대폰 최적화가 1순위다. iPad·Mac 설치를 막는 설정은 추가하지 않았고 iPad 최적화는
  후순위다. 기존 iOS `TARGETED_DEVICE_FAMILY = "1,2"`를 유지한다. Apple 로그인은 iPhone
  네이티브 앱만 제공하며, 실제 Mac 설치·배포 가능 여부는 이번에 확인하지 않았다.

참고 문서: README, routing/feature-development/state-management/testing 가이드,
social-login-integration-guide, api-swagger-reference, backend-api-open-questions,
remote-integration-test-readiness, screen-publishing-rules, figma-frame-map,
shared-widget-guide, design-token-rules, git-workflow, release-workflow.

## 기기·설정·백엔드 확인

| 확인 대상 | 2026-09-07 결과 | 의미 |
| --- | --- | --- |
| `fvm flutter devices --machine` | macOS·Chrome만 실행 가능 | Android/iPhone 실기기 실행 불가 |
| `xcrun devicectl list devices` | 등록된 iPhone 16 Pro·iPad는 unavailable | 등록 이력을 연결된 실기기로 계산하지 않음 |
| Android SDK `adb devices -l` | 연결된 기기 없음 | Android 실기기 검증 미실행 |
| 로컬 셸·작업 시작 시 Generated.xcconfig | Kakao key, Google server/iOS client ID 없음 | 별도 설정 파일 제공 필요; 외부 console 존재 여부는 미확인 |
| Android native 설정 | 기본 Kakao scheme은 `kakaonot-configured` | Dart key와 Gradle property를 동일하게 주입해야 함 |
| iOS Info.plist | Kakao 조회 allowlist 존재, URL Types 없음 | Kakao callback·Google reversed client scheme 설정 필요 |
| Apple entitlement | Sign in with Apple 선언 존재 | Developer App ID, signing profile·실제 SDK 토큰 발급은 미검증 |
| dev OpenAPI | curl HTTP 200, 19 paths·27 operations | Auth path는 login/register뿐; 실제 로그인 응답을 받은 것은 아님 |
| backend #152 | OPEN | Apple 토큰 서버 검증·dev 배포 전 Blocked |
| backend #149 | OPEN, OpenAPI에 refresh API 없음 | refresh-only 자동 갱신은 Blocked, 임시 endpoint·우회 없음 |

첫 Python OpenAPI 요청은 HTTP 오류였으나 같은 공개 URL을 curl로 다시 조회해 HTTP 200과
JSON을 확인했다. 인증 토큰이나 개인 계정 데이터는 조회·수집·기록하지 않았다.

## 발견해 수정한 누락

1. Auth parser가 공용 문자열 변환으로 숫자·bool·공백 token을 받아들였다. 로그인·가입 완료
   token은 비어 있지 않은 문자열만 허용하고, 신규 여부는 JSON bool만 허용한다. 실제 키가
   잘못돼도 호환 키 `newUser`로 대체하지 않는다.
2. Kakao 1.10.0 네이티브 SDK의 `PlatformException(CANCELED)`가 취소로 분류되지 않았다.
   Talk 취소 후 Account fallback과 Account 취소 후 오류 안내를 막았다.
3. iOS 여부만 검사해 iPad·iOS 브라우저도 Apple 진입 대상으로 취급했다. 작은 네이티브
   device idiom 조회를 UI와 기존 SDK gateway에서 공유하고, iOS 앱의 Mac 실행도 제외한다.
   조회 중·실패에는 숨기며 새 인증 프레임워크나 provider별 service를 만들지 않았다.
4. 기존 사용자 API 로그인에서 router가 보존한 목적지를 LoginPage가 Home으로 덮었다.
   API 모드는 기존 세션 redirect가 이동을 결정하고, API 비사용 데모 흐름은 유지한다.
5. 짧은 iPhone 화면의 오류 문구가 하단 시스템 영역에 들어갈 수 있었다. 버튼 그룹을 하단
   안전 여백 기준으로 배치해 오류가 늘면 위로 확장한다. 정상 기준 시안 좌표는 유지한다.
6. Android INTERNET 권한이 debug/profile에만 있어 release에서 누락됐다. main manifest에
   선언하고 release 병합 manifest에서 확인했다.
7. 로컬 설정 예제와 Git 제외 규칙을 추가하고, 이전 로그인/온보딩/탭 PR의 리뷰 중 표기와
   현재 화면 미연결 설명을 병합·구현 상태로 갱신했다.

## 실제 실기기 검증

**이번 실행에서 완료한 소셜 로그인 실기기 시나리오: 0건.**

| 시나리오 | 실기기 결과 | 다음 조건 |
| --- | --- | --- |
| Kakao 신규 사용자 isNewUser·signupToken·세션 미저장·프로필 이동 | 미실행 | 연결 기기, key·callback 설정, 신규 테스트 계정 |
| Kakao 기존 사용자 token 저장·Home·프로세스 종료 후 복원 | 미실행 | 가입 완료 또는 기존 테스트 계정 |
| Google 신규 사용자 같은 기준 | 미실행 | 연결 기기, OAuth client·scheme·signing 등록 |
| Google 기존 사용자 같은 기준 | 미실행 | 가입 완료 또는 기존 테스트 계정 |
| 같은 계정 신규 → 가입 완료 → 재로그인 | 미실행 | provider마다 승인된 신규 테스트 계정 |
| 취소·SDK/백엔드 오류·중복 탭 | 미실행 | 네이티브 로그인 화면 실행 가능 |
| iPhone Apple 버튼·SDK 토큰 발급 | 미실행 | iPhone, Apple signing/capability, 사용자 인증 |
| Android/iPad/Mac에서 Apple 비노출·SDK 차단 | 실기기 미실행 | 각 실행 환경; 자동 검증과 구분 |
| Apple 실제 토큰 백엔드 신규/기존 분기 | Blocked | backend #152 구현·dev 배포 |
| refresh-only 재발급 | Blocked | backend #149 API 계약·배포 |

## 자동 검증

| 범위 | 실행한 검증 | 경계 |
| --- | --- | --- |
| 응답 DTO | isNewUser true/false·호환 키 우선순위, token 누락·공백·숫자·bool·배열·객체 거절, 가입 완료 | 입력은 synthetic JSON |
| Kakao·Google 화면 흐름 | 실제 LoginPage → SDK gateway → datasource/repository → parser → token writer → 세션/router → 가입 화면 → register → Home → 로그아웃 → 재로그인 | SDK token loader·HTTP adapter·token store는 fake |
| 신규 사용자 세션 | 신규 응답에 access/refresh가 같이 있어도 저장 호출 0회, signupToken 메모리 보존 | 실제 secure storage 동작 아님 |
| 기존 사용자 복원 | 로그인 token 쌍 저장, 새 ProviderContainer에서 인증·Home 복원, 로그인 재요청 없음 | OS 프로세스 재실행·Keychain/Keystore 영속성 아님 |
| 오류·취소·중복 제출 | 두 provider별 취소·SDK 오류·HTTP 500·signup 누락·잘못된 token·비객체 응답, 이전 버튼 콜백 중복 호출, 잠금 해제와 재시도 | 오류는 fake 경계에서 주입; raw 상세는 화면 비노출 |
| Kakao SDK 취소 | 실제 패키지 코드에 mock method channel의 CANCELED를 전달, Talk 취소 시 Account 호출 0회 | 실제 계정·SDK 인증 UI 미실행 |
| Apple 경계 | iPhone 판별 true일 때 표시·SDK loader 사용, iPad/판별 실패 숨김, 비iOS·웹 SDK 전 호출 차단 | device channel mock; 네이티브 판별은 컴파일만 검증 |
| 작은 화면 | 320×640·375×667 iPhone 오류·하단 safe area, 기존 375×812 좌표 | widget test, 기기 스크린샷 아님 |
| refresh-only | 현재 부분 token 삭제 → 비인증 회귀 | 재발급 성공으로 계산하지 않음; #149 유지 |

- `fvm dart format --output=none --set-exit-if-changed .`: 326개 파일, 변경 0개
- `fvm flutter analyze`: 문제 없음
- `fvm flutter test`: 647개 통과, non-Linux golden 1개 기존 정책에 따라 skip
- `fvm flutter build ios --debug --no-codesign`: 기기용 Runner.app 빌드 통과, 설치·서명 미검증
- `fvm flutter build apk --release`: APK 빌드 통과, 기존 debug signing 유지. 배포용 인증 검증 아님
- `git diff --check`: 통과

첫 Android release 빌드는 다른 Flutter 검증 중 생성된 plugin registrant에 integration_test가
포함돼 Java 컴파일이 실패했다. Flutter 명령을 단독 순차 실행하자 소스 우회 없이 통과했다.
위 빌드는 소셜 설정값 없이 수행했으므로 provider console·callback 인증 성공을 뜻하지 않는다.

## 사용자가 준비할 내용과 실행 순서

1. iPhone 또는 Android를 연결·잠금 해제한다. iPhone은 개발자 모드·컴퓨터 신뢰와 Xcode
   signing을, Android는 USB 디버깅을 준비하고 `fvm flutter devices`에 ID가 표시되는지 확인한다.
2. `env/social-login.example.json`을 `env/social-login.local.json`으로 복사하고 Kakao native
   app key·Google Web/server client ID·Google iOS client ID를 채운다. 계정 비밀번호나 token을
   공유하지 않는다. Kakao의 com.plant.common·key hash, Google의 package/bundle·signing SHA
   등록이 필요하다.
3. iOS Runner의 URL Types에 `kakao<동일한-key>`와 Google iOS reversed client ID를 넣는다.
   Android는 실행 시 동일 Kakao key를 `--android-project-arg`로도 전달한다.
   정확한 실행 명령은 [소셜 로그인 가이드](../social-login-integration-guide.md#실기기-재개)를 따른다.
4. provider별 신규 테스트 계정으로 로그인한다. IDE breakpoint로 DTO의 `isNewUser == true`,
   signupToken의 존재 여부, AuthTokenWriter의 로그인 token 저장 미호출을 확인하고 프로필
   입력 화면을 확인한다. 기록에는 bool·호출 횟수·화면만 남기고 token 원문은 남기지 않는다.
5. 같은 계정으로 닉네임·약관 입력 후 가입을 끝낸다. `/auth/register` 성공 뒤 두 token 저장과
   Home 이동을 확인한다. 앱 설정의 로컬 로그아웃 후 같은 provider·계정으로 재로그인하여
   `isNewUser == false`, access/refresh 저장과 Home 이동을 확인한다.
6. 앱을 완전히 종료한 뒤 같은 설치 앱을 다시 실행한다(hot reload/restart로 대체하지 않는다).
   저장 token 쌍 복원과 로그인 화면 없이 Home 진입을 확인한다. 계정 A/B 혼용을 피한다.
7. 각 provider의 인증 취소, 실패 후 재시도, 빠른 연속 탭을 확인한다. SDK/백엔드 오류는
   별도 승인된 테스트 환경에서 유도하며 실제 서비스 응답을 임의로 변조하지 않는다.
8. iPhone Apple UI·SDK 단계와 backend 로그인 단계를 따로 기록한다. #152가 해결·배포되기
   전까지 Apple 서버 검증은 Blocked다. iPad·Mac·Android에는 Apple 버튼이 없어야 한다.
9. refresh-only는 #149 전까지 현재의 재로그인 동작만 기록한다. 수동 token 주입이나 임의
   refresh URL을 자동 갱신 검증으로 사용하지 않는다.

이미 가입된 계정을 신규 분기로 만들기 위해 임의로 탈퇴·DB 삭제를 수행하지 않는다. 신규
테스트 계정 또는 백엔드가 정한 초기화 절차가 필요하다. 후속 기록에는 날짜·기기/OS·provider·
신규 여부·token 존재/저장 횟수·route·재실행 결과만 남긴다.

## 커밋 이력

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| `d2a02c0` | Auth token·bool 검증, Kakao 네이티브 취소, iPhone SDK 판별과 회귀 테스트 | DTO/gateway 집중 테스트, iOS 빌드 |
| `61a841f` | 로그인 redirect·작은 화면 오류 배치, 전체 인증 흐름·refresh-only 회귀 | 화면·세션 테스트, 전체 647개 통과 |
| `0e7ea7a` | Android release INTERNET 권한, 로컬 설정 예제·Git 제외 | release APK·병합 manifest, JSON·ignore 확인 |

최종 문서 커밋과 PR 링크는 #293 검증 코멘트에서 함께 확인한다.
