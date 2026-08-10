# Code Readability Refactoring Round 3 Implementation Plan

> **For agentic workers:** 각 Task는 독립 GitHub 이슈와 브랜치, PR로 진행한다. 구현 전 해당 Task의 기존 테스트를 먼저 실행하고, 동작 변경 없이 상태 소유권과 의존 방향만 정리한다.

**Goal:** feature route page의 mutable state를 Riverpod Controller와 불변 상태 모델로 이동하고, fixture/view data, feature 소유권, repository 계약을 읽기 쉬운 경계로 정리한다.

**Architecture:** route page는 기본적으로 `ConsumerWidget`으로 유지한다. 검색어, 선택 목록, 폼 입력, 제출 상태처럼 화면 동작을 설명하는 상태는 feature의 `presentation/providers`에서 관리한다. `TextEditingController`, `FocusNode`, animation처럼 Flutter 객체 생명주기에 결합된 상태만 작은 leaf `StatefulWidget`에 남긴다. Provider와 Controller는 `BuildContext`를 알지 않으며 page가 navigation, dialog, snackbar를 담당한다.

**Tech Stack:** Flutter, Dart, Riverpod, go_router, flutter_test

**Status:** 2026-08-04 `develop` 기준 계획 수립. 상위 Epic은 #165, 계획 문서 Task는 #166이다. 2026-08-10 Task 8까지 병합됐고, Task 9 구현과 전체 검증을 완료해 PR #189에서 리뷰 중이다.

---

## 문서 목적

1·2차 가독성 리팩토링으로 큰 page와 feature widget, route parameter, detail action, mapper 경계를 분리했다. 현재 남은 읽기 비용은 파일 크기보다 상태 소유권이 여러 방식으로 섞인 데서 발생한다.

- route page의 `setState`
- Riverpod `NotifierProvider`와 별도 `ChangeNotifier`의 혼용
- page가 local/remote mode를 직접 판단하는 구조
- fixture 타입이 remote view의 공개 타입으로 사용되는 구조
- 한 feature가 다른 feature의 presentation Provider를 직접 참조하는 구조
- 테스트 fake가 실제 remote datasource와 `Dio`를 만들어야 하는 구조

3차 라운드는 위 문제를 Riverpod-first 원칙으로 정리한다. 목표는 `StatefulWidget`을 기계적으로 0개로 만드는 것이 아니다. 화면 동작을 설명하는 상태와 Flutter 생명주기 객체를 구분하고, route page만 읽어도 어떤 상태를 watch하고 어떤 event를 전달하는지 이해할 수 있게 만드는 것이 목표다.

## 참고 문서

- [README.md](../README.md)
- [에이전트 작업 지침](../AGENTS.md)
- [Feature 작업 가이드](feature-development-guide.md)
- [상태관리 Provider 작성 기준](state-management-guide.md)
- [테스트 작성 기준](testing-guide.md)
- [Git 브랜치 및 커밋 전략](git-workflow.md)
- [lib 구조 리팩토링 개선 방향](lib-refactoring-direction.md)
- [코드 가독성 리팩토링 1차 계획](code-readability-refactoring-plan.md)
- [코드 가독성 리팩토링 2차 계획](code-readability-refactoring-round-2-plan.md)
- [후속 결정 체크리스트](follow-up-decision-checklist.md)

## 현재 기준선

2026-08-04 `develop` 기준:

- `lib`에는 Dart 파일 153개, 약 14,546줄이 있다.
- `test`에는 Dart 테스트 파일 56개가 있다.
- feature route/page 중 `StatefulWidget` 또는 `ConsumerStatefulWidget`은 11개다.
- feature page에는 `setState` 호출이 22개 있다.
- shared에는 생명주기와 내부 interaction 때문에 Stateful이 필요한 위젯 3개가 있다.
- `useRemoteApiProvider`를 직접 참조하는 production 파일은 13개다.
- `fvm flutter analyze`는 통과한다.

### Stateful route/page 현황

