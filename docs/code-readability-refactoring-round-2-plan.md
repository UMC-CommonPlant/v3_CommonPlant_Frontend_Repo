# Code Readability Refactoring Round 2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 1차 가독성 리팩토링 이후에도 남은 큰 page, feature 전용 widget, 라우팅 파라미터, fixture/API 경계를 단계적으로 줄인다.

**Architecture:** 2차 라운드는 Place 중심의 대형 화면을 먼저 분해하고, route parameter와 detail action처럼 여러 화면에 반복되는 흐름을 helper/controller/view widget 단위로 정리한다. 백엔드 schema가 확정되지 않은 API mapper 작업은 raw 경계를 더 넓히지 않는 선에서만 다루고, 정책 결정이 필요한 작업은 별도 이슈로 보류한다.

**Tech Stack:** Flutter `3.35.7`, Dart `3.9.2`, `flutter_riverpod`, `go_router`, `flutter_test`, `flutter_lints`

**Status:** 2026-06-29 `develop` 기준 2차 라운드 후보 문서화. 각 task는 별도 GitHub 이슈와 PR로 진행한다.

---

## 문서 목적

이 문서는 [코드 가독성 리팩토링 실행 계획](code-readability-refactoring-plan.md)의 1차 라운드 완료 후 남은 후보를 2차 작업 단위로 재정리한다.

1차 라운드는 대형 route page와 feature 전용 widget 파일을 1차로 줄이는 작업이었다. 2차 라운드는 줄 수만 보는 대신 아래 읽기 비용을 함께 줄인다.

- page가 route, submit, navigation, snackbar, status view를 동시에 아는 문제
- fixture/sample data와 remote API mode가 provider와 page에 섞이는 문제
- route parameter 검증 규칙이 route builder 안에서 반복되는 문제
- shared widget 또는 feature widget이 여러 역할을 한 파일에 누적하는 문제

## 참고 문서

- `README.md` 프로젝트 문서 섹션
- `docs/code-readability-refactoring-plan.md`
- `docs/lib-refactoring-direction.md`
- `docs/feature-development-guide.md`
- `docs/state-management-guide.md`
- `docs/shared-widget-guide.md`
- `docs/routing-guide.md`
- `docs/testing-guide.md`
- `docs/git-workflow.md`

## 2차 후보 선정 기준

2026-06-29 `develop` 기준 주요 후보 파일은 아래와 같다.

| 파일 | 줄 수 | 읽기 비용 |
| --- | ---: | --- |
| `lib/features/place/presentation/pages/place_form_page.dart` | 466 | route page에 create/edit scaffold, status scaffold, submit 후 navigation/snackbar가 함께 있다. |
| `lib/features/place/presentation/widgets/place_friend_selection_widgets.dart` | 366 | profile model, selected strip, candidate list, avatar, bottom actions가 한 파일에 있다. |
| `lib/features/place/presentation/pages/place_invitations_page.dart` | 341 | local fixture, action state, list item, avatar, result text, action button UI가 page 파일 안에 있다. |
| `lib/features/place/presentation/pages/place_friend_add_page.dart` | 314 | local fixture, remote search, selection state, status view가 page 파일 안에 있다. |
| `lib/features/place/presentation/widgets/place_detail_header.dart` | 305 | 상세 header의 하위 조각이 누적되어 feature widget 목표치인 300줄을 넘는다. |
| `lib/app/router/app_routes.dart` | 250 | required path parameter 처리는 있으나 query parameter와 route request 조립 규칙은 route builder에 남아 있다. |
| `lib/features/place/presentation/pages/place_detail_page.dart` | 271 | exit dialog, controller 호출, destination 처리, snackbar가 page 안에 있다. |
| `lib/features/plant/presentation/pages/plant_detail_page.dart` | 236 | menu, delete dialog, controller 호출, destination 처리, snackbar가 page 안에 있다. |

2차 라운드의 완료 기준은 단순히 모든 파일을 250줄 이하로 만드는 것이 아니다. 아래 기준을 만족하는 방향으로 task를 쪼갠다.

- route page는 page state, provider watch, route event 연결 중심으로 남긴다.
- feature widget 파일은 하나의 화면 section 또는 하나의 재사용 조합만 담는다.
- fixture/sample data는 page 파일이 아니라 fixture/provider/model 파일에서 관리한다.
- route parameter 검증은 helper와 router test에서 먼저 확인한다.
- controller는 repository 호출과 invalidate를 담당하고, page는 결과에 따른 navigation과 dialog/snackbar 표시만 담당한다.
- API schema가 미확정인 영역은 임의 DTO를 만들지 않고 현재 fallback parser 경계를 유지한다.

