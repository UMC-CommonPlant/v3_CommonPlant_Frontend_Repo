# 테스트 작성 기준

커먼플랜트의 테스트는 빠르게 실행되는 widget/unit test를 기본 품질 게이트로 사용합니다. 새 기능은 화면이 정상적으로 렌더링되는지뿐 아니라 상태 변화와 입력 검증까지 함께 확인합니다.

MVP 단계의 필수 검증은 `fvm dart format --output=none --set-exit-if-changed .`, `fvm flutter analyze`, `fvm flutter test`입니다. Golden test와 integration test는 아래 적용 기준을 만족할 때 추가하고, 기준을 만족하기 전에는 PR 필수 게이트로 올리지 않습니다.

## 현재 테스트 구조

```text
test/
  app/router/                 # route 계약, 진입, 도메인별 사용자 흐름
  core/                       # 공통 파서와 기반 로직
  features/<feature>/
    data/                     # datasource, DTO, mapper, repository
    presentation/             # page, provider, widget, fixture, mapper
  helpers/                    # 여러 테스트에서 공유하는 앱 조립과 fixture
  shared/widgets/             # 공용 위젯
  widget_test.dart
```

현재 테스트는 앱 루트 진입, 라우팅, 공용 컴포넌트, 주요 화면 렌더링, API DTO/Repository 변환, form submit 상태, 닉네임 입력 검증 흐름을 확인합니다.

## 실행 명령

로컬에서는 FVM을 기준으로 실행합니다.

```bash
fvm flutter test
fvm flutter analyze
fvm dart format --output=none --set-exit-if-changed .
```

CI는 GitHub Actions에서 Flutter `3.35.7`을 설치한 뒤 `flutter pub get`, `flutter analyze`, `flutter test`를 실행합니다.

## 테스트 종류

| 종류 | 대상 |
| --- | --- |
| Unit test | validator, mapper, usecase, repository 변환 로직 |
| Widget test | 화면 렌더링, 입력, 버튼 상태, empty/error UI |
| Golden test | 디자인 회귀 검증이 필요한 공용 컴포넌트 |
| Integration test | 로그인, 장소 생성, 식물 등록 같은 주요 사용자 플로우 |

현재 PR 필수 기준은 unit/widget test입니다. Golden과 integration test는 MVP 품질 보조 수단으로 두되, 아래 적용 조건을 만족하는 범위부터 단계적으로 도입합니다.

## MVP 테스트 전략

| 구분 | MVP 기준 |
| --- | --- |
| Unit test | validator, DTO/entity mapper, repository 에러 매핑, Provider/Controller 분기 로직은 필수 |
| Widget test | 새 화면, 상태 UI, form validation, 버튼 활성/비활성, route parameter 처리는 필수 |
| Golden test | 공용 컴포넌트 또는 반복 화면에서 디자인 회귀 위험이 높을 때만 추가 |
| Integration test | API 비사용 앱 시작/route smoke는 디바이스 runner로 먼저 검증하고, remote flow는 staging API, 테스트 계정, 데이터 초기화 정책이 준비된 핵심 플로우에만 추가 |

MVP에서 새 기능을 만들 때 unit/widget test로 검증 가능한 동작을 golden 또는 integration test로 대체하지 않습니다. Golden test는 시각 회귀를 보강하는 용도이고, integration test는 여러 화면과 실제 실행 환경을 통과하는 흐름을 확인하는 용도입니다.

## Widget test 기준

위젯 테스트는 사용자가 실제로 보는 텍스트와 상호작용을 기준으로 작성합니다.

확인해야 할 항목:

- 초기 화면의 주요 title, CTA, 빈 상태
- 입력값 변경에 따른 helper/error text
- 버튼 enabled/disabled 상태
- loading, empty, error, success 분기
- route 진입 시 필수 parameter 처리

Riverpod Provider가 필요한 화면은 `ProviderScope`로 감싸고, 외부 의존성은 override합니다.

```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      // repositoryProvider.overrideWithValue(fakeRepository),
    ],
    child: const CommonPlantApp(),
  ),
);
```