| 화면 | 현재 mutable state | 3차 목표 |
| --- | --- | --- |
| `ProfileSetupPage` | nickname controller/focus, image 여부, `FormSubmitController`, 약관 Provider | `ProfileSetupState`와 Riverpod Controller로 통합하고 input lifecycle만 leaf widget에 둔다. |
| `MemoWritePage` | memo controller, photo 여부, submit 가능 여부 | `MemoWriteState`와 Controller로 이동한다. |
| `PlaceInvitationsPage` | invitation별 accept/delete 결과 map | `PlaceInvitationController`로 이동한다. |
| `AddressSearchPage` | 검색 controller, query 기반 결과 | `AddressSearchState`와 Controller로 이동한다. |
| `PlaceFriendAddPage` | 검색 controller, 선택 ID, remote 선택 user map | `PlaceFriendSelectionState`와 Controller로 이동한다. |
| `FriendManagementPage` | 검색 controller, 선택 ID, 삭제 상태 | `FriendManagementState`와 Controller로 이동한다. |
| `PlaceFormPage` | name controller, initial/current address, edit 적용 여부 | `PlaceFormState`가 draft와 initial snapshot을 관리한다. |
| `PlantFormPage` | name controller, selected place, edit 적용 여부 | `PlantFormState`가 draft, 선택 장소, edit 정보를 관리한다. |
| `PlantSearchPage` | 검색 controller, query 기반 결과 | `PlantSearchState`와 Controller로 이동한다. |
| `PlaceDetailPage` | 실제 mutable field 없음 | 바로 `ConsumerWidget`으로 전환한다. |
| `PlantDetailPage` | 실제 mutable field 없음 | 바로 `ConsumerWidget`으로 전환한다. |

### 유지할 StatefulWidget

아래 위젯은 Flutter 객체 생명주기 또는 재사용 컴포넌트 내부 interaction을 캡슐화하므로 Stateful을 유지한다.

| 위젯 | 유지 이유 |
| --- | --- |
| `CommonTextField` | 내부/외부 `TextEditingController`, `FocusNode` listener와 dispose 책임 |
| `CommonSearchTextField` | 내부/외부 input controller와 focus listener 책임 |
| `CommonFabDial` | 확장/축소 interaction과 위젯 내부 시각 상태 |
| feature leaf input widget | controller, focus, animation, scroll 등 Flutter 생명주기 객체를 소유하는 경우 |

공용 위젯에는 feature Provider를 주입하지 않는다. 공용 위젯은 값과 callback만 받는다.

## 3차에서 읽기 쉬운 코드의 기준

### 1. Route page는 상태 소유자가 아니라 연결점이다

route page가 담당하는 일:

- route argument를 의미 있는 request/args로 변환한다.
- 화면에 필요한 Provider 상태를 watch한다.
- page scaffold와 feature widget을 조립한다.
- 사용자 event를 Controller에 전달한다.
- 성공 결과에 따라 navigation, dialog, snackbar를 실행한다.

route page가 담당하지 않는 일:

- 검색 결과 필터링
- 선택 목록 추가/삭제
- initial/current form 값 비교
- `canSubmit` 계산
- local/remote mode 분기
- repository 호출과 request DTO 생성
- fixture와 remote entity 합성

### 2. 화면 상태는 하나의 이름 있는 모델로 읽힌다

관련된 값을 Provider 하나씩 흩뜨리지 않는다.

```dart
class MemoWriteState {
  const MemoWriteState({
    this.content = '',
    this.hasPhoto = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String content;
  final bool hasPhoto;
  final bool isSubmitting;
  final String? errorMessage;

  bool get canSubmit => content.trim().isNotEmpty && !isSubmitting;
}
```

`canSubmit`, filtered result, `hasChanges`처럼 다른 필드에서 계산 가능한 값은 별도 mutable field로 저장하지 않고 getter 또는 파생 Provider로 계산한다.

### 3. Controller API는 사용자 행동을 말한다

권장:

```text
updateQuery
toggleFriend
removePhoto
selectPlace
submit
retry
```

지양:

```text
setValue
setBool
changeState
handleData
apply
```

Controller는 `BuildContext`, `Navigator`, `ScaffoldMessenger`, widget class를 import하지 않는다.

### 4. Flutter 생명주기 객체는 Provider에 넣지 않는다

아래 객체는 Provider state에 저장하지 않는다.

- `TextEditingController`
- `FocusNode`
- `AnimationController`
- `ScrollController`
- `PageController`
- `GlobalKey`