## 라운드 범위

이번 라운드에서 다루는 것:

- Place form page 분해
- route parameter helper 보강
- Place friend selection widget 분해
- Place friend add page의 fixture/remote search 경계 정리
- Place invitation page의 fixture/widget 분리
- Place/Plant detail action UI와 action result 처리 경계 정리
- 상세 fixture와 remote view provider 경계 재정리

이번 라운드에서 다루지 않는 것:

- 백엔드 API schema가 필요한 Friend/Image/Memo 응답 DTO 확정
- production release, flavor, Firebase, CI secret 설정
- 화면 UX 정책 변경 또는 Figma와 다른 UI 변경
- Riverpod code generation 도입
- shared widget public API를 깨는 변경

## 우선순위

| 우선순위 | Task | 이유 |
| --- | --- | --- |
| P0 | Task 1. Place form page 분해 | 현재 가장 큰 route page이며, 파일 이동만으로 읽기 비용을 크게 낮출 수 있다. |
| P0 | Task 2. route parameter helper 보강 | 잘못된 route 진입을 page 내부 빈 값 전달 전에 차단한다. |
| P1 | Task 3. Place friend selection widget 분해 | feature 전용 widget 파일이 다시 커지는 흐름을 끊는다. |
| P1 | Task 4. Place friend add page 경계 정리 | local fixture, remote search, selection state를 분리해 API 연결 전 읽기 비용을 낮춘다. |
| P1 | Task 5. Place invitation page 경계 정리 | 친구 요청 API 연결 전 local fixture와 action UI를 분리한다. |
| P1 | Task 6. detail action UI 경계 정리 | Place exit와 Plant delete 흐름의 반복 구조를 줄인다. |
| P2 | Task 7. detail fixture/remote view 경계 정리 | mock fixture와 remote API mode의 섞임을 줄인다. |
| P2 | Task 8. mapper/parser 책임 재평가 | Swagger 확정 범위에서 repository의 unwrap/mapper 책임을 줄인다. |

## 목표 파일 배치

새 파일은 실제 분리 작업이 들어가는 task에서만 만든다. 빈 폴더는 만들지 않는다.

```text
lib/features/place/
  presentation/
    fixtures/
      place_friend_fixture.dart
      place_invitation_fixture.dart
    models/
      place_friend_profile.dart
      place_invitation.dart
    pages/
      place_form_page.dart
      place_friend_add_page.dart
      place_invitations_page.dart
    widgets/
      place_form_scaffold.dart
      place_form_status_scaffold.dart
      place_friend_avatar.dart
      place_friend_candidate_list.dart
      place_friend_selected_strip.dart
      place_friend_bottom_actions.dart
      place_friend_search_status_view.dart
      place_invitation_list_item.dart

lib/features/plant/
  presentation/
    widgets/
      plant_detail_menu_button.dart
      plant_delete_dialog.dart

lib/app/router/
  route_parameters.dart
```

## 실행 계획

각 task는 별도 GitHub 이슈, Project 10 항목, 브랜치, PR로 분리한다. 브랜치는 항상 최신 `develop`에서 생성한다.

### Task 1: Place form page 분해

**Files:**

- Modify: `lib/features/place/presentation/pages/place_form_page.dart`
- Create: `lib/features/place/presentation/widgets/place_form_scaffold.dart`
- Create: `lib/features/place/presentation/widgets/place_form_status_scaffold.dart`
- Test: `test/features/place/presentation/pages/place_form_page_test.dart`
- Test: `test/features/place/presentation/providers/place_form_controller_test.dart`

- [ ] **Step 1: 기존 테스트 기준선을 확인한다**

```bash
fvm flutter test test/features/place/presentation/pages/place_form_page_test.dart test/features/place/presentation/providers/place_form_controller_test.dart
```

Expected: 장소 등록/수정 page 테스트와 submit controller 테스트가 모두 통과한다.

- [ ] **Step 2: status scaffold를 별도 widget으로 이동한다**

이동 대상:

```text
_PlaceFormStatusScaffold
```

새 파일의 public 이름:

```dart
class PlaceFormStatusScaffold extends StatelessWidget
```

