# 품질·테스트 후속 작업 계획

이 문서는 코드 가독성 리팩토링 1~3차 완료 후 `QA-01`, `TEST-01`, `TEST-02`를 별도 이슈로 진행하기 위한 현재 상태, 의존관계, 완료 기준을 관리한다.

## 작업 원칙

- 로컬 코드와 저장소 설정만으로 결정할 수 있는 범위를 먼저 진행한다.
- dev API URL은 확인된 값으로 사용하고, 테스트 계정, seed/cleanup처럼 추가 백엔드 준비가 필요한 항목은 `Blocked`로 분리한다.
- Golden test와 integration test는 기존 unit/widget test를 대체하지 않는다.
- 새 테스트 종류를 PR 필수 게이트로 올리기 전 재현 가능한 로컬 실행 방법과 CI runner를 먼저 확보한다.
- 각 항목은 별도 GitHub 이슈와 `develop` 기반 브랜치에서 진행한다.

## 2026-08-23 현재 상태

| 점검 항목 | 현재 상태 | 판단 |
| --- | --- | --- |
| 기준 브랜치 | `develop@37501b6` | RELEASE-02 #211, PR #212까지 병합 완료 |
| 화면 기준 크기 | `AppSizes.mobileWidth` 375, `AppSizes.mobileHeight` 812 | Figma 기준 viewport로 유지 |
| Widget test viewport | `test/helpers/test_viewport.dart`에서 네 QA profile과 DPR 1 설정을 제공하고 compact gap 대상 화면에 적용 | 기존 raw viewport 설정은 관련 화면 수정 시 점진적으로 helper로 전환 |
| Golden test | #199에서 `OnboardingPage` `375×812`, DPR 1 baseline과 Pretendard helper 구현 | Ubuntu canonical renderer의 exact 비교와 수동 baseline workflow run `31811426737` 성공 확인 |
| Font/asset | 한글 포함 Pretendard v1.3.9 static OTF 4종과 OFL을 `pubspec.yaml` 및 저장소에 등록 | #200에서 Hangul glyph와 Android/iOS packaging 검증 완료 |
| Integration test | #203에서 SDK 의존성, API 비사용 Home → 장소 친구 요청 smoke 추가 | Android API 36.1 `emulator-5554` 로컬 실행 통과 |
| GitHub Actions | 기본 Flutter CI, 수동 `Golden Baseline`, 수동 `Android Integration Smoke` workflow 제공 | Android smoke run `32243828623` 성공, 연속 3회 기준 전이라 아직 required check가 아님 |
| 기본 품질 게이트 | macOS에서 unit/widget/asset 258개 통과와 golden 1개 skip, Ubuntu에서 golden 포함 259개 통과 | non-Linux font rasterization 차이는 skip하고 Ubuntu exact 결과를 필수 판정으로 사용 |
| Remote API 환경 | dev API `https://commonplant-dev.okbear.dev/api/v1`과 환경값 주입 지점 확인 | 테스트 계정, seed/cleanup, secret과 데이터 격리 정책은 Blocked |

## 의존관계를 반영한 작업 순서