필요하면 작은 leaf StatefulWidget이 객체를 소유하고 `onChanged` callback으로 Controller에 값을 전달한다. route page 전체를 controller 생명주기 때문에 Stateful로 만들지 않는다.

### 5. Provider lifecycle을 route lifecycle과 맞춘다

- route를 나가면 사라져야 하는 form/search/selection state는 `autoDispose`를 우선한다.
- `placeId`, `plantId`, mode처럼 route마다 다른 입력은 `family` parameter로 전달한다.
- 앱 전체 공유가 필요한 인증/세션 외에는 전역으로 오래 유지하지 않는다.
- 동일 화면 안의 상태를 field별 Provider 여러 개로 흩뜨리지 않는다.

### 6. Read state와 write action을 구분한다

- 단순 API 조회는 `FutureProvider` 또는 read-only Provider를 사용한다.
- 입력, 선택, 제출처럼 event가 누적되는 화면은 `NotifierProvider` 또는 `AsyncNotifierProvider`를 사용한다.
- Provider 파일이 커지면 조회 Provider와 action Controller를 분리하되, page가 불필요한 구현 Provider를 모두 알게 만들지 않는다.
- Controller test는 repository/provider override만으로 실행되어야 한다.

## 상태 소유권 판단표

| 상태 | 소유 위치 | 예시 |
| --- | --- | --- |
| 서버 조회 결과 | `FutureProvider`/`AsyncNotifierProvider` | place detail, plant detail |
| 폼 draft와 선택 상태 | feature Controller state | name, address, selected place |
| submit/loading/error | feature Controller state | create/update/delete |
| 검색 query와 선택 목록 | feature Controller state | friend search, plant search |
| 계산 가능한 UI 값 | state getter/derived Provider | `canSubmit`, filtered results |
| navigation/dialog/snackbar | route page | submit 결과 처리 |
| controller/focus/animation | leaf StatefulWidget | input focus, FAB animation |
| 공용 component interaction | shared StatefulWidget | clear button, FAB dial |

## 라운드 범위

이번 라운드에서 다루는 것:

- feature route page의 StatefulWidget과 `setState` 축소
- 화면별 불변 State와 Riverpod Controller 도입
- 상세 route page의 `ConsumerWidget` 전환
- `FixtureData`와 실제 화면 `ViewData` 분리
- presentation model이 widget 파일에 정의되는 역의존 제거
- Plant 등록 장소와 Place/User 검색 Provider 소유권 정리
- Place/Plant repository interface 및 테스트 fake 개선
- local/remote mode 판단을 page에서 제거
- 미사용 Phase 0 위젯 제거
- router test와 반복 test app 조립 코드 분리

이번 라운드에서 다루지 않는 것:

- Riverpod code generation 도입
- `flutter_hooks` 또는 `hooks_riverpod` 도입
- 모든 shared StatefulWidget 제거
- 백엔드 schema가 필요한 Friend/Image/Memo response DTO 확정
- 인증 redirect 정책 구현
- 공통 에러 메시지 mapping 정책 확정
- bottom navigation과 `ShellRoute` 정책 결정
- Figma와 다른 UX 또는 화면 동작 변경

## 목표 파일 배치

실제 Task가 시작될 때 필요한 파일만 만든다.

```text
lib/features/login/presentation/
  pages/
    profile_setup_page.dart
  providers/
    profile_setup_controller.dart
    profile_setup_state.dart
  widgets/
    profile_nickname_field.dart

lib/features/memo/presentation/
  pages/
    memo_write_page.dart
  providers/
    memo_write_controller.dart
    memo_write_state.dart

lib/features/place/presentation/
  models/
    place_detail_view_data.dart
  providers/
    address_search_controller.dart
    friend_management_controller.dart
    place_friend_selection_controller.dart
    place_form_controller.dart
    place_invitation_controller.dart

lib/features/plant/presentation/
  models/
    plant_detail_view_data.dart
  providers/
    plant_form_controller.dart
    plant_registration_place_provider.dart
    plant_search_controller.dart
```

State와 Controller가 짧고 항상 함께 변경되는 경우 같은 파일에 둘 수 있다. 파일 수를 늘리는 것보다 이름만 보고 역할을 찾을 수 있는지를 우선한다.