page 파일은 loading/error/empty 상태에서 `PlaceFormStatusScaffold`를 호출만 한다.

- [ ] **Step 3: create/edit scaffold를 별도 widget으로 이동한다**

이동 대상:

```text
_PlaceCreateScaffold
_PlaceEditScaffold
```

새 파일의 public 이름:

```dart
class PlaceCreateScaffold extends StatelessWidget
class PlaceEditScaffold extends StatelessWidget
```

두 scaffold는 기존 callback API를 유지한다.

- [ ] **Step 4: page 책임을 route event 연결 중심으로 줄인다**

`PlaceFormPage`에는 아래 책임만 남긴다.

- `TextEditingController` 생명주기
- edit info 적용
- `placeFormControllerProvider` watch/read
- submit 결과에 따른 `context.go` 또는 `context.push`
- submit 실패 snackbar 표시

- [ ] **Step 5: 검증한다**

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test test/features/place/presentation/pages/place_form_page_test.dart test/features/place/presentation/providers/place_form_controller_test.dart
```

Expected: 모든 명령이 exit code 0으로 종료한다.

- [ ] **Step 6: 커밋한다**

```bash
git add lib/features/place/presentation/pages/place_form_page.dart lib/features/place/presentation/widgets/place_form_scaffold.dart lib/features/place/presentation/widgets/place_form_status_scaffold.dart test/features/place/presentation/pages/place_form_page_test.dart
git commit -m "Refactor: 장소 폼 위젯 분리 #이슈번호"
```

### Task 2: route parameter helper 보강

**Files:**

- Modify: `lib/app/router/route_parameters.dart`
- Modify: `lib/app/router/app_routes.dart`
- Test: `test/app/router/app_router_test.dart`

- [ ] **Step 1: 기존 router 테스트 기준선을 확인한다**

```bash
fvm flutter test test/app/router/app_router_test.dart
```

Expected: 기존 router 테스트가 모두 통과한다.

- [ ] **Step 2: query parameter helper를 추가한다**

추가할 API:

```dart
String? optionalQueryParameter(
  Map<String, String> queryParameters,
  String parameterName,
)
```

규칙:

- 값이 없으면 `null`
- trim 후 빈 문자열이면 `null`
- 값이 있으면 trim한 문자열 반환

- [ ] **Step 3: required path parameter test를 유지하고 query parameter test를 추가한다**

추가 테스트 범위:

- `optionalQueryParameter(const {}, 'placeId')`는 `null`
- `optionalQueryParameter(const {'placeId': ''}, 'placeId')`는 `null`
- `optionalQueryParameter(const {'placeId': ' place-1 '}, 'placeId')`는 `place-1`

- [ ] **Step 4: route builder에서 query parameter 직접 접근을 helper로 교체한다**

교체 대상:

- `state.uri.queryParameters['role']`
- `state.uri.queryParameters['placeId']`
- `state.uri.queryParameters['name']`
- `state.uri.queryParameters['next']`

- [ ] **Step 5: 검증한다**

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test test/app/router/app_router_test.dart
```

Expected: 모든 명령이 exit code 0으로 종료한다.

- [ ] **Step 6: 커밋한다**

```bash
git add lib/app/router/route_parameters.dart lib/app/router/app_routes.dart test/app/router/app_router_test.dart
git commit -m "Refactor: 라우트 파라미터 정리 #이슈번호"
```

### Task 3: Place friend selection widget 분해

**Files:**

- Modify: `lib/features/place/presentation/widgets/place_friend_selection_widgets.dart`
- Create: `lib/features/place/presentation/models/place_friend_profile.dart`
- Create: `lib/features/place/presentation/widgets/place_friend_avatar.dart`
- Create: `lib/features/place/presentation/widgets/place_friend_candidate_list.dart`
- Create: `lib/features/place/presentation/widgets/place_friend_selected_strip.dart`
- Create: `lib/features/place/presentation/widgets/place_friend_bottom_actions.dart`
- Test: `test/features/place/presentation/pages/place_friend_add_page_test.dart`

- [ ] **Step 1: 기존 친구 추가 테스트 기준선을 확인한다**

```bash
fvm flutter test test/features/place/presentation/pages/place_friend_add_page_test.dart
```

Expected: 친구 검색, 선택, 완료 흐름 테스트가 모두 통과한다.

