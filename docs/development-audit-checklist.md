# 개발 감사·개선 체크리스트

2026-08-28 사용자 결정과 `develop`의 PR #246 병합 커밋 `2a01babb185ef5056b361c477717759194c53ec1`을 기준으로 합니다. 문서 정리는 [#247](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/247), 상위 개발 범위는 [Epic #226](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/226)입니다.

## 결정과 작업 경계

1. 문서 정리를 먼저 완료합니다. 현행 가이드, 실행 체크리스트, 과거 계획, 작업 이력을 [문서 인덱스](README.md)에서 구분합니다.
2. 미사용 공용 위젯 5개는 보존합니다: `CommonAddTile`, `CommonPlaceGuideBanner`, `CommonPlusIconButton`, `CommonPlusMark`, `CommonSectionHeader`. public 버튼 variant도 이번 정리에서 삭제하지 않습니다.
3. 동작 문제를 아래 순서대로 별도 이슈·브랜치·PR에서 수정합니다. #247은 문서만 변경하며 아래 버그를 해결한 것으로 표시하지 않습니다.
4. 추가 파서·위젯·Provider 정리는 진행할 수 있지만, 새로운 추상화나 패키지 도입을 목표로 삼지 않습니다.
5. 원격 데이터 변경, 새 외부 서비스, 배포·스토어·CI 설정은 이번 범위가 아닙니다. 불명확한 API 필드나 식별자를 추측하지 않습니다.

## 문서 정리 #247

- [x] README의 라이브러리·현행 개발 상태·다음 작업 안내 갱신
- [x] 현행 문서와 과거 기록 분리, 작업 이력 8개 인덱스 연결
- [x] Feature 구조·수기 DTO/mapper·secure storage의 실제 도입 상태 반영
- [x] 미사용 공용 위젯 보존 결정 기록
- [x] 동작 문제 6개와 추가 개선 3개를 중복 확인 후 개별 이슈로 등록
- [x] 화면·API 매트릭스와 이미지 유지·삭제 계약의 현황 대조
- [x] 문서 링크와 변경 범위·공백 검증
- [ ] PR·검증·커밋 이력과 Project 상태 기록

## 실행 순서

표의 체크는 해당 수정 PR이 병합되고 회귀 검증이 끝났을 때만 완료합니다. 현재 #248~#256은 모두 `Backlog`이며 아직 코드 변경이 없습니다. Project의 priority는 아래 P1을 `high`, P2를 `medium`, P3를 `low`로 대응합니다.

