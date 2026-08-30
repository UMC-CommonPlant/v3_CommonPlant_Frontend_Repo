# API 목록 항목 타입 검증 이력

## 작업 기준

- 이슈: [#254](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/254), AUDIT-07
- 상위 이슈: [#226](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/226)
- 작업일: 2026-08-29
- 기준 `develop`: `ded4fe265bb1e47f6b1301ea9a7e83484a590672` (사용자 PR #263 병합)
- 브랜치: `fix/api-list-item-validation-254`
- 상태: [PR #264](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/264) 사용자 병합 완료(`f723825`). 이슈는 Closed, 이슈·PR의 Project 10 상태는 `Done`입니다. category `Story`, priority `medium`, Issue Type `Bug`, 담당자 `ywkim95`·`bbielo`, milestone `v1.0.0 - MVP (핵심 기능 개발)`을 유지했습니다.
- 참고: [README](../../README.md), [감사 체크리스트](../development-audit-checklist.md), [화면·API 계획](../screen-api-integration-plan.md), [Feature](../feature-development-guide.md), [테스트](../testing-guide.md), [Git](../git-workflow.md)

clean 작업 트리와 원격 `develop`, 이슈 중복을 확인하고 기존 #254를 재사용했습니다. 작업 시작 시 #253은 Closed이고 이슈·PR #263의 Project 상태는 Done, 상위 #226은 17/20 완료였습니다. #254 병합 후 이슈·PR #264는 Done이며 상위 #226은 18/20 완료입니다. 이번 문서 변경에서 #253의 병합 전 표기를 정정했습니다.

## 원인과 수정

공용 `jsonListFromResponse`는 목록을 찾은 뒤 `JsonMap` 항목만 남겼습니다. 이 때문에 `[1, "bad"]` 같은 응답은 정상 빈 목록으로, 정상 Map과 잘못된 값이 섞인 응답은 부분 성공으로 바뀌어 서버 응답 오류가 화면의 정상 empty 또는 불완전한 데이터로 보일 수 있었습니다.

| 경계 | 처리 |
| --- | --- |
| 정상 목록 | 기존 `List<JsonMap>` 반환과 항목 순서를 유지 |
| 정상 빈 배열 | 오류로 바꾸지 않고 정상 빈 목록으로 유지 |
| direct·nested wrapper | 기존 `result`, `data`, `items`, `content`, `list`, `places`, `plants` 탐색을 유지 |
| 전체 비정상 목록 | 첫 비-Map 항목의 1부터 시작하는 위치와 호출 context를 포함한 `ApiException` 반환 |
| 일부 비정상 목록 | 정상 항목만 남기는 부분 성공을 허용하지 않고 첫 비-Map 항목에서 실패 |
| 항목 내부 필드 | 공용 파서는 outer object 타입만 검사하고 필드 누락·타입 오류는 기존 도메인 mapper가 처리 |

새 파서 프레임워크·codegen·패키지는 추가하지 않았습니다. 화면에 파싱 로직을 넣지 않고 기존 repository·Provider의 오류 전달 경계를 유지합니다.

## 검증

기존 테스트 파일 4개에 회귀 실행 사례 6개를 추가했습니다. 새 테스트 파일이나 fixture 대체 경로는 만들지 않았습니다.

| 테스트 | 검증 범위 |
| --- | --- |
| [공용 응답 파서](../../test/core/network/api_response_parser_test.dart) | 신규 3개: 정상 빈 목록, 전체 비정상 목록의 첫 위치 오류, nested wrapper 일부 비정상 목록의 두 번째 위치 오류. 기존 `result.content.items` 호환성 유지 |
| [Plant mapper](../../test/features/plant/data/mappers/plant_mapper_test.dart) | 신규 1개: 정상 Plant와 비-Map 항목이 섞인 응답을 부분 성공으로 반환하지 않음 |
| [Place repository](../../test/features/place/data/repositories/place_repository_test.dart) | 신규 1개: 사용자 장소 목록의 일부 비정상 응답이 repository 오류로 전달됨 |
| [User repository](../../test/features/user/data/repositories/user_repository_test.dart) | 신규 1개: 사용자 검색의 전체 비정상 응답이 정상 empty로 바뀌지 않음 |

- 관련 공용·Plant·Place·User·Friend 테스트 7개 파일: 39개 통과
- `fvm dart format --output=none --set-exit-if-changed .`: 309개 파일, 변경 0개
- `fvm flutter analyze`: 문제 없음
- `fvm flutter test --reporter expanded`: 508개 통과, 기존 non-Linux golden skip 1개
- `git diff --check`: 통과
- README·AGENTS·docs의 Markdown 45개, 로컬 링크 300개·anchor 14개: 누락 링크·미연결 문서 0개
- 최종 PR의 기본 Flutter CI는 Ubuntu golden을 포함한 509개를 2분 0초에 통과했습니다.

테스트는 fake 응답을 공용 파서와 실제 Plant mapper, Place·User repository에 전달했습니다. 실제 HTTP 전송이나 인증된 서버의 잘못된 응답을 재현한 것은 아닙니다. Friend의 독립적인 엄격 mapper 회귀도 대상 검사에 포함해 공용 변경이 기존 정상 처리를 깨지 않는지 확인했습니다.

## 남은 제한과 위험

- 공용 파서는 목록 항목의 outer JSON object 타입만 확인합니다. 필수 필드 누락·필드 타입 오류·도메인 의미 검증은 각 mapper의 기존 책임입니다.
- JSON 문자열 자체가 잘못됐거나 확인되지 않은 wrapper를 사용하는 응답의 계약은 바꾸지 않았습니다. 이번 문제를 이유로 범용 스키마 검증이나 codegen을 도입하지 않았습니다.
- 실제 인증 API의 비정상 목록 응답·원격 E2E·Android/iOS 수동 smoke는 미실행입니다. 배포·스토어·Environment·branch protection·기본 CI 설정은 변경하지 않았습니다.
- #248~#254 보호와 정상 빈 목록·확인된 wrapper 호환성, 미사용 공용 위젯 5개·public 버튼 variant를 유지합니다. #254 병합 뒤 최신 `develop`에서 #255를 시작했으며 이후 #256을 진행합니다.

## 커밋별 작업 이력

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| `6cae790` | 공용 목록 항목 타입·위치 검증과 Plant·Place·User 회귀 테스트 6개 추가 | 대상 39개·전체 508개 통과, 기존 skip 1개, format·analyze·diff 검사 |
| `74a1426` | #253 병합 상태 정정, #254 계약·검증·남은 제한과 현행 문서 갱신 | 로컬 Markdown 링크·문서 인덱스 확인, `git diff --check` |

문서·PR 이력만 기록하는 마지막 커밋은 자기 자신의 해시를 생략할 수 있습니다.