- [ ] **Step 2: `PlaceFriendProfile`을 model 파일로 이동한다**

새 파일:

```text
lib/features/place/presentation/models/place_friend_profile.dart
```

public API:

```dart
class PlaceFriendProfile {
  const PlaceFriendProfile({
    required this.id,
    required this.name,
    this.imageAsset,
  });

  final String id;
  final String name;
  final String? imageAsset;
}
```

- [ ] **Step 3: avatar, selected strip, candidate list, bottom actions를 파일 단위로 나눈다**

분리 기준:

- `PlaceFriendAvatar`는 avatar 표시만 담당한다.
- `PlaceSelectedFriendMarkStrip`은 선택된 친구 horizontal strip만 담당한다.
- `PlaceFriendCandidateList`는 검색 후보 list와 toggle callback만 담당한다.
- `PlaceFriendBottomActions`는 cancel/complete button row만 담당한다.

- [ ] **Step 4: 기존 barrel 파일을 만들지 않는다**

각 page는 필요한 widget 파일을 직접 import한다. `widgets/place_friend_widgets.dart` 같은 barrel 파일은 만들지 않는다.

- [ ] **Step 5: 검증한다**

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test test/features/place/presentation/pages/place_friend_add_page_test.dart
```

Expected: 모든 명령이 exit code 0으로 종료한다.

- [ ] **Step 6: 커밋한다**

```bash
git add lib/features/place/presentation/models/place_friend_profile.dart lib/features/place/presentation/widgets/place_friend_*.dart lib/features/place/presentation/pages/place_friend_add_page.dart test/features/place/presentation/pages/place_friend_add_page_test.dart
git commit -m "Refactor: 친구 선택 위젯 분리 #이슈번호"
```

### Task 4: Place friend add page 경계 정리

**Files:**

- Modify: `lib/features/place/presentation/pages/place_friend_add_page.dart`
- Create: `lib/features/place/presentation/fixtures/place_friend_fixture.dart`
- Create: `lib/features/place/presentation/widgets/place_friend_search_status_view.dart`
- Test: `test/features/place/presentation/pages/place_friend_add_page_test.dart`

- [ ] **Step 1: 기존 테스트 기준선을 확인한다**

```bash
fvm flutter test test/features/place/presentation/pages/place_friend_add_page_test.dart
```

Expected: 기존 테스트가 모두 통과한다.

- [ ] **Step 2: local friend fixture를 page 밖으로 이동한다**

이동 대상:

```text
_friends
```

새 파일의 public API:

```dart
const List<PlaceFriendProfile> placeFriendFixture = <PlaceFriendProfile>[
  PlaceFriendProfile(
    id: 'friend-1',
    name: '커먼맘',
    imageAsset: AppImageAssets.placeFriendAddCommonMom,
  ),
  PlaceFriendProfile(
    id: 'friend-2',
    name: '커먼인척',
    imageAsset: AppImageAssets.placeFriendAddCommonFake,
  ),
  PlaceFriendProfile(
    id: 'friend-3',
    name: '커먼일뻔',
    imageAsset: AppImageAssets.placeFriendAddCommonAlmost,
  ),
  PlaceFriendProfile(
    id: 'friend-4',
    name: '커먼일지도',
    imageAsset: AppImageAssets.placeFriendAddCommonMaybe,
  ),
  PlaceFriendProfile(id: 'friend-5', name: '커먼 파파'),
];
```

page는 `placeFriendFixture`를 읽어 local search 결과를 만든다.

- [ ] **Step 3: remote search status view를 별도 widget으로 이동한다**

이동 대상:

```text
_FriendSearchStatusView
```

새 이름:

```dart
class PlaceFriendSearchStatusView extends StatelessWidget
```

- [ ] **Step 4: remote user 변환 함수를 page 밖으로 이동한다**

추가할 함수:

```dart
List<PlaceFriendProfile> placeFriendsFromUsers(List<UserProfile> users)
```

위치는 `place_friend_fixture.dart` 또는 별도 mapper 파일 중 하나로 둔다. 이 라운드에서는 API schema 변경 없이 `UserProfile.id`, `UserProfile.name`만 사용한다.

- [ ] **Step 5: 검증한다**

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test test/features/place/presentation/pages/place_friend_add_page_test.dart
```

Expected: 모든 명령이 exit code 0으로 종료한다.

- [ ] **Step 6: 커밋한다**

