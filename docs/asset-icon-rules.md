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
  app_image_assets.dart
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

새 파일에는 대문자, 공백, 한글 파일명을 사용하지 않습니다. 기존에 들어온 예외 파일도 발견되면 별도 cleanup 작업으로 lowercase snake_case에 맞게 정리합니다.

## 아이콘 등록

SVG 아이콘을 추가하면 `lib/core/assets/app_icon_assets.dart`에 상수를 추가합니다. 이미지 asset을 추가하면 `lib/core/assets/app_image_assets.dart`에 상수를 추가합니다.

```dart
static const String addPlace = 'assets/icons/add_place.svg';
static const String placeDefaultIllustration =
    'assets/images/place_default_illustration.png';
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

## SVG 최적화 기준

ASSET-01에서는 SVG 용량 자체보다 Flutter 렌더링 호환성과 변경 리뷰 가능성을 우선합니다. SVGO `4.0.1`을 보조 도구로 채택하되, 기본 preset을 그대로 사용하거나 기존 asset 전체를 일괄 변환하지 않습니다.

판단 근거는 [SVGO 4.0.1 release](https://github.com/svg/svgo/releases/tag/v4.0.1), [SVGO preset-default 구성](https://svgo.dev/docs/preset-default/), [flutter_svg의 SVG 호환성 검사 안내](https://pub.dev/packages/flutter_svg)를 기준으로 합니다.

2026-08-19 기준 `assets/icons`, `assets/images`에는 SVG 35개, 총 71,032 byte가 있습니다. 모두 XML parse와 `viewBox` 검사를 통과했으며, 보수 설정을 적용한 복사본도 71,032 byte로 원본과 동일했습니다. 반면 SVGO 기본 preset은 38,696 byte로 45.52% 줄었지만 path 좌표, 색상 표기, ID, group 구조까지 변경했습니다. 현재 bundle 규모에서는 이 차이보다 시각 회귀와 대규모 diff 위험이 크므로 기본 preset은 사용하지 않습니다.

### 도구와 설정

- 버전은 `SVGO 4.0.1`로 고정합니다.
- Node 의존성을 앱 package에 추가하지 않고 `npx --yes svgo@4.0.1`로 실행합니다.
- 설정은 `tool/svg/svgo.config.mjs`를 사용합니다.
- 자동 변환은 doctype, XML processing instruction, comment, metadata, 편집기 namespace, script, 빈 attribute, 미사용 namespace 정리로 제한합니다.
- 출력은 먼저 별도 후보 파일로 만들며 검증 전 원본을 덮어쓰지 않습니다.
- 불필요한 정보가 실제로 제거되지 않거나 formatting만 바뀌거나 파일이 커지면 원본을 유지합니다. 최소 절감률을 품질 게이트로 두지 않습니다.

```bash
svg_source=path/to/figma_export.svg
svg_candidate=/tmp/commonplant_candidate.svg

npx --yes svgo@4.0.1 \
  --config tool/svg/svgo.config.mjs \
  --input "$svg_source" \
  --output "$svg_candidate"
