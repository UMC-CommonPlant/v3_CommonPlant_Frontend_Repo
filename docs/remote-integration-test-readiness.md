# Remote integration test 준비 계약

이 문서는 dev API를 사용하는 TEST-02-B를 재현 가능한 방식으로 실행하기 위해 백엔드, 프론트엔드, GitHub Actions가 각각 준비해야 할 조건을 정의한다. 실제 계정, secret 값, endpoint 이름은 임의로 만들지 않으며, 조건이 충족되기 전에는 remote workflow를 구현하거나 dev 데이터를 변경하지 않는다.

## 현재 판정

- 기준일: 2026-08-23
- 추적 이슈: #220
- dev API 문서 상태: Ready
- 인증·데이터 준비 상태: Blocked
- 첫 authenticated probe: Blocked
- 실제 앱 UI/CRUD end-to-end: Blocked

`Blocked`는 dev 서버가 없다는 의미가 아니다. 서버와 Swagger는 사용할 수 있지만 CI가 매번 새 인증을 얻고, 충돌 없는 데이터를 사용하고, 실패하더라도 정리할 수 있다는 계약이 아직 없다는 뜻이다.

## 확인된 근거

| 영역 | 확인된 사실 | 판정 |
| --- | --- | --- |
| dev 환경 | `https://commonplant-dev.okbear.dev/api/v1`과 OpenAPI JSON에 접근 가능 | Ready |
| endpoint inventory | OpenAPI 19개 path에 test, seed, fixture, cleanup 전용 endpoint가 없음 | Blocked 조건 유지 |
| 로그인 | `POST /auth/login`은 Google/Kakao/Apple SDK token을 요구 | CI 인증 방식 미확정 |
| 회원가입 | 신규 사용자 `signupToken`은 10분 동안만 유효 | 장기 fixture 생성 수단으로 사용 불가 |
| token lifecycle | access token 재발급과 logout endpoint가 Swagger에 없음 | 만료·폐기 대응 미확정 |
| 앱 인증 계층 | Auth repository, secure token store, bearer interceptor는 구현됨 | data 계층 준비 |
| 앱 화면 연결 | 로그인 버튼은 repository를 호출하지 않고 `/profile/setup`으로 이동하며 프로필 제출도 local state만 사용 | 실제 UI E2E 선행 구현 필요 |
| 데이터 API | Place/Plant 삭제 endpoint는 있으나 Place 성공 schema와 multipart 일부가 미확정 | CRUD pilot 보류 |
| Memo | OpenAPI inventory에 Memo endpoint가 없음 | Memo E2E 불가 |

## Ready gate

아래 gate는 하나라도 충족되지 않으면 다음 단계로 넘어가지 않는다.

| Gate | Ready 조건 | 현재 상태 | 책임 범위 |
| --- | --- | --- | --- |
| AUTH-BOOTSTRAP | 개인 계정 없이 CI가 실행마다 유효한 기존 사용자 인증을 얻을 수 있음 | Blocked | Backend/협의 |
| TOKEN-LIFECYCLE | token TTL, 갱신 또는 재발급, 폐기 방법과 실패 코드가 문서화됨 | Blocked | Backend |
| DATA-ISOLATION | run별 fixture owner 또는 격리 key가 있고 병렬 실행 충돌이 없음 | Blocked | Backend/Workflow |
| DATA-CLEANUP | 정상·실패 경로 cleanup과 중단된 run을 위한 TTL fallback이 있음 | Blocked | Backend/Workflow |
| FRONT-AUTH | 소셜 token 획득, repository 호출, token 저장, 신규·기존 사용자 route가 화면에 연결됨 | Blocked | Frontend |
| ENDPOINT-SCHEMA | pilot이 사용하는 성공 response와 식별자 계약이 Swagger에 있음 | 부분 Ready | Backend |
| CI-AUTHORITY | GitHub Environment, secret 등록 주체와 사용 권한을 팀이 승인함 | Blocked | Repository owner/team |

## CI 인증 계약

구현 방식은 백엔드가 아래 중 하나를 선택할 수 있다. 프론트 문서는 특정 endpoint 이름을 먼저 정하지 않는다.

1. dev에서만 활성화되는 테스트 인증 bootstrap이 짧은 수명의 access/refresh token을 발급한다.
2. 개인 소유가 아닌 소셜 테스트 계정과 자동화 가능한 token 발급·갱신 절차를 제공한다.
3. CI 전용 credential 교환으로 실행마다 짧은 수명의 사용자 token을 발급한다.

어떤 방식을 선택하더라도 아래 조건은 공통으로 만족해야 한다.

- production에서는 사용할 수 없어야 한다.
- 개인의 소셜 계정, 브라우저 세션, 수동 복사 token에 의존하지 않아야 한다.
- 새 workflow run이 이전 run의 access token에 의존하지 않아야 한다.
- 발급된 token의 TTL이 한 번의 테스트와 cleanup을 마칠 만큼 충분해야 한다.
- credential과 token이 로그, artifact, screenshot, 앱 binary에 남지 않아야 한다.
- 권한은 테스트 fixture에 필요한 최소 범위여야 한다.

고정 access token 하나를 GitHub secret에 장기간 저장하는 방식은 만료·폐기·소유권을 재현할 수 없으므로 단독 해결책으로 채택하지 않는다. token을 `--dart-define`으로 전달하는 방식도 빌드 인자와 산출물에 값이 남을 수 있어 사용하지 않는다.

## 데이터 격리와 cleanup 계약

