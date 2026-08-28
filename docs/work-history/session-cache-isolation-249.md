# 계정별 캐시·진행 중 요청 격리 이력

## 작업 기준

- 이슈: [#249](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/249), AUDIT-02
- PR: [#259](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/259), `develop` 병합 완료(`b15cdd7`). 이슈·PR은 Project 10의 `Done`, category `User`, priority `high`로 관리합니다.
- 상위 이슈: [#226](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/226)
- 작업일: 2026-08-28
- 기준 `develop`: `a630c66e3facb52f2a0f83d0f1aaa834c0cab7f0` (사용자 PR #258 병합)
- 브랜치: `fix/session-cache-isolation-249`
- 상태: 사용자 병합 완료(2026-08-28). #250 시작 시 이슈 종료와 Project `Done`을 확인하고 감사 체크리스트를 완료 처리했습니다.
- 참고: [README](../../README.md), [개발 감사 체크리스트](../development-audit-checklist.md), [Feature](../feature-development-guide.md), [상태관리](../state-management-guide.md), [라우팅](../routing-guide.md), [폼 검증](../form-validation-error-guide.md), [테스트](../testing-guide.md), [Git](../git-workflow.md)

기존 #249가 같은 범위를 다뤄 새 이슈를 중복 생성하지 않았습니다. #248과 PR #258의 종료·병합 및 Project `Done`을 확인한 뒤 최신 `develop`에서 분기했습니다. 미사용 공용 위젯, 새 UI 디자인, API 계약, 배포·CI 설정은 변경하지 않습니다.

## 재현과 구현

수정 전 같은 컨테이너에서 A→B 전환 및 로그아웃 뒤 늦은 조회 응답을 다룬 새 테스트 2개가 실패했습니다. 기존 Provider가 세션에 의존하지 않아 두 번째 계정의 조회가 시작되지 않았습니다. 추가로 지연 token 저장 테스트 2개에서 B token 덮어쓰기와 로그아웃 후 A token 재생성을 재현했습니다.

| 경계 | 처리 |
| --- | --- |
| 인증·데이터 수명 | `UserDataSession`의 세대·활성 여부를 교체. 동일한 `authenticated` 상태에서도 계정 결과마다 새 세션 사용 |
| 비인증 조회 | `requireUserDataSession`으로 repository 호출 전 차단. 초기 token 복원 완료 후 다시 조회 |
| 조회·화면 캐시 | 원격 Provider의 세션 의존성과 화면용 `unwrapPrevious()`로 이전 사용자 값이 loading/error 중 보이지 않도록 처리 |
| 입력·로컬 상태 | API 모드 폼·검색·선택·요청 결과·알림·로컬 추가 데이터 초기화. 기존 프로필 인수를 가진 오래된 폼은 재제출 차단 |
| 비동기 변경 | 요청 시작 Ref·세션을 캡처해 성공/실패, cache invalidate와 navigation 결과 전에 검사 |
| 네트워크 | 세션별 Dio를 만들고 이전 client 종료. token 읽기 전후와 응답 시 세션 검사, 비인증 요청에는 이전 Bearer token 미첨부 |
| 인증 token 저장 | `AuthTokenWriter`가 인증 시도 번호를 검사하고 저장·삭제를 직렬화. 큐는 세션 교체로 재생성하지 않음 |
| 로그아웃·탈퇴 | 현재 세션을 먼저 닫고 token 삭제 대기. 이전 탈퇴 응답이나 지연 삭제 완료로 새 인증 상태를 변경하지 않음 |

도메인에서 인증 feature를 역참조하지 않도록 데이터 세션은 `core/network`에 둡니다. token store는 저장소 구현, writer는 쓰기 순서만 담당하며 새로운 패키지나 범용 캐시 프레임워크는 추가하지 않습니다. 기존 공용 위젯·디자인 토큰과 route 계약은 유지합니다.

### 조회 범위

같은 code/id/query를 유지한 채 A→B로 바꿔 아래 14개 Provider 경로가 새 데이터로 바뀌는지 확인합니다. 기반 repository 조회는 11개이며 파생 Provider가 불필요한 중복 요청을 늘리지 않는지도 검사합니다.

| 범위 | Provider |
| --- | --- |
| User | `currentUserProvider`, `userSearchProvider` |
| Place | `remotePlaceListProvider`, `userPlaceSummariesProvider`, `placeSummaryProvider`, `placeDetailProvider`, `remoteFriendManagementMembersProvider` |
| Plant | `remotePlantListProvider`, `remotePlantDetailProvider`, `remotePlantEditInfoProvider` |
| Friend | `remotePlaceInvitationsProvider` |
| 파생 입력 정보 | `remotePlaceFormEditInfoProvider`, `remotePlantFormEditInfoProvider`, `plantRegistrationPlaceProvider` |

## 검증

기존 376개에서 회귀 테스트 34개를 추가했습니다. 기존 API domain 테스트 27개 파일에는 명시적 활성 세션 fixture를 추가했으며, 인증·계정 전환 테스트는 실제 Auth Controller와 메모리 token store로 별도 검증합니다.

| 추가 회귀 | 개수 | 증거 |
| --- | --- | --- |
| 조회 캐시·비인증 요청·A→B·늦은 응답 | 4 | [cache test](../../test/features/login/presentation/providers/session_cache_isolation_test.dart) |
| 프로필·장소/식물 생성·삭제·친구 처리·탈퇴의 늦은 결과 | 10 | [action test](../../test/features/login/presentation/providers/session_action_isolation_test.dart) |
| API 초안 초기화와 fixture 보존 | 2 | [draft test](../../test/features/login/presentation/providers/session_draft_isolation_test.dart) |
| 프로필 loading/error/retry에서 A 정보 숨김 | 1 | [profile widget test](../../test/features/user/presentation/pages/user_profile_session_test.dart) |
| 세션 복원·삭제, 지연 로그인·회원가입 | 7 | Auth session·Login·Profile Setup Controller test |
| token 읽기·Dio 전송·응답 취소·읽기 오류 | 4 | [network test](../../test/core/network/user_data_session_network_test.dart) |
| 오래된 token 저장 차단·저장/삭제 순서·실패 후 큐 복구 | 6 | [writer test](../../test/core/network/auth_token_writer_test.dart), [auth repository test](../../test/features/login/data/repositories/auth_repository_test.dart) |

- `fvm dart format --output=none --set-exit-if-changed .`: 303개 파일, 변경 0개
- `fvm flutter analyze`: 문제 없음
- `fvm flutter test`: 410개 통과, 기존 non-Linux golden skip 1개
- 인증·네트워크 관련 대상 테스트: 34개 통과
- 신규 조회·변경·초안·화면 세션 테스트: 17개 통과
- `git diff --check`: 통과
- Markdown 40개(README·AGENTS 포함), 로컬 링크 178개·anchor 9개: 누락 링크·미연결 문서 0개
- 구현·검증 문서 커밋 `c5b3d6c`의 [Flutter CI](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/actions/runs/33144026596)는 성공했습니다. 최종 문서 커밋 이후 결과는 [최신 PR checks](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/259/checks)와 이슈 검증 코멘트에서 확인합니다.

Android 수동 smoke와 실제 인증 dev E2E는 실행하지 않았습니다. fixture·앱 셸·route 정의를 변경하지 않았고 기존 widget/router 회귀 테스트는 전체 검사에 포함합니다. API endpoint·payload·Swagger 계약을 바꾸는 작업이 아니므로 이번 이슈에서 새로운 원격 인증·변경 요청은 하지 않았습니다.

## 남은 제한과 위험

- 이미 서버에 도착한 A의 생성·수정·삭제 요청을 rollback하거나 서버 처리를 취소한다고 보장하지 않습니다. 이번 보호는 이후 B의 상태·캐시·이동에 그 결과가 반영되는 것을 막습니다.
- 진행 중 secure storage 쓰기는 플랫폼에서 취소할 수 없습니다. 같은 ProviderScope에서 뒤따르는 삭제·새 저장 순서를 보장하지만 앱 강제 종료·다중 isolate·다른 앱 프로세스까지 원자적으로 묶지는 않습니다.
- OS 저장소 삭제가 실패해도 현재 앱의 인증·데이터 세션은 즉시 닫힙니다. 영속 token이 남으면 재시작 시 복원될 수 있으므로 실제 플랫폼 장애·복구 검증은 별도입니다. 메모리 테스트 성공을 영속 삭제 보장으로 해석하지 않습니다.
- refresh·만료 복구·서버 logout은 `TOKEN-01`/`TOKEN-02` 미확정 상태를 유지합니다. 소셜 SDK 설정과 원격 E2E의 인증 bootstrap·데이터 격리·cleanup 조건도 해결한 것이 아닙니다.
- Riverpod의 이전 값 숨김은 사용자 표시·상태 수명 격리이며 프로세스 메모리의 보안 삭제를 뜻하지 않습니다. 새 화면은 원격 `AsyncValue.value`를 직접 표시하지 않고 세션 격리 기준을 따라야 합니다.
- #250 중복 제출, #251 원격 장소 목록의 fixture 혼입, #252 code 없는 식물 수정, #253 주소 결과, #254~#256의 파서·위젯·Provider 개선은 별도로 남습니다. 이미지 수정 제한 #248과 미사용 공용 위젯 보존 결정도 유지합니다.

## 커밋별 작업 이력

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| `59c7d7d` | 데이터 세션·Dio 경계, 인증 결과 검사, token 저장·삭제 직렬화 | 인증·네트워크 대상 34개 통과, format·analyze |
| `a3e9711` | 사용자별 조회·초안·비동기 후처리 격리와 화면 이전 값 제거, domain fixture 보완 | 신규 세션 대상 17개, 전체 410개 통과·기존 skip 1개 |
| `c5b3d6c` | #248 병합·#249 구현 상태, 개발 가이드·매트릭스와 위험·검증 기록 | `git diff --check`, Markdown 40개·로컬 링크 178개·anchor 9개, 미연결 문서 0개 |
| `12eef39` | PR #259·Project In Review 연결과 커밋별 이력 기록(당시 상태) | `git diff --check`, 담당자·milestone·Bug type·parent·Project 필드 확인 |

#250 후속 문서에서 사용자 병합 커밋 `b15cdd7`과 이슈·PR `Done`을 반영했습니다. 위 검증과 남은 제한은 #249 작업 시점의 기록이며 다음 수정은 [제출 잠금 이력](form-submit-lock-250.md)으로 이어집니다.

문서·PR 이력만 기록하는 마지막 커밋은 자기 자신의 해시를 생략할 수 있습니다.
