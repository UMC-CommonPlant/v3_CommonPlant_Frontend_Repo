# 화면 퍼블리싱 작업 규칙

화면 퍼블리싱은 Figma를 단순 복사하는 작업이 아니라, 앱 전체 UX 문법과 공용 컴포넌트 재사용성을 함께 맞추는 작업입니다.

## 기본 원칙

- 화면의 기본 골격은 `CommonScaffold`를 우선 사용합니다.
- 버튼, 입력창, 카드, FAB, Dialog는 `shared/widgets`의 공용 위젯을 먼저 검토합니다.
- 색상, 폰트, spacing, radius, size는 `core/theme` 토큰을 사용합니다.
- 화면 내부에 비즈니스 로직을 넣지 않습니다.
- 상태별 UI는 loading, empty, error, success를 분리해서 설계합니다.
- 한 화면에서만 쓰이는 작은 UI는 feature 내부 `presentation/widgets`에 둡니다.

## 작업 흐름

1. Figma 화면의 목적과 사용자 액션을 먼저 파악합니다.
2. 이미 있는 공용 위젯으로 대체 가능한 요소를 표시합니다.
3. 부족한 스타일 토큰이 반복 값인지 일회성 값인지 판단합니다.
4. 페이지 레이아웃을 `CommonScaffold` 또는 feature 전용 scaffold로 구성합니다.
5. 상태별 화면을 먼저 정의한 뒤 성공 상태 UI를 채웁니다.
6. 긴 텍스트, 빈 이미지, 네트워크 실패, 키보드 노출 상태를 확인합니다.
7. 테스트와 analyzer를 실행합니다.

## 레이아웃 기준

| 항목 | 기준 |
| --- | --- |
| 기본 좌우 패딩 | `AppSpacing.x20` |
| 기본 상단 네비게이션 | `CommonScaffold`의 `CommonNavigationBar` |
| 페이지 배경 | `AppThemeTokens.canvas` |
| 일반 세로 간격 | `AppSpacing` 토큰 |
| 공통 버튼 높이 | `AppSizes.buttonHeight` 등 `AppSizes` |

특정 화면에서 Figma 좌표를 그대로 맞추기 위해 raw number를 반복 사용하지 않습니다. 반복되거나 의미가 있는 값은 토큰으로 승격합니다.

## 공용 위젯 우선순위

| UI | 우선 사용할 위젯 |
| --- | --- |
| 일반 액션 버튼 | `CommonButton` |
| 일반 입력창 | `CommonTextField` |
| 검색 입력창 | `CommonSearchTextField` |
| 주소/장소 선택 필드 | `CommonAddressOrPlaceField` |
| 페이지 기본 구조 | `CommonScaffold` |
| SVG 아이콘 | `CommonSvgIcon` |
| 장소 카드 | `CommonPlaceCard` |
| 식물 카드 | `CommonPlantCard`, `CommonPlacePlantCard` |
| 메모 카드 | `CommonMemoCard` |
| 확인/삭제 Dialog | `CommonDialogCard` |
| 확장 FAB | `CommonFabDial` |

공용 위젯이 거의 맞지만 한두 속성만 부족한 경우에는 새 위젯을 만들기보다 기존 위젯의 옵션 확장을 먼저 검토합니다.

## 상태 UI 기준

| 상태 | 표현 기준 |
| --- | --- |
| Loading | 화면 골격이 유지되는 로딩 UI 또는 진행 표시 |
| Empty | 사용자가 다음 액션을 알 수 있는 빈 상태 문구와 CTA |
| Error | 복구 가능한 메시지와 재시도 액션 |
| Success | 주요 액션이 명확한 기본 화면 |
| Disabled | 색상과 터치 불가 상태를 함께 표현 |

서버 오류 문구를 화면에 그대로 노출하지 않습니다. 공통 에러 모델이 생기기 전까지는 feature Provider 또는 Controller에서 사용자용 메시지로 변환합니다.

## 텍스트 기준

- 줄바꿈이 필요한 문구는 Figma 시안만 보지 말고 실제 기기 폭을 기준으로 확인합니다.
- 버튼 텍스트는 한 줄을 기본으로 하며 `CommonButton`의 ellipsis 정책을 유지합니다.
- 에러 메시지는 사용자가 수정할 수 있는 행동을 알려주는 문장으로 작성합니다.
- 상태값은 색상만으로 구분하지 않고 텍스트도 함께 제공합니다.

## 반응형 기준

- 기준 시안 폭은 `AppSizes.mobileWidth` 값인 375입니다.
- 고정 카드나 버튼은 `AppSizes`로 관리합니다.
- 리스트와 form은 가능한 `Expanded`, `Flexible`, `Wrap`, `SingleChildScrollView`를 사용해 overflow를 방지합니다.
- 키보드가 올라오는 입력 화면은 스크롤 가능해야 합니다.
- SafeArea를 고려하지 않은 절대 배치는 피합니다.

## 공용화 판단 기준

아래 조건 중 두 개 이상에 해당하면 `shared/widgets` 공용화를 검토합니다.

- 둘 이상의 feature에서 사용됩니다.
- Figma에서 같은 컴포넌트로 관리됩니다.
- 동일한 상태와 interaction을 가집니다.
- 스타일 토큰과 asset만 주입하면 도메인과 분리할 수 있습니다.

공용화하더라도 feature의 API 모델이나 Provider를 직접 import하지 않습니다.

## 퍼블리싱 완료 체크리스트

- [ ] raw color, raw spacing, raw radius가 화면에 남아 있지 않은가?
- [ ] 공용 위젯으로 대체 가능한 UI를 새로 만들지 않았는가?
- [ ] loading, empty, error 상태를 고려했는가?
- [ ] 긴 한글 문구와 작은 화면에서 overflow가 없는가?
- [ ] 키보드 노출 시 입력 필드와 CTA가 가려지지 않는가?
- [ ] 터치 영역이 충분한가?
- [ ] `fvm flutter analyze`를 통과하는가?
- [ ] 필요한 widget test를 추가 또는 갱신했는가?

## 결정 필요

- Figma 기준 해상도 외에 QA 필수 디바이스 목록이 필요합니다.
- Splash, onboarding, bottom navigation의 최종 UX 정책은 화면 범위 확정 후 별도 문서로 분리할 수 있습니다.