- 테스트 사용자는 실제 사용자와 분리된 backend 소유 fixture여야 한다.
- 각 run은 GitHub run id와 attempt처럼 충돌하지 않는 실행 식별자를 가져야 한다.
- 생성 데이터에는 실행 소유권을 추적할 방법이 있어야 하며, 화면 필드 길이 같은 도메인 제약 안에서 표현 방법은 백엔드와 합의한다.
- 초기 pilot은 공유 fixture를 읽기만 하고 데이터를 수정하지 않는다.
- CRUD 단계에서는 생성한 resource id를 run 동안 보존하고 자신이 만든 데이터만 역순으로 삭제한다.
- cleanup은 성공 여부와 무관하게 실행하되, runner 강제 종료로 실행되지 못한 경우를 위한 서버 TTL 또는 관리자 정리 수단이 필요하다.
- cleanup 실패는 테스트 성공으로 숨기지 않고 별도 실패 유형으로 기록한다.
- 격리가 검증되기 전에는 workflow를 직렬화하고, 병렬 실행은 backend가 충돌 없음을 보장한 뒤 허용한다.

## 단계별 도입 범위

| 단계 | 범위 | 데이터 변경 | 시작 조건 | TEST-02-B 완료로 계산 |
| --- | --- | --- | --- | --- |
| 0 | Swagger/OpenAPI reachability | 없음 | dev URL | 아니오. #213 완료 |
| 1 | 인증 후 `GET /users` read-only readiness probe | 없음 | AUTH-BOOTSTRAP, TOKEN-LIFECYCLE, CI-AUTHORITY | 아니오. 환경 검증 |
| 2 | 기존 사용자 로그인 → token 저장 → 인증 route UI smoke | 없음 | FRONT-AUTH와 단계 1 성공 | 부분 완료 |
| 3 | Place 또는 Plant 단일 CRUD flow | 있음 | DATA-ISOLATION, DATA-CLEANUP, endpoint schema | 도메인별 완료 |
| 4 | Friend, Image, Memo 확장 | 있음 | 각 도메인 schema와 cleanup | 도메인별 완료 |

첫 remote pilot은 단계 1로 제한한다. `GET /users`는 성공 schema가 있고 데이터 변경이 없으므로 인증과 dev 연결을 가장 작은 범위에서 검증할 수 있다. 이 probe는 Flutter 화면 E2E를 대신하지 않으며, 단계 2 전에는 TEST-02-B를 완료로 표시하지 않는다.

신규 사용자 회원가입은 10분 `signupToken`과 영구 사용자 생성이 결합되므로 첫 pilot으로 사용하지 않는다. Place/Plant CRUD도 인증, 식별자, cleanup이 모두 준비된 뒤 한 도메인씩 추가한다. Memo는 endpoint가 Swagger에 추가되기 전까지 대상에서 제외한다.

## Workflow 도입 기준

외부 조건이 해결되면 첫 workflow는 아래 순서로 도입한다.

1. 팀이 승인한 GitHub Environment와 최소 secret만 사용한다.
2. `workflow_dispatch` 수동 실행으로 시작하고 fork PR에는 secret을 제공하지 않는다.
3. 초기에는 dev 환경 run을 직렬화하고 전체 job timeout을 둔다.
4. 인증 발급, readiness probe, cleanup을 로그 step으로 구분한다.
5. response body, header, command line에 credential이나 token을 출력하지 않는다.
6. 앱 assertion 실패를 재실행으로 덮지 않으며, 429/5xx 같은 외부 장애 재시도 정책은 백엔드 합의 후 별도로 둔다.
7. 안정성과 비용을 검증하기 전에는 PR required check로 승격하지 않는다.

repository Environment 생성, secret 등록, branch protection 변경은 권한을 가진 팀 구성원의 명시적 승인 후 별도 작업으로 진행한다.

## 실패 판정

| 실패 | 분류 | 기본 처리 |
| --- | --- | --- |
| 인증 발급 401/403 | 인증 계약 실패 | 재시도 없이 실패, token 원문 미출력 |
| authenticated probe 401 | token TTL/전달 실패 | 재시도 없이 실패 |
| 429 또는 일시적 5xx | 외부 환경 후보 | 합의된 횟수만 재시도하고 원인 기록 |
| response schema/assertion 불일치 | 앱/API 계약 실패 | 재시도 없이 실패 |
| cleanup 실패 | 데이터 위생 실패 | run 실패 처리 후 fixture owner에게 알림 |
| runner/emulator provisioning 실패 | CI 인프라 실패 | 앱 실패와 구분해 기록 |

## Blocked 해제 체크리스트

- [ ] CI가 개인 계정 없이 실행마다 인증을 발급받을 수 있다.
- [ ] token TTL, 갱신/재발급, 폐기와 오류 코드가 문서화되어 있다.
- [ ] backend 소유 테스트 사용자와 데이터 사용 범위가 정해져 있다.
- [ ] run별 격리 key와 정상·실패 cleanup, TTL fallback이 준비되어 있다.
- [ ] GitHub Environment와 secret 등록 주체가 승인되었다.
- [ ] 단계 1 read-only probe의 request/response와 성공 기준이 합의되었다.
- [ ] 단계 2 전에 로그인/프로필 화면의 Auth repository 연결이 완료되었다.
- [ ] 실제 credential이나 secret 값은 저장소 문서와 이슈에 기록하지 않았다.

모든 항목이 확인되면 TEST-02-B를 `Ready`로 바꾸고, 단계 1 workflow와 단계 2 프론트 구현을 각각 별도 이슈로 진행한다.