```bash
git add lib/features/place/presentation/pages/place_friend_add_page.dart lib/features/place/presentation/fixtures/place_friend_fixture.dart lib/features/place/presentation/widgets/place_friend_search_status_view.dart test/features/place/presentation/pages/place_friend_add_page_test.dart
git commit -m "Refactor: 친구 추가 경계 정리 #이슈번호"
```

### Task 5: Place invitation page 경계 정리

**Files:**

- Modify: `lib/features/place/presentation/pages/place_invitations_page.dart`
- Create: `lib/features/place/presentation/models/place_invitation.dart`
- Create: `lib/features/place/presentation/fixtures/place_invitation_fixture.dart`
- Create: `lib/features/place/presentation/widgets/place_invitation_list_item.dart`
- Test: `test/features/place/presentation/pages/place_invitations_page_test.dart`

- [ ] **Step 1: 기존 테스트 기준선을 확인한다**

```bash
fvm flutter test test/features/place/presentation/pages/place_invitations_page_test.dart
```

Expected: 초대 수락/삭제 상태 테스트가 모두 통과한다.

- [ ] **Step 2: invitation model과 fixture를 page 밖으로 이동한다**

이동 대상:

```text
_PlaceInvitation
_invitations
```

새 public API:

```dart
class PlaceInvitation
const List<PlaceInvitation> placeInvitationFixture
```

- [ ] **Step 3: invitation list item을 별도 widget으로 이동한다**

이동 대상:

```text
_InvitationListItem
_InvitationAvatar
_InvitationDescription
_InvitationPlaceLine
_InvitationResultText
_InvitationActions
```

새 public widget:

```dart
class PlaceInvitationListItem extends StatelessWidget
```

나머지 하위 widget은 새 파일 안에서 private으로 유지한다.

- [ ] **Step 4: page 책임을 action result state로 축소한다**

`PlaceInvitationsPage`에는 아래 책임만 남긴다.

- `_results` state
- fixture 순회
- accept/delete callback 연결

- [ ] **Step 5: 검증한다**

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test test/features/place/presentation/pages/place_invitations_page_test.dart
```

Expected: 모든 명령이 exit code 0으로 종료한다.

- [ ] **Step 6: 커밋한다**

```bash
git add lib/features/place/presentation/pages/place_invitations_page.dart lib/features/place/presentation/models/place_invitation.dart lib/features/place/presentation/fixtures/place_invitation_fixture.dart lib/features/place/presentation/widgets/place_invitation_list_item.dart test/features/place/presentation/pages/place_invitations_page_test.dart
git commit -m "Refactor: 초대 화면 위젯 분리 #이슈번호"
```

### Task 6: detail action UI 경계 정리

**Files:**

- Modify: `lib/features/place/presentation/pages/place_detail_page.dart`
- Modify: `lib/features/plant/presentation/pages/plant_detail_page.dart`
- Create: `lib/features/place/presentation/widgets/place_exit_dialog.dart`
- Create: `lib/features/plant/presentation/widgets/plant_detail_menu_button.dart`
- Create: `lib/features/plant/presentation/widgets/plant_delete_dialog.dart`
- Test: `test/features/place/presentation/pages/place_detail_page_test.dart`
- Test: `test/features/plant/presentation/pages/plant_detail_page_test.dart`
- Test: `test/features/place/presentation/providers/place_exit_controller_test.dart`
- Test: `test/features/plant/presentation/providers/plant_delete_controller_test.dart`

- [ ] **Step 1: 기존 상세 화면 테스트 기준선을 확인한다**

```bash
fvm flutter test test/features/place/presentation/pages/place_detail_page_test.dart test/features/plant/presentation/pages/plant_detail_page_test.dart test/features/place/presentation/providers/place_exit_controller_test.dart test/features/plant/presentation/providers/plant_delete_controller_test.dart
```

Expected: Place/Plant 상세 page와 action controller 테스트가 모두 통과한다.

- [ ] **Step 2: Place exit dialog를 별도 widget으로 이동한다**

새 public API:

```dart
Future<void> showPlaceExitDialog({
  required BuildContext context,
  required bool isExiting,
  required VoidCallback onConfirm,
})
```

page는 `isExiting`을 읽고 `onConfirm`만 넘긴다.

- [ ] **Step 3: Plant menu button과 delete dialog를 별도 widget으로 이동한다**

새 public API:

```dart
class PlantDetailMenuButton extends StatelessWidget

