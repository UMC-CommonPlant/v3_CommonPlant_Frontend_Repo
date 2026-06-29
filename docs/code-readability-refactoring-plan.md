# Code Readability Refactoring Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 현재 Flutter 코드의 동작을 유지하면서 사람이 읽고 리뷰하고 수정하기 쉬운 구조로 단계적으로 정리한다.

**Architecture:** route page는 라우팅과 화면 조립만 담당하고, 화면 전용 section widget, modal/dialog, form state, submit controller, fixture, mapper를 책임별 파일로 나눈다. 한 PR은 하나의 화면 또는 하나의 책임 이동만 다루며, 기존 widget/unit test를 유지한 상태에서 필요한 테스트를 추가한다.

**Tech Stack:** Flutter `3.35.7`, Dart `3.9.2`, `flutter_riverpod`, `go_router`, `flutter_test`, `flutter_lints`

**Status:** 2026-06-28 `develop` 기준 1차 라운드 Task 1~7 완료. 아래 실행 계획은 원래 작업 단위와 리뷰 기준을 기록으로 보존한다.

---

## 문서 목적

이 문서는 "코드가 동작한다"에서 멈추지 않고 "사람이 빠르게 읽고 안전하게 고친다"를 목표로 하는 리팩토링 실행 기준이다.

기존 [lib 구조 리팩토링 개선 방향](lib-refactoring-direction.md)이 feature 경계, Riverpod, 라우팅, API 계층의 구조를 넓게 다룬다면, 이 문서는 한 파일을 열었을 때 읽기 어려운 이유와 이를 줄이는 작업 단위를 더 구체적으로 다룬다.

## 참고 문서

- `README.md` 프로젝트 문서 섹션
- `docs/feature-development-guide.md`
- `docs/state-management-guide.md`
- `docs/shared-widget-guide.md`
- `docs/screen-publishing-rules.md`
- `docs/testing-guide.md`
- `docs/git-workflow.md`
- `docs/lib-refactoring-direction.md`

## 1차 라운드 완료 요약

2026-06-28 `develop` 기준 `lib`의 Dart 코드는 약 14,358줄이다. 1차 라운드에서는 대형 route page와 feature 전용 widget 파일을 우선 분리했고, shared widget 스타일 계산과 Friend/Image raw 응답 경계까지 정리했다.

완료된 작업 단위:

| Task | 범위 | 이슈 | PR |
| --- | --- | --- | --- |
| Task 1 | Profile setup page 분해 | #129 | #130 |
| Task 2 | Plant form page 분해 | #131 | #132 |
| Task 3 | Home screen section 분해 | #133 | #134 |
| Task 4 | Detail widget 파일 section 분해 | #135 | #136 |
| Task 5 | Memo page interaction 분해 | #137 | #138 |
| Task 6 | shared widget variant 분해 | #139 | #140 |
| Task 7 | raw response 경계 축소 | #141 | #142 |

주요 파일 상태:

| 파일 | 현재 줄 수 | 상태 |
| --- | ---: | --- |
| `lib/features/login/presentation/pages/profile_setup_page.dart` | 167 | page는 route/event 연결 중심으로 축소되었다. |
| `lib/features/plant/presentation/pages/plant_form_page.dart` | 293 | create/edit shell과 입력 보조 widget이 분리되었다. |
| `lib/features/home/presentation/home_screen.dart` | 26 | route-level shell만 남기고 section은 widget 파일로 이동했다. |
| `lib/features/memo/presentation/pages/memo_list_page.dart` | 178 | dialog, empty view, list content가 page 밖으로 분리되었다. |
| `lib/shared/widgets/common_button.dart` | 376 | public API를 유지하고 style/metrics 계산을 private helper로 분리했다. |
| `lib/shared/widgets/common_text_field.dart` | 330 | 상태별 style resolution을 private helper로 분리했다. |

완료 후 상태:

