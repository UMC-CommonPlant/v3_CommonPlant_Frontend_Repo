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
| `lib/features/*/presentation/pages` | Onboarding, Login, Terms, Place, Plant, Memo, User route 화면 |

현재 등록된 라우트는 Figma `phase 0`과 User 후속 화면을 기준으로 route-level screen 21개입니다.

```dart
final appRouterProvider = Provider<GoRouter>(
  (ref) => createAppRouter(),
);
```

21개 route-level screen은 실제 page 위젯에 연결되어 있습니다. 새 route를 추가할 때 아직 화면 구현이 없다면 같은 route spec을 유지한 채 `RoutePlaceholderPage`를 임시로 연결하고, 기능 화면이 구현되면 builder만 실제 page로 교체합니다.

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
| Login | `login` | `/login` | `#1-2 Log in` | Kakao·Google 로그인, iOS에서만 Apple 로그인 |
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
| User | `userProfile` | `/me` | `04 마이페이지 - 메인` | 현재 사용자 정보와 My 탭 |
| User | `userSettings` | `/me/settings` | `#4-3설정` | 알림 설정, 로그아웃, 회원 탈퇴 |
| User | `userProfileEdit` | `/me/edit` | `#4 -2 수정` | 이름과 프로필 이미지 수정 진입 |

Place 상세/수정/친구 관리는 `placeId`를 path에 포함합니다. Plant 상세/수정/Memo 플로우는 `plantId` 중심으로 둡니다. 식물 등록은 Figma상 먼저 식물을 검색하고 다음 단계에서 장소를 고르는 흐름이므로 `/plants/new/*` 아래에 둡니다.

Plant 상세·수정의 optional query `placeId`는 장소 상세에서 전달받은 실제 장소 code입니다. route 이름은 유지하며, 원격 수정 Controller는 공백을 제거한 code를 필수로 확인해 API의 `placeCode` query로 전송합니다. #252에서 null·빈 값·공백은 기존 상태 화면과 홈→장소→식물 재진입 안내로 처리합니다. 현재 Plant 조회 응답에는 code가 없어 장소명이나 fixture로 복원하지 않습니다. API 비사용 모드의 code 없는 로컬 수정은 유지합니다([검증·제한](work-history/plant-edit-place-code-252.md)).

장소 생성 뒤 친구 추가 화면으로 이동할 때는
`/places/new/friends?placeCode={생성된 code}`를 사용합니다. `placeCode`는 route
path를 늘리지 않고 생성 직후의 후속 요청 문맥을 보존하는 optional query이며,
직접 route 진입과 API 비사용 화면 테스트에서는 없을 수 있습니다. 친구 요청
전송을 연결할 때는 이 query를 임의의 장소 id로 대체하지 않습니다.

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
| 알림 토글 | User settings | API 부재로 화면 세션의 Provider 상태 |
| 로그아웃·회원 탈퇴 확인 | User settings | dialog, 성공 후 인증 Provider가 로그인 route로 redirect |
| 프로필 이미지 선택 | User profile edit | 파일 선택·플랫폼 권한 정책 확정 후 연결, 현재는 진입 안내 상태 |

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

작은 MVP 화면에서도 Figma 기준 라우트가 이미 21개로 확정되었기 때문에 route spec과 path 상수는 분리해서 관리합니다.

## 앱 초기 진입과 온보딩 정책

#287에서 정한 정책을 #289에서 연결했습니다. 온보딩 완료 여부는 계정이나 인증 token과
분리된 `SharedPreferencesAsync` 로컬 값으로 관리합니다. 화면을 한 번 표시한 시점이 아니라
사용자가 `시작하기`를 눌러 온보딩을 완료한 시점에 값을 저장합니다.

초기 진입은 다음 순서를 따릅니다.

1. 로컬 온보딩 완료 값을 확인하는 동안 초기 route 결정을 보류합니다.
2. 값이 없거나 `false`이면 `/onboarding`을 표시합니다.
3. `true`이면 인증 세션 복원으로 넘어갑니다.
4. 온보딩 완료 뒤에는 기존 인증 route policy를 사용합니다. 비인증이면 `/login`, 인증
   세션이 복원됐으면 보존된 target 또는 `/`로 이동합니다.