Future<void> showPlantDeleteDialog({
  required BuildContext context,
  required bool isDeleting,
  required VoidCallback onConfirm,
})
```

page는 edit/delete callback 연결만 담당한다.

- [ ] **Step 4: action result 처리 이름을 통일한다**

권장 private method 이름:

- `_handleExitConfirmed`
- `_handleExitResult`
- `_handleDeleteConfirmed`
- `_handleDeleteResult`

navigation과 snackbar는 page에 남긴다. controller에는 `BuildContext`를 넘기지 않는다.

- [ ] **Step 5: 검증한다**

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test test/features/place/presentation/pages/place_detail_page_test.dart test/features/plant/presentation/pages/plant_detail_page_test.dart test/features/place/presentation/providers/place_exit_controller_test.dart test/features/plant/presentation/providers/plant_delete_controller_test.dart
```

Expected: 모든 명령이 exit code 0으로 종료한다.

- [ ] **Step 6: 커밋한다**

```bash
git add lib/features/place/presentation/pages/place_detail_page.dart lib/features/place/presentation/widgets/place_exit_dialog.dart lib/features/plant/presentation/pages/plant_detail_page.dart lib/features/plant/presentation/widgets/plant_detail_menu_button.dart lib/features/plant/presentation/widgets/plant_delete_dialog.dart test/features/place/presentation/pages/place_detail_page_test.dart test/features/plant/presentation/pages/plant_detail_page_test.dart
git commit -m "Refactor: 상세 액션 UI 분리 #이슈번호"
```

### Task 7: detail fixture/remote view 경계 정리

**Files:**

- Modify: `lib/features/place/presentation/providers/place_detail_view_provider.dart`
- Modify: `lib/features/plant/presentation/providers/plant_detail_view_provider.dart`
- Test: `test/features/place/presentation/providers/place_detail_view_provider_test.dart`
- Test: `test/features/plant/presentation/providers/plant_detail_view_provider_test.dart`

- [ ] **Step 1: 기존 provider 테스트 기준선을 확인한다**

```bash
fvm flutter test test/features/place/presentation/providers/place_detail_view_provider_test.dart test/features/plant/presentation/providers/plant_detail_view_provider_test.dart
```

Expected: local fixture mode와 remote mode 테스트가 모두 통과한다.

- [ ] **Step 2: local fixture provider와 remote view provider 이름을 명확히 한다**

권장 이름:

```dart
placeLocalDetailViewProvider
placeRemoteDetailViewProvider
plantLocalDetailViewProvider
plantRemoteDetailViewProvider
```

외부에서 사용하는 facade provider는 기존 이름을 유지한다.

```dart
placeDetailViewProvider
plantDetailViewProvider
```

- [ ] **Step 3: remote detail apply 함수를 분리한다**

권장 함수 이름:

```dart
PlaceDetailFixtureData? applyRemotePlaceSummaryToFixture({
  required PlaceDetailFixtureData fixture,
  required PlaceSummary summary,
})

PlantDetailFixtureData? applyRemotePlantDetailToFixture({
  required PlantDetailFixtureData fixture,
  required PlantDetail detail,
})
```

함수는 provider 안의 inline 로직보다 이름으로 의도를 드러내는 것을 목표로 한다.