- 500줄 이상 route page 파일이 없다.
- 400줄 이상 feature 전용 widget 파일이 없다.
- Place/Plant 상세 section widget은 파일 단위로 분리되었다.
- Memo 목록의 dialog와 empty/list content는 page 밖으로 분리되었다.
- Friend/Image의 schema 미확정 GET 응답은 `Raw` suffix로 경계를 명시하고, presentation 계층에서 직접 해석하지 않는다.

## 읽기 쉬운 코드의 기준

가독성 리팩토링은 개인 취향 정리가 아니라 팀이 같은 속도로 코드를 읽게 만드는 작업이다. 아래 기준을 만족하면 읽기 쉬운 코드로 본다.

| 기준 | 목표 |
| --- | --- |
| 파일 책임 | 한 파일은 하나의 화면, 하나의 widget 그룹, 하나의 controller, 하나의 mapper처럼 한 문장으로 설명 가능해야 한다. |
| page 크기 | route page는 250줄 이하를 목표로 하고, 300줄을 넘으면 분해 후보로 본다. |
| widget 파일 크기 | feature 전용 widget 파일은 300줄 이하를 목표로 하고, section 단위 파일로 나눌 수 있으면 나눈다. |
| build 메서드 | `build` 하나가 80줄을 넘으면 section widget, helper widget, state view로 분리한다. |
| 상태 경계 | 입력 controller와 focus node는 page/form widget에 있어도 되지만 submit, API 호출, invalidate 대상은 Provider/Controller에 둔다. |
| 네이밍 | 이름만 보고 도메인과 역할을 예측할 수 있어야 한다. `_Body`, `_Content`, `_Frame`처럼 넓은 이름은 주변 맥락 없이 의미가 약하면 구체화한다. |
| 테스트 | 분해 전후 기존 테스트가 통과해야 하며, 새로 public widget 또는 controller를 만든 경우 해당 단위 테스트를 추가한다. |
| 동작 변경 | 가독성 PR은 기본적으로 동작 변경을 포함하지 않는다. UX 변경이 필요하면 별도 이슈로 분리한다. |

## 리팩토링 원칙

1. 한 PR은 하나의 읽기 단위만 개선한다.
2. 파일 이동 PR과 상태관리 변경 PR을 섞지 않는다.
3. private widget을 옮길 때는 public API를 최소화한다.
4. 새 추상화는 실제 중복 또는 읽기 비용을 줄일 때만 추가한다.
5. Figma 좌표 상수는 page 상단에 길게 두지 않고 layout/widget 파일 가까이에 둔다.
6. mock fixture, view model, controller input은 UI widget과 분리한다.
7. `BuildContext`가 필요한 navigation/snackbar/dialog는 page 또는 presentation event handler에 남기고, repository 호출은 controller로 내린다.
8. `ref.watch`는 rebuild가 필요한 가장 작은 widget에서 호출한다.
9. 주석은 "왜 이렇게 했는지"를 설명할 때만 추가한다.
10. 리팩토링 PR에서도 `fvm dart format`, `fvm flutter analyze`, `fvm flutter test`를 통과해야 한다.

## 금지 패턴과 대체 패턴

### 1. page 파일에 modal과 dialog를 계속 추가하지 않는다

나쁜 흐름:

```dart
class ProfileSetupPage extends ConsumerStatefulWidget {
  // page state
}

class _ProfileImageActionSheet extends StatelessWidget {
  // sheet UI
}

class _ProfilePhotoPermissionDialog extends StatelessWidget {
  // dialog UI
}
```

권장 흐름:

```text
lib/features/login/presentation/pages/profile_setup_page.dart
lib/features/login/presentation/widgets/profile_setup_layout.dart
lib/features/login/presentation/widgets/profile_image_action_sheet.dart
lib/features/login/presentation/widgets/profile_photo_permission_dialog.dart
```

page는 아래처럼 조립과 event 연결을 맡는다.

