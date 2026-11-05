# 앱 시작 refresh-only 토큰 갱신 #311

## 기준과 범위

- 작업일: 2026-11-03
- 이슈: [#311](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/311), parent [#2](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/2)
- 기준 develop: `d46470d` (PR #310 병합), 브랜치 `feature/startup-token-refresh-311`
- 원본 develop의 개인 iOS Team 변경을 보존하고 최신 origin/develop의 별도 worktree에서 작업했다.
- #287에서 확정한 앱 시작 refresh-only 복원을 구현했다. 활성 access-token 요청의 자동 갱신·원요청 재전송, 서버 로그아웃은 별도 후속이다.
- Apple 확인·검증은 사용자 요청으로 계속 보류했다. iOS Bundle ID·Debug/Profile/Release 설정은 변경하지 않았다.

참고 문서: README, AGENTS, git-workflow, feature-development, state-management, routing,
testing, social-login-integration, shared-widget, design-token, screen-publishing, figma-frame-map,
api-swagger-reference, backend-api-open-questions, remote-integration-test-readiness 및 #287·#293·#295 이력.

## 최신 백엔드 계약 확인

2026-11-03 [live OpenAPI](https://commonplant-dev.okbear.dev/api/v1/api-docs/json)는 HTTP 200,
20 paths·28 operations다. backend develop
[`03ece0e`](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/commit/03ece0e466f2f47f72263085f3bfa737b3e1a53c)와
[PR #165](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/pull/165)의
AuthController, AuthRequest.Refresh, AuthResponse.RefreshResponse, AuthServiceImpl.refresh,
JwtAuthenticationFilter 및 테스트 소스를 대조했다. backend #149·#162는 OPEN이지만 배포된
endpoint를 제공하지 않는 것으로 판단하지 않았다. 백엔드 테스트를 실행한 것은 아니다.

| 항목 | 확인한 계약·반영 |
| --- | --- |
| 요청 | `POST /auth/refresh`, JSON `refreshToken` 필수 비공백 문자열·최대 512자 |
| 인증 헤더 | bearer를 보내지 않는다. JWT 필터가 전달된 만료 access token을 먼저 거절하므로 요청의 명시 skip 옵션으로 첨부·기본 헤더를 제외한다. |
| 성공 | `result.accessToken` 필수. `result.refreshToken`이 생략/null이면 기존 값 보존, 반환되면 회전한 값 저장 |
| 실패 | HTTP 401 A003(형식·서명), A004(만료), A012(type·저장값 불일치), HTTP 404 A006(활성 사용자 없음) |
| 회전 | 서버 저장 refresh가 교체되면 이전 refresh는 불일치로 거절. 로그인도 저장 refresh를 교체한다. |
| 기간 | #162 본문 임계 7일, Swagger 전체 7일·임계 1일, 설정 전체 30일·임계 3일로 충돌. 클라이언트 TTL·회전 시점 추정 없이 응답만 적용한다. |

## 구현과 상태 경계

- API 비사용, token 없음, access-only 정리, 완전한 token 쌍 복원은 기존 흐름을 유지한다.
- refresh-only는 갱신을 먼저 요청한다. 응답과 token 쌍 저장이 모두 끝나야 인증·사용자 데이터 세션을 시작한다.
- 새 access token과 반환된 refresh token은 비공백 문자열만 허용한다. 숫자·bool·배열·객체나 빈 문자열을 인증 token으로 변환하지 않는다.
- 현재 시도의 HTTP·파싱·저장 실패는 token을 정리하고 로그인으로 복귀한다. 자동 재시도는 하지 않는다.
- AuthTokenWriter의 기존 시도 revision·직렬 저장/삭제 큐를 사용한다. 이전 refresh의 성공·오류·느린 저장/삭제는 로그아웃·새 로그인 뒤 token과 세션을 바꾸지 않는다.
- 온보딩 완료 여부 확인 및 완료 후 인증 복원 중에는 앱 루트가 기존 테마의 진행 표시를 보여준다. Home 조회 실패 문구나 설정의 로그아웃 버튼을 먼저 노출하지 않는다. 온보딩 미완료는 기존 우선 노출을 유지하며 router 인스턴스와 이동 목적지는 보존한다.
- refresh 요청의 401은 활성 access-token 만료 callback을 호출하지 않는다. 활성 일반 요청의 기존 A003·A004·A009 종료 정책은 유지한다.
- 새 인증 프레임워크·Provider 계층·공용 loading 위젯·토큰 기간 계산은 추가하지 않았다.

## 자동 검증

Flutter/Dart 명령은 모두 FVM으로 순차 실행했다.

| 검증 | 결과 |
| --- | --- |
| `fvm dart format --output=none --set-exit-if-changed .` | 355개 파일, 변경 0개 |
| `fvm flutter analyze` | 문제 없음 |
| `fvm flutter test` | 810개 통과, macOS에서 기존 Linux golden 1개 스킵 |
| 계약·저장·세션·소셜 집중 테스트 | 155개 통과 |
| loading UI 보완 후 세션·라우팅 집중 테스트 | 49개 통과 |
| `git diff --check` 및 변경 문서의 로컬 링크 | 통과 |

DTO·JSON 전송·bearer 제외, 회전/미회전, HTTP/파싱/부분 저장 실패 정리, 늦은 응답과
로그아웃·새 로그인, checking 동안 비활성 데이터 세션, 진행 표시와 보호 화면 비노출,
성공/실패 뒤 보호 route 목적지를 검증했다. HTTP adapter와 token 저장소는 fake이며 실제
secure storage·소셜 provider·서버 token 회전을 검증한 결과가 아니다.

## 실제 서버·휴대폰 QA와 남은 조건

- 실제 서버에는 공개 OpenAPI 조회만 수행했다. 실제 인증·refresh·업로드 요청은 하지 않았다.
- iPhone 16 Pro가 연결된 상태로 감지됐지만 이 작업에서 앱 설치·실계정 로그인·사진 업로드를 실행하지 않았다. 등록 기기 조회를 실제 QA로 계산하지 않는다.
- 로컬에는 Kakao·Google 설정 파일과 iOS callback 설정이 없으며 사용자가 미준비 상태를 확인했다. 키·OAuth client·테스트 계정을 준비한 뒤 #293 로그인 → #295 앨범 선택·서버 저장·GET 재조회·앱 완전 종료/재실행을 확인한다.
- 회원정보 수정 후 마이페이지 표시는 PUT 응답으로 상태를 교체한 결과일 수 있다. 이를 서버 GET 재조회로 기록하지 않고 새 GET 또는 앱 재실행 결과를 확인한다.
- 실제 token 갱신·회전과 secure storage 복원은 미검증이다. 인증된 무인 원격 E2E의 bootstrap·데이터 격리·cleanup 준비 조건은 해제하지 않는다.
- 같은 live 명세·소스에서 물주기 주기 필드와 노출된 장소 좌표 계약은 여전히 확인되지 않았다. #299 API 입력 비활성, 주소 대응 확인 좌표 없는 날씨 조회 0회 정책을 유지한다.
- 원본 `env/local.weather.json`의 실제 키는 열람·출력·복사·커밋하지 않았다.

## 커밋 이력

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| `ba76b4f` | Refresh DTO·datasource·repository와 bearer 제외, 엄격 파싱·token 저장 회귀 | format, analyze, 집중 155개 |
| `a4e9192` | refresh-only 초기 복원·loading UI와 세션·라우팅 회귀 | format, analyze, 집중 49개, 전체 810개·기존 skip 1개 |

최종 문서 커밋과 PR·CI 링크는 #311 검증 코멘트에서 확인한다. PR 병합은 사용자가 진행한다.
