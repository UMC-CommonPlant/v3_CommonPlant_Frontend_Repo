# 기존 비즈앱 카카오 로컬 QA #293

## 기준과 작업 계획

- 2026-11-14 기준 프런트 develop `3bb7955`, 백엔드 develop `03ece0e`.
- 로그인 [#293](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/293), 사진 [#295](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/295)를 계속 사용한다.
- PR #320은 OPEN·미병합·CI 성공이며 이번 기준 develop에 문서가 포함되지 않았다. PR #314는 CLOSED·미병합으로 제외한다.
- #311 / PR #312의 앱 시작 refresh-only 복원은 구현·병합 완료이며 실제 계정 검증은 별개다.
- 기존 CommonPlant 비즈앱과 사용자 개인 카카오 계정을 사용한다. Apple 확인은 보류한다.
- 원본 iOS 개인 Team 변경, Debug Apple 비활성 및 Profile/Release 설정을 보존한다. 날씨 로컬 파일은 읽지 않는다.

1. 콘솔의 로그인 활성화·이메일 동의·Android/iOS 플랫폼과 실제 Debug 인증서·callback을 확인한다. 네이티브 키는 Git 제외 파일에서만 주입한다.
2. 별도 백엔드 worktree에서 PostgreSQL·Garage와 JDK 17 서버를 `local` 프로필로 실행한다. JWT는 로컬 생성하며 키·비밀번호·token 원문은 로그/커밋에 남기지 않는다.
3. 실제 SDK 인증 → 서버 신규/기존 분기 → 가입 → 홈/내 정보 GET → 완전 종료/재실행 → 로그아웃/재로그인을 순차 검증한다. 계정 입력과 동의는 사용자가 한다.
4. 로그인 성공 후 사진 선택·업로드 → 새 GET → 재실행을 확인한다. PUT 응답만으로 재조회 성공으로 기록하지 않는다.
5. 휴대폰에서 키보드·뒤로가기·로딩·빈 상태·오류·재시도를 확인한다.

## 결과 구분

| 범주 | 이번 실행 상태 |
| --- | --- |
| 자동 테스트 | 아직 재실행하지 않음. 이전 216개 fake 검증과 구분 |
| Android 에뮬레이터 실행 | 준비 중 |
| 실제 서버 인증 | 아직 0건 |
| 휴대폰 실기기 | iPhone 무선 감지, 이번 시나리오 미검증 |

발견된 코드 수정은 먼저 계획에 추가하고 API별 작은 커밋으로 분리한다. 문서 변경은 diff·링크를 확인하고 Flutter 코드 변경은 format → analyze → test를 순차 실행한다.
