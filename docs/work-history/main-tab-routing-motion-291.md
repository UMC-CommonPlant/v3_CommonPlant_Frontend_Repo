# 메인 탭 라우팅과 모션 정리 #291

## 작업 기준

- 이슈: [#291](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/291)
- 작업일: 2026-09-03
- 기준 `develop`: `8092783` (PR #290 병합)
- 브랜치: `feature/main-tab-routing-motion-291`
- 참고: [라우팅](../routing-guide.md), [Figma 매핑](../figma-frame-map.md), [디자인 토큰](../design-token-rules.md), [공용 위젯](../shared-widget-guide.md), [테스트](../testing-guide.md)

## 구현 범위

| 범위 | 처리 |
| --- | --- |
| 메인 Shell | 정원 `/`과 마이 `/me`만 단순 `ShellRoute`로 묶고 하단 바를 한 번 조립 |
| 실제 탭 | 현재 route를 기준으로 선택 상태를 계산하고 정원·마이를 양방향 연결 |
| 미구현 탭 | 정보·이야기·캘린더 선택 시 현재 화면에서 구현 예정 Snackbar 표시 |
| 탭 전환 | `NoTransitionPage`로 화면 전환은 즉시 처리하고 indicator만 180ms 전환 |
| Popup | 식물 수정·삭제 popup을 짧은 fade/scale로 변경 |
| FAB dial | 수동 Overlay 상태를 dialog route로 단순화하고 닫힌 뒤 action 실행 |
| 접근성 | 시스템 애니메이션 축소 설정에서는 짧은 motion을 즉시 전환 |

탭별 Navigator를 유지하는 `StatefulShellRoute`, animation service/Provider, 미구현 화면의 placeholder route는 추가하지 않았습니다. 기존 Place, Plant, Memo와 마이 상세 화면은 Shell 밖에 유지해 하단 바가 표시되지 않습니다.

## 검증 범위

- 정원 ↔ 마이 양방향 전환과 route 기반 선택 상태
- 정보·이야기·캘린더의 구현 예정 Snackbar
- 마이 상세 화면에서 하단 바 숨김과 뒤로가기 복원
- 애니메이션 축소 설정의 즉시 indicator 전환
- FAB dial 표시·닫기·action 호출 순서
- 식물 상세 popup과 기존 삭제 dialog 회귀
- 전체 format, analyze, widget/unit test, diff 검사

## 커밋과 검증 결과

| 커밋 | 변경 범위 |
| --- | --- |
| `8256d16` | 메인 Shell, 준비 중 탭 피드백, motion 적용과 회귀 테스트 |
| `05eef53` | 라우팅·Figma·디자인 토큰·공용 위젯 문서 갱신 |
| `399a769` | 포맷 품질 게이트 반영 |

- `fvm dart format --output=none --set-exit-if-changed .`: 통과
- `fvm flutter analyze`: 통과
- `fvm flutter test`: 570개 통과, 기존 Linux 전용 golden 1개 skip
- `git diff --check`: 통과

## 남은 범위

- 정보, 이야기, 캘린더 실제 화면·route·API
- 탭별 독립 탐색 기록과 state restoration
- 외부 딥링크 정책
