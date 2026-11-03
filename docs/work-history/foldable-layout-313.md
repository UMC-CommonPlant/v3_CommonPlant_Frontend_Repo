# 폴더블 가용 화면 UI #313

## 작업 기준

- 이슈: [#313](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/313)
- 작업: 2026-11-03 시작, 2026-11-04 검증 완료
- 기준 develop: `d46470d` (PR #310 병합), 브랜치 `feature/foldable-layout-313`
- 원본 develop의 개인 iOS Team 변경을 보존하고 별도 worktree에서 작업했다.
- #197의 기존 compact 휴대폰 overflow 수정과 구분해 폴더블의 넓은/짧은 창·분할화면을 다룬다.
- PR #312는 재개 시에도 미병합이다. 이번 브랜치에 refresh 구현을 섞지 않았다.
- 실제 Fold8·Fold8 Ultra·Flip8 규격을 추정하거나 기종 이름으로 분기하지 않았다.

참고 문서: README, AGENTS, screen-publishing-rules, figma-frame-map, shared-widget-guide,
design-token-rules, state-management-guide, routing-guide, testing-guide,
quality-testing-follow-up-plan, git-workflow.

## 확인한 문제와 변경

| 확인한 문제 | 변경 |
| --- | --- |
| 812×375 약관에서 하단 액션이 43px overflow | 짧은 창·큰 글씨에서 본문·동의·확인을 스크롤 흐름으로 배치 |
| Home의 높이 200 고정 헤더 아래 본문 영역이 낮아짐 | 같은 CustomScrollView에서 낮은 창은 헤더를 접으며 본문에 접근 |
| 펼친 Home은 두 섹션이 계속 세로로 쌓임 | 충분한 가용폭에서 장소·식물 섹션 병렬, 카드 Wrap |
| Place·Plant 상세 전체가 375폭에 머무름 | 충분한 폭에서 주요 정보와 목록/메모를 두 영역에 배치 |
| 폼·메모·마이의 전체 폭 확장 | 입력·읽기 영역 최대 560, 상세 전체 최대 1120, 하단 탭 최대 600 |
| 고정 좌표의 가입 화면이 낮은 창·키보드·큰 글씨와 충돌 | 로그인·온보딩의 가로 흐름, 프로필·약관의 순서 있는 스크롤과 가변 높이 |
| 접힘·힌지 위 본문/overlay 배치 위험 | 앱 루트에서 DisplayFeatureSubScreen으로 동일한 사용 가능 pane 선택 |

최종 시각 확인에서 펼친 Place의 정보 열이 320으로 좁아 이름이 더 잘리는 문제를 발견해
기존 375폭을 보존했다. 일반 휴대폰 430폭의 Home 배경·내부 20 여백도 유지했다.
좁은 가입 화면은 동의 문구 줄바꿈으로 완료 버튼이 오류 Snackbar와 겹치지 않도록 흐름
배치를 사용한다. API·인증·날씨 조회 조건이나 이미지 업로드 계약은 변경하지 않았다.

## 상태와 상호작용

- 루트의 CommonDisplayArea는 Navigator와 overlay를 함께 감싼다. 반접힘/힌지의 기본
  위·왼쪽 pane을 사용하며, flat 0폭 fold는 전체 화면을 사용한다.
- 같은 Flex·스크롤 요소와 Provider 인자를 유지한다. 크기 변경만으로 조회를 다시 시작하지 않는다.
- 장소·식물·회원정보·메모 폼의 입력·사진·선택·focus를 유지한다. 키보드로 가용 높이가
  아주 작아지면 CommonFormViewport가 전체 폼 스크롤을 허용한다.
- 프로필 가입의 닉네임 필드 하나는 단일 GlobalKey로 controller·focus·selection을 보존한다.
- 스크롤 offset은 새 콘텐츠의 유효 범위 안에서 유지한다. 두 열 전환으로 콘텐츠가 짧아지면
  새 최대 범위까지 정상적으로 줄어들 수 있다.
- 약관과 완료 버튼이 스크롤 아래에 있는 새 배치에서는 테스트도 먼저 해당 항목을 보이게
  스크롤한 뒤 누른다. 제출·가입·약관 상태와 라우팅 검증은 유지한다.
- FVM Flutter 3.35.7 내장 API와 기존 테마·위젯을 사용하고 새 외부 반응형 패키지는 추가하지 않았다.

## 자동 검증

Flutter/Dart 명령은 모두 FVM으로 순차 실행했다.

| 검증 | 결과 |
| --- | --- |
| `fvm dart format --output=none --set-exit-if-changed .` | 363개 파일, 변경 0개 |
| `fvm flutter analyze` | 문제 없음 |
| `fvm flutter test` | 810개 통과, macOS에서 기존 Linux golden 1개 스킵 |
| 공통 영역·폭·하단 탭 집중 검사 | 8개 통과 |
| Home·상세 집중 검사 | 21개 통과 |
| 최종 회귀 집중 검사 | 50개 통과 |
| `git diff --check` 및 변경 문서 상대 링크 | 통과 |

`test/app/router/foldable_route_layout_test.dart`는 21개 route × 아래 6개 logical viewport,
총 126개 API 비사용 초기 렌더링 조합을 확인한다.

- `320×720`, `600×800`, `720×720`, `884×812`, `812×375`, `560×320`

집중 테스트는 가짜 Provider의 loading/error/empty와 같은 페이지의 resize, 입력·사진·선택·
focus·selection·스크롤, 키보드 inset·큰 글씨·SafeArea, 합성 vertical hinge·horizontal
half-open fold·flat fold 및 dialog 영역을 검증한다. 실제 서버·OS 키보드·실기기 검증을
통과한 것으로 계산하지 않는다. 기존 Onboarding golden 파일은 변경하지 않았다.

## 시각 확인

Flutter 테스트 렌더러에 실제 앱 테마와 Pretendard·MaterialIcons를 로드해 캡처했다.
변경 전 5화면×3크기와 변경 후 7화면×3크기를 렌더링했으며, 변경 후 21개 캡처의
렌더 오류 기록은 0건이었다. 캡처용 임시 테스트는 저장소에서 제거했다.

직접 확인한 핵심 장면은 일반 휴대폰 Home, 펼친 Home·Place·Plant 상세, 짧은 창의 Login·
Onboarding·Profile·Terms다. 펼친 상세의 정보/목록 병렬, 로그인·온보딩의 그림/행동 병렬,
기존 휴대폰 정렬을 확인했다. 짧은 약관·프로필의 아래 액션은 스크롤로 도달하며 이는
별도 widget 동작 테스트로 검증했다. 합성 캡처를 기기 스크린샷으로 표현하지 않는다.

로컬 캡처는 Codex 시각 결과 폴더 `2026/11/04/commonplant-foldable-313`의 before/after에
보관한다. 저장소에 렌더 PNG나 개인 사진·키를 추가하지 않았다.

## 실제 기기 QA 경계

실제 Galaxy 폴더블·플립에서 앱 실행·물리 접힘 검증은 수행하지 않았다. 아래는 남은 수동 QA다.

- 접기/펼치기·회전·분할화면에서 실제 display features와 UI 확인
- 키보드·system back·SafeArea·사용자 글꼴/화면 배율과 CTA 확인
- 이미지 선택기나 dialog가 열린 상태의 접힘 전환
- Activity/프로세스 재생성 여부와 세션·초안 수명 확인

현재 초안은 메모리 수명이며 프로세스 종료 후 디스크 복원을 추가하지 않았다. 바깥 커버의
앱 실행 허용 정책·전용 런처 경험과 iPad 전용 최적화는 이번 구현 범위와 구분한다.
Apple 확인·검증 보류와 개인 iOS 설정 보존을 유지했다.

## 커밋 이력

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| `71a79cb` | 공통 display 영역·폭 기준, Scaffold·하단 탭과 회귀 | 공통 집중 8개 |
| `4de07a1` | Home·Place·Plant 상세의 재배치와 상태·스크롤 회귀 | 상세 집중 21개, 일반 휴대폰 회귀 포함 전체 검증 |
| `f87f4a0` | 폼·마이·메모 너비·낮은 키보드 창과 초안 보존 | 전체 810개 통과 |
| `4c16b00` | 로그인·온보딩·가입·약관 적응 배치와 사용자 동선 회귀 | 최종 집중 50개, 전체 810개 |
| `ba3c6ed` | 전체 route의 126개 가용 창 초기 배치 검사 | 전체 810개 |

최종 문서 커밋과 PR·CI 링크는 #313의 검증 코멘트에서 확인한다. PR 병합은 사용자가 진행한다.
