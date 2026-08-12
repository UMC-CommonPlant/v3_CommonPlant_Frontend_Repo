# 품질·테스트 후속 작업 계획

이 문서는 코드 가독성 리팩토링 1~3차 완료 후 `QA-01`, `TEST-01`, `TEST-02`를 별도 이슈로 진행하기 위한 현재 상태, 의존관계, 완료 기준을 관리한다.

## 작업 원칙

- 로컬 코드와 저장소 설정만으로 결정할 수 있는 범위를 먼저 진행한다.
- staging API, 테스트 계정, seed/cleanup처럼 백엔드 준비가 필요한 항목은 `Blocked`로 분리한다.
- Golden test와 integration test는 기존 unit/widget test를 대체하지 않는다.
- 새 테스트 종류를 PR 필수 게이트로 올리기 전 재현 가능한 로컬 실행 방법과 CI runner를 먼저 확보한다.
- 각 항목은 별도 GitHub 이슈와 `develop` 기반 브랜치에서 진행한다.

## 2026-08-12 현재 상태

| 점검 항목 | 현재 상태 | 판단 |
| --- | --- | --- |
| 기준 브랜치 | `develop@f001561` | 코드 가독성 리팩토링 3차 병합 완료 |
| 화면 기준 크기 | `AppSizes.mobileWidth` 375, `AppSizes.mobileHeight` 812 | Figma 기준 viewport로 유지 |
| Widget test viewport | 일부 화면 테스트가 `375×812`, DPR 1을 파일별로 직접 설정 | 공통 QA profile/helper는 없음 |
| Golden test | test, baseline image, 공통 font loader 없음 | TEST-01에서 첫 도입 범위 결정 필요 |
| Font/asset | Pretendard 4종과 앱 asset이 저장소 및 `pubspec.yaml`에 등록됨 | Golden 재현성의 기본 조건 충족 |
| Integration test | SDK 의존성, `integration_test/`, 실행 script 없음 | 로컬 smoke scaffold부터 별도 도입 가능 |
| GitHub Actions | Ubuntu에서 `flutter analyze`, `flutter test` 실행 | device 기반 workflow는 없음 |
| Remote API 환경 | `COMMONPLANT_USE_API`, `COMMONPLANT_API_BASE_URL` 주입 지점만 존재 | staging URL, 계정, 데이터 격리 정책은 Blocked |

## 의존관계를 반영한 작업 순서

