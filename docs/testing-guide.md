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
| Integration test | API 비사용 앱 시작/route smoke는 디바이스 runner로 먼저 검증하고, remote flow는 dev API 외에 테스트 계정과 데이터 초기화 정책까지 준비된 핵심 플로우에만 추가 |

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

### 사용자 데이터 세션 테스트

API 모드의 사용자별 조회·변경은 활성 `userDataSessionProvider`가 필요합니다. 인증 자체가 대상이 아닌 domain test에서는 `test/helpers/user_data_session.dart`의 `authenticatedUserDataSession` override와 fake repository를 함께 사용합니다. 실제 token이나 네트워크 권한을 부여하는 helper가 아닙니다.

인증·계정 전환 회귀 테스트에서는 위 helper로 인증 과정을 대체하지 않고, 메모리 token store와 실제 `AuthSessionController`를 사용합니다.

- 같은 ProviderContainer를 유지한 채 A 조회 → 로그아웃 또는 B 로그인 → 같은 code/id/query 재조회를 검증합니다.
- 이전 Future와 Controller를 살려 둔 채 `Completer`로 A의 늦은 성공·실패를 전달하고 B의 상태·캐시·이동 결과가 바뀌지 않는지 확인합니다.
- 로딩·실패 중 이전 `AsyncValue` 데이터가 실제 화면에 남지 않는지 widget test로 확인합니다.
- token 읽기·저장·삭제 지연은 메모리 저장소, 전송 경계는 fake Dio adapter로 검증합니다. 서버 요청 취소나 OS secure storage 영속 삭제를 검증한 것으로 해석하지 않습니다.
- API 비사용 fixture와 기존 route 회귀 테스트는 유지합니다.

#249의 [작업 이력](work-history/session-cache-isolation-249.md)에 세션·네트워크·화면별 회귀 테스트를 연결합니다.

### 폼 제출 잠금 회귀 테스트

- fake repository의 `Completer`로 첫 요청을 지연하고 이름·주소·날짜·선택값을 변경한 뒤 `submit()`을 다시 호출합니다. 요청 횟수는 1회, payload는 첫 제출값, 두 번째 호출 결과는 비성공이어야 합니다.
- 첫 요청의 성공·실패를 각각 완료합니다. 성공 결과는 최초 호출에만 반환되고, 실패 후에는 수정된 초안으로 새 요청을 보낼 수 있어야 합니다.
- widget test에서는 입력 변경 뒤에도 disabled/loading이 유지되는지 확인하고, 이전 프레임의 버튼 콜백을 다시 전달해 Controller 경계도 검사합니다. 성공 이동과 오류 표시·재시도를 함께 확인합니다.
- 로딩 indicator가 계속 도는 동안 `pumpAndSettle`로 대기하지 않습니다. 필요한 프레임만 `pump`하고, fake 응답을 완료한 후 화면 전환을 기다립니다.