여러 파일에서 같은 앱 껍데기를 반복할 때는 `test/helpers/test_app.dart`의 앱 조립 helper를 사용합니다. helper는 `ProviderScope`와 `MaterialApp` 또는 production router 앱 조립까지만 담당하며, 아래 내용은 테스트 본문에 남깁니다.

- 초기 route와 테스트별 repository override
- `pump`, `pumpAndSettle` 시점과 router 수명 관리
- 사용자 입력과 tap 같은 행동
- 화면 상태와 repository 호출 검증

특정 fake repository 조합이 한 테스트 파일에서만 의미가 있다면 로컬 helper로 유지합니다. 공용 helper가 Given/When/Then을 숨기거나 서로 다른 테스트 조건을 하나의 옵션 집합으로 만들지 않습니다.

## Unit test 기준

아래 로직은 화면 테스트보다 unit test를 우선합니다.

- DTO to entity 변환
- 날짜 포맷 변환
- enum mapping
- form validator
- usecase의 분기 로직
- repository의 에러 매핑

UI가 없어도 검증 가능한 로직은 widget test로 우회하지 않습니다.

## SVG asset 회귀 테스트

`test/core/assets/svg_assets_test.dart`는 `assets/icons`, `assets/images`의 모든 SVG를 현재 lockfile의 `flutter_svg` parser로 읽고 picture rasterize까지 실행합니다. 신규 또는 변경 SVG는 아래 검사를 통과해야 합니다.

```bash
fvm flutter test test/core/assets/svg_assets_test.dart
```

- 파일을 읽을 수 있고 SVG parser가 지원하는 구조여야 합니다.
- `viewBox`에서 계산된 width와 height가 0보다 커야 합니다.
- picture를 실제 image로 rasterize할 수 있어야 합니다.
- parser/rasterize 성공은 픽셀 동일성을 뜻하지 않습니다. 영향 화면에서 실제 최소·최대 표시 크기와 필요한 중간 크기를 확인하고, 기존 golden 대상이면 baseline 비교도 함께 수행합니다.
- SVG 최적화 도구와 후보 검증 순서는 `docs/asset-icon-rules.md`를 따릅니다.

## QA viewport와 디바이스 기준

화면 테스트와 수동 QA는 `docs/quality-testing-follow-up-plan.md`의 QA-01 profile을 공통 입력값으로 사용합니다.

| 구분 | Logical viewport | 기본 용도 |
| --- | --- | --- |
| Compact width | `320×640` | 작은 폭, 긴 문구, 가로 배치 overflow |
| Short height | `375×667` | 짧은 높이, keyboard/CTA overflow |
| Reference | `375×812` | Figma 및 `AppSizes.mobileWidth`/`mobileHeight` 기준 |
| Wide | `430×932` | 넓은 휴대폰의 card/grid 정렬과 최대 너비 |

- 모든 신규 화면 widget test는 Reference를 기본으로 사용합니다.
- form, 긴 문구, 가로 배치가 있으면 Compact width를 추가합니다.
- 키보드, 하단 CTA, 고정 세로 배치가 있으면 Short height를 추가합니다.
- grid, card list, 좌우 정렬 변화가 있으면 Wide를 추가합니다.
- 화면 구조가 바뀐 PR은 Android와 iOS에서 각각 한 개 이상의 필수 profile로 smoke QA를 수행합니다.
- release candidate는 QA-01의 Android 2개, iOS 2개 profile을 모두 확인합니다.
- layout 비교용 widget test와 full-screen golden baseline은 DPR 1을 사용합니다.
- 공통 profile과 DPR 설정은 `test/helpers/test_viewport.dart`의 `TestViewports`와 `configureTestViewport`를 사용합니다.
- 기존 테스트의 raw viewport 설정은 해당 화면을 수정할 때 공통 helper로 점진적으로 전환합니다.
- 제한형 가변 크기는 Compact와 Reference만 확인하지 않고 중간 viewport도 추가해 값이 갑자기 변하지 않는지 검증합니다.
- 최소·최대 viewport에서는 확정된 계약값과 overflow 부재를 확인하고, 중간 viewport에서는 정확한 픽셀값보다 최소·최대 범위와 단조 변화를 검증합니다.
- 버튼 높이와 최소 터치 영역처럼 고정해야 하는 값은 viewport별로 유지되는지도 함께 검증합니다.