`OnboardingLocalStore`는 로컬 bool 읽기·쓰기만 담당하고
`onboardingControllerProvider`가 초기 확인과 완료 저장 상태를 관리합니다. 라우터는 이
Provider의 결과만 사용하며 preferences에 직접 접근하지 않습니다. 저장 중에는 시작 버튼을
잠그고, 저장 실패 시 온보딩에 머물러 안내한 뒤 다시 시도할 수 있습니다. 보호 route에서
최초 진입한 경우에는 `redirect` query를 온보딩에서 로그인까지 보존합니다.

이 값은 사용자 계정에 귀속하지 않고 secure token 저장소에도 넣지 않습니다. 앱 업데이트와
일반 재실행에는 값을 유지합니다. 앱 삭제·재설치 때 로컬 값이 삭제되면 온보딩을 다시
표시하지만, OS 백업에서 앱 데이터가 복원돼 값이 돌아온 경우까지 강제로 다시 표시할지는
아직 결정하지 않았습니다. 따라서 현재 요구사항을 `설치 횟수` 판별로 표현하지 않고
`로컬 완료 값이 없는 실행`으로 정의합니다. 구현 이슈에서는 신규 설치, 앱 데이터 삭제,
재설치와 백업 복원 시나리오를 따로 검증합니다.

## 인증 라우팅 기준

인증 기능은 아래 구조로 연결합니다.

1. 인증 상태 Provider를 `appRouterProvider`에서 listen하고 router refresh에 연결합니다.
2. 로그인 전 접근 가능한 route, 회원가입 진행 route, 로그인 후 route를 route policy로 분리합니다.
3. 인증 토큰은 `flutter_secure_storage` 기반 저장소를 통해 관리하되, 라우터는 token storage에 직접 접근하지 않고 인증 Provider의 상태만 봅니다.
4. 확인된 access token 오류와 로그아웃은 인증 Provider 상태를 `unauthenticated`로 바꾸고, 라우터 redirect에서 `/login`으로 이동시킵니다.
5. 로그인 성공 후에는 사용자가 원래 접근하려던 위치로 복귀할 수 있도록 redirect target을 보존합니다.
6. 별도 회원가입 시작 route는 만들지 않습니다. `/auth/login`의 `isNewUser: true` 결과만 `profileSetup`으로 보내고, `false`는 인증 완료 route로 보냅니다.
7. Apple 로그인 버튼과 SDK 호출은 iOS에서만 제공하며 Android에는 Apple route나 빈 버튼 영역을 만들지 않습니다.

인증 판단을 개별 화면의 `initState`나 `build`에서 처리하지 않습니다.

### Auth redirect Provider 설계

`appRouterProvider`는 인증 세션 변경을 listen하고 `RouterRefreshNotifier`로 GoRouter redirect를 다시 평가합니다. 현재 파일 경계는 아래와 같습니다.

| 파일 | 역할 |
| --- | --- |
| `features/login/presentation/providers/auth_session_controller.dart` | 앱 시작 token 복원과 로그인/회원가입 결과에 따른 세션 전환을 담당합니다. |
| `features/login/presentation/providers/auth_session_state.dart` | 앱 전역 인증 상태를 `unauthenticated`, `signupRequired`, `authenticated`로 표현합니다. Provider loading을 `checking`으로 사용합니다. |
| `features/onboarding/presentation/providers/onboarding_controller.dart` | 로컬 온보딩 완료 값 확인과 완료 저장 상태를 담당합니다. |
| `app/router/auth_route_policy.dart` | 현재 URI와 온보딩·인증 상태를 기준으로 redirect location을 계산합니다. |
| `app/router/redirect_notifier.dart` | 인증 Provider 변경을 `GoRouter.refreshListenable`로 연결합니다. |
| `app/router/app_router.dart` | 인증 상태와 현재 location을 기준으로 redirect target을 계산합니다. |

라우터 redirect는 아래 순서를 따릅니다.

1. 온보딩 완료 값을 확인 중이면 현재 위치를 유지합니다.
2. 완료 값이 없거나 `false`이면 인증 상태와 관계없이 `/onboarding`으로 보내며 원래
   location을 redirect target으로 보존합니다.
