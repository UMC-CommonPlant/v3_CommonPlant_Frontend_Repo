# 테스트 작성 기준

커먼플랜트의 테스트는 빠르게 실행되는 widget/unit test를 기본 품질 게이트로 사용합니다. 새 기능은 화면이 정상적으로 렌더링되는지뿐 아니라 상태 변화와 입력 검증까지 함께 확인합니다.

## 현재 테스트 구조

```text
test/
  widget_test.dart
```

현재 테스트는 앱 루트 진입, 공용 컴포넌트 샘플 화면 표시, 닉네임 입력 검증 흐름을 확인합니다.

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

현재는 unit/widget test를 우선 작성합니다. Golden과 integration test는 QA 기준이 정해진 뒤 도입합니다.

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

## 테스트 파일 네이밍

| 대상 | 예시 |
| --- | --- |
| Widget test | `test/features/place/place_list_page_test.dart` |
| Provider test | `test/features/place/place_list_provider_test.dart` |
| Mapper test | `test/features/place/place_response_test.dart` |
| Shared widget test | `test/shared/widgets/common_button_test.dart` |

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

## 체크리스트

- [ ] 새 화면의 초기 렌더링 테스트가 있는가?
- [ ] 입력 검증 또는 버튼 상태 변화 테스트가 있는가?
- [ ] loading/empty/error 중 새로 추가한 상태를 테스트했는가?
- [ ] API mapper 또는 repository 에러 매핑 테스트가 있는가?
- [ ] Provider override가 가능하도록 의존성이 분리되어 있는가?
- [ ] 테스트가 네트워크나 실제 저장소에 의존하지 않는가?
- [ ] `fvm flutter test`를 통과하는가?

## 결정 필요

- Golden test 도입 여부와 기준 디바이스 크기를 정해야 합니다.
- Integration test 범위와 실행 환경은 MVP 핵심 플로우가 확정된 뒤 결정합니다.
