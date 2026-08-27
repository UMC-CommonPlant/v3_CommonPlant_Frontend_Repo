# 공용 위젯 사용 가이드

커먼플랜트의 공용 UI는 `lib/shared/widgets`에 둡니다. 화면은 공용 위젯을 조합하고, 공용 위젯 내부 스타일은 `core/theme` 토큰을 통해 관리합니다.

## 기본 원칙

- 공용 위젯 이름은 `Common` 접두어를 사용합니다.
- 공용 위젯은 기능 화면의 비즈니스 로직을 알지 않아야 합니다.
- 색상, 크기, 여백, radius, 텍스트 스타일은 `core/theme` 토큰을 사용합니다.
- 아이콘은 `CommonSvgIcon`과 `AppIconAssets`를 통해 사용합니다.
- 화면별 상태 변화는 `onPressed`, `onTap`, `onChanged`, `validator` 같은 콜백으로 외부에서 주입합니다.

## 레이아웃

### CommonScaffold

일반 페이지의 기본 골격입니다.

- 상단 네비게이션 바 기본 적용
- 좌측 뒤로가기 버튼 고정
- 중앙 제목 배치
- 우측 trailing 슬롯 제공
- 본문 기본 좌우 패딩 `20`

```dart
CommonScaffold(
  title: '장소 등록',
  trailing: const SizedBox.shrink(),
  child: const PlaceCreateView(),
)
```

상단 네비게이션 바가 필요 없는 샘플 또는 특수 화면은 `showNavigationBar: false`를 사용할 수 있습니다.

### CommonSectionHeader

섹션 제목과 우측 액션을 나란히 배치하는 작은 헤더입니다.

- 제목 텍스트는 `20/500`
- 우측 액션은 `action` 슬롯으로 주입
- 특정 도메인 상태나 Provider를 직접 알지 않음

## 버튼

### CommonButton

일반 액션 버튼입니다.

| Size | 높이 | 기본 너비 | Radius | Text |
| --- | --- | --- | --- | --- |
| `large` | 48 | full width | 8 | 16/500 |
| `medium` | 40 | 부모 너비 기준 | 4 | 14/500 |
| `small` | 36 | 96 | 8 | 14/500 |

```dart
CommonButton(
  label: '완료',
  size: CommonButtonSize.large,
  onPressed: onSubmit,
)
```

외곽선이 필요한 경우 `borderColor`만 주입합니다. 두께는 위젯 내부에서 `1`로 고정됩니다.

### CommonPlusIconButton

36x36 영역의 플러스 아이콘 버튼입니다. 아이콘은 24x24로 중앙 정렬됩니다.

내부 플러스 도형은 `CommonPlusMark`가 담당합니다. `CommonPlusMark`는 단독 사용보다 `CommonPlusIconButton`, `CommonAddTile` 같은 공용 컨트롤 내부 primitive로 우선 사용합니다.

### CommonWateringButton

장소 내 식물 카드에서 사용하는 물주기 버튼입니다.

- 크기: 72x40
- radius: 16
- 아이콘: `watering.svg`

## 입력 필드

### CommonTextField

일반 텍스트 입력 필드입니다.

- 텍스트: 18/500
- clear 버튼: 포커스 중이고 입력값이 있을 때 표시
- counter: 현재 글자수만 Bold
- helper text: 상태에 따라 색상 변경
- `forceFocusedDecoration`: 키보드 포커스를 강제로 주지 않고 활성 line, clear 버튼, counter 스타일만 유지할 때 사용

외부 검증 조건이 필요한 경우 `validator`를 사용합니다.

```dart
CommonTextField(
  hintText: '닉네임을 입력해 주세요',
  maxLength: 10,
  validator: (value, isFocused) {
    if (value.length < 2 || value.length > 10) {
      return const CommonTextFieldValidation(
        state: CommonTextFieldState.error,
        helperText: '2~10자의 닉네임으로 입력해주세요',
      );
    }

    if (isFocused) {
      return const CommonTextFieldValidation(
        state: CommonTextFieldState.normal,
      );
    }

    return const CommonTextFieldValidation(
      state: CommonTextFieldState.success,
      helperText: '사용가능한 닉네임 입니다',
    );
  },
)
```

### CommonSearchTextField

검색 전용 입력 필드입니다.

- 높이: 64
- 좌측 search 아이콘: 24x24
- 텍스트: 18/500
- placeholder 색상: Gray/Gray3
- 입력값이 있으면 포커스 해제 후에도 Delete 아이콘 유지

### CommonAddressOrPlaceField

주소 또는 장소 선택용 필드입니다.

- 높이: 56
- 하단 border: Gray/Gray2
- 값이 없으면 우측 chevron 표시
- 값이 있으면 선택 텍스트와 Delete 아이콘 표시

```dart
CommonAddressOrPlaceField(
  label: '주소',
  value: selectedAddress,
  onTap: openAddressSearch,
  onClear: clearAddress,
)
```

## 이미지 입력

### CommonCircleImageBox

