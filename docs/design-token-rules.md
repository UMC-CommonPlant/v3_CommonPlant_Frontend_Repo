# 디자인 토큰 규칙

커먼플랜트 UI는 화면에서 raw color, spacing, radius, typography 값을 직접 사용하지 않고 `lib/core/theme`의 토큰을 통해 스타일을 적용합니다.

## 토큰 파일 구조

| 파일 | 역할 |
| --- | --- |
| `app_colors.dart` | Figma 색상 원본값, 의미 기반 색상, 그라디언트 정의 |
| `app_text_styles.dart` | Pretendard 기반 텍스트 스타일 정의 |
| `app_spacing.dart` | 공통 여백 단위 정의 |
| `app_radius.dart` | 공통 border radius 정의 |
| `app_sizes.dart` | 컴포넌트별 고정 크기와 아이콘 크기 정의 |
| `app_theme_tokens.dart` | `ThemeExtension`으로 주입되는 의미 기반 테마 토큰 |
| `app_theme.dart` | 앱 전체 `ThemeData` 구성 |

## 색상 규칙

색상은 아래 우선순위로 사용합니다.

1. 화면과 공용 위젯에서는 `AppThemeTokens` 또는 `AppColors`의 의미 기반 이름을 사용합니다.
2. Figma 원본값을 추가해야 할 때는 `AppColorPrimitives`에 먼저 등록합니다.
3. `AppColorPrimitives`에 등록한 값은 가능하면 `AppColors`의 의미 기반 이름으로 한 번 더 연결합니다.
4. `Color(0x...)`, `Colors.black`, `Colors.white` 같은 raw color는 화면 코드에서 직접 사용하지 않습니다.

예외적으로 Figma가 특정 primitive와 opacity를 명시한 경우에는 아래처럼 primitive에 opacity를 적용할 수 있습니다.

```dart
AppColorPrimitives.separatorColors.withValues(alpha: 0.36)
```

## 색상 계층

`AppColorPrimitives`는 Figma 색상표의 원본 이름과 hex 값을 보존하는 계층입니다.

```dart
static const seaGreenDark3 = Color(0xFF009773);
static const grayGray6 = Color(0xFF404040);
```

`AppColors`는 코드에서 사용하는 의미 기반 계층입니다.

```dart
static const brandStrong = AppColorPrimitives.seaGreenDark3;
static const textStrong = AppColorPrimitives.grayGray6;
```

공용 위젯에서 `BuildContext`가 있고 테마 변경 가능성을 고려해야 한다면 `AppThemeTokens`를 우선 사용합니다.

```dart
final tokens =
    Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;
```

## 텍스트 규칙

폰트 패밀리는 `Pretendard`를 사용합니다.

현재 기본 텍스트 weight는 Figma의 `AppleSDGothicNeoM00` 기준에 맞춰 `500`으로 정의합니다. 굵게 보여야 하는 부분만 `700` 토큰을 사용합니다.

| 토큰 | 크기 | Weight | Line height |
| --- | --- | --- | --- |
| `size24Medium` | 24 | 500 | 32 |
| `size20Medium` | 20 | 500 | 24 |
| `size18Medium` | 18 | 500 | 24 |
| `size16Medium` | 16 | 500 | 22 |
| `size16Bold` | 16 | 700 | 22 |
| `size14Medium` | 14 | 500 | 20 |
| `size14Bold` | 14 | 700 | 20 |
| `size12Medium` | 12 | 500 | 16 |

새 텍스트 스타일이 필요하면 `AppTextStyles`에 추가한 뒤 사용합니다. 화면에서 직접 `TextStyle(fontSize: ..., fontWeight: ...)`를 작성하지 않습니다.

## Spacing 규칙

반복 사용되는 여백은 `AppSpacing`을 사용합니다.

| 토큰 | 값 |
| --- | --- |
| `x4` | 4 |
| `x8` | 8 |
| `x10` | 10 |
| `x12` | 12 |
| `x16` | 16 |
| `x20` | 20 |
| `x24` | 24 |
| `x32` | 32 |
| `x40` | 40 |

페이지 기본 좌우 패딩은 `20`이며 `CommonScaffold`의 기본 `bodyPadding`에 반영되어 있습니다.

## Radius 규칙

공통 radius는 `AppRadius`를 사용합니다.

| 토큰 | 값 | 용도 |
| --- | --- | --- |
| `xSmall` | 4 | medium button 등 작은 radius |
| `small` | 8 | tile, field, small surface |
| `dialog` | 14 | dialog card |
| `medium` | 16 | card, popup, common surface |
| `large` | 20 | 큰 surface |
| `full` | 999 | 원형 버튼, pill |

## Size 규칙

컴포넌트의 고정 크기는 `AppSizes`에 정의합니다. 공용 위젯 안에서 같은 숫자가 반복되거나 Figma 스펙으로 관리해야 하는 값은 raw number 대신 `AppSizes`에 추가합니다.

예시:

```dart
static const double placeCardWidth = 250;
static const double placeCardHeight = 156;
static const double searchTextFieldHeight = 64;
```

## 그라디언트 규칙

그라디언트는 `AppGradients`에 정의합니다.

| 토큰 | 용도 |
| --- | --- |
| `heroOverlay` | 장소 카드 이미지 하단 텍스트 가독성 오버레이 |
| `softFade` | 식물 카드 내부 하단 fade 영역 |

위젯에서 opacity가 필요한 경우 `Opacity`로 감싸서 Figma 기준값을 표현합니다.

## 토큰 추가 절차

1. Figma 또는 이미지 기준으로 값이 실제로 반복 사용되는지 확인합니다.
2. 색상은 `AppColorPrimitives`에 원본 이름과 hex를 먼저 추가합니다.
3. 화면 의미가 명확한 색상은 `AppColors`와 `AppThemeTokens`에 연결합니다.
4. 텍스트는 `AppTextStyles`에 size/weight/line-height 기준으로 추가합니다.
5. 여백, radius, 고정 크기는 각각 `AppSpacing`, `AppRadius`, `AppSizes`에 추가합니다.
6. 새 토큰을 사용하는 공용 위젯 또는 샘플 화면을 함께 갱신합니다.
7. `fvm flutter analyze`와 `fvm flutter test --concurrency=1 --dds-port=0`를 실행합니다.

## 사용 예시

좋은 예시:

```dart
Text(
  title,
  style: AppTextStyles.size16Bold.copyWith(
    color: AppColors.textStrong,
  ),
)
```

피해야 하는 예시:

```dart
Text(
  title,
  style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Color(0xFF404040),
  ),
)
```

## 예외 기준

아래 경우에는 raw value 사용을 허용할 수 있습니다.

- Flutter API가 특정 상수를 요구하고 토큰화 가치가 낮은 경우
- 한 위젯 내부에서만 쓰이는 계산용 값인 경우
- Figma에서 일회성 좌표나 opacity를 명시했고 재사용 가능성이 낮은 경우

단, 화면 또는 여러 공용 위젯에서 반복되는 값은 반드시 토큰으로 승격합니다.
