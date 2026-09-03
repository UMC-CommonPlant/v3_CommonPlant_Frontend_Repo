# 온보딩·토큰 갱신 정책 문서화 #287

## 작업 기준

- 이슈: [#287](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/287)
- PR: [#288](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/288), 사용자 병합 대기
- 백엔드 의존성: [#149](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/149)
- 작업일: 2026-09-03
- 기준 `develop`: `9259213` (PR #286 병합)
- 브랜치: `docs/onboarding-refresh-policy-287`
- 상태: 문서화 완료. 이슈와 PR은 Project 10의 category `User`, priority `high`,
  status `In Review`를 사용합니다.

## 확정한 정책

- 온보딩 완료 여부는 인증 token과 분리된 비보안 로컬 값으로 저장합니다.
- 로컬 완료 값이 없으면 온보딩을 표시하고, 사용자가 `시작하기`를 누를 때 완료 값을 저장합니다.
- access token 없이 refresh token만 있으면 즉시 삭제하지 않고 token 갱신을 먼저 시도합니다.
- refresh 실패·만료·위조 시에만 token과 사용자 데이터 세션을 정리하고 로그인으로 이동합니다.
- 서버 로그아웃 API 연동은 현재 우선순위에서 제외하며 기존 로컬 로그아웃 동작은 변경하지 않습니다.

## 구현과 분리한 항목

- 온보딩 로컬 저장소 선택과 초기 route 연결은 후속 구현 이슈에서 진행합니다.
- 앱 삭제·재설치 시 OS 백업으로 완료 값이 복원되는 경우 다시 표시할지는 미결정입니다.
- refresh endpoint, request/response, token rotation, 오류 code와 동시 요청 정책은 backend #149 답변 뒤 구현합니다.

## 재확인 근거

2026-09-03 dev OpenAPI는 19 paths·27 operations이며 Auth endpoint는
`/auth/login`, `/auth/register`뿐입니다. backend main `f67ee6c`의
`AuthController`와 `AuthService`에도 refresh·logout endpoint가 없습니다.

## 검증

- 문서 전용 변경이므로 `git diff --check`를 실행합니다.