프로필 이미지 추가 영역입니다.

- 기본 크기: 100x100
- 기본 아이콘: `add_person.svg`
- 이미지가 있으면 원형으로 꽉 차게 표시
- 우측 하단 overlay는 `overlay`로 교체하고 `overlayInset`으로 Figma 내부 여백을 조정

### CommonPhotoAddButton

사진 추가 버튼입니다.

- 크기: 80x80
- border: Gray/Gray2
- camera 아이콘: 32x32
- 카운터 분자만 Bold

### CommonPlaceImageAddButton

장소 등록 이미지 추가 버튼입니다.

- 외부 크기: 120x120
- 내부 이미지 박스: 100x100
- 우측 하단 camera 버튼: 40x40

## 타일과 배너

### CommonAddTile

장소/식물 추가 카드입니다.

| Variant | 크기 | 방향 | 아이콘 |
| --- | --- | --- | --- |
| `place` | 250x156 | 가로 | `plus_green.svg` |
| `plantDisabled` | 164x108 | 세로 | `plus_gray.svg` |
| `outline` | 유동 | 세로 | 주입 가능 |

### CommonPlaceGuideBanner

장소 안내 배너입니다.

- 높이: 32
- padding: x10, y4
- 배경: SeaGreen/Dark3
- 텍스트: 14/500

## 카드

### CommonPlaceCard

장소 카드입니다.

- 크기: 250x156
- radius: 16
- 하단 그라디언트 opacity: 0.6

### CommonPlantCard

식물 카드입니다.

- 크기: 164x108
- radius: 16
- 빈 상태 아이콘: `plant_empty.svg`
- 하단 soft fade 영역: 높이 28, bottom 8

### CommonPlacePlantCard

장소 안의 식물 카드입니다.

- 크기: 335x136
- padding: 10
- 이미지: Reference에서 최대 136x108, compact에서 최소 96x96
- 이미지 폭은 카드에서 padding, 간격, 정보 영역 보호 폭을 제외한 값으로 계산하고 96~136 사이로 제한
- 이미지 높이는 계산된 폭을 따르되 96~108 사이로 제한
- 현재 정보 영역 보호 폭 156은 이 카드의 내부 배치값이므로 공용 `AppSizes`가 아닌 위젯 private 상수로 관리
- name: 16/700
- species/description/date: 12/500
- D-day: 16/500, SeaGreen/Dark2

가변 크기 요소를 추가하거나 변경할 때는 아래 순서로 검토합니다.

1. 텍스트, action, 터치 영역의 최소 크기를 먼저 보존합니다.
2. 남은 가용 공간에서 시각 요소 크기를 계산합니다.
3. 최소·최대 범위로 `clamp`하고, 여러 곳에서 공유하는 규격만 `AppSizes`에 둡니다.
4. Compact와 Reference의 계약값, 중간 폭의 범위·단조성, 모든 폭의 overflow 부재를 테스트합니다.

### CommonMemoCard

메모 카드입니다.

- 크기: 250x174
- padding: 16
- radius: 16
- shadow: x0, y1, blur4, Gray/Gray5 25%
- 작성자: 16/500
- 내용: 16/500
- 날짜: 14/500

## Dialog, Popup, FAB

### CommonDialogCard

확인/삭제 등 기본 알림 다이얼로그입니다.

- 크기: 270x148
- radius: 14
- title: 16/700
- message: 14/500
- action 영역 높이: 44
- 우측 확인 버튼은 `CommonDialogActionButton.confirm` 사용

### CommonEditDeletePopup

수정/삭제 액션 팝업입니다.

- 크기: 230x128
- radius: 16
- divider: `separatorColors` 36%
- 아이콘: 24x24
- 텍스트: 16/500

### CommonFabDial

FAB 확장 메뉴입니다.

- FAB 크기: 56x56
- 확장 시 barrier: black 60%
- 라벨: 16/700
- 라벨 배경 없음

## 아이콘 사용

SVG 아이콘은 직접 `SvgPicture.asset`을 호출하지 않고 `CommonSvgIcon`을 사용합니다.

```dart
const CommonSvgIcon(
  AppIconAssets.search,
  width: AppSizes.searchTextFieldIconSize,
  height: AppSizes.searchTextFieldIconSize,
)
```

새 아이콘을 추가할 때는 `assets/icons`에 파일을 넣고 `AppIconAssets`에 상수를 추가합니다.

## 소유권 감사 결과

2026-08-12의 소유권 정리 이후 2026-08-28 `develop` PR #246 기준으로 다시 확인했습니다. 과거 사용처가 없던 `features/common`의 Phase 0 보조 위젯은 이미 제거됐으며, 공용 UI는 `shared/widgets`, 도메인 UI는 각 feature의 `presentation/widgets`에서 소유합니다.

