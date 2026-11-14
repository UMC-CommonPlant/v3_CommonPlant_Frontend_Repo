# 미선택 정원 탭 아이콘 색상 #321

- 이슈 [#321](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/321)
- 기준 `develop` `3bb7955`
- 관련 가이드 [디자인 토큰](../../design-token-rules.md), [아이콘 색상](../../asset-icon-rules.md)

## 재현과 수정 계획

Android 에뮬레이터에서 마이 탭을 선택하면 중앙 잎사귀의 SVG 원본 획 색상 `#404040`이 표시된다. 정보, 이야기, 캘린더는 `AppColors.iconInactive` (`#999999`)를 사용한다.

정원 탭의 미선택 SVG에만 공통 아이콘 색상을 주입한다. 정원 선택 시 기존 초록색과 잎사귀 내부의 흰 선을 표시한다. 기존 에뮬레이터에서 마이 → 정원 전환을 확인하고 포맷, 분석, 전체 테스트를 실행한다.