## Golden test 기준

Golden test는 MVP 기본 필수 항목이 아닙니다. 아래 조건 중 하나 이상을 만족하고, baseline 관리 비용보다 회귀 방지 효과가 클 때 추가합니다.

- `shared/widgets`의 공용 버튼, 입력창, 카드, Dialog, Scaffold처럼 여러 feature에서 반복 사용되는 컴포넌트
- 디자인 토큰 변경 시 시각 회귀가 크게 발생할 수 있는 컴포넌트
- Figma 기준 화면과 구현 화면의 차이를 반복적으로 확인해야 하는 핵심 UI 조합

Golden test를 추가할 때는 아래 기준을 따릅니다.

- 테스트 파일은 대상 위치와 맞춰 `test/shared/widgets/common_button_golden_test.dart`처럼 둡니다.
- 기준 폭은 `AppSizes.mobileWidth`와 같은 375 logical pixel을 우선 사용합니다.
- full-screen golden의 기본 viewport는 QA-01 Reference인 `375×812`, DPR 1입니다.
- 첫 pilot은 remote API, 시간, locale에 의존하지 않는 `OnboardingPage`입니다. Compact width, Short height, Wide baseline은 일괄 추가하지 않고 대상 화면의 레이아웃 위험에 따라 별도 결정합니다.
- `test/helpers/golden_test_helper.dart`로 viewport, 앱 Theme, Pretendard 400/500/600/700과 asset 렌더링을 준비합니다. helper 파일명은 test runner가 독립 테스트로 오인하지 않도록 `_test.dart`로 끝내지 않습니다.
- baseline은 테스트 파일과 같은 경로의 `goldens/` 아래에 `<화면>_<logical width>x<logical height>.png` 형식으로 둡니다.
- Ubuntu `ubuntu-latest`를 canonical renderer로 사용하며 Flutter 기본 exact comparator, 즉 허용 오차 0%를 유지합니다.
- Linux가 아닌 로컬 환경에서는 full-screen golden만 skip합니다. 기존 unit/widget test는 그대로 실행하며 golden이 동작 검증을 대체하지 않습니다.

### Ubuntu를 canonical renderer로 사용하는 이유

2026-08-14 Flutter `3.35.7` 검증에서 macOS가 생성한 `OnboardingPage` baseline은 같은 viewport, DPR, Pretendard OTF, SVG asset을 사용했음에도 Ubuntu exact 비교에서 `1.03%`, `3,122px` 차이가 발생했습니다. isolated diff는 제목과 버튼 라벨의 글자 경계에 집중됐고 SVG, 배경, 크기와 배치는 일치했습니다. 따라서 원인은 화면 구조가 아니라 OS별 font rasterization과 anti-aliasing 차이로 판단합니다.

전체 이미지에 1~2% 허용 오차를 주면 작은 위치, 색상, 크기 회귀까지 함께 통과시킬 수 있으므로 채택하지 않습니다. PR 필수 CI가 실행되는 Ubuntu를 하나의 canonical 환경으로 고정하고 그 환경에서는 0% exact 비교를 유지합니다. macOS를 포함한 non-Linux 환경은 같은 픽셀을 보장할 수 없으므로 golden만 skip합니다.

### Baseline 생성과 리뷰

baseline은 의도한 디자인 변경이 있는 PR에서만 갱신합니다.

1. GitHub Actions에서 `Golden Baseline` workflow를 대상 브랜치로 수동 실행합니다.
2. workflow가 Ubuntu에서 대상 test를 `--update-goldens`로 실행하고 `onboarding-golden-<commit SHA>` artifact를 생성합니다.
3. artifact의 PNG를 같은 이름의 저장소 baseline에 반영합니다.
4. 변경된 화면 코드, 기존 baseline, 새 baseline을 함께 리뷰합니다. CI를 통과시키기 위한 이유만으로 baseline을 갱신하지 않습니다.
5. PR의 Ubuntu `Flutter CI`가 일반 `flutter test`에서 exact 비교를 통과하는지 확인합니다.

```bash
gh workflow run golden_baseline.yml --ref <작업-브랜치>
gh run list --workflow golden_baseline.yml --branch <작업-브랜치> --limit 1
gh run watch <run-id>
gh run download <run-id>
```

