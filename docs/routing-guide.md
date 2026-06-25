# 라우팅 구조 설명

커먼플랜트는 `go_router`를 사용해 앱 라우팅을 관리합니다. 라우터 인스턴스는 Riverpod Provider로 주입해서 인증 상태, 딥링크, 테스트 환경에서 확장할 수 있도록 둡니다.

## 현재 구조

| 파일 | 역할 |
| --- | --- |
| `lib/app/common_plant_app.dart` | `MaterialApp.router` 구성 |
| `lib/app/router/app_router.dart` | 앱 전역 `GoRouter` Provider 정의 |
| `lib/app/router/app_routes.dart` | Figma 기준 route tree와 route metadata 정의 |
| `lib/app/router/route_paths.dart` | route name, path, location helper 상수 |
| `lib/app/router/route_placeholder_page.dart` | 새 route 추가 시 임시 진입 화면으로 사용할 fallback |
| `lib/features/home/presentation/home_screen.dart` | 인증 후 홈 화면 |
| `lib/features/*/presentation/pages` | Onboarding, Login, Terms, Place, Plant, Memo route 화면 |

현재 등록된 라우트는 Figma `phase 0` 페이지를 기준으로 route-level screen 18개입니다.

```dart
final appRouterProvider = Provider<GoRouter>(
  (ref) => createAppRouter(),
);
```

`phase 0`의 18개 route-level screen은 실제 page 위젯에 연결되어 있습니다. 새 route를 추가할 때 아직 화면 구현이 없다면 같은 route spec을 유지한 채 `RoutePlaceholderPage`를 임시로 연결하고, 기능 화면이 구현되면 builder만 실제 page로 교체합니다.

## 기본 원칙

- 라우트 정의는 `lib/app/router`에서 관리합니다.
- 화면 파일은 라우팅 정책을 직접 알지 않도록 합니다.
- 화면 이동은 임시 문자열보다 route name 또는 route path 상수를 우선 사용합니다.
- 인증 전/후 라우팅은 라우터 계층에서 분기하고, 각 화면에서 직접 인증 여부를 판단하지 않습니다.
- MVP 단계에서는 복잡한 nested route보다 읽기 쉬운 단일 route tree를 우선합니다.
- Place, Plant, Memo 상세 플로우는 URL path에 도메인 관계가 드러나도록 설계합니다.

## Figma 기준 라우트 설계

Figma 파일 `Common Plant 복제`의 `phase 0` 페이지를 기준으로 프레임 이름, 내부 대표 텍스트, 플로우 위치를 함께 확인했습니다. alert, bottom sheet, 검색 결과, 버튼 처리 결과는 별도 route가 아니라 화면 상태로 처리합니다.
정확한 Figma node-id, 상태 프레임, 구현 PR 연결은 `docs/figma-frame-map.md`를 기준으로 확인합니다.

| 도메인 | Route name | Path | Figma 근거 | 화면 역할 |
| --- | --- | --- | --- | --- |
| Home | `home` | `/` | `#2 Main`, `#2 Main/D` | 인증 후 홈, My place/My plant 요약 |
| Onboarding | `onboarding` | `/onboarding` | `#1-1` | 시작/온보딩 |
| Login | `login` | `/login` | `#1-2 Log in` | 카카오/Apple 소셜 로그인 |
| Login | `profileSetup` | `/profile/setup` | `#1-2-2 Log in` | 닉네임, 프로필 이미지 설정 |
| Terms | `terms` | `/terms/privacy` | `#1-2-3 Sign up / 2D` | 개인정보 이용약관 |
| Place | `placeInvitations` | `/places/invitations` | `#2-2 Main / 장소 친구 요청` | 장소 초대 요청 목록 |
| Place | `placeCreate` | `/places/new` | `#2-2-2 장소 등록` | 장소 등록 |
| Place | `addressSearch` | `/places/new/address-search` | `#2-2-2-2 장소 등록 / 주소 검색` | 장소 등록 중 주소 검색 |
| Place | `placeFriendAdd` | `/places/new/friends` | `#2-2-2-2 장소 등록-친구 추가` | 장소 등록 중 친구 추가 |
| Place | `placeEdit` | `/places/:placeId/edit` | `#2-2-2 장소 수정` | 장소 수정 |
| Place | `placeDetail` | `/places/:placeId` | `#2-3 My place 리더화면`, `팀원화면` | 장소 상세 |
| Place | `friendManagement` | `/places/:placeId/friends` | `#2-3-2 친구 관리` | 장소 친구 관리 |
| Plant | `plantSearch` | `/plants/new/search` | `#2-2-3 식물 등록` | 식물 등록 1단계, 식물 검색 |
| Plant | `plantCreateDetails` | `/plants/new/details` | `#2-2-3-2 식물 등록` | 식물 등록 2단계, 상세 정보 입력 |
| Plant | `plantEdit` | `/plants/:plantId/edit` | `#2-2-3-3 식물 수정` | 식물 수정 |
| Plant | `plantDetail` | `/plants/:plantId` | `#2-4 My plants` | 식물 상세 |
| Memo | `memoWrite` | `/plants/:plantId/memos/new` | `#2-4-2 메모 작성` | 식물 메모 작성 |
| Memo | `memoList` | `/plants/:plantId/memos` | `#2-4-3 메모` | 식물 메모 목록 |

Place 상세/수정/친구 관리는 `placeId`를 path에 포함합니다. Plant 상세/수정/Memo 플로우는 `plantId` 중심으로 둡니다. 식물 등록은 Figma상 먼저 식물을 검색하고 다음 단계에서 장소를 고르는 흐름이므로 `/plants/new/*` 아래에 둡니다.

