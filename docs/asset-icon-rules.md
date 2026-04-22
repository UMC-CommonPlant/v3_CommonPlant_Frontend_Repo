# Assets 및 Icons 규칙

이미지와 아이콘은 화면 코드에서 직접 경로 문자열을 반복하지 않고, 등록된 asset 상수와 공용 렌더링 위젯을 통해 사용합니다.

## 현재 asset 구조

```text
assets/
  fonts/
  icons/
  images/

lib/core/assets/
  app_icon_assets.dart
```

`pubspec.yaml`에는 `assets/icons/`, `assets/images/`가 폴더 단위로 등록되어 있습니다.

## 파일 네이밍

새 asset은 아래 규칙을 따릅니다.

| 대상 | 규칙 | 예시 |
| --- | --- | --- |
| SVG 아이콘 | lowercase snake_case | `add_place.svg` |
| 태그 아이콘 | `tag_` prefix | `tag_sunlight.svg` |
| 로고 | `logo_` prefix | `logo_wordmark_common.svg` |
| 빈 상태 | `{domain}_empty.svg` | `plant_empty.svg` |
| 일반 이미지 | lowercase snake_case | `place_default.png` |
| 해상도 variant | Flutter asset variant 규칙 또는 명확한 suffix | `place_default@3x.png` |

새 파일에는 대문자, 공백, 한글 파일명을 사용하지 않습니다. 현재 `Delete.svg`처럼 기존에 들어온 예외 파일은 레거시로 보고 새 파일에서는 반복하지 않습니다.

## 아이콘 등록

SVG 아이콘을 추가하면 `lib/core/assets/app_icon_assets.dart`에 상수를 추가합니다.

```dart
static const String addPlace = 'assets/icons/add_place.svg';
```

상수명은 camelCase를 사용하고, 파일명은 snake_case를 사용합니다.

## 아이콘 사용

화면과 공용 위젯에서는 `SvgPicture.asset`을 직접 호출하지 않고 `CommonSvgIcon`을 사용합니다.

```dart
const CommonSvgIcon(
  AppIconAssets.search,
  width: AppSizes.iconMedium,
  height: AppSizes.iconMedium,
  semanticsLabel: '검색',
)
```

아이콘 크기는 `AppSizes` 값을 우선 사용합니다. 같은 크기가 반복되면 새 size 토큰을 추가합니다.

## 색상 처리

- 원본 SVG 색상이 디자인 의미를 가진 경우 파일 색상을 유지합니다.
- 상태에 따라 색상이 바뀌는 아이콘은 `CommonSvgIcon`의 색상 주입 가능 여부를 확인한 뒤 적용합니다.
- 화면 코드에서 SVG 내부 색상을 임시로 바꾸기 위해 새 파일을 복제하지 않습니다.
- disabled, active, danger 상태는 가능한 테마 토큰 색상을 사용합니다.

## 이미지 사용

- 사진 또는 일러스트 이미지는 `assets/images`에 둡니다.
- 도메인 기본 이미지는 `place_default`, `plant_default`처럼 의미가 드러나는 이름을 사용합니다.
- feature 전용 이미지가 늘어나면 `assets/images/{feature}/` 하위 분리를 검토합니다.
- 네트워크 이미지와 로컬 asset fallback은 화면에서 직접 분기하기보다 feature widget에서 캡슐화합니다.

## 추가 절차

1. Figma export 이름을 프로젝트 네이밍 규칙에 맞게 정리합니다.
2. SVG는 불필요한 metadata와 canvas 크기를 확인합니다.
3. 파일을 `assets/icons` 또는 `assets/images`에 추가합니다.
4. 아이콘이면 `AppIconAssets`에 상수를 추가합니다.
5. 사용 위치에서 `CommonSvgIcon` 또는 적절한 이미지 위젯을 사용합니다.
6. `fvm flutter test` 또는 앱 실행으로 asset load 오류가 없는지 확인합니다.

## 체크리스트

- [ ] 파일명이 lowercase snake_case인가?
- [ ] 아이콘 경로가 `AppIconAssets`에 등록되었는가?
- [ ] 화면 코드에 asset path 문자열이 직접 반복되지 않는가?
- [ ] 의미 있는 `semanticsLabel`을 제공했는가?
- [ ] 같은 아이콘의 색상별 복제 파일을 불필요하게 만들지 않았는가?
- [ ] `pubspec.yaml` asset 등록 범위 안에 있는가?

## 결정 필요

- Figma export 시 SVG 최적화 도구 사용 여부를 정해야 합니다.
- 이미지 압축 기준과 최대 파일 크기 기준은 아직 정해지지 않았습니다.
