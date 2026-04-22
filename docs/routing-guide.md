# 라우팅 구조 설명

커먼플랜트는 `go_router`를 사용해 앱 라우팅을 관리합니다. 라우터 인스턴스는 Riverpod Provider로 주입해서 인증 상태, 딥링크, 테스트 환경에서 확장할 수 있도록 둡니다.

## 현재 구조

| 파일 | 역할 |
| --- | --- |
| `lib/app/common_plant_app.dart` | `MaterialApp.router` 구성 |
| `lib/app/router/app_router.dart` | 앱 전역 `GoRouter` Provider 정의 |
| `lib/features/home/presentation/home_screen.dart` | 현재 초기 화면 및 공용 컴포넌트 샘플 |

현재 등록된 라우트는 `/` 하나입니다.

```dart
final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    ],
  ),
);
```

## 기본 원칙

- 라우트 정의는 `lib/app/router`에서 관리합니다.
- 화면 파일은 라우팅 정책을 직접 알지 않도록 합니다.
- 화면 이동은 임시 문자열보다 route name 또는 route path 상수를 우선 사용합니다.
- 인증 전/후 라우팅은 라우터 계층에서 분기하고, 각 화면에서 직접 인증 여부를 판단하지 않습니다.
- MVP 단계에서는 복잡한 nested route보다 읽기 쉬운 단일 route tree를 우선합니다.
- Place, Plant, Memo 상세 플로우는 URL path에 도메인 관계가 드러나도록 설계합니다.

## 권장 라우트 설계

아직 화면이 구현되지 않았기 때문에 아래는 다음 기능 개발 시 기준으로 사용할 권장안입니다.

| 도메인 | Path 예시 | 화면 역할 |
| --- | --- | --- |
| Home | `/` | 인증 후 진입하는 홈 또는 임시 컴포넌트 샘플 |
| Login | `/login` | 로그인 및 회원가입 진입 |
| Place 목록 | `/places` | 사용자가 속한 장소 목록 |
| Place 생성 | `/places/new` | 장소 생성 |
| Place 상세 | `/places/:placeId` | 장소 상세 및 장소 내 식물 목록 |
| Plant 생성 | `/places/:placeId/plants/new` | 특정 장소에 식물 등록 |
| Plant 상세 | `/plants/:plantId` | 식물 상세 정보 |
| Memo 목록 | `/plants/:plantId/memos` | 특정 식물의 메모 목록 |
| Memo 작성 | `/plants/:plantId/memos/new` | 특정 식물의 메모 작성 |

Place와 Plant 관계가 필요한 화면은 `placeId`를 path에 포함하고, 식물 자체의 독립 상세 화면은 `plantId` 중심으로 둡니다.

## 파일 배치 기준

라우트 정의가 커지면 아래처럼 분리합니다.

```text
lib/app/router/
  app_router.dart
  app_routes.dart
  route_paths.dart
  redirect_notifier.dart
```

| 파일 | 역할 |
| --- | --- |
| `app_router.dart` | `GoRouter` 생성과 route tree 조립 |
| `app_routes.dart` | route name, route builder, shell route 정의 |
| `route_paths.dart` | path 문자열 상수 |
| `redirect_notifier.dart` | 인증 상태 변경 시 router refresh 연결 |

작은 MVP 화면에서는 `app_router.dart` 안에 유지해도 됩니다. 같은 path 문자열이 두 곳 이상 반복되기 시작하면 상수 분리를 진행합니다.

## 인증 라우팅 기준

인증 기능이 들어오면 아래 방향으로 확장합니다.

1. 인증 상태 Provider를 `app_routerProvider`에서 watch합니다.
2. 로그인 전 접근 가능한 route와 로그인 후 route를 `/login`, `/` 기준으로 분리합니다.
3. 인증 토큰은 `flutter_secure_storage` 기반 저장소를 통해 관리합니다.
4. access token 만료, refresh 실패, 로그아웃은 라우터 redirect에서 `/login`으로 이동시킵니다.
5. 로그인 성공 후에는 사용자가 원래 접근하려던 위치로 복귀할 수 있도록 redirect target을 보존합니다.

인증 판단을 개별 화면의 `initState`나 `build`에서 처리하지 않습니다.

## 화면 이동 기준

| 상황 | 권장 방식 |
| --- | --- |
| 탭 전환 또는 최상위 이동 | `context.go(...)` |
| 생성/수정 화면처럼 되돌아갈 화면이 명확함 | `context.push(...)` |
| 저장 완료 후 이전 화면 갱신이 필요함 | `context.pop(result)` 또는 상태 Provider invalidate |
| 로그인 완료 후 홈 진입 | `context.go(...)` |

## 새 라우트 추가 체크리스트

- [ ] route path가 도메인 관계를 드러내는가?
- [ ] route name 또는 path 상수로 이동하는가?
- [ ] 필요한 path parameter를 화면 생성자에서 명확히 받는가?
- [ ] `state.pathParameters`를 화면 내부 여러 곳에서 직접 읽지 않는가?
- [ ] 인증 필요 여부가 라우터 정책에 반영되어 있는가?
- [ ] deep link로 진입했을 때 필요한 초기 데이터 로딩 경로가 있는가?
- [ ] 위젯 테스트에서 최소 진입 화면이 깨지지 않는가?

## 결정 필요

- 하단 탭이 들어갈 경우 `ShellRoute` 또는 단순 탭 상태 중 어떤 구조를 사용할지 화면 범위 확정 후 결정해야 합니다.
- 외부 딥링크 scheme, universal link 도메인, 공유 링크 정책은 아직 확정되지 않았습니다.
