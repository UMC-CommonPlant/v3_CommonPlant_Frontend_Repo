# 테스트 작성 기준

커먼플랜트의 테스트는 빠르게 실행되는 widget/unit test를 기본 품질 게이트로 사용합니다. 새 기능은 화면이 정상적으로 렌더링되는지뿐 아니라 상태 변화와 입력 검증까지 함께 확인합니다.

MVP 단계의 필수 검증은 `fvm dart format --output=none --set-exit-if-changed .`, `fvm flutter analyze`, `fvm flutter test`입니다. Golden test와 integration test는 아래 적용 기준을 만족할 때 추가하고, 기준을 만족하기 전에는 PR 필수 게이트로 올리지 않습니다.

## 현재 테스트 구조

```text
test/
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
| Integration test | staging API, 테스트 계정, 실행 runner, 데이터 초기화 정책이 준비된 핵심 플로우에만 추가 |

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

## Unit test 기준

아래 로직은 화면 테스트보다 unit test를 우선합니다.

- DTO to entity 변환
- 날짜 포맷 변환
- enum mapping
- form validator
- usecase의 분기 로직
- repository의 에러 매핑

UI가 없어도 검증 가능한 로직은 widget test로 우회하지 않습니다.

## Golden test 기준

Golden test는 MVP 기본 필수 항목이 아닙니다. 아래 조건 중 하나 이상을 만족하고, baseline 관리 비용보다 회귀 방지 효과가 클 때 추가합니다.

- `shared/widgets`의 공용 버튼, 입력창, 카드, Dialog, Scaffold처럼 여러 feature에서 반복 사용되는 컴포넌트
- 디자인 토큰 변경 시 시각 회귀가 크게 발생할 수 있는 컴포넌트
- Figma 기준 화면과 구현 화면의 차이를 반복적으로 확인해야 하는 핵심 UI 조합

Golden test를 추가할 때는 아래 기준을 따릅니다.

- 테스트 파일은 대상 위치와 맞춰 `test/shared/widgets/common_button_golden_test.dart`처럼 둡니다.
- 기준 폭은 `AppSizes.mobileWidth`와 같은 375 logical pixel을 우선 사용합니다.
- full-screen golden은 QA 필수 디바이스 목록이 확정된 뒤 추가하고, 그 전에는 컴포넌트 단위 golden을 우선합니다.
- Pretendard font와 asset 로딩이 CI에서 재현 가능해야 합니다.
- baseline 갱신은 의도한 디자인 변경이 있는 PR에서만 `fvm flutter test --update-goldens`로 수행합니다.

Golden test가 저장소에 추가된 뒤에는 일반 `fvm flutter test`에 포함되므로, 불안정한 baseline은 커밋하지 않습니다.

## Integration test 기준

Integration test는 MVP 기본 PR 필수 게이트가 아닙니다. 아래 조건이 준비된 뒤 핵심 사용자 흐름부터 추가합니다.

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

staging API와 runner가 준비되기 전에는 integration test를 PR CI에 연결하지 않습니다. 준비 전 회귀 검증은 unit/widget test와 feature별 Provider override를 사용합니다.

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
- 여러 테스트에서 반복되는 도메인 fixture는 `test/helpers`로 분리합니다.
- 실제 API 응답 샘플이 필요한 경우 JSON fixture를 사용합니다.
- 테스트에서 네트워크를 직접 호출하지 않습니다.

## CI와 pre-commit

`lefthook.yml`의 pre-commit 검사는 아래 순서로 실행됩니다.

- format
- analyze
- test

로컬에 `.fvmrc`와 FVM이 있으면 lefthook도 `fvm` 명령을 우선 사용합니다.

GitHub Actions의 기본 CI는 PR과 push에서 `flutter pub get`, `flutter analyze`, `flutter test`를 실행합니다. Golden test가 저장소에 들어오면 `flutter test`에 포함되고, integration test는 실행 환경이 준비된 뒤 별도 workflow 또는 release candidate 검증으로 연결합니다.

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

- QA 필수 디바이스 목록이 확정되면 full-screen golden 기준 크기를 추가합니다.
- staging API, 테스트 계정, runner가 준비되면 integration test workflow를 release 검증 또는 별도 CI job으로 연결합니다.