| 순서 | ID | 범위 | 선행 조건 | 현재 상태 |
| --- | --- | --- | --- | --- |
| 1 | QA-01 | QA 필수 디바이스와 viewport 기준 확정 | 없음 | Decided (#195) |
| 2 | TEST-01 | full-screen golden 대상 화면, baseline, 갱신 규칙 도입 | QA-01 | Ready |
| 3 | TEST-02-A | remote API를 사용하지 않는 integration smoke와 로컬 실행 환경 검토 | 없음. 우선순위상 TEST-01 다음 | Ready |
| 4 | TEST-02-B | staging API 기반 integration workflow와 핵심 CRUD flow 연결 | staging URL, 테스트 계정, seed/cleanup, secret 정책 | Blocked |

TEST-01과 TEST-02-A 사이에 기술적 의존은 없지만 테스트 도입 범위를 한 번에 넓히지 않도록 QA-01, TEST-01, TEST-02 순서를 유지한다. TEST-02-B의 외부 조건이 준비되지 않아도 TEST-02-A의 API 비사용 smoke와 runner 검토는 별도 이슈로 진행할 수 있다.

## QA-01 필수 기준

### 자동 레이아웃 검증 viewport

Flutter test의 `tester.view`에는 physical pixel이 아니라 아래 logical viewport와 DPR 1을 사용한다.

| Profile | Logical viewport | 용도 | 적용 기준 |
| --- | --- | --- | --- |
| Compact | `320×568` | 작은 휴대폰의 가로 overflow와 짧은 세로 공간 확인 | form, 긴 문구, 가로 배치, 하단 CTA가 있는 화면 |
| Reference | `375×812` | Figma와 현재 `AppSizes` 기준 회귀 확인 | 모든 신규 화면의 기본 widget test |
| Wide | `430×932` | 넓고 긴 휴대폰에서 정렬, 최대 너비, 여백 확인 | grid, card list, 좌우 정렬 변화가 있는 화면 |

- `320` logical pixel은 Android의 small phone 기준을 하한 회귀 폭으로 사용한다.
- `375×812`는 디자인 비교와 향후 full-screen golden의 기본 후보 크기다.
- 세 프로필을 모든 테스트에 기계적으로 반복하지 않는다. Reference는 기본으로 사용하고 Compact/Wide는 레이아웃 위험이 있는 화면에 추가한다.
- DPR 차이는 layout 검증 기준과 분리한다. Golden baseline의 DPR은 TEST-01에서 확정한다.

### 수동 QA 필수 디바이스 profile

실제 보유 기기 모델명을 고정하지 않고 재현 가능한 logical viewport와 플랫폼 역할을 기준으로 관리한다.

| Platform | Profile | Logical viewport | 필수 확인 |
| --- | --- | --- | --- |
| Android | Compact phone emulator | 약 `360×800` | 작은 폭, 시스템 back, 키보드, scroll, safe inset |
| Android | Large phone emulator | 약 `412×915` | 넓은 폭, 긴 목록, card/grid 정렬, 하단 CTA |
| iOS | Compact-height simulator | `375×667` | 짧은 높이, 키보드, safe area, navigation 전환 |
| iOS | Reference-height simulator | `375×812` | Figma 기준 정렬, notch 계열 safe area, 기본 사용자 흐름 |

- 화면 PR은 Reference widget test를 기본으로 하고 레이아웃 위험에 따라 Compact 또는 Wide를 추가한다.
- 화면 구조가 바뀐 PR은 Android와 iOS에서 각각 한 개 이상의 필수 profile로 smoke QA를 수행한다.
- release candidate QA에서는 네 profile을 모두 확인한다.
- 실제 기기는 같은 역할과 같거나 더 작은 사용 가능 viewport를 제공하면 해당 profile을 대체할 수 있다. PR 또는 QA 기록에 기기, OS, 사용 가능 viewport를 남긴다.
- 가로 모드, tablet, foldable의 필수 지원 여부는 이 항목에서 임의로 확정하지 않으며 제품 지원 범위가 정해지면 QA matrix를 확장한다.

### 공통 확인 항목

- 첫 진입, loading, empty, error, success 상태
- 긴 한글 문구, 이미지 없음, 네트워크 실패 상태
- 키보드가 입력 필드와 CTA를 가리지 않는지
- SafeArea, system back, scroll 복구, dialog 닫기
- 화면 하단 CTA와 FAB의 접근 가능성
- RenderFlex overflow와 잘린 텍스트가 없는지

## TEST-01 다음 작업 범위

TEST-01은 아래 순서로 별도 이슈화한다.

1. Pretendard와 asset을 명시적으로 로드하는 golden test helper를 만든다.
2. remote API와 시간, locale에 의존하지 않는 화면 한 개를 `375×812` full-screen pilot으로 선정한다.
3. baseline 파일명, 저장 위치, DPR, 허용 오차, `--update-goldens` 리뷰 규칙을 정한다.
4. Compact/Wide baseline은 pilot 화면에 일괄 추가하지 않고 레이아웃 위험과 회귀 효과를 확인해 대상 화면별로 선택한다.
5. 로컬과 Ubuntu CI에서 같은 baseline이 재현된 뒤 일반 `fvm flutter test`에 포함한다.

## TEST-02 Ready와 Blocked 경계

### 로컬에서 진행 가능한 범위

- Flutter SDK의 `integration_test` 의존성과 디렉터리 구조 검토
- `COMMONPLANT_USE_API=false`인 앱 시작/route smoke flow 작성
- Android emulator 또는 iOS simulator의 명시적 device ID를 사용하는 실행 명령 정리
- 독립 workflow를 수동 실행으로 먼저 검증하고 PR 필수 게이트 승격 조건 문서화

### 백엔드 준비 전 Blocked 범위

- `COMMONPLANT_USE_API=true`인 로그인과 CRUD end-to-end flow
- staging API URL과 API versioning을 포함한 CI 환경값
- 테스트 전용 계정과 인증 갱신 정책
- seed 데이터, 중복 방지, 테스트 후 cleanup 정책
- secret 접근 권한과 외부 API 장애 시 재시도/판정 정책

Blocked 조건이 해소되기 전에는 remote integration job을 PR 필수 게이트에 추가하지 않는다.

## 외부 기준

- [Flutter testing overview](https://docs.flutter.dev/testing/overview)
- [Flutter integration testing](https://docs.flutter.dev/testing/integration-tests)
- [Android responsive/adaptive layouts](https://developer.android.com/develop/ui/views/layout/responsive-adaptive-design-with-views)

## 커밋별 작업 이력

| ID | 커밋 | 변경 범위 | 검증 |
| --- | --- | --- | --- |
| QA-01 | - | QA 필수 viewport/device profile, 후속 작업 순서, Ready/Blocked 경계 문서화 | `git diff --check` 예정 |

작업 이력만 갱신하는 마지막 문서 커밋은 자기 자신의 해시를 생략할 수 있다.