Golden 실패 시 `Flutter CI`는 `test/**/failures/`의 master, test, isolated diff, masked diff를 7일간 artifact로 보존합니다. diff를 먼저 확인하고 의도한 변경이 아니면 화면 코드나 재현 환경을 수정합니다.

## Integration test 기준

Integration test는 MVP 기본 PR 필수 게이트가 아닙니다. 백엔드 준비 여부에 따라 API 비사용 smoke와 remote API end-to-end를 분리합니다.

### TEST-02-A API 비사용 smoke

첫 pilot인 `integration_test/app_smoke_test.dart`는 production `main()`으로 실제 앱을 시작하고 아래 계약을 확인합니다.

- `COMMONPLANT_USE_API=false`를 명시하고 테스트 안에서도 remote API가 꺼져 있는지 확인합니다.
- Home의 `My place`, `My plant`, `장소 요청 3건`을 확인합니다.
- `장소 요청 3건`을 탭해 장소 친구 요청 화면과 요청 항목이 노출되는지 확인합니다.
- 네트워크, 계정, seed 데이터에 의존하지 않으며 기존 unit/widget test를 대체하지 않습니다.

로컬 Android 실행은 연결된 기기의 ID를 명시합니다.

```bash
fvm flutter devices
fvm flutter test integration_test/app_smoke_test.dart \
  -d <android-device-id> \
  --dart-define=COMMONPLANT_USE_API=false
```

Android emulator가 필요하면 `fvm flutter emulators`로 ID를 확인한 뒤 `fvm flutter emulators --launch <emulator-id>`로 시작합니다. Flutter wrapper로 기동 상태를 확인하기 어려운 환경에서는 Android SDK의 공식 emulator CLI로 같은 AVD를 실행할 수 있습니다.

`.github/workflows/android_integration_smoke.yml`은 Ubuntu의 Android API 35 Google APIs x86_64 Pixel 6 emulator에서 같은 테스트를 실행하는 수동 workflow입니다.

```bash
gh workflow run android_integration_smoke.yml --ref <작업-브랜치>
gh run list --workflow android_integration_smoke.yml --branch <작업-브랜치> --limit 1
gh run watch <run-id>
gh run view <run-id> --log
```

`workflow_dispatch`로 새로 추가한 workflow는 파일이 기본 브랜치에 병합된 뒤 실행할 수 있습니다. 따라서 첫 병합 직후 `develop`을 대상으로 smoke를 실행하고 결과를 #203에 남깁니다.

앱 build, 설치, 시작 또는 테스트 assertion 실패는 smoke 실패입니다. emulator provisioning 같은 runner 인프라 실패는 로그에서 테스트 실패와 분리하고 한 번 재실행할 수 있지만, assertion 실패를 이유 없이 재실행해 통과로 바꾸지 않습니다.

다음 조건을 모두 충족하기 전에는 PR 필수 게이트로 승격하지 않습니다.

1. `develop` 수동 실행이 assertion 실패나 재시도 없이 연속 3회 성공합니다.
2. 실패 원인을 앱과 runner 인프라로 구분할 수 있는 로그가 안정적으로 남습니다.
3. 실행 시간과 GitHub Actions 비용이 팀이 수용할 수 있는 범위입니다.
4. 팀이 required check 승격에 동의합니다.

### TEST-02-B remote API end-to-end

remote API를 사용하는 핵심 사용자 흐름은 아래 조건이 준비된 뒤 추가합니다.

- staging 또는 테스트용 API base URL이 확정되어 있습니다.
- 테스트 전용 계정과 seed 데이터 또는 테스트 후 정리 방식이 준비되어 있습니다.
- Android emulator, iOS simulator, 실제 기기, 또는 GitHub Actions runner 중 실행 환경이 정해져 있습니다.
- 네트워크 실패, 인증 만료, 데이터 중복이 테스트 결과를 불안정하게 만들지 않도록 격리 전략이 있습니다.

우선 도입 대상은 아래 흐름으로 제한합니다.

- 로그인과 프로필 설정 smoke flow
- 장소 생성/수정/삭제 flow
- 식물 등록/수정/삭제 flow
- 메모 작성/삭제 flow

