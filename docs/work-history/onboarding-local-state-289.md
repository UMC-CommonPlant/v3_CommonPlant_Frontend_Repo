# 온보딩 완료 상태 로컬 저장 #289

## 작업 기준

- 이슈: [#289](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/289)
- 작업일: 2026-09-03
- 기준 `develop`: `03ba27d` (PR #288 병합)
- 브랜치: `feature/onboarding-local-state-289`
- 참고: [라우팅](../routing-guide.md), [상태관리](../state-management-guide.md), [테스트](../testing-guide.md), [정책 #287](onboarding-refresh-policy-287.md)

## 구현 범위

| 범위 | 처리 |
| --- | --- |
| 로컬 저장 | `SharedPreferencesAsync`로 온보딩 완료 bool 읽기·쓰기 |
| 상태 | 단일 `OnboardingController`에서 초기 확인, 완료 저장, 실패 재시도 관리 |
| 초기 route | 미완료면 온보딩, 완료면 기존 인증 세션 정책 적용 |
| 완료 시점 | 화면 표시가 아니라 `시작하기` 저장 성공 시점 |
| redirect | 최초 보호 route를 온보딩과 로그인 뒤까지 보존 |
| 저장 실패 | 중복 탭을 막고 온보딩에 머물러 안내 후 재시도 |

별도 repository나 공용 preferences 프레임워크는 만들지 않았습니다. feature data 계층의 작은
store가 플랫폼 저장소를 감싸고, 화면과 라우터는 Provider 결과만 사용합니다. 인증 token은
기존 `flutter_secure_storage`에 유지해 두 저장소의 책임을 섞지 않습니다.

## 검증

- 온보딩 미완료·완료 초기 route
- 완료 저장과 새 ProviderScope 복원
- 저장 실패 뒤 같은 Controller 재시도
- 보호 route redirect 보존
- 기존 로그인·가입 route 회귀
- API 비사용 Android smoke에 온보딩 시작 구간 추가
- `fvm flutter analyze`
- `fvm flutter test`: 566개 통과, 기존 Linux 전용 golden 1개 skip
- `fvm flutter build apk --debug`
- `fvm flutter build ios --simulator --debug`

## 남은 범위

- 앱 삭제·재설치 중 OS 백업으로 로컬 값이 복원되는 경우의 재노출 정책
- refresh token 갱신과 서버 logout은 #289 범위가 아닙니다.
