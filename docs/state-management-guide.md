# 상태관리 Provider 작성 기준

커먼플랜트는 `flutter_riverpod`를 상태관리와 의존성 주입의 기본 도구로 사용합니다. 앱 루트는 `ProviderScope`로 감싸져 있고, 라우터도 Provider로 관리합니다.

## 현재 구조

| 파일 | 내용 |
| --- | --- |
| `lib/main.dart` | `ProviderScope` 적용 |
| `lib/app/router/app_router.dart` | `appRouterProvider` 정의 |
| `lib/features/home/presentation/home_screen.dart` | 샘플 문자열 Provider 사용 |

## 기본 원칙

- 서버 상태와 UI 입력 상태를 구분합니다.
- 전역 상태는 인증, 라우팅, 사용자 세션처럼 앱 전체에 필요한 것만 둡니다.
- feature 내부 상태는 feature의 `presentation/providers`에 둡니다.
- 화면 위젯에서 API 호출, JSON 파싱, 에러 매핑을 직접 하지 않습니다.
- 비동기 상태는 loading, success, empty, error가 명확해야 합니다.
- Provider는 화면 rebuild 범위를 고려해 필요한 값만 watch합니다.

## Provider 선택 기준

| 상황 | 권장 Provider |
| --- | --- |
| 변하지 않는 의존성 주입 | `Provider` |
| 단순 파생 값 | `Provider` |
| 일회성 화면 입력 상태 | `StateProvider` 또는 StatefulWidget 내부 state |
| API 호출 결과 | `FutureProvider`, `AsyncNotifierProvider` |
| 사용자 액션으로 상태 전이가 많음 | `NotifierProvider`, `AsyncNotifierProvider` |
| 앱 전역 인증 상태 | 별도 Auth Provider |

입력 필드의 `TextEditingController`, `FocusNode`처럼 위젯 생명주기에 밀접한 객체는 화면 또는 form widget에서 관리해도 됩니다. 제출, 검증, API 호출처럼 화면을 벗어나는 로직은 Controller Provider로 분리합니다.

## 권장 파일 배치

```text
lib/features/plant/
  presentation/
    pages/
      plant_detail_page.dart
    providers/
      plant_detail_provider.dart
      plant_create_controller.dart
    widgets/
```

Provider 파일이 커지면 read provider와 write controller를 분리합니다.

## 상태 모델 기준

서버 데이터를 표시하는 화면은 최소한 아래 상태를 표현할 수 있어야 합니다.

| 상태 | 의미 |
| --- | --- |
| Loading | 최초 로딩 또는 명시적 새로고침 중 |
| Success | 표시할 데이터가 있음 |
| Empty | 요청은 성공했지만 표시할 데이터가 없음 |
| Error | 복구 가능한 실패가 있음 |

Riverpod의 `AsyncValue<T>`를 사용하면 loading/error/data를 기본으로 표현할 수 있습니다. empty는 data 내부 값이 비어 있는지 확인해 별도 UI로 분기합니다.

## 화면에서의 사용 기준

좋은 예시:

```dart
final plants = ref.watch(placePlantsProvider(placeId));
```

화면은 Provider의 상태를 보고 위젯을 선택합니다.

```dart
return plants.when(
  loading: () => const PlantListLoadingView(),
  error: (error, stackTrace) => PlantListErrorView(onRetry: retry),
  data: (items) {
    if (items.isEmpty) {
      return const PlantListEmptyView();
    }

    return PlantListView(items: items);
  },
);
```

API 호출 결과를 `build` 안에서 직접 await하거나, 화면에서 DTO의 raw JSON을 파싱하지 않습니다.

## Controller 기준

생성, 수정, 삭제처럼 사용자 액션으로 상태가 바뀌는 기능은 Controller를 둡니다.

Controller 책임:

- 현재 제출 중인지 관리합니다.
- 입력값 검증 결과를 반영합니다.
- repository를 호출합니다.
- 실패를 사용자용 에러 상태로 변환합니다.
- 성공 후 route 이동 또는 Provider invalidate를 호출할 수 있게 결과를 반환합니다.

화면 책임:

- Controller 상태를 watch합니다.
- 버튼 disabled/loading UI를 표시합니다.
- 성공 결과에 따라 route 이동이나 안내를 수행합니다.

## 인증 상태 기준

인증 기능은 `authStateProvider`와 보안 토큰 저장소를 분리합니다.

```text
lib/features/login/
  data/
    datasources/
      auth_local_data_source.dart
      auth_remote_data_source.dart
    repositories/
  presentation/
    providers/
      auth_state_provider.dart
```

- 토큰 저장은 `flutter_secure_storage`를 기본으로 사용합니다.
- access token과 refresh token의 읽기/쓰기는 local datasource로 캡슐화합니다.
- 라우터는 인증 Provider의 결과만 보고 redirect하며, storage에 직접 접근하지 않습니다.
- refresh 실패 또는 로그아웃 시 인증 상태를 unauthenticated로 전환합니다.

## Provider 네이밍

| 대상 | 예시 |
| --- | --- |
| 목록 조회 | `placeListProvider` |
| 상세 조회 | `plantDetailProvider` |
| 생성 controller | `placeCreateControllerProvider` |
| 수정 controller | `memoEditControllerProvider` |
| 전역 인증 | `authStateProvider` |

Provider 이름은 feature와 역할을 함께 드러냅니다.

## 금지 패턴

- 화면마다 서로 다른 상태관리 패턴을 도입하지 않습니다.
- 단순 화면 state를 모두 전역 Provider로 올리지 않습니다.
- Provider 내부에서 UI 위젯이나 `BuildContext`에 의존하지 않습니다.
- API 에러 문자열을 화면에서 switch하지 않습니다.
- `ref.watch`를 과하게 넓은 위젯에서 호출해 불필요한 rebuild를 만들지 않습니다.

## 체크리스트

- [ ] Provider 위치가 feature 책임에 맞는가?
- [ ] loading/success/empty/error가 화면에 반영되는가?
- [ ] API 호출과 파싱이 화면 밖에 있는가?
- [ ] 재시도 또는 새로고침 경로가 있는가?
- [ ] 버튼 중복 탭 방지 상태가 있는가?
- [ ] Provider 이름이 도메인과 역할을 설명하는가?
- [ ] 테스트에서 Provider override가 가능한 구조인가?

## 결정 필요

- API 공통 에러 타입과 사용자 메시지 매핑 기준이 필요합니다.
- Riverpod code generation 사용 여부는 아직 정해지지 않았습니다.