테스트 파일은 `integration_test/` 아래에 플로우 단위로 둡니다. remote API를 사용하는 경우 실행 명령은 환경값을 명시합니다.

```bash
fvm flutter test integration_test \
  --dart-define=COMMONPLANT_USE_API=true \
  --dart-define=COMMONPLANT_API_BASE_URL=<staging-api-url>
```

staging API, 테스트 계정, seed/cleanup 정책이 필요한 end-to-end flow는 준비 전까지 `Blocked`입니다. 준비 전 회귀 검증은 unit/widget test와 feature별 Provider override를 사용합니다.

## 테스트 파일 네이밍

| 대상 | 예시 |
| --- | --- |
| Widget test | `test/features/place/place_list_page_test.dart` |
| Provider test | `test/features/place/place_list_provider_test.dart` |
| Mapper test | `test/features/place/place_response_test.dart` |
| Shared widget test | `test/shared/widgets/common_button_test.dart` |
| Golden test | `test/shared/widgets/common_button_golden_test.dart` |
| Integration test | `integration_test/place_create_flow_test.dart` |

feature 구조와 test 구조를 비슷하게 맞추면 찾기 쉽습니다.

## 테스트 데이터 기준

- 테스트 데이터는 테스트 파일 안에서 읽기 쉬운 fixture로 둡니다.
- 여러 테스트 파일에서 반복되는 도메인 fixture와 앱 조립만 `test/helpers`로 분리합니다.
- 실제 API 응답 샘플이 필요한 경우 JSON fixture를 사용합니다.
- 테스트에서 네트워크를 직접 호출하지 않습니다.

## CI와 pre-commit

`lefthook.yml`의 pre-commit 검사는 아래 순서로 실행됩니다.

- format
- analyze
- test

로컬에 `.fvmrc`와 FVM이 있으면 lefthook도 `fvm` 명령을 우선 사용합니다.

GitHub Actions의 기본 CI는 PR과 push에서 `flutter pub get`, `flutter analyze`, `flutter test`를 실행합니다. Ubuntu에서는 Golden test가 일반 `flutter test`에 포함되고 non-Linux 로컬에서는 golden만 skip됩니다. API 비사용 Android integration smoke는 별도 수동 workflow로 검증하며 승격 조건을 충족하기 전에는 required check가 아닙니다. Remote integration test는 백엔드 실행 환경이 준비된 뒤 release candidate 검증 또는 별도 CI job으로 연결합니다.

## 체크리스트

- [ ] 새 화면의 초기 렌더링 테스트가 있는가?
- [ ] 입력 검증 또는 버튼 상태 변화 테스트가 있는가?
- [ ] loading/empty/error 중 새로 추가한 상태를 테스트했는가?
- [ ] API mapper 또는 repository 에러 매핑 테스트가 있는가?
- [ ] Provider override가 가능하도록 의존성이 분리되어 있는가?
- [ ] 테스트가 네트워크나 실제 저장소에 의존하지 않는가?
- [ ] 시각 회귀 위험이 큰 공용 컴포넌트라면 Golden test 적용 기준을 확인했는가?
- [ ] 여러 화면과 실제 실행 환경이 필요한 흐름이라면 Integration test 준비 조건을 확인했는가?
- [ ] `fvm flutter test`를 통과하는가?

## 후속 결정 필요

- TEST-01 pilot은 #199에서 `OnboardingPage`, `375×812`, DPR 1, Ubuntu canonical, exact comparator로 확정했습니다. 추가 화면과 viewport baseline은 회귀 위험과 유지 비용을 확인해 별도 이슈로 확장합니다.
- TEST-02-A는 #203에서 API 비사용 Home → 장소 친구 요청 Android smoke와 수동 workflow로 도입했습니다. 병합 후 `develop` 수동 실행을 검증하고 연속 성공 기준을 충족하기 전에는 PR 필수 게이트로 승격하지 않습니다.
- TEST-02-B는 staging API, 테스트 계정, seed/cleanup이 준비되면 remote integration test workflow를 release 검증 또는 별도 CI job으로 연결합니다. 준비 전 상태는 `Blocked`입니다.