| 체크 | 순서 | 이슈 | 우선도 | 문제·완료 기준 요약 |
| --- | --- | --- | --- | --- |
| [ ] | AUDIT-01 | [#248](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/248) | P1 | 장소·식물의 텍스트 수정이 기존 이미지를 삭제하지 않도록 key와 사용자 의도를 보존 |
| [ ] | AUDIT-02 | [#249](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/249) | P1 | 로그아웃·계정 전환 후 이전 사용자 캐시와 진행 중 요청의 영향 차단 |
| [ ] | AUDIT-03 | [#250](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/250) | P1 | 요청 중 입력 변경으로 submit 잠금이 풀리지 않도록 수정 |
| [ ] | AUDIT-04 | [#251](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/251) | P1 | API 모드 식물 등록의 loading/error/empty에서 샘플 장소 사용 금지 |
| [ ] | AUDIT-05 | [#252](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/252) | P1 | 장소 코드가 없어 API를 생략한 식물 수정의 거짓 성공 방지 |
| [ ] | AUDIT-06 | [#253](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/253) | P2 | 주소 선택·취소 결과를 장소 폼 상태와 검증에 연결 |
| [ ] | AUDIT-07 | [#254](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/254) | P2 | 잘못된 목록 항목을 빈 목록 성공으로 숨기지 않고 오류 처리 |
| [ ] | AUDIT-08 | [#255](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/255) | P2 | 비활성 입력창에서 clear 버튼으로 값이 바뀌지 않도록 차단 |
| [ ] | AUDIT-09 | [#256](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/256) | P3 | 수정 정보 Provider의 전달 단계를 줄이되 비동기 상태·재시도·fixture 유지 |

여러 항목이 같은 Form Controller를 수정하므로 이번에는 순차 진행합니다. 문서 PR과 각 수정 PR을 사용자가 병합한 뒤 최신 `develop`에서 다음 브랜치를 생성합니다. 기존 상태관리 구조를 보존하면서 필요한 상태·모델 변경과 회귀 테스트를 같은 작업에 포함합니다.

## 먼저 수정할 문제의 근거와 경계

### AUDIT-01 — 기존 이미지 보존

- 위치: [Plant Form Controller](../lib/features/plant/presentation/providers/plant_form_controller.dart), [Place Form Controller](../lib/features/place/presentation/providers/place_form_controller.dart).
- 재현: 기존 이미지가 있는 식물의 이름만 바꾸면 update 요청에서 `imageKey`가 누락됩니다. Place도 현재 Form에서 key를 보내지 않습니다.
- 계약: 새 파일이 없을 때 기존 key를 보내면 유지하고, key가 없거나 null이면 삭제합니다. [Swagger 참고](api-swagger-reference.md)의 Place/Plant 수정 계약과 backend `7d572cb`에서 확인했습니다. 원격 이미지 삭제를 실행해서 검증한 것은 아닙니다.
- 완료: 이미지 유지·명시적 삭제·교체를 구분하고 텍스트 수정 회귀 테스트를 추가합니다.
- 선행 확인: Plant edit 응답은 key를 제공하지만 Place 상세 응답은 URL만 제공합니다. Place key 확보가 불가능하면 데이터 유실을 막는 처리를 먼저 하고 계약 공백을 기록합니다. URL에서 key를 추측하지 않습니다. 새 파일 선택기 전체 구현과는 분리합니다.

### AUDIT-02 — 계정별 캐시 격리

- 위치: [인증 세션 Controller](../lib/features/login/presentation/providers/auth_session_controller.dart), 사용자별 원격 목록·상세 Provider.
- 재현: 같은 `ProviderScope`에서 A의 장소를 조회한 뒤 로그아웃하고 B로 바꾸면 A의 캐시를 재사용할 수 있습니다.
- 완료: 로그아웃·탈퇴·계정 전환 때 User/Place/Plant/Friend 등 사용자 데이터를 초기화하거나 세션별로 격리합니다. A의 늦은 응답이 B의 상태를 덮지 않도록 검증합니다.
- 경계: 클라이언트 상태 격리는 미확정 서버 refresh/logout endpoint와 무관하게 진행합니다.

### AUDIT-03 — 입력 중 중복 제출

- 위치: Place/Plant Form, User Profile Edit, Profile Setup Controller의 입력 변경·제출 상태.
- 재현: 지연된 장소 생성 요청 중 이름을 변경하고 다시 submit하면 repository가 두 번 호출됩니다. 입력 변경이 `FormSubmitState.idle`을 만들기 때문입니다.
- 완료: 진행 중 요청 잠금과 수정 가능한 입력 상태를 일관되게 관리하고, 실패 후 재시도와 성공 결과의 단일 처리를 테스트합니다. 버튼 비활성화만이 아니라 Controller 호출 경계도 검증합니다.

### AUDIT-04 — 원격 식물 등록의 fixture 혼입

- 위치: [Plant Form Controller](../lib/features/plant/presentation/providers/plant_form_controller.dart)의 `_effectivePlaces`와 장소 목록 구독.
- 재현: API의 장소 목록이 비어도 샘플 4개가 표시되며 `place-1`로 생성 요청이 가능합니다. loading/error도 빈 배열로 축약됩니다.
- 완료: API 모드의 loading/error/empty/success를 보존하고 실제 장소가 없으면 제출하지 않습니다. API 비사용 모드의 fixture와 smoke 동선은 유지합니다.

### AUDIT-05 — 장소 코드 없는 수정의 거짓 성공

- 위치: Plant Form Controller `_update`, 수정 route의 선택적 `placeId`.
- 재현: API 모드에서 장소 코드 없이 수정하면 repository 호출은 0회지만 상세 이동 성공 결과를 반환합니다.
- 완료: 확인된 데이터에서 실제 code를 확보하거나 오류·제출 차단으로 처리합니다. 원격 수정 없이 성공을 반환하지 않으며 API 성공 후 목록·상세 갱신도 검증합니다.

### AUDIT-06 — 주소 선택 결과 전달

- 위치: [주소 검색 Page](../lib/features/place/presentation/pages/address_search_page.dart), [Place Form Page](../lib/features/place/presentation/pages/place_form_page.dart).
- 재현: 주소를 선택해도 결과 없이 pop하며 장소 폼의 주소는 null로 남습니다. API 생성 요청은 주소를 필수로 요구합니다.
- 완료: 선택 결과를 반환·소비하고, 취소 시 기존 값을 유지하며, 필수 검증과 submit에 연결하는 widget/router 테스트를 추가합니다.
- 경계: 외부 주소 검색 서비스·키·과금 결정은 별도입니다. 결과 전달 수정만으로 실서비스 검색이 완료됐다고 표시하거나 fixture 주소를 원격 검색 결과로 취급하지 않습니다.

## 추가 개선의 근거와 경계

- **AUDIT-07:** [응답 파서](../lib/core/network/api_response_parser.dart)는 목록의 비-Map 항목을 조용히 제외합니다. `result: [1, "bad"]`가 정상 빈 목록으로 바뀌는 문제를 수정하되, 확인된 wrapper 호환성과 정상 빈 배열은 유지합니다. 범용 파서 프레임워크나 codegen 도입은 필요하지 않습니다.
- **AUDIT-08:** [CommonTextField](../lib/shared/widgets/common_text_field.dart)는 `enabled: false`와 강제 focus 장식 조합에서 clear 버튼이 동작합니다. disabled 입력·삭제를 함께 차단하고 활성 상태의 clear 동작은 보존합니다.
- **AUDIT-09:** [Plant 수정 정보 Provider](../lib/features/plant/presentation/providers/plant_form_edit_provider.dart)와 [Place 수정 정보 Provider](../lib/features/place/presentation/providers/place_form_edit_provider.dart)의 fetch·변환·mode 선택 단계를 점검합니다. 네트워크 호출이 세 번이라는 뜻은 아닙니다. 하나의 원격 비동기 상태와 순수 변환 경계를 유지하고 loading/error/notFound/retry 및 테스트 override를 보존합니다.

## 검증과 완료 처리

- 직전 구현 #245의 전체 검증은 362개 통과·기존 skip 1개, analyze 통과였습니다. 이는 새 감사 회귀 사례가 검증됐다는 뜻이 아닙니다.
- 감사에서는 별도 임시 테스트로 8개 실패 사례를 재현했습니다. 기존 저장소 테스트 실패와 구분하며, 각 수정 이슈에서 지속적으로 실행할 회귀 테스트를 저장소에 추가합니다.
- 문서만 변경하는 #247은 `git diff --check`, 로컬 문서 링크, 변경 파일이 Markdown뿐인지 확인합니다.
- #247 검증 결과: Markdown 37개에서 로컬 링크 138개(heading anchor 3개 포함)를 확인했고 누락은 없습니다. `docs`의 나머지 문서 35개가 모두 인덱스에 연결됐으며, 변경 파일 19개는 모두 Markdown입니다. 보관 문서 7개의 기존 경로를 유지했습니다.
- 코드 수정은 `fvm dart format --output=none --set-exit-if-changed .`, `fvm flutter analyze`, `fvm flutter test`, `git diff --check`를 통과해야 합니다.
- 각 이슈·PR에는 `ywkim95`, `bbielo`, MVP milestone과 Project 10을 연결합니다. 진행 중 `In Progress`, PR 생성 후 `In Review`, 병합·완료 후 `Done`으로 갱신합니다.
- 커밋별 변경 범위·검증 결과를 작업 문서와 이슈에 남기고, 병합 후 이 표의 체크와 화면 매트릭스를 갱신합니다.

## 문서 정리 커밋 이력

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| `155b093` | 현행 가이드·인덱스·과거 기록 분리와 개선 체크리스트 | `git diff --check`, Markdown 37개·로컬 링크 126개·미연결 문서 0개 |

작업 이력만 갱신하는 마지막 문서 커밋은 자기 자신의 해시를 생략할 수 있습니다.