```dart
return ProfileSetupLayout(
  nicknameController: _nicknameController,
  isTermsAccepted: isTermsAccepted,
  isSubmitting: _isSubmitting,
  hasImage: _hasImage,
  onBack: _goBack,
  onImagePressed: _openProfileImageSheet,
  onTermsPressed: _handleTermsCheck,
  onComplete: () => _handleComplete(isTermsAccepted),
);
```

### 2. 생성/수정 화면을 한 build에서 끝까지 읽게 만들지 않는다

나쁜 흐름:

```dart
@override
Widget build(BuildContext context) {
  if (widget.isEdit) {
    return _buildEditMode();
  }

  final remotePlaces = ref.watch(plantRegistrationPlaceProvider);
  final places = _registrationPlacesFromSummaries(remotePlaces.value ?? []);
  return _PlantCreateScaffold(...);
}
```

권장 흐름:

```dart
@override
Widget build(BuildContext context) {
  return widget.isEdit
      ? PlantEditFormRoute(plantId: widget.plantId!)
      : PlantCreateFormRoute(initialPlantName: _selectedPlantName);
}
```

초기에는 별도 route class까지 나누지 않아도 된다. 다만 create/edit UI, place picker, bottom actions는 page 밖 파일로 먼저 이동한다.

### 3. 전용 widget 파일 하나에 section을 계속 누적하지 않는다

나쁜 흐름:

```text
plant_detail_widgets.dart
  PlantHero
  PlantCareSummary
  MemoPreviewSection
  PlantInfoSection
  _PlantHeroImage
  _PlaceBadge
  _PlantDateSummary
  _PlantMemoCard
```

권장 흐름:

```text
widgets/
  plant_detail_content_width.dart
  plant_hero.dart
  plant_care_summary.dart
  plant_memo_preview_section.dart
  plant_info_section.dart
```

## 목표 파일 배치

새 파일을 만들 때는 기존 feature-first 구조를 유지한다.

```text
lib/features/<feature>/
  presentation/
    pages/
      <route>_page.dart
    widgets/
      <screen>_layout.dart
      <screen>_<section>.dart
      <screen>_<dialog_or_sheet>.dart
    providers/
      <screen>_controller.dart
      <screen>_view_provider.dart
    models/
      <screen>_view_state.dart
    fixtures/
      <screen>_fixture.dart
```

폴더는 실제 파일이 생길 때만 추가한다. 빈 폴더를 먼저 만들지 않는다.

## 우선순위

| 우선순위 | 작업 | 이유 |
| --- | --- | --- |
| P0 | `profile_setup_page.dart` 분해 | 현재 가장 큰 파일이며 dialog, sheet, form widget이 page에 모두 있다. |
| P0 | `plant_form_page.dart` create/edit/widget 분해 | 생성/수정 분기와 submit 흐름이 길어 식물 등록/수정 작업의 진입 비용이 높다. |
| P1 | `home_screen.dart` section 분해 | 홈은 여러 도메인의 목록 상태를 소비하므로 이후 API/UX 변경 때 충돌 가능성이 크다. |
| P1 | Place/Plant detail widget 파일 section 분해 | page는 줄었지만 전용 widget 파일이 다시 큰 파일이 되어가고 있다. |
| P1 | Memo list/write page 분해 | Memo 기능 확장 전에 local interaction과 dialog를 분리한다. |
| P2 | shared widget variant 분해 | 공용 위젯 변경의 회귀 범위를 줄인다. |
| P2 | raw response 경계 축소 | Swagger 확정 범위에서 API 계층의 읽기 비용을 줄인다. |

## 실행 계획

각 task는 별도 GitHub 이슈, Project 10 항목, 브랜치, PR로 분리했다. 브랜치는 항상 최신 `develop`에서 생성한다.

아래 Task 1~7은 2026-06-28 기준 모두 완료되었으며, 세부 step은 작업 기록과 향후 유사 리팩토링의 참고 기준으로 남긴다.

### Task 1: Profile setup page 분해

**Files:**

