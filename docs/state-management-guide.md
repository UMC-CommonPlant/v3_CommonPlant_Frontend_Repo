# 상태관리 Provider 작성 기준

커먼플랜트는 `flutter_riverpod`를 상태관리와 의존성 주입의 기본 도구로 사용합니다. 앱 루트는 `ProviderScope`로 감싸져 있고, 라우터도 Provider로 관리합니다.

## 현재 구조

| 파일 | 내용 |
| --- | --- |
| `lib/main.dart` | `ProviderScope` 적용 |
| `lib/app/router/app_router.dart` | `appRouterProvider` 정의 |
| `lib/features/place/presentation/providers` | Place 목록/상세/form/action Provider와 Controller |
| `lib/features/plant/presentation/providers` | Plant 목록/상세/form/action Provider와 Controller |
| `lib/features/memo/presentation/providers` | local Memo 목록 상태 Provider |

## 기본 원칙

- 서버 상태와 UI 입력 상태를 구분합니다.
- 전역 상태는 인증, 라우팅, 사용자 세션처럼 앱 전체에 필요한 것만 둡니다.
- feature 내부 상태는 feature의 `presentation/providers`에 둡니다.
- route page는 `ConsumerWidget`을 기본으로 하고 화면 동작 상태를 직접 소유하지 않습니다.
- 화면 위젯에서 API 호출, JSON 파싱, 에러 매핑을 직접 하지 않습니다.
- 비동기 상태는 loading, success, empty, error가 명확해야 합니다.
- Provider는 화면 rebuild 범위를 고려해 필요한 값만 watch합니다.

## Provider 선택 기준

| 상황 | 권장 Provider |
| --- | --- |
| 변하지 않는 의존성 주입 | `Provider` |
| 단순 파생 값 | `Provider` |
| 단일 primitive 화면 입력 상태 | `StateProvider` |
| 여러 값과 규칙이 묶인 화면 상태 | `NotifierProvider`, `AsyncNotifierProvider` |
| API 호출 결과 | `FutureProvider`, `AsyncNotifierProvider` |
| 사용자 액션으로 상태 전이가 많음 | `NotifierProvider`, `AsyncNotifierProvider` |
| 앱 전역 인증 상태 | 별도 Auth Provider |

입력 필드의 `TextEditingController`, `FocusNode`처럼 위젯 생명주기에 밀접한 객체는 작은 form/leaf StatefulWidget에서 관리합니다. 검색어, 선택값, 폼 draft, 제출, 검증, API 호출처럼 화면 동작을 설명하는 상태는 Controller Provider로 분리합니다.

## StatefulWidget과 Riverpod 경계

feature route page는 기본적으로 `ConsumerWidget`으로 작성합니다. StatefulWidget은 없애는 것 자체가 목표가 아니라 Flutter 객체 생명주기를 캡슐화하는 용도로 제한합니다.

Riverpod으로 이동하는 상태:

- 검색 query와 필터 결과
- 선택 ID와 선택된 domain/presentation model
- form draft와 initial/current 비교
- 이미지 선택 여부처럼 사용자 동작으로 바뀌는 값
- loading, submitting, success, failure
- `canSubmit`, `hasChanges`처럼 관련 상태에서 계산되는 값

leaf StatefulWidget에 남기는 상태:

- `TextEditingController`
- `FocusNode`
- `AnimationController`
- `ScrollController`, `PageController`
- 공용 위젯 내부의 포커스와 일시적 시각 interaction

Provider state에는 위 Flutter 객체나 `BuildContext`, widget instance를 저장하지 않습니다. leaf widget은 callback으로 문자열과 사용자 event만 Controller에 전달합니다.

화면을 나가면 폐기되어야 하는 form/search/selection Provider는 `autoDispose`를 우선하고, route argument마다 별도 상태가 필요한 경우 `family`를 사용합니다. 관련 필드를 Provider 하나씩 흩뜨리지 않고 이름 있는 불변 State로 묶습니다.

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
- dialog, snackbar, navigation처럼 `BuildContext`가 필요한 UI effect를 수행합니다.

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

