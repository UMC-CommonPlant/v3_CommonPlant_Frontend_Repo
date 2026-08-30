# 수정 정보 Provider 전달 단순화 이력

## 작업 기준

- 이슈: [#256](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/256), AUDIT-09
- PR: [#266](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/266), `develop` 대상
- 상위 이슈: [#226](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/226)
- 작업일: 2026-08-30
- 기준 `develop`: `894dd5f7b0bfe7e1e3de0d295115480b1f2753cb` (사용자 PR #265 병합)
- 브랜치: `refactor/form-edit-provider-flow-256`
- 상태: 2026-08-30 사용자 PR #266 병합 완료(`011ef7db1affb9b50fc241222b5f9408bc5eb5f5`). 이슈·PR은 Project 10의 `Done`, category `Plant`, priority `low`이며 상위 Epic #226은 하위 이슈 20/20 완료로 종료됐습니다.
- 참고: [README](../../README.md), [감사 체크리스트](../development-audit-checklist.md), [화면·API 계획](../screen-api-integration-plan.md), [Feature](../feature-development-guide.md), [상태관리](../state-management-guide.md), [테스트](../testing-guide.md), [Git](../git-workflow.md)

clean 작업 트리와 원격 `develop`, 이슈 중복을 확인하고 기존 #256을 재사용했습니다. 작업 시작 시 #255는 Closed이고 이슈·PR #265의 Project 상태는 Done, 상위 #226은 19/20 완료였습니다. 이번 문서 변경에서 #255의 병합 전 표기를 정정했습니다.

## 원인과 수정

Plant와 Place 수정 정보는 실제 원격 fetch 원본 뒤에 그 원본의 `.future`를 기다렸다가 nullable 폼 정보로 다시 포장하는 `FutureProvider`가 각각 하나씩 있었습니다. 실제 네트워크 요청이 세 번 발생한 구조는 아니었지만, 같은 loading/error가 두 원격 Provider에 걸쳐 전달되고 재시도 때 원본과 중간 단계를 함께 무효화해야 했습니다.

| 경계 | 변경 후 계약 |
| --- | --- |
| API 비사용 | 기존 fixture와 즉시 완료되는 폼 진입 `AsyncValue` 유지 |
| Plant API 모드 | `remotePlantEditInfoProvider`가 fetch·오류·재시도의 단일 원본, 폼 진입점은 빈 이름을 `null`로 변환 |
| Place API 모드 | `placeSummaryProvider`가 fetch·오류·재시도의 단일 원본, 폼 진입점은 빈 이름을 `null`로 처리하고 `PlaceFormEditInfo`로 변환 |
| 계정 전환 표시 | 폼 진입점의 `unwrapPrevious()`를 유지해 이전 계정 데이터를 숨김 |
| 사용자 재시도 | Controller가 실제 fetch 원본 하나만 무효화 |
| 테스트 override | 공개 폼 진입점 아래의 원본 family instance를 override하고 repository 위임은 원본 Provider에서 별도 검증 |

`remotePlantFormEditInfoProvider`와 `remotePlaceFormEditInfoProvider`만 제거했습니다. 공개 폼 진입 Provider, 원본 fetch Provider, Controller와 State 이름은 유지했습니다. 새 추상화·패키지·API·DTO·repository·화면은 추가하지 않았고 서버 요청 횟수도 바꾸지 않았습니다.

## 검증

Place 원본 repository 위임과 실패 후 재조회 회귀 2개를 추가하고, 기존 테스트가 제거된 중간 Provider가 아니라 남은 원본과 공개 폼 진입점을 관찰하도록 갱신했습니다.

| 테스트 | 검증 범위 |
| --- | --- |
| [Plant 폼 정보](../../test/features/plant/presentation/providers/plant_form_edit_provider_test.dart) | API 비사용 fixture, 원본 override의 원격 성공·빈 정보, 원본 repository 위임 |
| [Place 폼 정보](../../test/features/place/presentation/providers/place_form_edit_provider_test.dart) | API 비사용 fixture, 원본 summary override의 변환·빈 정보 |
| [Place 원본 조회](../../test/features/place/presentation/providers/place_detail_remote_provider_test.dart) | route code를 사용한 `placeSummaryProvider`의 repository 위임 신규 1개 |
| [Place Form Controller](../../test/features/place/presentation/providers/place_form_controller_test.dart) | 원격 조회 실패 뒤 원본 summary만 무효화해 2번째 조회로 ready 복구 신규 1개 |
| [세션·기존 보호](../../test/features/login/presentation/providers/session_cache_isolation_test.dart) | 공개 폼 상태의 계정별 재조회, Plant·Place 제출 잠금·이미지·장소 code와 화면 상태 회귀 |

- 관련 Provider·Controller·화면 대상 테스트: 통과
- `fvm dart format --output=none --set-exit-if-changed .`: 309개 파일, 변경 0개
- `fvm flutter analyze`: 문제 없음
- `fvm flutter test --reporter expanded`: 513개 통과, 기존 non-Linux golden skip 1개
- `git diff --check`: 통과
- README·AGENTS·docs의 Markdown 47개, 로컬 링크 336개·anchor 15개: 누락 링크·미연결 문서 0개
- 최종 PR CI: [Flutter CI quality](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/actions/runs/33316664772/job/99271258349) 통과, 1분 52초. Ubuntu golden 포함 514개 통과입니다.

테스트는 fake repository와 Provider override를 사용했습니다. 실제 dev API 읽기·쓰기, 인증 E2E, Android/iOS 수동 smoke는 실행하지 않았습니다.

## 남은 제한과 위험

- 이 변경은 같은 원격 응답을 전달하는 Provider 단계를 줄인 구조 정리입니다. API 호출 수·응답 시간·서버 부하는 전후가 같으며 성능 개선을 검증한 작업이 아닙니다.
- `whenData`는 원본 loading/error를 유지하고 데이터만 변환합니다. 추후 폼에 독립 캐시나 별도 비동기 정책이 필요해지면 그 요구사항과 상태 계약을 별도 이슈에서 정의합니다.
- API 비사용 fixture와 API 모드 실제 응답은 계속 분리합니다. fixture를 원격 loading/error/empty의 대체값으로 사용하지 않습니다.
- #248~#255 보호, 사진이 있는 Place 수정 제한, 미확인 Plant 이미지 key·장소 code 차단, 미사용 공용 위젯 5개와 public 버튼 variant를 유지합니다.
- 실제 주소 검색·이미지 선택·미확정 백엔드 계약, 배포·스토어·Environment·branch protection은 변경하지 않습니다.

## 커밋별 작업 이력

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| `63b96b2` | Plant·Place 중간 원격 수정 정보 Provider 제거, 원본 조회·재시도·override 회귀 정리 | 관련 대상 테스트, format·analyze·diff 검사 |
| `dd21e26` | #255 병합 상태 정정, #256 계약·검증·남은 제한과 현행 문서 갱신 | 전체 Flutter·Markdown 링크·인덱스·diff 검사 |
| 이 문서의 후속 커밋 | PR #266 병합·Done, 최종 CI 514개와 Epic #226 20/20 완료 반영 | GitHub PR·이슈·Project·CI 확인, `git diff --check` |

문서·PR 이력만 기록하는 마지막 커밋은 자기 자신의 해시를 생략할 수 있습니다.
