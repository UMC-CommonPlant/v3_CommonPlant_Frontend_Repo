# 기존 비즈앱 카카오 로컬 QA #293

## 기준과 작업 계획

- 2026-11-14 기준 프런트 develop `3bb7955`, 백엔드 develop `03ece0e`.
- 로그인 [#293](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/293), 사진 [#295](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/295)를 계속 사용한다.
- PR #320은 OPEN·미병합·CI 성공이며 이번 기준 develop에 문서가 포함되지 않았다. PR #314는 CLOSED·미병합으로 제외한다.
- #311 / PR #312의 앱 시작 refresh-only 복원은 구현·병합 완료이며 실제 계정 검증은 별개다.
- 기존 CommonPlant 비즈앱과 사용자 개인 카카오 계정을 사용한다. Apple 확인은 보류한다.
- 원본 iOS 개인 Team 변경, Debug Apple 비활성 및 Profile/Release 설정을 보존한다. 날씨 로컬 파일은 읽지 않는다.

1. 콘솔의 로그인 활성화·이메일 동의·Android/iOS 플랫폼과 실제 Debug 인증서·callback을 확인한다. 네이티브 키는 Git 제외 파일에서만 주입한다.
2. 별도 백엔드 worktree에서 PostgreSQL·Garage와 JDK 17 서버를 `local` 프로필로 실행한다. JWT는 로컬 생성하며 키·비밀번호·token 원문은 로그/커밋에 남기지 않는다.
3. 실제 SDK 인증 → 서버 신규/기존 분기 → 가입 → 홈/내 정보 GET → 완전 종료/재실행 → 로그아웃/재로그인을 순차 검증한다. 계정 입력과 동의는 사용자가 한다.
4. 로그인 성공 후 사진 선택·업로드 → 새 GET → 재실행을 확인한다. PUT 응답만으로 재조회 성공으로 기록하지 않는다.
5. 휴대폰에서 키보드·뒤로가기·로딩·빈 상태·오류·재시도를 확인한다.

## 결과 구분

| 범주 | 이번 실행 상태 |
| --- | --- |
| 자동 테스트 | Flutter 로그인·라우팅·토큰 저장 259개 통과. SDK·HTTP·저장소는 테스트 대역 사용 |
| Android 에뮬레이터 실행 | Android 16 전용 AVD에서 설치·온보딩·카카오 버튼·Chrome 인증 진입 확인 |
| 실제 서버 인증 | 아직 0건 |
| 휴대폰 실기기 | iPhone Debug 서명 빌드 확인. 무선 연결 오류로 설치 대기 |

발견된 코드 수정은 먼저 계획에 추가하고 API별 작은 커밋으로 분리한다. 문서 변경은 diff·링크를 확인하고 Flutter 코드 변경은 format → analyze → test를 순차 실행한다.

## 준비 점검 결과

- 카카오 콘솔: 기존 Common Plant 비즈앱, 사용자 Editor 역할 확인. 로그인 ON, 이메일 `account_email` 필수 동의·수집, 닉네임 필수·사진 선택 동의 확인.
- 비어 있던 네이티브 앱 키의 Android 패키지 `com.plant.common`, Debug 키 해시, iOS Bundle ID `com.commonplant.umc`를 등록·저장했다. 새 앱이나 새 키는 생성하지 않았다.
- 사용자가 네이티브 키를 Git 제외·권한 600 파일에 저장했다. 키 원문은 문서·로그에 기록하지 않았다.
- 첫 Android 빌드의 격리된 XDG 설정 경로가 별도 Debug 인증서를 만들었다. 기존 Mac 인증서를 로컬 설정에 복사하여 재빌드했고 APK에서 제공받은 Debug 키 해시와 일치를 확인했다. APK callback과 Dart 설정 키의 일치도 확인했다.
- iOS는 Git 제외 plist/xcconfig를 만들어 callback·개인 Team·로컬 네트워크 설정을 주입한다. 원본 Xcode 프로젝트와 Apple 구성은 변경하지 않는다.
- 사용자 추가 규칙: 백엔드는 로컬 수정·실행 가능, 원격 push·PR·이슈/파일 변경 등 저장소 반영은 절대 금지. 원본 백엔드와 QA worktree의 Git 제외 `AGENTS.md`에 저장했다.
- PostgreSQL 15·Garage 2.3.0·public proxy를 로컬 compose로 실행했다. 백엔드는 JDK 17, `local`, `ddl-auto: update`, 별도 랜덤 JWT/DB/스토리지 비밀값으로 실행하며 로그인 상세·SQL 출력은 껐다. 액세스 로그에는 메서드·경로·HTTP 상태·처리 시간만 남긴다.
- 로컬 health HTTP 200. 실제 카카오 사용자 인증 성공과는 구분한다.

공식 설정 근거: [Kakao Flutter 시작하기](https://developers.kakao.com/docs/ko/flutter/getting-started), [Kakao 로그인 설정](https://developers.kakao.com/docs/ko/kakaologin/prerequisite). SDK 1.10.0의 기존 callback activity를 유지하며 최신 2.x 예제의 class 이름을 그대로 옮기지 않는다.

- 전용 Android 16 AVD `CommonPlant_QA_API_36_1`의 데이터 영역은 10GB다. 기존 에뮬레이터가 저장 공간 부족으로 설치를 거절해 격리된 AVD를 새로 만들었다. 기존 AVD의 앱 데이터는 유지했다.
- `10.0.2.2:8080`에서 에뮬레이터의 로컬 health HTTP 200을 확인했다. 사용자의 개인 계정 입력·동의 이전까지 백엔드 사용자 수는 0명이다.
- iPhone 서명 Debug 빌드의 Bundle ID, URL callback과 키 일치, Apple 로그인 비활성, 로컬 네트워크 안내를 확인했다. Xcode 27.2의 최소 iOS 15 조건은 worktree의 Git 제외 Debug xcconfig에서 적용했다. 무선 CoreDevice 연결이 끊겨 설치·실행은 대기한다.
- 자동 테스트 명령은 `fvm flutter test --no-pub --reporter compact test/features/login test/app/router test/core/network/auth_token_writer_test.dart`이다.
- Android 전용 AVD 앨범에 저장소의 식물 JPEG를 추가했다. 개인 사진은 QA에 필요하지 않다.