### Auth state Provider 설계

인증 상태는 token 문자열 자체보다 앱이 판단해야 하는 route 상태를 중심으로 표현합니다.

| 상태 | 의미 | 라우터 처리 |
| --- | --- | --- |
| `checking` | 앱 시작 시 secure storage 또는 세션 복원 확인 중 | 현재 location 유지 |
| `unauthenticated` | 유효한 로그인 세션이 없음 | 인증 필요 route를 `/login`으로 redirect |
| `signupRequired` | 로그인은 성공했지만 신규 유저 프로필 설정이 필요함 | `profileSetup`, `terms` 외 route를 `/profile/setup`으로 redirect |
| `authenticated` | 홈과 도메인 화면에 접근 가능한 세션 | 공개/회원가입 route 진입 시 `/` 또는 보존된 target으로 redirect |

Provider 책임은 아래처럼 나눕니다.

| 대상 | 책임 |
| --- | --- |
| `AuthTokenStore` | access token, refresh token의 저장/읽기/삭제만 담당합니다. UI나 라우터 상태를 알지 않습니다. |
| `AuthInterceptor` | 요청 직전 access token을 `Authorization: Bearer ...` header에 첨부합니다. redirect를 직접 수행하지 않습니다. |
| `authStateProvider` | token store와 로그인/회원가입 결과를 바탕으로 앱 인증 상태를 노출합니다. |
| 로그인/회원가입 Controller | repository 호출, token 저장, `signupRequired` 또는 `authenticated` 전환을 담당합니다. |
| 로그아웃 Controller | 로컬 token clear 후 `unauthenticated`로 전환합니다. 서버 로그아웃 API는 `TOKEN-02` 답변 후 추가합니다. |

`authStateProvider`는 테스트에서 override할 수 있어야 하며, router test는 `unauthenticated`, `signupRequired`, `authenticated` 상태별 redirect를 직접 검증합니다.

`TOKEN-01` refresh API가 확정되기 전까지 access token 만료 자동 복구는 구현하지 않습니다. 401 응답을 받은 뒤 token을 갱신하는 interceptor 재시도 정책은 백엔드 endpoint와 error code가 확정된 뒤 별도 이슈에서 다룹니다.

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
- route page의 `setState`로 검색, 선택, 폼, 제출 상태를 관리하지 않습니다.
- field별 Provider를 과도하게 만들어 한 화면의 상태를 흩뜨리지 않습니다.
- `TextEditingController`, `FocusNode`, `BuildContext`를 Provider state에 저장하지 않습니다.
- Provider 내부에서 UI 위젯이나 `BuildContext`에 의존하지 않습니다.
- API 에러 문자열을 화면에서 switch하지 않습니다.
- `ref.watch`를 과하게 넓은 위젯에서 호출해 불필요한 rebuild를 만들지 않습니다.

## 체크리스트

- [ ] Provider 위치가 feature 책임에 맞는가?
- [ ] route page가 `ConsumerWidget`이며 화면 동작 mutable state를 소유하지 않는가?
- [ ] StatefulWidget이 남아 있다면 Flutter 생명주기 객체 소유 이유가 분명한가?
- [ ] 관련 화면 상태가 이름 있는 불변 State로 묶였는가?
- [ ] route 범위 상태에 `autoDispose`/`family`가 적절히 적용됐는가?
- [ ] loading/success/empty/error가 화면에 반영되는가?
- [ ] API 호출과 파싱이 화면 밖에 있는가?
- [ ] 재시도 또는 새로고침 경로가 있는가?
- [ ] 버튼 중복 탭 방지 상태가 있는가?
- [ ] Provider 이름이 도메인과 역할을 설명하는가?
- [ ] 테스트에서 Provider override가 가능한 구조인가?

## 결정 필요

- API 공통 에러 타입과 사용자 메시지 매핑 기준이 필요합니다.
- Riverpod code generation 사용 여부는 아직 정해지지 않았습니다.