## 우선순위와 선후 관계

| 우선순위 | Task | 선행 조건 | 이유 |
| --- | --- | --- | --- |
| P0 | Task 1. Detail route page stateless 전환 | 없음 | 실제 local state가 없는 Stateful page를 먼저 제거해 기준 패턴을 만든다. |
| P0 | Task 2. Search 화면 state Controller 전환 | Task 1 | query/filtered result처럼 단순한 상태로 Riverpod-first 패턴을 검증한다. |
| P0 | Task 3. Place friend/invitation state 전환 | Task 2 | selection map/set과 remote search 상태를 불변 모델로 정리한다. |
| P0 | Task 4. Memo write state 전환 | Task 2 | content/photo/canSubmit을 작은 form state 패턴으로 정리한다. |
| P1 | Task 5. Profile setup state 통합 | Task 4 | Riverpod과 ChangeNotifier 혼용을 제거하고 약관/이미지/제출 상태를 통합한다. |
| P1 | Task 6. Place form state 통합 | Task 5 | initial/current draft와 submit 상태를 Controller 중심으로 바꾼다. |
| P1 | Task 7. Plant form state와 Provider 소유권 정리 | Task 6 | Place presentation 의존과 form draft를 함께 명확히 한다. |
| P1 | Task 8. Place/Plant detail ViewData 경계 정리 | Task 1 | fixture 타입과 widget item 모델 역의존을 제거한다. |
| P2 | Task 9. Repository 계약과 local/remote 경계 정리 | Task 6~8 | Controller가 환경 flag와 concrete repository를 직접 아는 범위를 줄인다. |
| P2 | Task 10. 미사용 Phase 0 구조 정리 | 없음 | 사용처 없는 임시 위젯과 소유권 문서를 현재 상태에 맞춘다. |
| P2 | Task 11. Router/test helper 가독성 정리 | Task 1~9 | 최종 구조 기준으로 491줄 router test와 반복 app builder를 나눈다. |

## 실행 계획

### Task 1: Detail route page stateless 전환

**대상:**

- `lib/features/place/presentation/pages/place_detail_page.dart`
- `lib/features/plant/presentation/pages/plant_detail_page.dart`
- `test/features/place/presentation/pages/place_detail_page_test.dart`
- `test/features/plant/presentation/pages/plant_detail_page_test.dart`

**작업:**

- `ConsumerStatefulWidget`을 `ConsumerWidget`으로 전환한다.
- helper는 `WidgetRef`, route argument, `BuildContext`를 명시적으로 받는다.
- async UI 결과는 `context.mounted`로 확인한다.
- dialog, navigation, snackbar는 page에 유지한다.
- 기존 controller와 view Provider 동작은 변경하지 않는다.

**완료 조건:**

- 두 page에 mutable field와 State class가 없다.
- exit/delete 결과와 navigation 동작이 유지된다.
- 관련 widget/controller test가 통과한다.

### Task 2: Search 화면 state Controller 전환

**대상:**

- `lib/features/place/presentation/pages/address_search_page.dart`
- `lib/features/plant/presentation/pages/plant_search_page.dart`
- 새 search state/controller 파일
- 관련 page/provider test

**작업:**

- query, normalized query, filtered results를 Riverpod state로 이동한다.
- fixture/model을 page private class에서 feature model/fixture로 이동한다.
- page는 `ConsumerWidget`으로 전환한다.
- input controller가 필요하면 search field 또는 작은 leaf widget이 소유한다.

**완료 조건:**

- 두 page에 `setState`가 없다.
- 검색 결과와 empty state 전이를 Controller unit test로 검증한다.
- 검색 선택 route 동작이 유지된다.

### Task 3: Place friend/invitation state 전환

**대상:**

- `place_friend_add_page.dart`
- `friend_management_page.dart`
- `place_invitations_page.dart`
- 새 Place selection/invitation controller와 test

**작업:**

- 선택 ID, 선택 profile, invitation result를 불변 상태로 이동한다.
- local/remote 검색 결과를 page의 `if (useRemoteApi)` 밖으로 이동한다.
- User entity를 Place friend view model로 바꾸는 책임을 Provider/controller 경계에 둔다.
- dialog와 route 이동은 page에 유지한다.