[#250 작업 이력](work-history/form-submit-lock-250.md)에 대상 Controller와 Reference·Compact width·Short height 화면 검증을 기록합니다. 실제 원격 쓰기나 서버 멱등성 검증은 포함하지 않습니다.

## Unit test 기준

아래 로직은 화면 테스트보다 unit test를 우선합니다.

- DTO to entity 변환
- 날짜 포맷 변환
- enum mapping
- form validator
- usecase의 분기 로직
- repository의 에러 매핑

UI가 없어도 검증 가능한 로직은 widget test로 우회하지 않습니다.

### API 목록 항목 검증

공용 응답 파서나 목록 mapper를 변경할 때는 정상 목록·빈 목록·확인된 wrapper와 함께 전체 비정상 목록 및 일부만 비정상인 목록을 검사합니다. 비-Map 항목을 제외해 정상 빈 목록이나 부분 성공으로 바꾸지 않으며, 오류에는 원인을 찾을 수 있는 항목 위치를 포함합니다. 공용 파서 테스트와 영향을 받는 도메인 mapper 또는 repository 테스트를 함께 실행하되, fake 응답 검증을 실제 서버 응답이나 인증 E2E 검증으로 기록하지 않습니다.

### 비활성 공용 입력 검증

공용 입력 위젯의 enabled·disabled 동작을 변경할 때는 키보드 입력 가능 여부뿐 아니라 clear 같은 별도 액션도 같은 상태를 따르는지 widget test로 확인합니다. 강제 focus 장식처럼 실제 포커스와 시각 상태가 다른 조합을 포함하고, 비활성 값·콜백이 바뀌지 않는지와 활성 상태의 기존 액션이 유지되는지를 함께 검증합니다. 장식 상태를 입력 권한으로 해석하지 않습니다.

### 파생 Provider 단순화 검증

원격 조회를 폼이나 화면용 타입으로 변환하는 Provider를 단순화할 때는 실제 fetch를 소유한 원본 Provider와 순수 변환 진입점을 분리해 검증합니다. 변환 테스트는 원본 family instance를 override해 success·빈 정보·loading/error 전달을 확인하고, 원본 테스트는 repository 위임과 route 식별자 전달을 확인합니다. 재시도는 원본 조회 횟수가 한 번만 늘고 화면 상태가 failure에서 ready로 복구되는지 검사합니다.

중간 Provider 이름을 테스트 편의를 위해 유지하지 않습니다. 공개 화면 진입점, 실제 fetch 원본, Controller 상태를 기준으로 테스트하고 API 비사용 fixture·계정 전환·제출 잠금 회귀도 함께 실행합니다([#256 이력](work-history/form-edit-provider-flow-256.md)).

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

#218에서 아래 `develop` 수동 run을 겹치지 않게 순차 실행했고, 모두 최초 시도에서 성공했습니다.

| 순서 | run | `develop` head | smoke job | 결과 | 재시도 |
| --- | --- | --- | --- | --- | --- |
| 1 | [`32243828623`](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/actions/runs/32243828623) | `3a8781b` | 6분 36초 | Success | 없음 |
| 2 | [`32628473811`](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/actions/runs/32628473811) | `34845e9` | 7분 32초 | Success | 없음 |
| 3 | [`32628815566`](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/actions/runs/32628815566) | `34845e9` | 5분 1초 | Success | 없음 |

연속 3회 성공과 로그 구분 조건은 충족했습니다. emulator 설치·cold boot와 실제 `flutter test` 명령이 같은 smoke step 안에서도 구분되어 runner 인프라와 앱 assertion의 실패 지점을 판별할 수 있습니다. #224에서 기본 `Flutter CI / quality`만 `develop` required check로 설정하고, 5분 1초~7분 32초가 걸리는 Android smoke는 관련 변경과 release candidate에서 선택 실행하는 수동 workflow로 유지하기로 결정했습니다.

### TEST-02-B remote API end-to-end

remote API의 상세 준비 조건은 [Remote integration test 준비 계약](remote-integration-test-readiness.md)에서 관리합니다. dev API URL은 준비됐지만 아래 단계는 서로 다른 검증으로 취급합니다.

| 단계 | 범위 | 현재 상태 |
| --- | --- | --- |
| Swagger/OpenAPI reachability | dev 문서와 base URL 접근 | Done (#213) |
| authenticated read-only probe | 실행마다 발급한 token으로 `GET /users` 확인 | Blocked |
| 실제 앱 auth UI smoke | 소셜 로그인, repository, token 저장, route 연결 | Blocked |
| Place/Plant CRUD | run별 격리 데이터 생성과 항상 실행되는 cleanup | Blocked |
| Friend/Image/Memo 확장 | schema와 도메인별 cleanup 확보 | Blocked |

첫 remote pilot은 데이터 변경이 없는 authenticated read-only probe로 제한합니다. 이는 인증과 dev 연결 준비를 확인하는 workflow-level probe이며 Flutter 화면 E2E 완료로 계산하지 않습니다. 실제 앱 smoke는 로그인/프로필 화면이 Auth repository에 연결된 뒤 별도 이슈로 추가합니다.

고정 access token이나 개인 소셜 계정을 장기 secret으로 사용하지 않습니다. credential/token을 `--dart-define`으로 전달하거나 앱 binary, 로그, artifact에 남기는 방식도 사용하지 않습니다. 팀이 승인한 인증 bootstrap, token lifecycle, fixture 격리와 cleanup, GitHub Environment가 모두 준비되기 전에는 실행 가능한 remote 명령이나 workflow를 저장소에 추가하지 않습니다.

Blocked 기간의 회귀 검증은 unit/widget test와 feature별 Provider override를 사용합니다. 환경 조건이 해결되면 read-only probe, 실제 auth UI, 단일 도메인 CRUD 순서로 각각 별도 이슈에서 진행합니다.

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

GitHub Actions의 기본 CI는 `develop` 대상 PR과 `develop` push에서 `flutter pub get`, `flutter analyze`, `flutter test`를 실행합니다. `Flutter CI / quality`는 `develop` branch protection의 required check이며 관리자에게도 적용됩니다. feature branch push는 별도로 실행하지 않아 열린 PR의 `pull_request` 실행과 중복되지 않습니다. Ubuntu에서는 Golden test가 일반 `flutter test`에 포함되고 non-Linux 로컬에서는 golden만 skip됩니다. API 비사용 Android integration smoke는 3회 연속 성공과 로그 구분을 확인했지만 #224 결정에 따라 별도 수동 workflow로 유지합니다. Remote integration test는 백엔드 실행 환경이 준비된 뒤 release candidate 검증 또는 별도 CI job으로 연결합니다.

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
- TEST-02-A는 #203에서 API 비사용 Home → 장소 친구 요청 Android smoke와 수동 workflow로 도입했고, #218에서 `develop` run 3회의 연속 성공과 로그 구분을 확인했습니다. #224에서 기본 `Flutter CI / quality`만 required check로 설정하고 Android smoke는 수동으로 유지하기로 결정했습니다.
- TEST-02-B의 dev API URL은 #213에서 확인했고 #220에서 인증, token lifecycle, 데이터 격리·cleanup, secret 승인 gate를 구체화했습니다. 첫 단계는 authenticated read-only probe이며, 외부 조건이 준비되기 전 상태는 `Blocked`입니다.