- Modify: `lib/features/login/presentation/pages/profile_setup_page.dart`
- Create: `lib/features/login/presentation/widgets/profile_setup_layout.dart`
- Create: `lib/features/login/presentation/widgets/profile_avatar.dart`
- Create: `lib/features/login/presentation/widgets/profile_nickname_field.dart`
- Create: `lib/features/login/presentation/widgets/profile_terms_agreement_row.dart`
- Create: `lib/features/login/presentation/widgets/profile_complete_button.dart`
- Create: `lib/features/login/presentation/widgets/profile_image_action_sheet.dart`
- Create: `lib/features/login/presentation/widgets/profile_photo_permission_dialog.dart`
- Test: `test/features/login/presentation/pages/profile_setup_page_test.dart`

- [ ] **Step 1: 기존 테스트 기준선을 확인한다**

```bash
fvm flutter test test/features/login/presentation/pages/profile_setup_page_test.dart
```

Expected: 기존 프로필 설정 화면 테스트가 모두 통과한다.

- [ ] **Step 2: page의 역할을 event 연결과 layout 조립으로 축소한다**

`ProfileSetupPage`는 `TextEditingController`, `FocusNode`, `FormSubmitController`, navigation, sheet/dialog 호출만 유지한다.

```dart
return ProfileSetupLayout(
  nicknameController: _nicknameController,
  nicknameFocusNode: _nicknameFocusNode,
  hasImage: _hasImage,
  isTermsAccepted: isTermsAccepted,
  isSubmitting: _isSubmitting,
  onBack: _goBack,
  onImagePressed: _openProfileImageSheet,
  onTermsPressed: _handleTermsCheck,
  onComplete: () => _handleComplete(isTermsAccepted),
);
```

- [ ] **Step 3: modal과 dialog를 별도 파일로 이동한다**

`_ProfileImageActionSheet`, `_ProfileActionSheetTitle`, `_ProfileActionSheetButton`, `_ProfileSheetDivider`는 `profile_image_action_sheet.dart`로 이동한다.

`_ProfilePhotoPermissionDialog`, `_ProfilePermissionActionButton`은 `profile_photo_permission_dialog.dart`로 이동한다.

- [ ] **Step 4: form section widget을 별도 파일로 이동한다**

`_ProfileAvatar`, `_ProfileNicknameField`, `_TermsAgreementRow`, `_ProfileCompleteButton`을 각각 독립 파일로 이동한다. page 외부에서 쓰는 class는 private 이름을 제거한다.

- [ ] **Step 5: import와 visibility를 정리한다**

page에서 더 이상 직접 쓰지 않는 asset/theme import를 제거한다. 옮긴 widget 파일은 필요한 theme/asset만 import한다.

- [ ] **Step 6: 검증한다**

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test test/features/login/presentation/pages/profile_setup_page_test.dart
fvm flutter test
```

Expected: 전체 테스트가 통과한다.

- [ ] **Step 7: 커밋한다**

```bash
git add lib/features/login/presentation/pages/profile_setup_page.dart lib/features/login/presentation/widgets test/features/login/presentation/pages/profile_setup_page_test.dart
git commit -m "Refactor: 프로필 설정 화면 분리 #이슈번호"
```

### Task 2: Plant form page 분해

**Files:**

- Modify: `lib/features/plant/presentation/pages/plant_form_page.dart`
- Create: `lib/features/plant/presentation/widgets/plant_form_scaffold.dart`
- Create: `lib/features/plant/presentation/widgets/plant_place_picker.dart`
- Create: `lib/features/plant/presentation/widgets/plant_watering_date_field.dart`
- Create: `lib/features/plant/presentation/widgets/plant_form_bottom_actions.dart`
- Create: `lib/features/plant/presentation/models/plant_registration_place.dart`
- Test: `test/features/plant/presentation/pages/plant_form_page_test.dart`
- Test: `test/features/plant/presentation/providers/plant_form_controller_test.dart`

- [ ] **Step 1: 기존 테스트 기준선을 확인한다**

```bash
fvm flutter test test/features/plant/presentation/pages/plant_form_page_test.dart
fvm flutter test test/features/plant/presentation/providers/plant_form_controller_test.dart
```

Expected: 식물 생성/수정 화면과 controller 테스트가 모두 통과한다.

- [ ] **Step 2: `_PlantRegistrationPlace`를 presentation model로 이동한다**

`plant_registration_place.dart`에 `PlantRegistrationPlace`를 만든다. page 내부 static fallback list는 model 파일이 아니라 page 또는 fixture에 남겨 실제 데이터와 구분한다.

```dart
class PlantRegistrationPlace {
  const PlantRegistrationPlace({
    required this.id,
    required this.name,
    required this.imageAsset,
  });