**완료 조건:**

- 세 page가 `ConsumerWidget`이다.
- 선택/해제/삭제/수락 상태 전이가 unit test에 있다.
- page가 User presentation Provider를 직접 import하지 않는다.

### Task 4: Memo write state 전환

**대상:**

- `memo_write_page.dart`
- 새 `memo_write_state.dart`, `memo_write_controller.dart`
- memo write page/controller test

**작업:**

- content, photo 여부, submit 가능 여부를 State로 이동한다.
- `addMemo` 호출은 Controller가 담당하고 page는 성공 시 이동한다.
- leaf input widget만 `TextEditingController`를 소유한다.

**완료 조건:**

- page에 `setState`와 mutable field가 없다.
- content/photo/canSubmit/submit 상태 전이를 unit test로 검증한다.
- 현재 local memo 작성 동작이 유지된다.

### Task 5: Profile setup state 통합

**대상:**

- `profile_setup_page.dart`
- `profile_setup_state_provider.dart`
- `shared/forms/form_submit_state.dart`
- profile setup/terms/controller test

**작업:**

- nickname, image, terms, submit 상태를 하나의 Riverpod 상태 경계로 통합한다.
- Profile에서만 쓰는 `ChangeNotifier` 기반 `FormSubmitController`를 제거한다.
- nickname controller/focus는 leaf widget에서 관리한다.
- 약관 화면은 명시적인 signup/profile state API만 호출한다.

**완료 조건:**

- Profile route page가 `ConsumerWidget`이다.
- Riverpod과 ChangeNotifier가 한 화면에서 혼용되지 않는다.
- nickname/image/terms/submit 상태 전이를 unit test로 검증한다.

### Task 6: Place form state 통합

**대상:**

- `place_form_page.dart`
- `place_form_controller.dart`
- `place_form_edit_provider.dart`
- Place form widget/controller test

**작업:**

- initial/current name과 address, mode, load/submit 상태를 명시적인 form state로 만든다.
- edit info 적용 여부를 page mutable field로 관리하지 않는다.
- `hasChanges`, `canSubmit`은 state getter로 계산한다.
- request DTO와 local/remote 분기는 page 밖에 유지한다.

**완료 조건:**

- page에 `setState`, initial/current mutable field가 없다.
- create/edit draft와 submit 상태 전이가 controller test에 있다.
- 기존 navigation과 snackbar 동작이 유지된다.

### Task 7: Plant form state와 Provider 소유권 정리

**대상:**

- `plant_form_page.dart`
- `plant_form_controller.dart`
- `plant_form_edit_provider.dart`
- `place/presentation/providers/plant_registration_place_provider.dart`
- Plant form model/provider/controller test

**작업:**

- form draft, selected place, edit snapshot, load/submit 상태를 State로 이동한다.
- Plant 등록 화면 전용 Provider를 Plant feature로 이동한다.
- Place feature는 사용자 장소 조회 상태만 공개하고 Plant가 자체 view model로 변환한다.
- Provider 의존으로 invalidate가 전파되게 하여 Place controller가 Plant Provider를 직접 invalidate하지 않게 한다.

**완료 조건:**

- Plant form page가 `ConsumerWidget`이다.
- Plant presentation이 Place presentation Provider를 직접 import하지 않는다.
- create/edit/selection state 전이가 controller test에 있다.

### Task 8: Place/Plant detail ViewData 경계 정리

**대상:**

- `place_detail_fixture.dart`
- `place_detail_view_provider.dart`
- Place detail widget item model
- `plant_detail_fixture.dart`
- `plant_detail_view_provider.dart`
- Plant detail memo item model
- 관련 fixture/provider/widget test

**작업:**

- `PlaceDetailViewData`, `PlantDetailViewData`를 presentation model로 추가한다.
- friend/plant/memo item model을 widget 파일 밖으로 이동한다.
- fixture는 local ViewData를 만드는 함수만 제공한다.
- remote entity와 fallback ViewData 합성은 명시적인 view mapper가 담당한다.

**완료 조건:**

- 공개 Provider 타입에 `FixtureData`가 없다.
- fixture가 widget 파일을 import하지 않는다.
- local/remote view test가 기존 결과를 유지한다.