- [ ] **Step 4: 검증한다**

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test test/features/place/presentation/providers/place_detail_view_provider_test.dart test/features/plant/presentation/providers/plant_detail_view_provider_test.dart
```

Expected: 모든 명령이 exit code 0으로 종료한다.

- [ ] **Step 5: 커밋한다**

```bash
git add lib/features/place/presentation/providers/place_detail_view_provider.dart lib/features/plant/presentation/providers/plant_detail_view_provider.dart test/features/place/presentation/providers/place_detail_view_provider_test.dart test/features/plant/presentation/providers/plant_detail_view_provider_test.dart
git commit -m "Refactor: 상세 뷰 경계 정리 #이슈번호"
```

### Task 8: mapper/parser 책임 재평가

**Files:**

- Modify: `lib/core/network/api_response_parser.dart`
- Modify: `lib/features/place/data/mappers/place_mapper.dart`
- Modify: `lib/features/place/data/repositories/place_repository.dart`
- Modify: `lib/features/plant/data/mappers/plant_mapper.dart`
- Modify: `lib/features/plant/data/repositories/plant_repository.dart`
- Test: `test/features/place/data/mappers/place_mapper_test.dart`
- Test: `test/features/place/data/repositories/place_repository_test.dart`
- Test: `test/features/plant/data/mappers/plant_mapper_test.dart`
- Test: `test/features/plant/data/repositories/plant_repository_test.dart`

- [ ] **Step 1: 기존 data 계층 테스트 기준선을 확인한다**

```bash
fvm flutter test test/features/place/data/mappers/place_mapper_test.dart test/features/place/data/repositories/place_repository_test.dart test/features/plant/data/mappers/plant_mapper_test.dart test/features/plant/data/repositories/plant_repository_test.dart
```

Expected: mapper와 repository 테스트가 모두 통과한다.

- [ ] **Step 2: Swagger 미확정 영역을 건드리지 않는다**

이 task에서 하지 않는 것:

- Friend/Image raw 응답 DTO 확정
- Memo API DTO 생성
- 백엔드 wrapper 이름 임의 확정
- `jsonListFromResponse` fallback key 제거

- [ ] **Step 3: repository에서 반복되는 list/detail unwrap 호출을 mapper 함수로 이동한다**

권장 함수 이름:

```dart
List<PlaceSummary> placeSummariesFromResponse(Object? data)
PlaceSummary placeSummaryFromResponse(Object? data, {required String fallbackId})
List<PlantSummary> plantSummariesFromResponse(Object? data)
PlantDetail plantDetailFromResponse(Object? data, {required String fallbackId})
```

repository는 datasource 호출 후 위 mapper 함수만 호출한다.

- [ ] **Step 4: parser helper의 소유권을 문서화한다**

`api_response_parser.dart` 상단에 짧은 주석을 추가한다.

```dart
// Swagger response wrappers are still being finalized; keep this parser broad
// and move domain-specific interpretation into feature mappers.
```

- [ ] **Step 5: 검증한다**

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test test/features/place/data/mappers/place_mapper_test.dart test/features/place/data/repositories/place_repository_test.dart test/features/plant/data/mappers/plant_mapper_test.dart test/features/plant/data/repositories/plant_repository_test.dart
```

Expected: 모든 명령이 exit code 0으로 종료한다.

- [ ] **Step 6: 커밋한다**

```bash
git add lib/core/network/api_response_parser.dart lib/features/place/data/mappers/place_mapper.dart lib/features/place/data/repositories/place_repository.dart lib/features/plant/data/mappers/plant_mapper.dart lib/features/plant/data/repositories/plant_repository.dart test/features/place/data/mappers/place_mapper_test.dart test/features/place/data/repositories/place_repository_test.dart test/features/plant/data/mappers/plant_mapper_test.dart test/features/plant/data/repositories/plant_repository_test.dart
git commit -m "Refactor: API 매퍼 책임 정리 #이슈번호"
```

## 완료 판단

2차 라운드는 아래 조건을 만족하면 완료로 본다.

- [ ] `place_form_page.dart`가 250줄 안팎의 route/event 연결 파일로 축소된다.
- [ ] `place_friend_selection_widgets.dart`가 역할별 파일로 분리되거나 제거된다.
- [ ] `place_friend_add_page.dart`에서 local fixture와 remote search status view가 분리된다.
- [ ] `place_invitations_page.dart`에서 invitation fixture와 list item widget이 분리된다.
- [ ] required/optional route parameter 규칙이 helper와 router test로 확인된다.
- [ ] Place/Plant detail page의 dialog/menu UI가 page 밖으로 분리된다.
- [ ] detail view provider에서 local fixture mode와 remote mode의 이름이 분명해진다.
- [ ] repository의 response unwrap 책임이 feature mapper로 일부 이동한다.
- [ ] 각 PR에서 해당 task에 명시된 `fvm flutter test` 명령이 통과한다.
- [ ] 라운드 마지막 PR에서 전체 `fvm flutter test`가 통과한다.

## 후속 보류 후보

아래 항목은 2차 라운드 중 바로 실행하지 않고, 정책이나 백엔드 답변이 정리된 뒤 별도 이슈로 다룬다.

- Friend 요청 목록/수락/거절 API DTO 확정
- Image upload/download/update/delete 응답 타입 정리
- Memo CRUD API 계층 추가
- 인증 redirect Provider 설계
- shared widget public API 재설계
- bottom navigation 도입 시 `ShellRoute` 적용 여부 결정