2026-08-28 사용자 결정에 따라 현재 미사용 공용 위젯 5개는 삭제하지 않습니다. `CommonAddTile`, `CommonPlaceGuideBanner`, `CommonPlusIconButton`, `CommonSectionHeader`는 직접 화면·테스트 사용처가 없고, `CommonPlusMark`는 미사용 `CommonPlusIconButton` 내부에서만 참조됩니다. 보존을 위해 새 화면에 억지로 연결하지 않으며, 새 사용처가 생길 때 의미와 소유권을 검토합니다.

| 분류 | 대상 | 판단 |
| --- | --- | --- |
| 공용 control로 유지 | `CommonButton`, `CommonScaffold`, `CommonNavigationBar`, `CommonSvgIcon`, `CommonTextField`, `CommonSearchTextField`, `CommonAddressOrPlaceField`, `CommonDialogCard`, `CommonDialogActionButton`, `CommonEditDeletePopup`, `CommonFab`, `CommonFabDial` | 여러 feature에서 같은 의미와 상호작용으로 쓰이고 도메인 정책을 알지 않으므로 `shared/widgets`에 둡니다. |
| 공용 primitive로 유지 | `CommonPlusMark` | `CommonPlusIconButton` 내부 primitive로만 사용합니다. 화면별 조합 로직은 넣지 않습니다. |
| 공용 image input 후보 | `CommonCircleImageBox`, `CommonPhotoAddButton`, `CommonPlaceImageAddButton` | 이미지 선택 UI라는 공통성이 있습니다. 다만 `CommonPlaceImageAddButton`처럼 특정 도메인 이름이 들어간 위젯은 다른 feature로 확장하기 전에 generic variant 추가 또는 feature 내부 이동을 먼저 검토합니다. |
| 공용 display 후보 | `CommonPlaceCard`, `CommonPlantCard`, `CommonPlacePlantCard`, `CommonMemoCard`, `CommonWateringButton` | Home, Place, Plant, Memo 사이에서 같은 카드 표현을 공유할 가능성이 있어 당장은 유지합니다. API 상태, route 이동, 권한 정책이 들어가기 시작하면 feature 내부 widget으로 내리거나 domain-agnostic display model을 주입하는 방식으로 정리합니다. |
| 미사용 상태로 보존 | `CommonAddTile`, `CommonPlaceGuideBanner`, `CommonPlusIconButton`, `CommonSectionHeader` | 사용자 결정으로 유지합니다. 사용처가 생기면 도메인 전용인지 공용인지 재검토하며, 이번 정리에서는 삭제·이동하지 않습니다. |

공용 위젯 보존과 동작 오류 수정은 별개입니다. 비활성 `CommonTextField`의 삭제 버튼 문제는 [#255](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/255)에서 수정하고, 기존 버튼 variant 등 public API를 단순 미사용이라는 이유로 축소하지 않습니다. 실행 순서는 [개발 감사 체크리스트](development-audit-checklist.md)를 따릅니다.

### Phase 0 구조 정리 결과

- `Phase0Section`, `Phase0Surface`, `Phase0Chip`, `Phase0EmptyState`, `Phase0UserAvatar`, `Phase0InfoRow`는 production/test 사용처가 없어 제거했습니다.
- 위 위젯만 소유하던 `lib/features/common` 빈 구조도 제거했습니다.
- 이후 feature 공통처럼 보이는 UI도 먼저 실제 재사용 주체를 확인하고 `shared/widgets` 또는 도메인 feature에 배치합니다.

### 이동 판단 기준

- 두 개 이상의 feature에서 같은 형태와 같은 상호작용으로 쓰이면 `shared/widgets` 유지 또는 승격을 검토합니다.
- 도메인 이름이 들어간 위젯은 여러 feature에서 같은 의미로 재사용되는 display 컴포넌트일 때만 `shared/widgets`에 둡니다.
- route 이동, Provider watch, API 상태, 권한 정책을 알게 되는 순간 feature 내부 `presentation/widgets` 또는 `presentation/providers`로 내립니다.
- Figma 특정 section, banner, form 조합처럼 한 화면의 배치 의도가 강한 위젯은 공용화하지 않습니다.
- `shared/widgets`에서 feature 내부로 이동하는 PR은 동작 변경 없이 import와 테스트만 함께 정리합니다.
- 공용 위젯이 300줄을 넘거나 variant가 늘어나면 primitive, style, variant 파일 분리를 검토합니다.

## 새 공용 위젯 추가 체크리스트

- [ ] `lib/shared/widgets/common_*.dart` 이름으로 추가했는가?
- [ ] style 값이 `core/theme` 토큰을 사용하고 있는가?
- [ ] 필요한 asset이 `AppIconAssets`에 등록되어 있는가?
- [ ] 상태 변화가 콜백으로 외부 주입 가능한가?
- [ ] 두 개 이상의 feature에서 같은 의미로 재사용되는가?
- [ ] 도메인 정책, route, Provider, API 모델을 직접 알지 않는가?
- [ ] 샘플 화면에서 확인 가능한가?
- [ ] `fvm flutter analyze`를 통과하는가?
- [ ] 필요한 경우 widget test를 갱신했는가?