  final String id;
  final String name;
  final String imageAsset;
}
```

- [ ] **Step 3: create/edit scaffold를 분리한다**

`_PlantCreateScaffold`와 `_PlantEditScaffold`를 `plant_form_scaffold.dart`로 이동한다. 파일 이름은 두 scaffold가 한 화면의 create/edit shell이라는 점을 드러낸다.

- [ ] **Step 4: 입력 보조 widget을 분리한다**

`_PlantPlacePicker`, `_PlantWateringDateField`, `_PlantFormBottomActions`, `_PlantEditPhotoButton`을 각각 역할에 맞는 파일로 이동한다.

- [ ] **Step 5: page의 private method 이름을 제출 흐름 중심으로 정리한다**

권장 이름:

| 현재 이름 | 유지 또는 변경 |
| --- | --- |
| `_buildEditMode` | `_buildEditRoute` |
| `_buildEditScaffold` | widget 이동 후 제거 |
| `_submitCreate` | 유지 |
| `_submitEdit` | 유지 |
| `_showSubmitErrorIfNeeded` | `_showSubmitErrorSnackBar` |

- [ ] **Step 6: 검증한다**

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test test/features/plant/presentation/pages/plant_form_page_test.dart
fvm flutter test test/features/plant/presentation/providers/plant_form_controller_test.dart
fvm flutter test
```

Expected: 전체 테스트가 통과한다.

- [ ] **Step 7: 커밋한다**

```bash
git add lib/features/plant/presentation/pages/plant_form_page.dart lib/features/plant/presentation/widgets lib/features/plant/presentation/models test/features/plant/presentation
git commit -m "Refactor: 식물 폼 화면 분리 #이슈번호"
```

### Task 3: Home screen section 분해

**Files:**

- Modify: `lib/features/home/presentation/home_screen.dart`
- Create: `lib/features/home/presentation/widgets/home_frame.dart`
- Create: `lib/features/home/presentation/widgets/home_hero.dart`
- Create: `lib/features/home/presentation/widgets/home_body.dart`
- Create: `lib/features/home/presentation/widgets/home_sections.dart`
- Create: `lib/features/home/presentation/widgets/home_bottom_tab_bar.dart`
- Test: 관련 홈 화면 widget test가 있으면 해당 파일을 유지하고, 없으면 `test/features/home/presentation/home_screen_test.dart`를 추가한다.

- [ ] **Step 1: 홈 화면 테스트 상태를 확인한다**

```bash
fvm flutter test test/widget_test.dart
```

Expected: 앱 루트 또는 홈 진입 테스트가 통과한다.

- [ ] **Step 2: hero와 frame을 분리한다**

`_HomeFigmaFrame`은 `HomeFrame`, `_HomeHero`는 `HomeHero`로 이동한다.

- [ ] **Step 3: data 상태 분기를 `HomeBody`로 이동한다**

`HomeBody`는 `placeSummariesProvider`, `plantSummariesProvider`를 watch한다. `HomeScreen`은 system UI와 scaffold만 유지한다.

- [ ] **Step 4: section과 bottom tab을 분리한다**

`_HomeSectionHeader`, `_HomePlaceRequestButton`, `_HomeSectionAddButton`, `_HomeAddTile`은 `home_sections.dart`로 이동한다.