```

### 자동 변경 금지와 수동 검토 대상

아래 항목은 현재 설정으로 자동 변경하지 않습니다.

- root `width`, `height`, `viewBox`, `preserveAspectRatio`
- `id`와 `url(#...)`로 연결된 mask, gradient, clipPath, defs
- `fill`, `stroke`, `currentColor`, CSS variable fallback을 포함한 색상 표기
- path 좌표와 숫자 정밀도, transform
- path 병합, shape 변환, group 축약 또는 이동
- `title`, `desc`와 접근성 관련 요소

`cleanupIds`, `removeDimensions`, `removeViewBox`, `convertPathData`, `convertTransform`, `convertColors`, `mergePaths`, `collapseGroups` 같은 변환이 필요하면 해당 asset만 별도 작업으로 분리하고 전후 시각 비교 근거를 남깁니다. `<script>`, event handler, 외부 URL image/font, 지원 여부가 불명확한 `<style>`/class가 발견되면 자동 정리 결과를 그대로 채택하지 않고 Figma 원본을 단순한 path/attribute 구조로 다시 export합니다.

### 신규 또는 변경 SVG 검증 순서

1. 원본과 후보의 byte 크기와 `git diff --no-index` 결과를 확인합니다.
2. `xmllint --noout /tmp/commonplant_candidate.svg`로 XML 구조를 검사합니다.
3. `vector_graphics_compiler` 호환성 검사를 실행합니다.
4. 검증된 후보만 asset 경로에 반영하고 SVG asset 회귀 테스트를 실행합니다.
5. 실제 사용 화면에서 최소·최대 표시 크기와 QA 기준 viewport를 확인합니다. 중간 크기는 비율 유지와 깨짐 여부를 확인합니다.
6. mask, gradient, CSS variable fallback, 색상 주입이 있는 asset은 해당 상태를 모두 비교합니다.

```bash
fvm dart run vector_graphics_compiler \
  -i /tmp/commonplant_candidate.svg \
  -o /tmp/commonplant_candidate.svg.vec \
  --no-optimize-masks \
  --no-optimize-clips \
  --no-optimize-overdraw \
  --no-tessellate

fvm flutter test test/core/assets/svg_assets_test.dart
```

`test/core/assets/svg_assets_test.dart`는 등록 대상 디렉터리의 모든 SVG를 `flutter_svg`로 parse하고 실제 picture로 rasterize합니다. 이 검사는 asset load와 렌더 pipeline 호환성을 확인하지만 픽셀 동일성을 보장하지 않으므로, 화면 시각 비교나 기존 golden test를 대체하지 않습니다.

기존 SVG 전체 정리가 필요하면 신규 export 적용과 분리한 이슈에서 진행합니다. 일괄 변경 PR에는 영향 화면 목록, 용량 전후, 구조 diff, 최소·최대 표시 크기 시각 비교, 관련 golden 또는 screenshot 근거가 필요합니다.

## 이미지 사용

- 사진 또는 일러스트 이미지는 `assets/images`에 둡니다.
- 도메인 기본 이미지는 `place_default`, `plant_default`처럼 의미가 드러나는 이름을 사용합니다.
- feature 전용 이미지가 늘어나면 `assets/images/{feature}/` 하위 분리를 검토합니다.
- 네트워크 이미지와 로컬 asset fallback은 화면에서 직접 분기하기보다 feature widget에서 캡슐화합니다.

## 폰트 asset

앱 기본 font family는 한글 glyph를 포함한 공식 Pretendard를 사용합니다.

| Weight | 파일 |
| --- | --- |
| 400 Regular | `assets/fonts/pretendard_regular.otf` |
| 500 Medium | `assets/fonts/pretendard_medium.otf` |
| 600 SemiBold | `assets/fonts/pretendard_semibold.otf` |
| 700 Bold | `assets/fonts/pretendard_bold.otf` |

- 출처는 [공식 Pretendard v1.3.9 release](https://github.com/orioncactus/pretendard/releases/tag/v1.3.9)의 static OTF입니다.
- 원본 `Pretendard-1.3.9.zip` SHA-256은 `04be351a74d6bf7d60c480a3087e51d185485d35a52023142af1df19eb8c428a`입니다.
- 라이선스는 SIL Open Font License 1.1이며 `assets/fonts/pretendard_ofl.txt`에 보존하고 runtime asset으로 등록해 Android/iOS 배포물에 함께 포함합니다.
- `Pretendard Std`는 라틴/그리스/키릴 전용이므로 한글 앱의 기본 font asset으로 사용하지 않습니다.
- 폰트 교체 시 내부 family가 `Pretendard`인지, weight가 `400/500/600/700`에 대응하는지, Hangul syllable `AC00-D7A3` 범위를 포함하는지 확인합니다.
- 폰트 asset 변경은 앱 전체 text metrics와 bundle 크기에 영향을 주므로 Android/iOS build와 전체 widget test를 함께 검증합니다.

## 추가 절차

1. Figma export 이름을 프로젝트 네이밍 규칙에 맞게 정리합니다.
2. SVG는 불필요한 metadata와 canvas 크기를 확인하고 위 보수 설정으로 후보를 만듭니다.
3. 후보의 구조, Flutter compiler 호환성, 실제 표시 크기를 검증합니다.
4. 파일을 `assets/icons` 또는 `assets/images`에 추가합니다.
5. 아이콘이면 `AppIconAssets`에 상수를 추가합니다.
6. 사용 위치에서 `CommonSvgIcon` 또는 적절한 이미지 위젯을 사용합니다.
7. SVG asset 회귀 테스트와 영향 화면을 확인합니다.

## 체크리스트

- [ ] 파일명이 lowercase snake_case인가?
- [ ] 아이콘 경로가 `AppIconAssets`에 등록되었는가?
- [ ] 화면 코드에 asset path 문자열이 직접 반복되지 않는가?
- [ ] 의미 있는 `semanticsLabel`을 제공했는가?
- [ ] 같은 아이콘의 색상별 복제 파일을 불필요하게 만들지 않았는가?
- [ ] `pubspec.yaml` asset 등록 범위 안에 있는가?
- [ ] SVGO 후보와 원본의 구조 diff를 검토했는가?
- [ ] `viewBox`, 크기, 색상, ID 참조가 유지되는가?
- [ ] 최소·최대 표시 크기에서 시각 회귀가 없는가?

## 결정 필요

- 이미지 압축 기준과 최대 파일 크기 기준은 아직 정해지지 않았습니다.

## ASSET-01 작업 이력

| 이슈 | 커밋 | 변경 범위 | 검증 |
| --- | --- | --- | --- |
| #207 | `a11a585` | SVGO `4.0.1` 보수 allowlist 설정 추가 | 35개 복사본 XML parse, 원본과 byte/diff 동일 확인 |
| #207 | `5720a3c` | 전체 SVG parse 및 rasterize 회귀 테스트 추가 | 대상 test 36개 통과 |
| #207 | - | 도구 채택 범위, 금지 변환, 신규/기존 적용 경계와 검증 절차 문서화 | `git diff --check`, format, analyze, 전체 test |
