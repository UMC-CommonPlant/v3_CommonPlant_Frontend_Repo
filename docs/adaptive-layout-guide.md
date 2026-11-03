# 폴더블 가용 화면별 배치 기준

2026-11-03 사용자 요청과 #313을 기준으로 하며, 2026-11-04 최종 검증을 반영한다. Fold·Flip 계열의 접힌/펼친 창, 가로 창,
분할화면을 현재 앱의 휴대폰 대응 범위에 포함한다. 특정 기종의 이름·물리 해상도·가로세로
방향으로 배치를 결정하지 않고, 앱이 실제로 받은 logical 가용 영역을 사용한다.
iPad 전용 화면이나 바깥 커버용 별도 런처·위젯을 구현한 것은 아니다.

## 가용 영역과 공통 기준

- `CommonPlantApp`의 `CommonDisplayArea`가 Navigator와 overlay를 함께 감싼다.
  Flutter 3.35.7의 `DisplayFeatureSubScreen`으로 실제 화면을 분리하는 힌지·반접힘을 피한다.
  LTR에서는 기본 위/왼쪽 pane을 사용하고, 평평한 0폭 fold는 화면을 분리하지 않는다.
  접힘 정보가 없는 일반 화면은 전체 창을 사용한다. 화면별 SafeArea와 키보드 inset 처리는 유지한다.
- 분리된 pane의 MediaQuery·constraints를 하위 화면이 사용한다. 화면마다 기종 판별,
  임의 hinge 위치, 물리 해상도나 DPI 환산을 추가하지 않는다.
- `LayoutBuilder`로 부모의 실제 폭·높이를 읽는다. 크기 변경만으로 route, Provider family
  인자, Controller, 이미지 초안을 새로 만들거나 API를 다시 조회하지 않는다.
- `CommonContentWidth`는 내용의 최대 폭을 제한한다. 넓다고 글자·버튼·이미지를 비례 확대하지 않는다.
- `CommonFormViewport`는 평소 고정 하단 액션을 유지한다. 키보드 등으로 header·최소 입력줄·
  액션을 놓을 높이도 부족하면 폼 전체를 스크롤할 수 있게 한다. 내부 입력 스크롤과 위젯 구조는 유지한다.

| AppSizes 토큰 | 값 | 사용 목적 |
| --- | --- | --- |
| `expandedLayoutMinWidth` | 720 | 두 내용 영역이 함께 들어갈 때의 재배치 기준 |
| `compactLayoutMaxHeight` | 500 | 홈 배너 접기 및 짧은 창 배치 기준 |
| `formMaxWidth` | 560 | 입력·프로필·메모의 읽기 폭 상한 |
| `contentMaxWidth` | 1120 | 홈·상세 내용 전체 폭 상한 |
| `bottomNavigationMaxWidth` | 600 | 하단 탭을 넓은 창에서 중앙에 모으는 상한 |

위 값은 앱 레이아웃의 기준이며 특정 Galaxy 기종 규격이 아니다. 안쪽 padding이 있는
영역은 이를 제외한 constraints로 판단한다. 약관은 실제 하단 액션 높이를 확보할 수 있는지
계산해 500보다 높은 창에서도 필요하면 스크롤 배치를 사용한다.

## 화면별 동작

| 화면 | 좁은 일반 창 | 넓거나 짧은 창 |
| --- | --- | --- |
| Home | 기존 헤더·세로 섹션·가로 카드 목록 | 넓으면 장소·식물 섹션 병렬 및 카드 Wrap. 낮으면 헤더를 접으며 본문 스크롤 |
| 장소 상세 | 장소 정보 아래 식물 목록 | 장소 정보·식물 목록 병렬, 목록에 충분한 폭이 있으면 카드 두 열 |
| 식물 상세 | 이미지·관리·메모·정보 순서 | 이미지/관리와 메모/정보 병렬 |
| 로그인·온보딩 | 375×812 기본 시안 위치 유지 | 넓으면 그림과 행동을 두 열, 낮거나 큰 글씨면 흐름 배치와 스크롤 |
| 프로필 가입·약관 | 375×812 기본 시안 유지 | 좁은 가입 화면과 넓거나 짧은 창에서는 입력·본문·동의·확인을 순서대로 스크롤, 글씨가 커지면 높이 자동 확장 |
| 장소·식물·회원정보 폼, 메모 작성 | 기존 입력과 하단 액션 | 최대 560폭, 극단적으로 낮은 키보드 창에서 전체 스크롤 |
| 마이·메모 목록·일반 목록 | 기존 한 열 | 프로필 배경·버튼·내용과 메모 피드의 과도한 가로 확장 제한 |
| 하단 탭 | 기존 다섯 탭 | 배경은 창을 채우고 탭은 최대 600폭 중앙 정렬 |

폼의 각기 다른 width 배치로 TextField subtree를 교체하지 않는다. 프로필 가입은 기존 고정
배치와 흐름 배치 사이에서 닉네임 필드 하나의 GlobalKey를 유지해 controller·focus·selection을
보존한다. 폼 전체나 Navigator에 화면 크기를 반영한 Key를 부여하지 않는다.

## 검증과 실제 기기 경계

자동 검사 크기는 [품질 검증 계획](quality-testing-follow-up-plan.md)의 논리 viewport를 따른다.
일반 크기 렌더링 외에 같은 화면 인스턴스에서 narrow → expanded → short → narrow 변경,
키보드·시스템 여백·큰 글씨, 합성 vertical hinge·horizontal half-open fold·flat fold를 확인한다.
126개 조합은 API 비사용 초기 렌더링이며 loading/error/empty는 fake Provider 응답으로 검증한다. 실제 서버 검증과 OS folding 검증을 대신하지 않는다.

실제 Android 폴더블 QA에서는 아래를 별도로 확인한다.

1. 접기·펼치기·가로 전환·분할화면에서 내용과 액션에 접근할 수 있는지 확인한다.
2. 입력·사진 선택·선택 범위·스크롤 위치·현재 route가 유지되는지 확인한다. 내용이 줄어드는
   경우 scroll offset은 새 최대 범위까지 줄어들 수 있다.
3. 키보드를 연 상태, 시스템 back, 노치·내비게이션 영역과 실제 힌지 보고값을 확인한다.
4. OS가 Activity/프로세스를 재생성하는 경우를 구분한다. 현재 메모리 초안은 프로세스 종료 후
   복원되지 않으며, 이 작업은 디스크 초안 저장을 추가하지 않는다.
5. 바깥 커버에서 앱을 실행할 수 있는지는 기기 OS 정책과 구분한다. 별도 커버 전용 경험을
   제공하거나 실제 Fold8/Ultra/Flip8 기종 인증을 완료했다고 표현하지 않는다.

구현·검증·캡처 기록은 [#313 작업 이력](work-history/foldable-layout-313.md)에서 관리한다.

## 공식 참고

- [Flutter adaptive best practices](https://docs.flutter.dev/ui/adaptive-responsive/best-practices): 기종·방향 대신 가용 공간, 입력과 상태 유지 기준
- [Flutter large screens](https://docs.flutter.dev/ui/adaptive-responsive/large-screens): 넓은 화면의 grid·내용 폭·foldable 고려
- [DisplayFeatureSubScreen](https://api.flutter.dev/flutter/widgets/DisplayFeatureSubScreen-class.html): 분리 영역·anchor·MediaQuery 조정 동작. 저장소 FVM 3.35.7 소스와 함께 대조
- [Android foldables](https://developer.android.com/develop/adaptive-apps/guides/foldables/learn-about-foldables): 창 크기·posture 변경과 사용자 동선 연속성
