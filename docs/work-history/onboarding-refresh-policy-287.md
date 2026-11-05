# 온보딩·토큰 갱신 정책 문서화 #287

## 작업 기준

- 이슈: [#287](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/287)
- PR: [#288](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/288), 2026-09-03 develop 병합 (`03ba27d`)
- 당시 백엔드 의존성: [#149](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/149). 현재 초기 복원 계약과 구현은 아래 #311 갱신을 따른다.
- 작업일: 2026-09-03
- 기준 `develop`: `9259213` (PR #286 병합)
- 브랜치: `docs/onboarding-refresh-policy-287`
- 상태: 문서화 완료. 이슈와 PR은 Project 10의 category `User`, priority `high`,
  병합 완료 status `Done`를 사용합니다.

## 확정한 정책

- 온보딩 완료 여부는 인증 token과 분리된 비보안 로컬 값으로 저장합니다.
- 로컬 완료 값이 없으면 온보딩을 표시하고, 사용자가 `시작하기`를 누를 때 완료 값을 저장합니다.
- 확정 정책: access token 없이 refresh token만 있으면 token 갱신을 먼저 시도합니다. #287·#293 당시에는 API가 없어 부분 token 삭제 후 로그인으로 이동했으며, 2026-11-03 배포 확인 뒤 #311에서 초기 복원을 연결합니다.
- refresh 실패·만료·위조 시에만 token과 사용자 데이터 세션을 정리하고 로그인으로 이동합니다.
- 서버 로그아웃 API 연동은 현재 우선순위에서 제외하며 기존 로컬 로그아웃 동작은 변경하지 않습니다.

## 구현과 분리한 항목

- 온보딩 로컬 저장소와 초기 route 연결은 #289 / PR #290에서 완료했습니다.
- 앱 삭제·재설치 시 OS 백업으로 완료 값이 복원되는 경우 다시 표시할지는 미결정입니다.
- 초기 refresh-only 복원은 #311에서 확인된 endpoint·request/response·rotation·오류 계약을 적용합니다. 자동 401 갱신·동시 요청과 원요청 재시도는 별도 후속으로 남깁니다.

## 당시 재확인 근거

2026-09-03 dev OpenAPI는 19 paths·27 operations였으며 Auth endpoint는
`/auth/login`, `/auth/register`뿐이었습니다. backend main `f67ee6c`의
`AuthController`와 `AuthService`에도 당시 refresh·logout endpoint가 없었습니다.

## 2026-11-03 초기 복원 재개 #311

[live OpenAPI](https://commonplant-dev.okbear.dev/api/v1/api-docs/json) 20 paths·28 operations와
backend develop [`03ece0e`](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/commit/03ece0e466f2f47f72263085f3bfa737b3e1a53c),
[PR #165](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/pull/165)에서
`POST /auth/refresh`를 확인했습니다. #149·#162가 열려 있다는 이유로 제공된 초기 복원
계약을 다시 보류하지 않습니다.

- bearer 없이 JSON `refreshToken`을 전송합니다. JWT 필터가 만료 access bearer를 먼저
  거절하므로 갱신 요청에 access token을 붙이지 않습니다.
- `result.accessToken`은 필수이며 `result.refreshToken`은 회전 시에만 반환됩니다.
  생략/null이면 기존 refresh를 보존하고, 새 값이 있으면 저장한 뒤 인증을 복원합니다.
- 갱신·저장 중 인증 확인 상태를 유지합니다. 실패 시 세션을 정리하며 로그아웃·새 로그인
  뒤 도착한 이전 갱신 결과로 세션을 되살리지 않습니다.
- HTTP 401 `A003`·`A004`·`A012`, HTTP 404 `A006`은 각각 JWT 오류·만료·refresh 불일치·
  활성 사용자 부재 계약입니다. 원요청 자동 재전송과 서버 로그아웃은 이번 범위 밖입니다.
- TTL은 #162 본문·Swagger·현재 서버 설정이 서로 다릅니다. 클라이언트에 기간이나
  회전 시점을 고정하지 않으며 [TOKEN-01](../backend-api-open-questions.md#token-01-refresh-token-재발급-api)에 차이를 남깁니다.

이번 배포 명세·소스 확인은 실제 계정 token 갱신이나 실기기 재실행 성공을 뜻하지 않습니다.
자동 검증 결과는 [#311 작업 기록](startup-token-refresh-311.md)에서 별도로 관리합니다.
Apple 관련 확인·검증은 사용자 요청으로 계속 보류하며 이 복원의 선행 조건으로 삼지 않습니다.

## 검증

- 문서 전용 변경이므로 `git diff --check`를 실행합니다.