## Route가 아닌 상태

아래 Figma 프레임은 별도 route로 만들지 않고 해당 화면의 상태, dialog, bottom sheet로 처리합니다.

| 상태 | 소속 화면 | 처리 기준 |
| --- | --- | --- |
| 로그인 필요 안내 | Home | 홈의 비인증 상태 |
| 프로필 사진 선택 | Profile setup | bottom sheet 또는 dialog |
| 장소 요청 버튼 결과 | Place invitations | 요청 목록 item 상태 |
| 주소 검색 결과 | Address search | 검색 결과/empty 상태 |
| 친구 검색 과정 | Place friend add, Friend management | 검색 결과/선택 상태 |
| 친구 삭제 alert | Friend management | dialog |
| 장소 나가기 alert | Place detail | dialog |
| 식물 검색 결과 | Plant search | 검색 결과 상태 |
| 장소/날짜 선택 | Plant create details | picker 또는 bottom sheet 상태 |
| 메모 수정/삭제 메뉴 | Memo list | popup/action sheet |
| 메모 삭제 alert | Memo list | dialog |

## 파일 배치 기준

라우트 정의가 커지면 아래처럼 분리합니다.

```text
lib/app/router/
  app_route_spec.dart
  app_router.dart
  app_routes.dart
  route_paths.dart
  route_placeholder_page.dart
  redirect_notifier.dart
```

| 파일 | 역할 |
| --- | --- |
| `app_route_spec.dart` | route metadata 모델 |
| `app_router.dart` | `GoRouter` 생성과 route tree 조립 |
| `app_routes.dart` | route name, route builder, shell route 정의 |
| `route_paths.dart` | path 문자열 상수 |
| `route_placeholder_page.dart` | 미구현 route의 임시 화면 |
| `redirect_notifier.dart` | 인증 상태 변경 시 router refresh 연결 |

작은 MVP 화면에서도 Figma 기준 라우트가 이미 18개로 확정되었기 때문에 route spec과 path 상수는 분리해서 관리합니다.

## 인증 라우팅 기준

인증 기능이 들어오면 아래 방향으로 확장합니다.

1. 인증 상태 Provider를 `appRouterProvider`에서 watch합니다.
2. 로그인 전 접근 가능한 route, 회원가입 진행 route, 로그인 후 route를 route policy로 분리합니다.
3. 인증 토큰은 `flutter_secure_storage` 기반 저장소를 통해 관리하되, 라우터는 token storage에 직접 접근하지 않고 인증 Provider의 상태만 봅니다.
4. access token 만료, refresh 실패, 로그아웃은 인증 Provider 상태를 `unauthenticated`로 바꾸고, 라우터 redirect에서 `/login`으로 이동시킵니다.
5. 로그인 성공 후에는 사용자가 원래 접근하려던 위치로 복귀할 수 있도록 redirect target을 보존합니다.

인증 판단을 개별 화면의 `initState`나 `build`에서 처리하지 않습니다.

### Auth redirect Provider 설계

현재 `appRouterProvider`는 `createAppRouter()`만 반환하며 인증 상태를 watch하지 않습니다. 인증 redirect 구현 PR에서는 아래 파일 경계를 목표로 둡니다.

| 파일 | 역할 |
| --- | --- |
| `features/login/presentation/providers/auth_state_provider.dart` | 앱 전역 인증 상태를 `checking`, `unauthenticated`, `signupRequired`, `authenticated`처럼 표현합니다. |
| `app/router/route_access_policy.dart` | route name별 접근 정책을 공개, 회원가입 진행, 인증 필요로 분류합니다. |
| `app/router/redirect_notifier.dart` | 인증 Provider 변경을 `GoRouter.refreshListenable`로 연결합니다. |
| `app/router/app_router.dart` | 인증 상태와 현재 location을 기준으로 redirect target을 계산합니다. |

라우터 redirect는 아래 순서를 따릅니다.

1. 인증 상태가 `checking`이면 현재 위치를 유지합니다.
2. 공개 route는 인증 여부와 관계없이 진입을 허용합니다.
3. `signupRequired` 상태에서는 `profileSetup`, `terms` route만 허용하고 그 외 route는 `/profile/setup`으로 보냅니다.
4. `unauthenticated` 상태에서 공개 route가 아닌 route에 접근하면 `/login`으로 보내며, 원래 location은 redirect target으로 보존합니다.
5. `authenticated` 상태에서 공개 route나 회원가입 진행 route에 접근하면 보존된 redirect target 또는 `/`로 보냅니다.

초기 route policy는 아래처럼 둡니다.

| 정책 | Route name |
| --- | --- |
| 공개 route | `onboarding`, `login` |
| 회원가입 진행 route | `profileSetup`, `terms` |
| 인증 필요 route | `home`, `placeInvitations`, `placeCreate`, `addressSearch`, `placeFriendAdd`, `placeEdit`, `placeDetail`, `friendManagement`, `plantSearch`, `plantCreateDetails`, `plantEdit`, `plantDetail`, `memoWrite`, `memoList` |

`TOKEN-01`, `TOKEN-02`가 답변되기 전까지 refresh token 재발급과 서버 로그아웃 invalidation은 redirect 구현 범위에 넣지 않습니다. 그 전에는 토큰이 없거나 명시적으로 clear된 경우만 `unauthenticated`로 전환합니다.

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