`_HomeBottomTabBar`, `_HomeBottomTabItem`, `_HomeGardenTabItem`은 `home_bottom_tab_bar.dart`로 이동한다.

- [ ] **Step 5: 검증한다**

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test
```

Expected: 전체 테스트가 통과한다.

- [ ] **Step 6: 커밋한다**

```bash
git add lib/features/home/presentation test/features/home test/widget_test.dart
git commit -m "Refactor: 홈 화면 섹션 분리 #이슈번호"
```

### Task 4: Detail widget 파일 section 분해

**Files:**

- Modify: `lib/features/plant/presentation/widgets/plant_detail_widgets.dart`
- Create: `lib/features/plant/presentation/widgets/plant_detail_content_width.dart`
- Create: `lib/features/plant/presentation/widgets/plant_hero.dart`
- Create: `lib/features/plant/presentation/widgets/plant_care_summary.dart`
- Create: `lib/features/plant/presentation/widgets/plant_memo_preview_section.dart`
- Create: `lib/features/plant/presentation/widgets/plant_info_section.dart`
- Modify: `lib/features/place/presentation/widgets/place_detail_widgets.dart`
- Create: `lib/features/place/presentation/widgets/place_detail_header.dart`
- Create: `lib/features/place/presentation/widgets/place_plant_list.dart`
- Create: `lib/features/place/presentation/widgets/place_detail_fab.dart`
- Test: `test/features/plant/presentation/widgets/plant_detail_widgets_test.dart`
- Test: `test/features/place/presentation/widgets/place_detail_widgets_test.dart`

- [ ] **Step 1: 기존 widget 테스트를 확인한다**

```bash
fvm flutter test test/features/plant/presentation/widgets/plant_detail_widgets_test.dart
fvm flutter test test/features/place/presentation/widgets/place_detail_widgets_test.dart
```

Expected: 기존 상세 전용 widget 테스트가 통과한다.

- [ ] **Step 2: Plant detail section을 파일 단위로 나눈다**

`PlantHero`, `PlantCareSummary`, `MemoPreviewSection`, `PlantInfoSection`을 각각 파일로 이동한다. helper widget은 해당 section 안에서만 쓰이면 같은 파일의 private class로 둔다.

- [ ] **Step 3: Place detail section을 파일 단위로 나눈다**

`PlaceDetailHeader`, `PlacePlantList`, `PlaceDetailFab`를 각각 파일로 이동한다. `_PlaceMetricStrip`, `_PlaceFriendStrip`처럼 header 내부에서만 쓰는 class는 `place_detail_header.dart`에 둔다.

- [ ] **Step 4: barrel 파일을 만들지 않는다**

초기 분해 PR에서는 `widgets.dart` barrel export를 만들지 않는다. import가 실제 의존성을 드러내도록 둔다.

- [ ] **Step 5: 검증한다**

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test test/features/plant/presentation/widgets/plant_detail_widgets_test.dart
fvm flutter test test/features/place/presentation/widgets/place_detail_widgets_test.dart
fvm flutter test
```

Expected: 전체 테스트가 통과한다.

- [ ] **Step 6: 커밋한다**

```bash
git add lib/features/plant/presentation/widgets lib/features/place/presentation/widgets test/features/plant/presentation/widgets test/features/place/presentation/widgets
git commit -m "Refactor: 상세 위젯 파일 분리 #이슈번호"
```

### Task 5: Memo page interaction 분해

**Files:**

- Modify: `lib/features/memo/presentation/pages/memo_list_page.dart`
- Modify: `lib/features/memo/presentation/pages/memo_write_page.dart`
- Create: `lib/features/memo/presentation/widgets/memo_list_content.dart`
- Create: `lib/features/memo/presentation/widgets/memo_empty_view.dart`
- Create: `lib/features/memo/presentation/widgets/memo_delete_dialog.dart`
- Test: `test/features/memo/presentation/pages/memo_list_page_test.dart`
- Test: `test/features/memo/presentation/pages/memo_write_page_test.dart`

