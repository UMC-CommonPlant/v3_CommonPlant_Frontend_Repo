# 개발 감사·개선 체크리스트

2026-08-28 사용자 결정과 `develop`의 PR #246 병합 커밋 `2a01babb185ef5056b361c477717759194c53ec1`을 기준으로 합니다. 문서 정리는 [#247](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/247), 상위 개발 범위는 [Epic #226](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/226)입니다.

문서 PR [#257](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/257)은 `develop`에 병합됐습니다(`f1331b2`). 후속 #248 / [PR #258](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/258)도 병합됐으며(`a630c66`) [이미지 보존 이력](work-history/form-image-preservation-248.md)에서 남은 제한을 확인합니다. #249 / [PR #259](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/259) 계정별 캐시·요청 격리(`b15cdd7`, [이력](work-history/session-cache-isolation-249.md))와 #250 / [PR #260](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/260) 입력 변경 중 제출 잠금도 병합됐습니다(`bc6e68d`, [이력](work-history/form-submit-lock-250.md)). 2026-08-30 기준 #251 / [PR #261](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/261) 원격 식물 등록 장소 상태(`ebf6dc4`, [이력](work-history/remote-plant-places-251.md)), #252 / [PR #262](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/262) 장소 code 없는 수정 차단(`5fc0140`, [이력](work-history/plant-edit-place-code-252.md)), #253 / [PR #263](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/263) 주소 결과 전달(`ded4fe2`, [이력](work-history/place-address-result-253.md)), #254 / [PR #264](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/264) 목록 항목 타입 검증(`f723825`, [이력](work-history/api-list-item-validation-254.md)), #255 / [PR #265](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/265) 비활성 입력 clear 차단(`894dd5f`, [이력](work-history/disabled-text-field-clear-255.md))까지 병합됐습니다. #256 수정 정보 Provider 전달 단순화는 구현·로컬 검증 후 사용자 병합을 기다립니다([이력](work-history/form-edit-provider-flow-256.md)).

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
- [x] PR·검증·커밋 이력과 Project 상태 기록

## 실행 순서

표의 체크는 해당 수정 PR이 병합되고 회귀 검증이 끝났을 때만 완료합니다. #248~#255는 병합 완료, #256은 구현·검증 후 사용자 병합 대기입니다. Project의 priority는 아래 P1을 `high`, P2를 `medium`, P3를 `low`로 대응합니다.

| 체크 | 순서 | 이슈 | 우선도 | 문제·완료 기준 요약 |
| --- | --- | --- | --- | --- |
| [x] | AUDIT-01 | [#248](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/248) | P1 | PR #258 병합: Plant key 보존·미확인 key 차단, 사진이 있는 Place 수정은 임시 제한 |
| [x] | AUDIT-02 | [#249](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/249) | P1 | PR #259 병합: 계정별 조회·초안·후처리 격리와 늦은 토큰 저장 방지 |
| [x] | AUDIT-03 | [#250](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/250) | P1 | PR #260 병합: 입력 변경 중 제출 잠금·제출값 고정·실패 후 수정값 재시도 |
| [x] | AUDIT-04 | [#251](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/251) | P1 | PR #261 병합: 실제 장소만 선택·등록, loading/error/empty 차단과 조회 재시도 |
| [x] | AUDIT-05 | [#252](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/252) | P1 | PR #262 병합: code 누락 안내·제출 차단, API 성공 후 관련 목록·상세·편집 정보 갱신 |
| [x] | AUDIT-06 | [#253](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/253) | P2 | PR #263 병합: 주소 반환·폼 연결, API fixture 차단, 실제 검색 서비스 미연결 |
| [x] | AUDIT-07 | [#254](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/254) | P2 | PR #264 병합: 비-Map 항목을 빈 목록·부분 성공으로 숨기지 않고 위치가 드러나는 오류 처리 |
| [x] | AUDIT-08 | [#255](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/255) | P2 | PR #265 병합: 비활성 입력의 clear 미노출·값 보존, 활성 clear 유지 |
| [ ] | AUDIT-09 | [#256](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/256) | P3 | 구현·검증 완료, 병합 대기: 중간 원격 Provider 제거, 비동기 상태·재시도·fixture·override 유지 |

여러 항목이 같은 Form Controller를 수정하므로 이번에는 순차 진행합니다. 문서 PR과 각 수정 PR을 사용자가 병합한 뒤 최신 `develop`에서 다음 브랜치를 생성합니다. 기존 상태관리 구조를 보존하면서 필요한 상태·모델 변경과 회귀 테스트를 같은 작업에 포함합니다.

## 먼저 수정할 문제의 근거와 경계

### AUDIT-01 — 기존 이미지 보존

- 위치: [Plant Form Controller](../lib/features/plant/presentation/providers/plant_form_controller.dart), [Place Form Controller](../lib/features/place/presentation/providers/place_form_controller.dart).
- 감사 당시 재현: 기존 이미지가 있는 식물의 이름만 바꾸면 update 요청에서 `imageKey`가 누락됐습니다. Place Form도 key를 보내지 않았습니다.
- 계약: 새 파일이 없을 때 기존 key를 보내면 유지하고, key가 없거나 null이면 삭제합니다. [Swagger 참고](api-swagger-reference.md)의 Place/Plant 수정 계약과 backend `7d572cb`에서 확인했습니다. 원격 이미지 삭제를 실행해서 검증한 것은 아닙니다.
- #248 구현: Plant Form 초기 key·URL을 보존하고 이름·날짜 수정과 재시도에서 key를 전달합니다. URL은 있으나 key가 없는 Plant와 사진이 있는 Place는 수정 API를 호출하지 않고 안내합니다. 회귀 테스트 14개를 추가했고 전체 376개 통과·기존 skip 1개입니다.
- 남은 확인: Place 상세 응답은 URL만 제공하므로 사진이 있는 장소 수정은 key 조회 계약 확보 후 별도 해제합니다. 새 파일 선택·삭제 UI와 동시 수정의 서버 측 보호는 별도이며, [제한·위험 기록](work-history/form-image-preservation-248.md#남은-제한과-위험)을 따릅니다.

### AUDIT-02 — 계정별 캐시 격리

- 위치: [인증 세션 Controller](../lib/features/login/presentation/providers/auth_session_controller.dart), 사용자별 원격 목록·상세 Provider.
- 감사 당시 재현: 같은 `ProviderScope`에서 A의 장소를 조회한 뒤 로그아웃하고 B로 바꾸면 A의 캐시를 재사용했습니다. 토큰 저장이 늦으면 새 계정 토큰을 덮거나 로그아웃 뒤 이전 토큰을 되살리는 사례도 추가 재현했습니다.
- #249 구현: 로그인·회원가입 결과와 로그아웃·탈퇴 때 데이터 세션을 교체하고 User/Place/Plant/Friend의 조회, 폼·선택·로컬 추가 상태를 격리합니다. 진행 중 요청의 후처리는 시작 세션과 Ref가 유지될 때만 실행하고, 화면에서는 이전 `AsyncValue` 데이터를 표시하지 않습니다.
- 검증: 동일 컨테이너의 조회 14개 경로, 늦은 변경 응답 10개 사례, 토큰 읽기·저장·삭제 경쟁과 프로필 loading/error/retry를 포함해 회귀 테스트 34개 추가, 전체 410개 통과·기존 skip 1개입니다.
- 경계: 서버에 이미 도착한 쓰기 요청의 취소·롤백, refresh/logout endpoint, OS 저장소 삭제 실패 시 영속 삭제 보장은 별도입니다. [제한과 위험](work-history/session-cache-isolation-249.md#남은-제한과-위험)을 따르며 #250~#256은 해결한 것으로 표시하지 않습니다.

### AUDIT-03 — 입력 중 중복 제출

- 위치: Place/Plant Form, User Profile Edit, Profile Setup Controller의 입력 변경·제출 상태.
- 감사 당시 재현: 지연된 장소 생성 요청 중 이름을 변경하고 다시 submit하면 repository가 두 번 호출됐습니다. 입력 변경이 `FormSubmitState.idle`을 만들기 때문입니다. #250 수정 전 새 Controller 회귀 테스트 13개가 실패하는 것을 확인했습니다.
- #250 구현: 입력은 수정할 수 있지만 진행 중 제출 상태는 유지합니다. 가입 프로필 이름은 세션 확인을 기다리기 전에 캡처합니다. 실패 후에는 최신 초안으로 재시도하고 성공한 최초 요청만 이동 결과를 반환합니다. 기존 enum·공용 버튼과 #249 세션 보호를 재사용합니다.
- 검증: Controller 대상 40개, 주요 화면의 3개 viewport를 포함한 전체 436개 통과·기존 skip 1개입니다. 회귀 실행 사례 26개를 추가하고 기존 화면 테스트 2개를 보강했습니다. [#250 이력](work-history/form-submit-lock-250.md)을 참고합니다.
- 경계: 현재 Controller의 동시 요청을 막는 수정이며, 서버의 멱등성·성공 후 새 요청·다른 화면이나 기기의 중복까지 보장하지 않습니다. #251~#256과 실제 이미지·주소 검색 연결은 별도입니다.

### AUDIT-04 — 원격 식물 등록의 fixture 혼입

- 위치: [Plant Form Controller](../lib/features/plant/presentation/providers/plant_form_controller.dart)의 장소 목록 구독·선택·제출 경계.
- 감사 당시 재현: `_effectivePlaces`가 API loading/error/empty를 샘플 4개로 바꿔 `place-1`로 생성 요청을 허용했습니다. #251 수정 전 새 Controller 회귀 11개 중 8개가 실패했습니다.
- #251 구현: 원격 loading/error/empty/success를 보존하고 실제 목록에 있는 장소만 선택·제출합니다. 재조회 중에는 이전 장소를 숨기며, 화면 재빌드 전 콜백도 최신 상태를 확인합니다. 실패 재시도는 실제 장소 조회 source를 갱신하고 빈 목록은 기존 홈으로 안내합니다.
- 검증: Controller 11개·화면 10개를 추가했고 4개 viewport를 포함한 전체 457개 통과·기존 skip 1개입니다. API 비사용 fixture, #249 세션 격리와 #250 제출 잠금도 유지합니다. [작업 이력](work-history/remote-plant-places-251.md)을 참고합니다.
- 경계: 장소 사진은 기존 placeholder이며, 조회 이후 서버에서 삭제·권한 변경된 장소의 최종 유효성은 서버 응답에 따릅니다. 실제 인증 E2E·주소 검색·학명/이미지 연결과 #252~#256은 별도입니다.

### AUDIT-05 — 장소 코드 없는 수정의 거짓 성공

- 위치: [Plant Form Controller](../lib/features/plant/presentation/providers/plant_form_controller.dart) `_update`, 수정 route의 선택적 `placeId`.
- 감사 당시 재현: API 모드에서 장소 코드 없이 수정하면 repository 호출은 0회지만 상세 이동 성공 결과를 반환합니다. #252 수정 전 새 Controller 회귀 10개 중 6개가 실패했습니다.
- #252 구현: 원격 수정은 null·빈 값·공백 code를 `missingPlace` 상태로 차단하고 기존 상태 화면에서 홈→장소→식물 재진입을 안내합니다. code가 있으면 공백을 제거해 기존 `placeCode` query로 전달하며 이미지 key·제출 잠금·세션 보호를 유지합니다.
- 갱신: PUT 성공과 현재 요청 세션 확인 후 식물 목록·해당 식물 상세·해당 장소 상세·편집 정보의 원본 Provider를 갱신합니다. 폼이 구독 중인 편집 정보를 너무 일찍 무효화해 성공 결과가 사라지지 않도록 결과 확정 뒤 처리합니다. 실패는 초안 보존·재시도이며 성공 이동을 반환하지 않습니다.
- 검증: Controller 10개·실제 route builder를 사용하는 화면 9개 추가, 3개 viewport를 포함한 전체 476개 통과·기존 skip 1개입니다. [작업 이력](work-history/plant-edit-place-code-252.md)을 참고합니다.
- 경계: 2026-08-29 live OpenAPI의 PUT에는 `placeCode`가 필수지만 Plant 목록·상세·편집 응답에는 없습니다. 장소명·샘플 code로 복원하지 않습니다. Home 식물 목록에서 바로 수정하는 동선의 code 확보는 [PLANT-01](backend-api-open-questions.md#plant-01-식물에서-소속-장소-code-조회)로 남기며, 실제 인증 E2E·플랫폼 수동 QA와 #253~#256은 별도입니다.

### AUDIT-06 — 주소 선택 결과 전달

- 위치: [주소 검색 Page](../lib/features/place/presentation/pages/address_search_page.dart), [Place Form Page](../lib/features/place/presentation/pages/place_form_page.dart).
- 감사 당시 재현: 주소를 선택해도 결과 없이 pop하며 장소 폼의 주소는 null로 남았습니다. API 생성·수정 요청은 주소를 필수로 요구합니다.
- #253 구현: `AddressSearchResult`를 typed route 결과로 반환하고 출처를 구분합니다. 생성·수정 폼은 취소·빈 값·폐기된 폼·이전 계정 결과를 무시하며, 유효한 주소를 기존 `updateAddress`와 제출에 전달합니다. 제출 중 주소 변경은 잠금과 최초 요청값을 유지합니다.
- 검증: 신규 회귀 26개와 기존 제출 잠금·이미지 보호 테스트를 보강했습니다. 3개 viewport의 route 선택·취소·필수 검증·요청 DTO, 실제 Auth Controller의 계정 전환과 화면 폐기 경계를 [작업 이력](work-history/place-address-result-253.md)에 기록합니다.
- 경계: API 모드는 검색 미연결 안내만 표시하고 Controller에서도 fixture 결과를 거부합니다. 기존 서버 주소는 유지하지만 새 주소 검색은 여전히 불가능하므로 API 장소 생성 전체가 완료된 것은 아닙니다. 외부 주소 검색 서비스·키·과금·실제 adapter 도입은 별도 결정입니다.

## 추가 개선의 근거와 경계

### AUDIT-07 — 목록 항목 타입 검증

- 위치: [공용 응답 파서](../lib/core/network/api_response_parser.dart), Plant·Place·User 목록 mapper와 repository 경계.
- 감사 당시 재현: 파서가 비-Map 항목을 조용히 제외해 `result: [1, "bad"]`를 정상 빈 목록으로, Map과 잘못된 값이 섞인 응답을 부분 성공으로 바꿨습니다.
- #254 구현: 목록 wrapper를 찾은 뒤 모든 항목이 JSON object인지 검사합니다. 하나라도 다르면 context와 1부터 시작하는 항목 위치를 포함한 `ApiException`을 던지며, 확인된 direct·nested wrapper와 정상 빈 배열은 유지합니다.
- 검증: 공용 파서 3개, Plant mapper 1개, Place repository 1개, User repository 1개의 회귀 사례를 추가했습니다. 관련 7개 파일의 대상 테스트 39개와 전체 508개가 통과했고 기존 non-Linux golden 1개는 skip했습니다. format·analyze·diff 검사도 통과했습니다([작업 이력](work-history/api-list-item-validation-254.md)).
- 경계: fake 응답과 실제 mapper·repository를 사용한 검증이며 실제 인증 서버의 비정상 응답이나 원격 E2E를 실행한 것은 아닙니다. 항목 내부 필드 검증은 기존 도메인 mapper 책임으로 유지하며 범용 파서 프레임워크나 codegen을 도입하지 않았습니다.

### AUDIT-08 — 비활성 공용 입력 clear 차단

- 위치: [CommonTextField](../lib/shared/widgets/common_text_field.dart)의 실제 enabled 판정과 clear trailing.
- 감사 당시 재현: 값이 있는 필드에 `forceFocusedDecoration: true`를 지정하면 `enabled: false` 또는 `CommonTextFieldState.disabled`여도 clear 버튼이 만들어져 값을 지울 수 있었습니다. Flutter `TextField` 입력만 비활성이고 별도 삭제 액션은 같은 상태를 따르지 않았습니다.
- #255 구현: validation을 반영한 실제 enabled 값을 clear 표시 조건에 전달하고, 실행 시점에도 `enabled`와 disabled validation 상태를 다시 확인합니다. 비활성일 때 clear는 만들지 않지만 trailing·counter는 유지합니다.
- 검증: 활성 clear와 `onChanged('')` 보존 1개, `enabled: false`와 disabled state의 입력 비활성·clear 미노출·값·콜백 보존 2개를 추가했습니다. 공용 위젯 대상 5개와 전체 511개가 통과했고 기존 non-Linux golden 1개는 skip했습니다. format·analyze·diff 검사도 통과했습니다([작업 이력](work-history/disabled-text-field-clear-255.md)).
- 경계: 장식 상태는 입력 권한을 바꾸지 않습니다. `CommonSearchTextField`와 `CommonAddressOrPlaceField`는 별도 구현이며 동작을 변경하지 않았습니다. 실제 Android/iOS 수동 입력·접근성 smoke와 새 시각 baseline은 실행하지 않았습니다.

### AUDIT-09 — 수정 정보 Provider 전달 단순화

- 위치: [Plant 수정 정보 Provider](../lib/features/plant/presentation/providers/plant_form_edit_provider.dart), [Place 수정 정보 Provider](../lib/features/place/presentation/providers/place_form_edit_provider.dart)와 각 Form Controller.
- 감사 당시 구조: Plant·Place 모두 실제 fetch 원본과 폼 진입점 사이에 원본 `.future`를 기다렸다가 nullable 수정 정보로 다시 포장하는 `FutureProvider`가 하나씩 있었습니다. 네트워크 호출이 여러 번 발생한 문제는 아니지만 loading/error/retry/override 경계가 두 단계로 갈렸습니다.
- #256 구현: 중간 `remotePlantFormEditInfoProvider`와 `remotePlaceFormEditInfoProvider`를 제거했습니다. 폼 진입점은 API 비사용 fixture 분기를 유지하고, API 모드에서는 `remotePlantEditInfoProvider` 또는 `placeSummaryProvider`의 `AsyncValue`를 `whenData`로만 변환한 뒤 `unwrapPrevious()`를 적용합니다. Controller 재시도도 실제 fetch를 소유한 원본 하나만 무효화합니다.
- 검증: 원본 Provider override를 통한 폼 변환·빈 정보 `null`, repository 위임, Place 실패 후 원본 재조회와 기존 Plant loading/error/notFound, 제출 잠금·이미지·장소 code·세션 격리 회귀를 확인했습니다([작업 이력](work-history/form-edit-provider-flow-256.md)).
- 경계: 새 API·DTO·repository·화면·패키지는 추가하지 않았고 실제 요청 수를 줄이는 성능 작업으로 해석하지 않습니다. 실제 인증 API·Android/iOS 수동 smoke는 실행하지 않았습니다.

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
| `6f368a8` | 화면·API 상태, 이미지 유지·삭제 계약, PR #246 병합 현황 정정 | `git diff --check`, 로컬 링크 138개·anchor 3개, 변경 파일 19개 모두 Markdown |
| `8066edb` | PR #257·Project In Review 연결과 커밋별 이력 기록(당시 상태) | `git diff --check`, 이슈 #247~#256의 Type·담당자·milestone·parent·Project 필드 확인 |

작업 이력만 갱신하는 마지막 문서 커밋은 자기 자신의 해시를 생략할 수 있습니다.