| 순서 | ID | 범위 | 선행 조건 | 현재 상태 |
| --- | --- | --- | --- | --- |
| 1 | QA-01 | QA 필수 디바이스와 viewport 기준 확정 | 없음 | Decided (#195) |
| 2 | QA-01 적용 후속 | compact-width overflow 수정과 viewport 회귀 테스트 추가 | QA-01 | Done (#197) |
| 3 | TEST-01 폰트 선행 | 한글 Pretendard asset과 라이선스 정리 | QA-01 적용 후속 | Done (#200) |
| 4 | TEST-01 | full-screen golden 대상 화면, baseline, 갱신 규칙 도입 | TEST-01 폰트 선행 | Done (#199) |
| 5 | TEST-02-A | remote API를 사용하지 않는 integration smoke와 수동 Android runner 도입 | 없음. 우선순위상 TEST-01 다음 | Done (#203) |
| 6 | TEST-02-B | dev API 기반 integration workflow와 핵심 CRUD flow 연결 | 테스트 계정, seed/cleanup, secret과 데이터 격리 정책 | Blocked |

TEST-01과 TEST-02-A 사이에 기술적 의존은 없지만 테스트 도입 범위를 한 번에 넓히지 않도록 QA-01, compact-width 회귀 수정, TEST-01, TEST-02 순서를 유지한다. TEST-02-B의 외부 조건이 준비되지 않아도 TEST-02-A의 API 비사용 smoke와 runner 검토는 별도 이슈로 진행할 수 있다.

## QA-01 필수 기준

### 자동 레이아웃 검증 viewport

Flutter test의 `tester.view`에는 physical pixel이 아니라 아래 logical viewport와 DPR 1을 사용한다.

| Profile | Logical viewport | 용도 | 적용 기준 |
| --- | --- | --- | --- |
| Compact width | `320×640` | 작은 휴대폰의 가로 overflow 확인 | form, 긴 문구, 가로 배치가 있는 화면 |
| Short height | `375×667` | 짧은 세로 공간과 하단 CTA 확인 | 키보드, 하단 CTA, 고정 세로 배치가 있는 화면 |
| Reference | `375×812` | Figma와 현재 `AppSizes` 기준 회귀 확인 | 모든 신규 화면의 기본 widget test |
| Wide | `430×932` | 넓고 긴 휴대폰에서 정렬, 최대 너비, 여백 확인 | grid, card list, 좌우 정렬 변화가 있는 화면 |

- `320` logical pixel은 Android의 small phone 기준을 하한 회귀 폭으로 사용하고, 기존 낮은 높이 화면 테스트와 일치하는 `320×640`으로 관리한다.
- `375×667`은 폭과 높이 위험을 한 profile에 섞지 않고 짧은 높이 회귀를 독립적으로 확인할 때 사용한다.
- `375×812`는 디자인 비교와 향후 full-screen golden의 기본 후보 크기다.
- 네 profile을 모든 테스트에 기계적으로 반복하지 않는다. Reference는 기본으로 사용하고 Compact width, Short height, Wide는 레이아웃 위험이 있는 화면에 추가한다.
- DPR 차이는 layout 검증 기준과 분리한다. Golden baseline의 DPR은 TEST-01에서 확정한다.

### 2026-08-13 viewport 검증 결과

임시 진단 테스트로 route-level 화면 18개를 8개 viewport에서 초기 렌더링해 총 144개 조합을 확인했다. 진단 파일은 결과 확인 후 제거했으며 저장소 테스트에는 포함하지 않았다.

| Logical viewport | 결과 |
| --- | --- |
| `320×568` | Place 초대, 주소 검색, Place 상세, Plant 상세에서 overflow |
| `320×640` | `320×568`과 같은 4개 route에서 overflow |
| `360×800` | Place 초대에서 overflow |
| `375×667` | 18개 route 통과 |
| `375×812` | 18개 route 통과 |
| `412×915` | 18개 route 통과 |
| `430×812` | 18개 route 통과 |
| `430×932` | 18개 route 통과 |

`320×568`과 `320×640`이 같은 width 문제를 검출했으므로 기존 테스트와 정렬되는 `320×640`을 Compact width로 채택한다. 짧은 높이 검증은 전체 route가 통과한 `375×667`로 분리한다. 이 검증은 DPR 1과 system inset이 없는 widget 환경의 초기 렌더링 검사이므로 키보드, SafeArea, system back은 수동 QA로 계속 확인한다.

### 확인된 적용 gap

| 화면 | 확인된 문제 | 처리 기준 |
| --- | --- | --- |
| Place 초대 | action button Row가 320에서 50px, 360에서 10px 가로 overflow | #197에서 버튼 폭을 72~114로 제한하고 `320×640`, `360×800` 연속 변화와 overflow 부재 검증 |
| 주소 검색 | 결과 Row가 320에서 12px 가로 overflow | #197에서 가변 text 영역과 `320×640` 회귀 테스트 적용 |
| Place 상세 | 공용 Plant card 내부 세로 overflow | #197에서 image를 96~136 폭과 96~108 높이로 제한하고 320/340/375 폭의 끝값·범위·단조성 검증 |
| Plant 상세 | 날짜 요약 Row가 320에서 22px 가로 overflow | #197에서 320~375 폭의 진행률로 간격을 8~34 사이 보간하고 최소/중간/최대 폭의 끝값·범위·단조성 검증 |

QA-01은 정책 결정 상태인 `Decided`로 유지한다. 위 gap은 #197에서 정책 적용과 회귀 테스트를 완료했으며, TEST-01의 선행 조건은 해소되었다.

### 수동 QA 필수 디바이스 profile

실제 보유 기기 모델명을 고정하지 않고 재현 가능한 logical viewport와 플랫폼 역할을 기준으로 관리한다.

| Platform | Profile | Logical viewport | 필수 확인 |
| --- | --- | --- | --- |
| Android | Compact phone emulator | 약 `360×800` | 작은 폭, 시스템 back, 키보드, scroll, safe inset |
| Android | Large phone emulator | 약 `412×915` | 넓은 폭, 긴 목록, card/grid 정렬, 하단 CTA |
| iOS | Compact-height simulator | `375×667` | 짧은 높이, 키보드, safe area, navigation 전환 |
| iOS | Reference-height simulator | `375×812` | Figma 기준 정렬, notch 계열 safe area, 기본 사용자 흐름 |

- 화면 PR은 Reference widget test를 기본으로 하고 레이아웃 위험에 따라 Compact width, Short height, Wide를 추가한다.
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

## TEST-01 확정 기준

Compact width 적용 gap과 대상 화면 회귀 테스트는 #197에서 완료했다. TEST-01은 #199에서 아래 범위로 확정했다.

1. #200에서 등록한 한글 Pretendard OTF 4개 weight와 asset을 `test/helpers/golden_test_helper.dart`에서 명시적으로 로드한다.
2. remote API와 시간, locale에 의존하지 않는 `OnboardingPage`를 `375×812`, DPR 1 full-screen pilot으로 사용한다.
3. baseline은 대상 test 옆 `goldens/onboarding_page_375x812.png`에 두고 Ubuntu에서 Flutter 기본 exact comparator로 비교한다.
4. Compact width, Short height, Wide baseline은 pilot 화면에 일괄 추가하지 않고 레이아웃 위험과 회귀 효과를 확인해 대상 화면별로 선택한다.
5. non-Linux 로컬에서는 golden만 skip하고 기존 unit/widget test를 유지한다. Ubuntu CI에서는 golden을 일반 `flutter test`에 포함한다.
6. baseline 갱신은 수동 `Golden Baseline` workflow가 Ubuntu에서 생성한 artifact만 사용하고, 의도한 디자인 변경과 함께 리뷰한다.

### Ubuntu canonical renderer 결정 근거

첫 baseline은 macOS와 Ubuntu에서 Flutter `3.35.7`, `375×812`, DPR 1, 같은 Pretendard OTF와 SVG를 사용했다. macOS에서는 exact 비교가 통과했지만 Ubuntu run `31806673835`에서는 `1.03%`, `3,122px` 차이로 실패했다. CI failure artifact의 isolated diff를 확인한 결과 제목과 버튼 라벨의 글자 경계만 달랐고 SVG, 배경, 크기와 배치는 일치했다. OS별 font rasterization과 anti-aliasing 차이로 판정한다.

1~2%의 전체 이미지 허용 오차는 작은 위치·색상·크기 회귀를 숨길 수 있으므로 도입하지 않는다. Ubuntu runner를 canonical renderer로 고정해 0% exact 비교를 유지하고, 같은 픽셀을 보장할 수 없는 non-Linux 환경에서는 golden만 skip한다. Ubuntu canonical baseline을 반영한 run `31807337886`에서 analyzer와 전체 unit/widget/golden test가 통과했다.

## TEST-02 Ready와 Blocked 경계

### TEST-02-A 확정 범위

- Flutter SDK의 `integration_test`를 dev dependency로 등록한다.
- `integration_test/app_smoke_test.dart`에서 production `main()`을 실행하고 `COMMONPLANT_USE_API=false`를 assertion으로 고정한다.
- Home의 기본 콘텐츠를 확인한 뒤 `장소 요청 3건`을 탭해 장소 친구 요청 화면까지 이동한다.
- 로컬 명령은 Android device ID를 명시하고, GitHub Actions는 Android API 35 Google APIs x86_64 Pixel 6 emulator의 수동 workflow로 실행한다.
- `develop`의 첫 수동 run `32243828623`은 성공했다.
- `develop` 수동 run이 assertion 실패나 재시도 없이 3회 연속 성공하고 로그 구분, 실행 시간·비용, 팀 동의를 확인한 뒤에만 required check 승격을 검토한다.

### 백엔드 준비 전 Blocked 범위

- `COMMONPLANT_USE_API=true`인 로그인과 CRUD end-to-end flow
- 확인된 dev API URL을 CI에 주입할 variable/secret 정책
- 테스트 전용 계정과 인증 갱신 정책
- seed 데이터, 중복 방지, 테스트 후 cleanup 정책
- secret 접근 권한과 외부 API 장애 시 재시도/판정 정책

Blocked 조건이 해소되기 전에는 remote integration job을 PR 필수 게이트에 추가하지 않는다.

## 외부 기준

- [Flutter testing overview](https://docs.flutter.dev/testing/overview)
- [Flutter integration testing](https://docs.flutter.dev/testing/integration-tests)
- [GitHub Actions workflow 수동 실행](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow)
- [Android emulator command line](https://developer.android.com/studio/run/emulator-commandline)
- [Android responsive/adaptive layouts](https://developer.android.com/develop/ui/views/layout/responsive-adaptive-design-with-views)

## 커밋별 작업 이력

| ID | 커밋 | 변경 범위 | 검증 |
| --- | --- | --- | --- |
| QA-01 | `3e01a12` | QA 필수 viewport/device profile, 후속 작업 순서, Ready/Blocked 경계 문서화 | `git diff --check`, format 252개 파일, analyze, unit/widget test 218개 |
| QA-01 검증 | `7e82774` | 144개 route/viewport 조합 검증, Compact/Short height 분리, 적용 gap과 후속 순서 보완 | 임시 route-level viewport 진단, `git diff --check` |
| QA-01 적용 | `b09e6a7` | Place 초대, 주소 검색, Place 상세, Plant 상세 compact 반응형 레이아웃 수정 | 대상 화면 test 21개, `fvm flutter analyze` |
| QA-01 회귀 | `20a1ed5` | 공통 viewport helper와 compact 회귀 widget test 4개 추가 | format 253개 파일, `fvm flutter analyze`, unit/widget test 222개 |
| QA-01 가변 범위 | `fe0f5fc` | 초대 버튼, 장소 식물 카드 image, 식물 날짜 간격을 최소·최대 범위의 연속 계산으로 보완 | 대상 화면 test 21개, 최소·중간·최대 viewport 값 검증 |
| QA-01 가변 기준 정리 | `a80d3ae` | 위젯 전용 보호값을 private 상수로 이동하고 날짜 간격을 정규화 보간하며 중간값 테스트를 범위·단조성 기준으로 완화 | Place/Plant 상세 test 15개, `git diff --check` |
| TEST-01 폰트 선행 | `cc93a5c` | Latin 전용 Pretendard Std를 한글 포함 공식 Pretendard v1.3.9 OTF 4종으로 교체하고 OFL 보존 | Hangul `AC00-D7A3`, 임시 Flutter render, format 253개, analyze, unit/widget test 222개, Android/iOS debug build |
| TEST-01 폰트 라이선스 | `befcb93` | OFL 저작권·라이선스 본문을 runtime asset으로 등록해 Android/iOS 배포물에 포함 | APK와 Runner.app의 `flutter_assets/assets/fonts` packaging 확인 |
| TEST-01 pilot | `c97beaa` | Pretendard 4개 weight와 Theme을 준비하는 helper, Onboarding full-screen test와 375×812 baseline 추가 | macOS target exact test, `fvm flutter analyze` |
| TEST-01 canonical 환경 | `874dfb3` | non-Linux golden skip, Ubuntu baseline 생성 workflow, CI failure artifact 업로드 추가 | macOS unit/widget 222개 통과, golden 1개 skip, Ubuntu diff artifact 확인 |
| TEST-01 Ubuntu baseline | `2c1907b` | Ubuntu test image를 canonical baseline으로 반영 | GitHub Actions run `31807337886` analyzer와 unit/widget/golden 223개 통과 |
| TEST-02-A smoke | `61fd571` | `integration_test` 의존성과 API 비사용 Home → 장소 친구 요청 실제 앱 smoke 추가 | Android API 36.1 `emulator-5554` target test, `fvm flutter analyze` 통과 |
| TEST-02-A runner | `fb1e7fd` | Android API 35 emulator 기반 수동 integration smoke workflow 추가 | workflow YAML parse 통과 |
| TEST-02-A action | `92bd778` | 새 Android workflow의 checkout과 Java setup을 Node.js 24 기반 현재 major로 갱신 | 공식 release 확인, workflow YAML parse 통과 |
| TEST-02-B dev 환경 | `6a9fbc9` | dev API URL 준비 완료와 계정·데이터·secret 정책 Blocked 경계 갱신 | dev Swagger/API endpoint와 OpenAPI schema 확인, `git diff --check` |

작업 이력만 갱신하는 마지막 문서 커밋은 자기 자신의 해시를 생략할 수 있다.