- [ ] **Step 1: 기존 Memo 테스트를 확인한다**

```bash
fvm flutter test test/features/memo/presentation/pages/memo_list_page_test.dart
fvm flutter test test/features/memo/presentation/pages/memo_write_page_test.dart
```

Expected: 메모 목록/작성 테스트가 모두 통과한다.

- [ ] **Step 2: 삭제 dialog를 분리한다**

`showDialog` 호출은 page에 남기고, dialog body widget은 `memo_delete_dialog.dart`로 이동한다.

- [ ] **Step 3: 목록 content와 empty view를 분리한다**

목록 렌더링은 `MemoListContent`, 빈 상태는 `MemoEmptyView`가 담당한다.

- [ ] **Step 4: 검증한다**

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test test/features/memo/presentation/pages/memo_list_page_test.dart
fvm flutter test test/features/memo/presentation/pages/memo_write_page_test.dart
fvm flutter test
```

Expected: 전체 테스트가 통과한다.

- [ ] **Step 5: 커밋한다**

```bash
git add lib/features/memo/presentation test/features/memo/presentation
git commit -m "Refactor: 메모 화면 위젯 분리 #이슈번호"
```

### Task 6: shared widget variant 분해

**Files:**

- Modify: `lib/shared/widgets/common_button.dart`
- Modify: `lib/shared/widgets/common_text_field.dart`
- Test: `test/shared/widgets/common_button_test.dart`
- Test: `test/shared/widgets/common_scaffold_test.dart`

- [ ] **Step 1: shared widget 테스트 기준선을 확인한다**

```bash
fvm flutter test test/shared/widgets/common_button_test.dart
fvm flutter test test/shared/widgets/common_scaffold_test.dart
```

Expected: 공용 widget 테스트가 통과한다.

- [ ] **Step 2: public API를 먼저 고정한다**

기존 feature가 사용하는 constructor와 enum 이름을 유지한다. 새 이름이 필요하면 기존 이름을 바로 제거하지 않고 한 PR에서 호출부까지 함께 바꾼다.

- [ ] **Step 3: style 계산을 private helper로 분리한다**

button/text field의 variant별 색상, border, padding 계산이 길면 UI build와 style resolution을 분리한다.

```dart
class _CommonButtonStyle {
  const _CommonButtonStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
}
```

- [ ] **Step 4: 검증한다**

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test test/shared/widgets/common_button_test.dart
fvm flutter test
```

Expected: 전체 테스트가 통과한다.

- [ ] **Step 5: 커밋한다**

```bash
git add lib/shared/widgets test/shared/widgets
git commit -m "Refactor: 공용 위젯 스타일 분리 #이슈번호"
```

### Task 7: raw response 경계 축소

**Files:**

- Modify: `lib/features/friend/data/datasources/friend_remote_data_source.dart`
- Modify: `lib/features/friend/data/repositories/friend_repository.dart`
- Modify: `lib/features/image/data/datasources/image_remote_data_source.dart`
- Modify: `lib/features/image/data/repositories/image_repository.dart`
- Test: `test/features/friend/data/datasources/friend_remote_data_source_test.dart`
- Test: `test/features/image/data/repositories/image_repository_test.dart`

- [ ] **Step 1: Swagger에서 응답 body가 확정된 API만 선택한다**

응답 schema가 비어 있거나 백엔드 확인이 필요한 API는 raw response 축소 대상에서 제외한다.

- [ ] **Step 2: 확정된 응답만 DTO 또는 value object로 감싼다**

예를 들어 image download URL이 문자열로 확정되면 presentation이 `Object?`를 보지 않도록 repository 반환 타입을 명확히 한다.

```dart
class ImageDownloadUrl {
  const ImageDownloadUrl(this.value);

  final String value;
}
```

- [ ] **Step 3: mapper test를 repository test와 분리한다**

JSON 구조 해석은 mapper test에서, datasource 호출과 repository 조합은 repository/datasource test에서 검증한다.

