# 장소 주소 선택 결과 연결 이력

## 작업 기준

- 이슈: [#253](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/253), AUDIT-06
- 상위 이슈: [#226](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/226)
- 작업일: 2026-08-29
- 기준 `develop`: `5fc01405a91bc715a5a87ce8e40c2e8c58815714` (사용자 PR #262 병합)
- 브랜치: `fix/place-address-result-253`
- 상태: [PR #263](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/263) 사용자 병합 완료(`ded4fe2`). 이슈는 Closed, 이슈·PR의 Project 10 상태는 `Done`입니다. category `Place`, priority `medium`, Issue Type `Bug`, 담당자 `ywkim95`·`bbielo`, milestone `v1.0.0 - MVP (핵심 기능 개발)`을 유지했습니다.
- 참고: [README](../../README.md), [감사 체크리스트](../development-audit-checklist.md), [화면·API 계획](../screen-api-integration-plan.md), [Feature](../feature-development-guide.md), [라우팅](../routing-guide.md), [상태관리](../state-management-guide.md), [폼 검증](../form-validation-error-guide.md), [공용 위젯](../shared-widget-guide.md), [디자인 토큰](../design-token-rules.md), [퍼블리싱](../screen-publishing-rules.md), [Figma 매핑](../figma-frame-map.md), [테스트](../testing-guide.md), [Git](../git-workflow.md)

clean 작업 트리와 원격 `develop`, 이슈 중복을 확인하고 기존 #253을 재사용했습니다. 작업 시작 당시 #252는 Closed이고 이슈·PR #262의 Project 상태는 Done, 상위 #226은 16/20 완료였습니다. #253 병합 후 이슈·PR #263은 Done이며 상위 #226은 17/20 완료입니다. 이 문서 변경에서 #252의 병합 전 표기를 정정했습니다.

## 원인과 수정

`AddressSearchPage`는 주소 선택 시 결과 없이 복귀했고, `PlaceFormPage`는 route 반환값을 기다리지 않았습니다. 선택한 주소가 폼에 도달하지 않아 API 생성·수정의 주소 필수 검증에 사용할 수 없었습니다.

| 경계 | 처리 |
| --- | --- |
| 선택 결과 | 기존 `AddressSearchResult`를 `push<AddressSearchResult>` / `maybePop<AddressSearchResult>`로 전달. 제목 대신 `address`를 사용하고 `source`로 fixture·searchService 구분 |
| 생성·수정 폼 | `applyAddressSelection`에서 유효한 주소의 앞뒤 공백을 제거하고 기존 `updateAddress`에 전달. 기존 필수 검증·요청 DTO 사용 |
| 취소·빈 결과 | null·공백 주소는 기존 주소·초안·오류 상태를 바꾸지 않음. 사용자가 주소 삭제 버튼을 누르는 동작과 구분 |
| 화면·폼 폐기 | 화면의 `context.mounted`와 검색 시작 시 Controller Ref를 확인. Provider가 남아 있어도 호출 화면이 없으면 반영하지 않음 |
| 계정 전환 | 검색 시작 세션과 현재 세션을 비교해 이전 계정 결과를 반영하지 않음 |
| 제출 중 주소 변경 | `submitting` 유지, 최초 요청은 처음 주소 사용, 재호출 차단. 실패 시 새 초안을 보존해 재시도 |
| API 비사용 | 기존 fixture 검색·선택과 주소 선택 사항 정책 유지. 일치 결과가 없으면 empty 안내 |
| API 사용 | 기본 검색은 미연결 안내, 결과·선택 버튼 없음. Controller에서도 fixture 결과를 거부 |

새 route·공용 위젯·디자인 토큰·의존성은 추가하지 않았습니다. 기존 `CommonScaffold`, `CommonAddressOrPlaceField`, 색상·글꼴 토큰을 재사용합니다. API 파싱과 유효성 검증은 화면으로 옮기지 않았으며 기존 사진이 있는 Place 수정 제한도 유지합니다.

## 검증

기존 테스트 파일 5개에 회귀 실행 사례 26개를 추가하고, 주소 반환·제출 잠금·사진 보호의 기존 테스트 6개를 보강했습니다. 신규 테스트 파일이나 실서비스 adapter는 추가하지 않았습니다.

| 테스트 | 검증 범위 |
| --- | --- |
| [장소 route 흐름](../../test/app/router/place_route_flow_test.dart) | 신규 15개: 로컬 생성·수정 선택/취소, 실제 production 생성·수정·검색 route builder와 요청 DTO, API 기본 미연결·샘플 거부, 계정 세션 전환, 화면만 폐기된 경우, 제출 중 재선택·성공/실패·재시도 |
| [주소 검색 Page](../../test/features/place/presentation/pages/address_search_page_test.dart) | 신규 4개: 3개 viewport의 API 미연결 안내·fixture 미노출, 로컬 empty. 기존 선택 테스트에서 주소·출처 반환 확인 |
| [주소 검색 Controller](../../test/features/place/presentation/providers/address_search_controller_test.dart) | 신규 1개: API 초기화와 검색어 변경에서 fixture 결과 미노출 |
| [장소 Form Controller](../../test/features/place/presentation/providers/place_form_controller_test.dart) | 신규 5개: 모드별 fixture 허용/거부, 취소·빈 주소 상태 보존, 폐기된 Provider 결과 차단. 기존 생성·수정 성공/실패 잠금 4개와 사진 보호 1개에 비동기 주소 선택 적용 |
| [인증 액션 격리](../../test/features/login/presentation/providers/session_action_isolation_test.dart) | 신규 1개: 메모리 token store와 실제 Auth Controller로 A→B 전환 후 A 선택 결과 차단 |

- Viewport: Reference `375×812`, Compact width `320×640`, Short height `375×667`, DPR 1
- 위 5개 파일 대상 테스트: 57개 통과
- `fvm dart format --output=none --set-exit-if-changed .`: 309개 파일, 변경 0개
- `fvm flutter analyze`: 문제 없음
- `fvm flutter test --reporter expanded`: 502개 통과, 기존 non-Linux golden skip 1개
- `git diff --check`: 통과
- README·AGENTS·docs의 Markdown 44개, 로컬 링크 284개·anchor 14개: 누락 링크·미연결 문서 0개
- 최종 PR의 기본 Flutter CI는 Ubuntu golden을 포함한 503개를 1분 54초에 통과했습니다.

API payload 검증은 테스트 전용 검색 결과와 fake datasource를 사용하되, production route·Form Controller·PlaceRepositoryImpl·요청 DTO를 통과시킵니다. 실제 HTTP 전송·외부 주소 검색·인증 API 쓰기를 검증한 것은 아닙니다. 기존 datasource의 multipart 직렬화·API 경계 테스트는 전체 검사에 포함됩니다.

## 남은 제한과 위험

- **실제 주소 검색 서비스는 미연결입니다.** `searchService` 출처를 가진 결과는 현재 테스트에서만 생성합니다. 이 enum은 외부 서비스 계약이나 검색 성공·주소 유효성 보증이 아닙니다.
- API 모드에서는 새 주소를 선택할 수 없습니다. 기존 서버 주소를 유지한 사진 없는 장소 수정은 가능하지만, 새 주소가 필요한 장소 생성·주소 변경 동선은 검색 서비스 결정 후 연결해야 합니다. fixture로 필수 검증을 통과시키지 않습니다.
- 외부 서비스 선택·키 발급·과금·플랫폼 권한·검색 API 응답 계약·실제 adapter는 이번 범위에서 결정하거나 추가하지 않았습니다. 주소를 지운 뒤의 복원 UI도 새로 만들지 않았습니다.
- 늦은 결과 방어는 클라이언트의 폼·세션 수명에 대한 처리입니다. 서버에 도착한 쓰기 취소·롤백이나 다른 기기의 중복 요청은 보장하지 않습니다.
- 실제 인증 API 쓰기·원격 E2E·Android/iOS 수동 smoke·새 Figma 시각 대조는 미실행입니다. 배포·스토어·Environment·branch protection·기본 CI 설정은 변경하지 않았습니다.
- #248~#253 보호와 미사용 공용 위젯 5개·public 버튼 variant를 유지합니다. #253 병합 뒤 최신 `develop`에서 #254를 시작했으며 이후 #255 → #256 순서로 진행합니다.

## 커밋별 작업 이력

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| `d54d3e4` | 주소 typed 결과·출처·폼 연결·API fixture 차단과 화면/폼/계정 수명 보호, 회귀 테스트 26개 추가 | 대상 57개·전체 502개 통과, 기존 skip 1개, format·analyze·diff 검사 |
| `e3a5797` | #252 병합 상태 정정, #253 계약·검증·남은 제한과 현행 문서 갱신 | 로컬 Markdown 링크·문서 인덱스 확인, `git diff --check` |

문서·PR 이력만 기록하는 마지막 커밋은 자기 자신의 해시를 생략할 수 있습니다.
