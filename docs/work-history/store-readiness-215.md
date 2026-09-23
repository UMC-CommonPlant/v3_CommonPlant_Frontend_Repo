# 스토어 계정·배포 준비 재점검 #215

## 범위와 진행 순서

2026-09-23 사용자 요청으로 [#215](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/215)를 재개했다. 기준은 `develop`의 `7f2251b`이며, 기존 2026-08-23 조사 이후 바뀐 상태를 확인한다. 원본 작업 폴더의 개인 iOS 설정은 별도 worktree를 사용해 보존한다.

1. 계정·앱 등록·권한, 서명·빌드 환경·GitHub 설정을 읽기 전용으로 확인한다.
2. 확인 결과를 이 문서에 먼저 기록하고 `Docs` 커밋으로 분리한다.
3. 중앙 배포 문서와 후속 체크리스트의 보류 표현·다음 단계를 갱신하고 별도 `Docs` 커밋으로 정리한다.
4. 문서 검사 후 develop 대상 PR과 Project 10을 갱신한다. 아직 확인하지 못한 계정·서명·스토어 이력이 있어 이슈는 열어 둔다.

이번 점검은 실제 업로드·심사 제출·공개·계정 인증을 완료한 작업이 아니다. 비밀번호, 인증번호, 개인 이메일, 인증서 원문과 키 값은 문서에 남기지 않는다.

## 2026-09-23 확인 결과

| 항목 | 확인한 사실 | 남은 작업 |
| --- | --- | --- |
| Google Play 계정 | 커먼랩 개인 개발자 계정에 접근 가능. 현재 사용자는 활성·만료일 없음·관리자(모든 권한) | 계정 소유자의 인증 완료 |
| Play 인증 | 본인 확인·Android 휴대기기 접근 확인·연락처 전화번호 인증 모두 조치 필요. 본인 확인·전화번호는 소유자 전용 | 소유자가 콘솔 안내에 따라 처리 후 재점검 |
| Play 앱 | 앱 목록 없음, 앱 만들기 비활성 | 계정 확인 후 기존 앱/패키지 이력부터 확인하고 앱 등록 진행 |
| Apple 계정 | App Store Connect 로그인 화면에서 대기 | 사용자 로그인 후 Developer Program 팀·역할·App ID·앱·빌드 이력 확인 |
| Android 식별자·서명 | `com.plant.common`, Release가 Debug signing 사용. 원본 저장소의 `android/key.properties` 없음 | 기존 업로드 키 소유·보관 상태 확인 후 배포 signing 연결 |
| iOS 식별자·서명 | `com.commonplant.umc`. 커밋된 프로젝트에 Team 미설정. Debug Apple 로그인 비활성, Profile/Release entitlement 유지 | 정식 배포 팀·인증서·프로비저닝 확인 |
| 이 Mac의 코드 서명 | 로컬 유효 identity 조회에서 Development 1개, Distribution 0개 | 다른 Mac·팀·클라우드 서명 자산 존재 여부는 미확인. 로컬 결과를 팀 전체 자산 부재로 해석하지 않음 |
| Flutter·Android SDK | FVM Flutter 3.35.7 / Dart 3.9.2. 해당 SDK의 compile/target 기본값은 36이며 앱은 이를 사용 | 실제 배포 AAB의 target 및 네이티브 라이브러리 호환성 검증 |
| Xcode·iOS SDK | Xcode 27.0 (`27A266a`) 버전 조회 성공, iOS 27 SDK 설치, 프로젝트 최소 iOS 13.0 | 실제 Release archive·서명·검증 필요. 과거 Xcode 라이선스 오류는 이번 버전 조회에서 재현되지 않음 |
| GitHub 배포 설정 | repository 범위 Actions Secrets 0개·Variables 0개·Environments 0개. 기존 품질 검사/smoke/golden workflow만 존재 | 계정·서명 확인 후 필요한 배포 설정과 내부 배포 workflow 구성. 조직 공유 secret은 이번 조회 범위 밖 |
| 버전·서버 | `1.0.0+1` 개발 기본값. 운영 API 주소는 확정 기록 없음 | 양쪽 스토어 이력 확인 후 공통 빌드 번호·운영 환경 확정 |

등록 앱이 없다는 결과는 현재 접근한 Play 계정의 목록에 한정한다. 다른 계정의 동일 패키지 이력이나 App Store Connect 이력을 확인한 것은 아니므로 `+1`을 최초 업로드 번호로 확정하지 않는다.

## 현재 제출 기준과 확인 범위

- Android 신규/업데이트 제출은 2026-08-31부터 API 36 이상을 요구한다. 현재 FVM SDK 설정은 36이지만 실제 배포 파일 검증은 남아 있다. [Google Play 기준](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en)
- iOS 제출은 Xcode 26 이상·iOS 26 SDK 이상을 요구하며, 2026-09-09부터 최소 대상 OS는 iOS 13 이상이다. 설치된 도구·프로젝트 설정은 해당 버전 범위에 있으나 Flutter·플러그인·서명 archive 성공을 의미하지 않는다. [Apple 기준](https://developer.apple.com/news/upcoming-requirements/)
- Android 네이티브 라이브러리의 16KB 페이지 크기 대응은 최종 AAB/APK와 기기에서 확인한다. Flutter 버전이나 target 값만으로 완료 처리하지 않는다. [Android 검증 가이드](https://developer.android.com/guide/practices/page-sizes)
- 2023-11-13 이후 생성한 개인 Play 계정은 프로덕션 접근 신청 전에 최소 12명이 14일 연속 참여하는 비공개 테스트가 필요하다. 현재 계정 생성일·적용 여부는 미확인이다. Internal testing만으로 이 조건을 충족했다고 표시하지 않는다. [개인 계정 테스트 기준](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en)

## 계정 확인 뒤 진행할 작업

| 순서 | 작업과 완료 기준 | 수정할 영역 |
| --- | --- | --- |
| 1 | Play 인증 완료, Apple 로그인·팀/역할·두 식별자의 앱/빌드 이력 확인 | 이 문서·#215, RELEASE-02-B/03 |
| 2 | 기존 키·인증서의 소유자와 보관 경로를 확인하고 배포 signing으로 검증 | Android `build.gradle.kts`/비공개 signing 설정, iOS Team·배포 프로파일. 개인 Debug 설정 보존 |
| 3 | 운영 API·소셜 로그인·날씨 설정과 빌드 번호 확정 | `pubspec.yaml`, 배포 환경 주입, 설정 문서. 비밀값은 저장소 제외 |
| 4 | 실제 출시 기능에 맞춰 설명·스크린샷·지원/개인정보 URL·데이터 공개 항목·등급·심사 접근 방법 준비 | 별도 스토어 등록 자료. 미완료 기능을 지원한다고 쓰지 않음 |
| 5 | 배포 서명된 AAB/IPA로 로그인·사진 저장/재조회·탈퇴·오류 복구 검증, 내부 테스트 배포 | #293/#295, Android Internal testing·iOS TestFlight. 필요한 경우 Play 비공개 테스트 추가 |
| 6 | 검증한 내부 배포를 자동화하고 동일 산출물의 심사 제출·수동 공개 절차 연결 | `.github/workflows/android_release.yml`, `ios_testflight.yml`, 이후 `publish.yml` |

수동 내부 배포 확인과 자동화 자격 증명 준비를 구분한다. Play service account와 ASC API key는 자동화 경로에 맞춰 준비하며, 수동 업로드 가능 여부를 API key 유무만으로 판단하지 않는다. 계정·서명 조건이 확인되기 전에는 실제 업로드 workflow를 추가하지 않는다.

## 검증과 남은 제한

- 저장소·콘솔·공식 문서 조사와 Markdown 변경만 수행했다. Flutter 애플리케이션 동작, Release 빌드, 실제 업로드·로그인·사진 QA는 이번 점검에서 실행하지 않았다.
- 문서 검증: `git diff --check` 통과, Markdown 6개의 상대 링크 129개와 heading 연결 통과, 원본 개인 iOS 파일의 작업 전후 SHA-256 일치. 문서만 변경하여 Flutter format/analyze/test는 재실행하지 않았다.
- Apple 로그인이 완료되면 같은 이슈에서 확인을 이어간다. 로그인·Play 소유자 인증·서명·빌드 이력 미확인 항목은 완료 처리하지 않는다.

## 커밋 기록

| 커밋 | 범위 |
| --- | --- |
| `1f7818f` | 콘솔·서명·도구·GitHub 설정 확인 결과와 후속 순서 기록 |
| 중앙 문서 갱신 커밋 | README·문서 인덱스·배포 가이드·후속/화면 계획의 재개 상태 동기화, 문서 검증 결과 기록 |

현재 커밋의 해시는 같은 커밋에 중복 기록하지 않으며 PR에서 확인한다. PR 병합은 사용자가 진행한다.