- [ ] **Step 4: 검증한다**

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test test/features/friend/data
fvm flutter test test/features/image/data
fvm flutter test
```

Expected: 전체 테스트가 통과한다.

- [ ] **Step 5: 커밋한다**

```bash
git add lib/features/friend lib/features/image test/features/friend test/features/image
git commit -m "Refactor: API 응답 경계 정리 #이슈번호"
```

## PR 작성 기준

가독성 리팩토링 PR은 아래 문구를 본문에 포함한다.

```markdown
## 관련 이슈
- Closes #이슈번호

## 구현 범위
- 동작 변경 없이 파일 책임을 분리했습니다.
- 기존 테스트가 다루는 사용자 동작은 유지했습니다.

## 테스트
- `fvm dart format --output=none --set-exit-if-changed .`
- `fvm flutter analyze`
- `fvm flutter test`

## 리뷰 포인트
- 새 파일 경계가 한 문장으로 설명되는지
- page가 과도한 UI 세부사항을 계속 들고 있지 않은지
- public API가 불필요하게 넓어지지 않았는지
```

## 리뷰 체크리스트

- [ ] 파일 이름과 class 이름만 보고 역할을 예측할 수 있다.
- [ ] route page가 화면 조립, navigation, snackbar/dialog 호출 이상의 책임을 갖지 않는다.
- [ ] section widget은 domain data를 표시하고, repository나 datasource를 직접 알지 않는다.
- [ ] controller는 `BuildContext`에 의존하지 않는다.
- [ ] `ref.watch`가 rebuild가 필요한 가장 작은 단위에 있다.
- [ ] 새 public widget의 생성자는 필요한 값과 callback만 받는다.
- [ ] private helper가 다른 파일에서 필요해졌다면 명확한 public 이름으로 승격했다.
- [ ] 테스트 이름이 사용자 행동 또는 상태 전이를 설명한다.
- [ ] 동작 변경이 포함되었다면 별도 이슈로 분리했거나 PR 본문에 명시했다.

## 완료 판단

가독성 리팩토링 라운드는 아래 조건을 만족하면 완료로 본다.

- [x] 500줄 이상 page 파일이 없다.
- [x] 400줄 이상 feature 전용 widget 파일이 없다.
- [x] `profile_setup_page.dart`, `plant_form_page.dart`, `home_screen.dart`의 route page 책임이 조립 중심으로 축소되었다.
- [x] Place/Plant 상세 section widget이 파일 단위로 분리되었다.
- [x] Memo 화면의 dialog와 empty/list content가 page 밖으로 분리되었다.
- [x] shared widget 변경 시 영향받는 variant를 테스트에서 바로 찾을 수 있다.
- [x] presentation 계층에서 raw API response를 직접 해석하지 않는다.
- [x] 전체 `fvm flutter test`가 통과한다.

## 완료된 이슈

- `[Task] Profile setup page 가독성 리팩토링`
- `[Task] Plant form page 가독성 리팩토링`
- `[Task] Home screen section 분리`
- `[Task] Place/Plant 상세 widget 파일 분리`
- `[Task] Memo 화면 interaction widget 분리`
- `[Task] shared widget variant 구조 정리`
- `[Task] raw API response 경계 축소`

## 다음 구조 개선 후보

다음 라운드는 [lib 구조 리팩토링 개선 방향](lib-refactoring-direction.md)의 남은 진단 항목을 기준으로 재평가한다.
재평가한 2차 작업 단위는 [코드 가독성 리팩토링 2차 계획](code-readability-refactoring-round-2-plan.md)에서 관리한다.

- `[Task] 라우트 파라미터 검증 헬퍼 추가`
- `[Task] Place 폼 Controller 분리`
- `[Task] Plant 폼 Controller 분리`
- `[Task] 장소/식물 상세 액션 Controller 분리`
- `[Task] 상세 화면 mock fixture 분리`
- `[Task] API mapper 파일 분리`
- `[Task] 인증 redirect Provider 설계`