### Task 9: Repository 계약과 local/remote 경계 정리

**대상:**

- Place/Plant `domain/repositories`
- Place/Plant `data/repositories`
- form/detail/list Controller와 Provider
- repository/controller test fake

**작업:**

- repository interface와 `RepositoryImpl`을 분리한다.
- 테스트 fake가 실제 `Dio` datasource를 생성하거나 concrete repository를 상속하지 않게 한다.
- local/remote mode 선택을 page에서 제거하고 Provider 조립 경계로 모은다.
- remote create/update 후 local state 동기화처럼 현재 테스트로 고정된 동작은 별도 변경 없이 유지한다.

**완료 조건:**

- Controller test가 순수 fake repository로 실행된다.
- page가 `useRemoteApiProvider`, repository 구현, request DTO를 직접 알지 않는다.
- local/remote 동작이 각각 unit test로 확인된다.

### Task 10: 미사용 Phase 0 구조 정리

**대상:**

- `lib/features/common/presentation/widgets/phase0_widgets.dart`
- `docs/shared-widget-guide.md`
- 관련 import/test

**작업:**

- 실제 사용처가 없는 Phase 0 위젯과 빈 feature 폴더를 제거한다.
- shared/feature 소유권 감사 결과를 현재 사용처와 맞춘다.
- `CommonButton`, `CommonTextField`처럼 응집된 공용 위젯은 줄 수만으로 분리하지 않는다.

**완료 조건:**

- 미사용 Phase 0 코드가 없다.
- shared widget 소유권 문서가 현재 코드와 일치한다.

### Task 11: Router/test helper 가독성 정리

**대상:**

- `test/app/router/app_router_test.dart`
- `test/helpers/`
- 반복되는 feature page test app builder

**작업:**

- route registry/parameter, signup flow, Place flow, Plant/Memo flow test를 책임별 파일로 나눈다.
- 반복되는 `ProviderScope`, router, fake repository 조립은 의미 있는 helper로만 추출한다.
- 테스트 이름은 사용자 행동이나 상태 전이를 설명하게 유지한다.

**완료 조건:**

- 한 router test 파일이 모든 route flow를 소유하지 않는다.
- helper가 test 본문의 Given/When/Then을 숨기지 않는다.
- 전체 test가 통과한다.

## Task 공통 진행 순서

각 Task는 아래 순서를 지킨다.

1. 관련 기존 테스트를 먼저 실행한다.
2. State와 Controller의 public API를 테스트로 고정한다.
3. mutable state를 Controller로 이동한다.
4. page를 `ConsumerWidget`으로 전환한다.
5. leaf lifecycle widget을 필요한 범위에만 둔다.
6. widget test가 렌더링과 route/feedback 동작을 유지하는지 확인한다.
7. format, analyze, 전체 test를 실행한다.

## 커밋 분리와 기록 기준

각 Task는 구현 전에 이슈 본문에 커밋 계획을 작성한다. State, Controller, page/widget, 문서 갱신처럼 리뷰 가능한 책임을 기준으로 커밋을 나누고, 완료 전에 아래 커밋별 작업 이력 표를 갱신한다.

기본 커밋 구성:

1. 실행 계획 또는 작업 기준 문서
2. State/model과 상태 계산 테스트
3. Controller와 상태 전이 테스트
4. page/widget 연결과 사용자 동작 테스트
5. 전체 검증 결과와 작업 이력 문서

작은 Task는 인접 단계를 합칠 수 있다. 다만 하나의 커밋에 문서, 상태 모델, Controller, 여러 page 변경을 모두 넣는 방식은 피하고, 각 구현 커밋은 가능한 범위에서 관련 테스트를 통과해야 한다. 세부 기준은 [Git 브랜치 및 커밋 전략](git-workflow.md)의 `작업 계획과 커밋별 이력`을 따른다.

## 검증 기준

문서만 수정한 PR:

```bash
git diff --check
```