3. 온보딩이 완료됐지만 인증 상태가 `checking`이면 현재 위치를 유지합니다.
4. 비인증 공개 route는 `login`이며, `signupRequired` 상태에서는 `profileSetup`, `terms`만 허용합니다.
5. `unauthenticated` 상태에서 로그인 외 route에 접근하면 `/login`으로 보내며 보존된 target을 유지합니다.
6. `authenticated` 상태에서 로그인·온보딩·회원가입 진행 route에 접근하면 보존된 target 또는 `/`로 보냅니다.

초기 route policy는 아래처럼 둡니다.

| 정책 | Route name |
| --- | --- |
| 초기 진입 gate | `onboarding` |
| 비인증 공개 route | `login` |
| 회원가입 진행 route | `profileSetup`, `terms` |
| 인증 필요 route | `home`, `placeInvitations`, `placeCreate`, `addressSearch`, `placeFriendAdd`, `placeEdit`, `placeDetail`, `friendManagement`, `plantSearch`, `plantCreateDetails`, `plantEdit`, `plantDetail`, `memoWrite`, `memoList`, `userProfile`, `userSettings`, `userProfileEdit` |

active access-token 요청에서 확인된 `A003`, `A004`, `A009`가 오면 #275의 세션 Controller가 현재 사용자 데이터 세션을 먼저 닫고 `unauthenticated(expired)`로 전환합니다. 라우터는 기존 정책으로 `/login`에 이동하고 로그인 화면은 만료 이유를 안내합니다. 이전 계정의 늦은 오류는 현재 세션을 바꾸지 않습니다.

`TOKEN-01`은 backend #149에서 답변 대기 중입니다. API가 제공되면 access token 없이
refresh token만 남은 초기 상태에서 곧바로 로그인으로 보내지 않고 갱신을 먼저 시도합니다.
현재는 endpoint가 없어 기존처럼 부분 token을 삭제하고 `unauthenticated`로 전환합니다.
서버 로그아웃과 invalidation(`TOKEN-02`)은 현재 우선순위에서 제외하며, 기존 로컬
로그아웃·clear 동작은 바꾸지 않습니다.

#249부터 로그아웃·탈퇴 성공 시 저장소 삭제 완료를 기다리기 전에 인증 상태와 사용자 데이터 세션을 닫습니다. 기존 redirect 규칙은 그대로 사용하며, 느린 token 삭제 완료나 이전 계정의 요청 결과가 새 인증 상태를 변경하지 않도록 Controller에서 검사합니다. 데이터 수명은 [상태관리의 세션 격리 기준](state-management-guide.md#사용자-데이터-세션-격리)을 따릅니다.

## 화면 이동 기준

| 상황 | 권장 방식 |
| --- | --- |
| 탭 전환 또는 최상위 이동 | `context.go(...)` |
| 생성/수정 화면처럼 되돌아갈 화면이 명확함 | `context.push(...)` |
| 저장 완료 후 이전 화면 갱신이 필요함 | `context.pop(result)` 또는 상태 Provider invalidate |
| 로그인 완료 후 홈 진입 | `context.go(...)` |

### 주소 선택 반환 계약

장소 생성·수정은 기존 `/places/new/address-search`를 `push<AddressSearchResult>`로 열고 선택 시 같은 모델을 `pop` 결과로 받습니다. 뒤로 가기·취소는 `null`이며, 표시용 제목이 아닌 `address`를 폼에 반영합니다. route path나 query는 추가하지 않습니다.

`AddressSearchResult.source`는 `fixture`와 `searchService`를 구분합니다. API 모드의 기본 검색은 아직 미연결 안내만 표시하며 fixture 결과를 반환하지 않습니다. 폼 Controller에서도 API 모드의 fixture·빈 주소를 거부합니다. 화면은 `context.mounted`, Controller는 검색 시작 시 Ref·사용자 데이터 세션을 확인하므로 폐기된 폼이나 이전 계정의 결과는 무시합니다. [#253 검증·제한](work-history/place-address-result-253.md)을 참고하며 실제 검색 서비스 연결 완료를 뜻하지 않습니다.

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
