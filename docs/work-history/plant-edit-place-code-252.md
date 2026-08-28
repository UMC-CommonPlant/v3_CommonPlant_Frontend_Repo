# 식물 수정 장소 코드 검증 이력

## 작업 기준

- 이슈: [#252](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/252), AUDIT-05
- 상위 이슈: [#226](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/226)
- 작업일: 2026-08-29
- 기준 `develop`: `ebf6dc41e5f959b9f9f8ba2c772d5de790cc7d7a` (사용자 PR #261 병합)
- 브랜치: `fix/plant-edit-place-code-252`
- 상태: 구현·로컬 검증 완료, PR 준비. 이슈는 Project 10의 `In Progress`, category `Plant`, priority `high`로 관리합니다.
- 참고: [README](../../README.md), [감사 체크리스트](../development-audit-checklist.md), [Feature](../feature-development-guide.md), [상태관리](../state-management-guide.md), [폼 검증](../form-validation-error-guide.md), [라우팅](../routing-guide.md), [퍼블리싱](../screen-publishing-rules.md), [Figma 매핑](../figma-frame-map.md), [공용 위젯](../shared-widget-guide.md), [테스트](../testing-guide.md), [Git](../git-workflow.md), [Swagger](../api-swagger-reference.md)

열린 이슈 중복을 확인하고 기존 #252를 재사용했습니다. #251 종료와 PR #261 병합·Project `Done`을 확인한 뒤 최신 `develop`에서 분기했습니다. 상위 #226의 완료 하위 이슈는 15/20이며 #252는 병합 전 완료로 세지 않습니다. 미사용 공용 위젯과 #248 이미지 보호·#249 세션 격리·#250 제출 잠금·#251 등록 장소 검증을 유지합니다.

## 원인과 계약 근거

기존 `_update`는 `placeId != null`일 때만 API를 호출하고, 그 조건 밖에서 로컬 이름 변경과 상세 이동 결과를 반환했습니다. code가 없으면 원격 수정 없이 성공한 것처럼 보였고, 성공한 경우에도 관련 상세·편집 캐시가 남았습니다. 수정 전 신규 Controller 회귀 10개 중 6개가 실패하고 4개가 통과했습니다.

2026-08-29 [dev OpenAPI JSON](https://commonplant-dev.okbear.dev/api/v1/api-docs/json)을 읽기 전용으로 재확인했습니다(HTTP 200).

- `PUT /plants/{plantId}`의 query `placeCode`는 required입니다.
- `PlantSummary`에는 plantId·nickname·representativeImageUrl, `EditInfoResponse`에는 imageKey·imageUrl·nickname·lastWateredDate가 있으며 장소 code는 없습니다.
- `DetailResponse`에는 placeName이 있지만 장소 code와 nickname은 없습니다. 같은 장소명·학명으로 식별자를 복원하지 않습니다.
- 현재 장소 상세→식물 상세→수정 route는 실제 장소 code를 `placeId` query로 전달합니다. route 이름·API endpoint·DTO·repository 계약은 그대로 사용합니다.

위 재확인은 Plant query·schema 범위이며 backend main의 새 커밋이나 실제 인증 응답을 재검증한 것은 아닙니다. code 조회 확장은 [PLANT-01](../backend-api-open-questions.md#plant-01-식물에서-소속-장소-code-조회)로 분리합니다.

## 수정 동작

| 상황 | 폼·API·이동 |
| --- | --- |
| 원격 code null·빈 값·공백 | `missingPlace`, 편집 정보 조회·PUT·로컬 변경·성공 결과 없음. 기존 상태 화면에서 홈→장소→식물 재진입 안내 |
| 원격 code 있음 | 앞뒤 공백을 제거한 실제 code와 기존 이미지 key·제출 시 이름·날짜로 PUT 호출 |
| PUT 성공·현재 요청 세션 유지 | 식물 목록·해당 식물 상세·해당 장소 상세·편집 정보 갱신 후 상세 이동 결과 반환 |
| PUT 실패 | 캐시·로컬 값 유지, 초안 보존·사용자용 오류, 재시도 가능. 이동 없음 |
| 계정 전환 후 늦은 성공·실패 | 새 계정 캐시·초안에 후처리하지 않고 이동 결과도 반환하지 않음 |
| API 비사용 | code 없는 기존 로컬 수정 유지 |

- 코드 검증과 제출 처리는 Controller에 두고, 화면은 `PlantStateScaffold`의 안내·홈 이동만 조합합니다. 공용 위젯·토큰·route를 새로 만들지 않습니다.
- `missingPlace` 상태에서는 이름·날짜 변경과 조회 재시도로 제출을 우회할 수 없습니다. `_update`에도 누락 code 방어를 둡니다.
- 캐시 무효화는 성공 결과·현재 요청 세션 확인과 제출 상태 정리 뒤에 수행합니다. 폼이 watch하는 편집 정보를 너무 일찍 무효화해 요청 Ref가 바뀌고 성공 결과가 유실되는 경우를 방지합니다.
- 성공 후 재조회 오류는 조회 상태에서 처리합니다. 이미 성공한 PUT을 실패로 바꾸거나 자동으로 다시 전송하지 않습니다. 다른 식물·장소 상세 캐시는 유지합니다.

## 검증

Controller 10개·widget/router 9개, 총 19개 회귀 테스트를 추가했습니다. 기존 Plant Form의 원격 loading/empty/error 테스트 3개에는 해당 조회를 시작할 유효한 장소 code를 명시했습니다.

| 테스트 | 검증 범위 |
| --- | --- |
| [Controller 회귀](../../test/features/plant/presentation/providers/plant_edit_place_code_test.dart) | code 3종 누락, 공백 정규화·payload, 성공 후 원본 조회 4종 갱신·다른 캐시 유지, 실패·재시도·중복 제출, 늦은 계정 응답 2종, 성공 후 조회 실패, 로컬 수정 |
| [화면·라우트 회귀](../../test/app/router/plant_edit_place_code_flow_test.dart) | 실제 production Plant route builder, code 누락 5사례의 홈 안내, 상세→수정→상세→수정 3개 viewport, 날짜·애칭 재조회, 실패 시 초안 유지·재시도 성공 후 이동 |

- Viewport: Reference `375×812`, Compact width `320×640`, Short height `375×667`, DPR 1
- 신규 Controller·기존 Plant Form 대상: 40개 통과
- 신규 widget/router: 9개 통과
- `fvm dart format --output=none --set-exit-if-changed .`: 309개 파일, 변경 0개
- `fvm flutter analyze`: 문제 없음
- `fvm flutter test --reporter expanded`: 476개 통과, 기존 non-Linux golden skip 1개
- `git diff --check`: 통과
- 프로젝트 Markdown 44개(미입력 링크가 있는 `.github` 이슈 템플릿 제외), 로컬 링크 257개·anchor 14개: 누락 링크·미연결 문서 0개

테스트에는 실제 Provider 체인과 Plant route builder에 fake repository를 주입했습니다. 실제 dev API 쓰기·인증 E2E·Android/iOS 수동 smoke는 실행하지 않았습니다. 플랫폼 back·SafeArea 등의 수동 QA나 새로운 Figma 시각 일치 검증을 완료한 작업이 아닙니다.

## 남은 제한과 위험

- Home 식물 목록 응답에는 code가 없어 이 경로의 수정은 안내로 막힙니다. 현재 가능한 동선은 홈에서 해당 장소를 선택한 뒤 식물 상세→수정으로 들어가는 방식입니다. 모든 장소를 순회하거나 첫 장소·이름으로 code를 추정하지 않습니다.
- code가 존재한다고 현재 권한·소속을 보장하지 않습니다. 조회 후 삭제·권한 변경·잘못된 외부 query는 서버가 최종 판단하며 기존 수정 오류로 안내합니다.
- 상세 API에는 nickname이 없어 상세의 학명을 애칭으로 덮어쓰지 않습니다. 새 애칭은 목록과 다시 연 편집 화면, 새 물 준 날짜는 상세·편집·장소 상세 재조회로 확인합니다.
- 서버에 도착한 쓰기의 취소·롤백, 응답 유실 후 재시도·다른 기기의 멱등성은 보장하지 않습니다. 성공 후 새 조회의 서버 측 최신성도 프론트 캐시 무효화만으로 보장할 수 없습니다.
- 사진이 있는 Place 수정 제한과 미확인 Plant 이미지 key 차단은 유지합니다. 실제 이미지 선택·삭제, 주소 결과 전달 #253, 파서·위젯·Provider 개선 #254~#256은 별도입니다.
- 배포·스토어·CI required check·Environment·의존성·미확정 API 정책은 변경하지 않습니다.

## 커밋별 작업 이력

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| `464b9b3` | 원격 수정 code 검증·누락 상태, 성공 후 관련 캐시 갱신과 Controller 회귀 10개 | 신규 Controller·기존 Plant Form 대상 40개 통과 |
| `4dcb910` | 3개 viewport의 실제 Plant route 전달·갱신·실패 재시도 회귀 | 신규 widget/router 9개, 전체 476개·기존 skip 1개, format·analyze |
| 문서 커밋 | #251 병합·#252 구현 상태, API 경계·백엔드 질문·가이드·매트릭스와 검증·위험 기록 | Markdown 44개·로컬 링크 257개·anchor 14개, `git diff --check` |

문서·PR 이력만 기록하는 마지막 커밋은 자기 자신의 해시를 생략할 수 있습니다.