Flutter 코드가 변경된 각 Task:

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test
```

Controller가 추가된 Task는 대상 controller test를 먼저 단독 실행한 뒤 전체 test를 실행한다.

여러 Task가 연속 병합된 중간 지점과 라운드 완료 전에는 [코드 가독성 리팩토링 검증 기준](code-readability-refactoring-validation.md)에 따라 구조 감사, 대상 회귀 테스트, 전체 품질 게이트, 플랫폼 빌드를 함께 실행한다.

## 리뷰 체크리스트

- [ ] route page가 `ConsumerWidget`인가?
- [ ] StatefulWidget이 남아 있다면 Flutter 생명주기 객체 소유 이유가 분명한가?
- [ ] page에 `setState`와 화면 동작 mutable field가 남아 있지 않은가?
- [ ] 관련 상태가 이름 있는 불변 State로 묶였는가?
- [ ] 계산 가능한 값을 별도 mutable state로 저장하지 않았는가?
- [ ] Controller API가 사용자 행동을 설명하는가?
- [ ] Controller가 `BuildContext`, widget, dialog, snackbar를 알지 않는가?
- [ ] navigation과 UI feedback은 page에 남아 있는가?
- [ ] route별 상태가 `autoDispose`/`family` lifecycle을 갖는가?
- [ ] page가 local/remote mode와 concrete repository를 직접 판단하지 않는가?
- [ ] controller 상태 전이가 unit test로 검증되는가?
- [ ] widget test가 렌더링과 사용자 interaction에 집중하는가?
- [ ] 동작 변경 없이 기존 test가 통과하는가?

## 완료 판단

3차 라운드는 아래 조건을 만족하면 완료로 본다.

- [x] feature route/page의 StatefulWidget 11개가 `ConsumerWidget`으로 전환된다.
- [x] `features/**/pages`에 화면 상태 변경 목적의 `setState`가 없다.
- [x] StatefulWidget은 shared 또는 lifecycle leaf widget에만 남는다.
- [x] `FormSubmitController` 기반 ChangeNotifier 혼용이 제거된다.
- [x] 검색, 선택, 폼 draft, 제출 상태가 Riverpod Controller test로 검증된다.
- [x] Provider 공개 타입에서 `FixtureData` 이름이 제거된다.
- [x] fixture가 widget 파일에 정의된 item model을 import하지 않는다.
- [x] feature 간 presentation Provider 직접 의존이 줄어든다.
- [x] page가 `useRemoteApiProvider`, request DTO, repository 구현을 직접 알지 않는다.
- [ ] 사용처 없는 Phase 0 위젯이 제거된다.
- [ ] router test가 책임별로 분리된다.
- [ ] README와 상태관리/테스트/shared widget 문서가 실제 구조를 반영한다.
- [x] 전체 `fvm flutter test`가 통과한다.

## 이슈와 PR 기록

| Task | 이슈 | PR | 상태 |
| --- | --- | --- | --- |
| 3차 상위 Epic | #165 | - | In Progress |
| 3차 계획 문서화 | #166 | #167 | Done |
| Task 1. Detail route page stateless 전환 | #168 | #169 | Done |
| Task 2. Search 화면 state Controller 전환 | #170 | #171 | Done |
| Task 3. Place friend/invitation state 전환 | #172 | #173 | Done |
| Task 4. Memo write state 전환 | #174 | #175 | Done |
| Task 5. Profile setup state 통합 | #176 | #177 | Done |
| Task 6. Place form state 통합 | #178 | #179 | Done |
| Task 1~6 중간 검증 | #180 | #181 | Done |
| Task 7. Plant form state와 Provider 소유권 정리 | #182 | #183 | Done |
| Task 8. Place/Plant detail ViewData 경계 정리 | #184 | #187 | Done |
| Task 9. Repository 계약과 local/remote 경계 정리 | #188 | #189 | In Review |
| Task 10. 미사용 Phase 0 구조 정리 | 시작 시 생성 | - | Pending |
| Task 11. Router/test helper 가독성 정리 | 시작 시 생성 | - | Pending |

각 Task 이슈를 만들 때 #165를 parent issue로 연결하고, Project 10의 category는 대상 domain을 우선한다. 여러 domain을 함께 다루는 공통 구조와 문서 Task는 `Story`로 지정한다.

## 커밋별 작업 이력

| Task | 커밋 | 작업 범위 | 검증 |
| --- | --- | --- | --- |
| 3차 계획 | `c813ac1` | 3차 후보, 상태 소유권 원칙, Task 1~11 실행 계획 문서화 | `git diff --check` |
| Task 1 | `909e677` | Place/Plant detail route page를 `ConsumerWidget`으로 전환 | 관련 detail page/controller test, 전체 test |
| Task 2 | `6f5f44e` | 주소/식물 검색 상태를 Riverpod Controller로 이동 | 관련 search page/controller test, 전체 test |
| Task 3 | `6a4b2ab` | Place 친구 선택·관리·초대 상태를 Riverpod Controller로 이동 | 관련 Place page/controller test, 전체 test |
| Task 4 | `89288b8` | Memo 작성 draft와 사진·제출 상태를 Riverpod Controller로 이동 | 관련 Memo page/controller test, 전체 test |
| Task 5 | `37e7f28` | Profile 설정 상태 통합과 ChangeNotifier 제출 Controller 제거 | 관련 Profile/Terms/controller test, 전체 test |
| Task 6 | `172216f` | 작업 전 커밋 분리와 커밋별 이력 기록 기준 추가 | `git diff --check` |
| Task 6 | `fb2d24c` | Place 폼 생성·수정·조회·제출 상태 모델과 계산 테스트 추가 | Place form state test 4개 |
| Task 6 | `4117715` | Place 폼 draft, 조회, 제출 상태를 family Controller로 통합 | Place form controller/page test 8개 |
| Task 6 | `ab2f014` | Place form page를 `ConsumerWidget`으로 전환하고 이름 입력 제어를 leaf widget으로 이동 | Place form 대상 test 15개 |
| Task 6 | `4c7fe75` | Place form controller test의 중복 import 정리 | `fvm flutter analyze`, 전체 test 212개 |
| 중간 검증 | `5a6e2d0` | 구조 감사, 회귀 테스트, 플랫폼 빌드 검증 기준과 Task 1~6 결과 문서화 | 대상 test 83개, 전체 test 212개, analyze, iOS/Android debug build |
| Task 7 | `96b5af7` | Plant 폼 생성·수정 상태 모델과 제출 가능 여부 계산 테스트 추가 | Plant form state test 5개 |
| Task 7 | `42c26a9` | 사용자 장소 조회 facade와 Plant 등록 장소 Provider의 feature 소유권 분리 | Place/Plant Provider 및 폼 대상 test 16개 |
| Task 7 | `1888adc` | Plant 폼 조회·선택·생성·수정·제출 상태를 family Controller로 통합 | Plant form controller/page test 11개 |
| Task 7 | `64e9208` | Plant form page를 `ConsumerWidget`으로 전환하고 이름 입력 제어를 leaf widget으로 이동 | Plant 폼 및 router 대상 test 39개 |
| Task 7 | `7c7093c` | Provider facade와 Controller test의 불필요한 import 정리 | format, analyze, 전체 test 218개 |
| Task 8 | `73cac15` | Place 상세 ViewData와 item model을 정의하고 remote summary 합성을 view mapper로 분리 | Place 상세 대상 test 15개 |
| Task 8 | `d2e618b` | Plant 상세 ViewData와 memo item model을 정의하고 remote detail 합성을 view mapper로 분리 | Plant 상세 대상 test 14개 |
| Task 8 | - | `FixtureData` 공개 타입과 detail fixture의 widget 역의존 제거를 구조 감사하고 작업 이력 갱신 | 대상 test 29개, format, analyze, 전체 test 218개 |
| Task 9 | `1dbe513` | Place repository domain 계약, data 구현체, feature 의존 조립 경계를 분리하고 테스트 fake의 Dio 의존 제거 | Place 대상 test 71개, analyze |
| Task 9 | `689e1ef` | Plant repository domain 계약, data 구현체, feature 의존 조립 경계를 분리하고 테스트 fake의 Dio 의존 제거 | Plant 대상 test 63개, analyze |
| Task 9 | - | Place/Plant presentation의 data 계층 의존과 concrete fake 상속을 구조 감사하고 Task 8·9 상태 및 작업 이력 갱신 | 구조 감사, format, analyze, 전체 test 218개 |

Task 6부터는 구현 커밋을 책임별로 나누고 각 커밋을 별도 행으로 기록한다. 작업 이력만 갱신하는 마지막 문서 커밋은 자기 자신의 해시를 생략할 수 있다.
