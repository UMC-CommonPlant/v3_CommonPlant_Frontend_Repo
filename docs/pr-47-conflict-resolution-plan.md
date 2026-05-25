# PR 47 Conflict Resolution Plan

## Context

- PR: #47 `Feat: API 연계 보강 #45`
- Base branch: `develop`
- Head branch: `docs/swagger-api-diff-43`
- 재현 명령: `git merge --no-ff --no-commit origin/develop`
- 확인일: 2026-05-25

현재 충돌의 주 원인은 #47이 작성된 뒤 `develop`에 Swagger 문서 PR(#44)과 API 연계 기반 PR(#46)이 먼저 병합되었고, #47이 같은 파일들을 최신 Swagger 기준으로 다시 보강했기 때문이다.

## Conflict Files

| 상태 | 파일 | 판단 |
| --- | --- | --- |
| `UU` | `README.md` | 문서 링크/후속 작업 내용 병합 |
| `AA` | `docs/api-swagger-reference.md` | 최신 Swagger 보강분이 많은 #47 내용을 기준으로 유지하되 develop 문구 누락 확인 |
| `AA` | `lib/core/network/api_response_parser.dart` | wrapper `result.content.items` 보강이 포함된 #47 버전 우선 |
| `AA` | `lib/features/login/data/dtos/auth_result.dart` | `newUser` 명시 처리가 포함된 #47 버전 우선 |
| `AA` | `lib/features/place/data/datasources/place_remote_data_source.dart` | 장소 수정 multipart가 포함된 #47 버전 우선 |
| `AA` | `lib/features/place/data/dtos/place_requests.dart` | `address` required 및 update request가 포함된 #47 버전 우선 |
| `AA` | `lib/features/place/data/repositories/place_repository.dart` | 장소 수정 repository가 포함된 #47 버전 우선 |
| `UU` | `lib/features/place/presentation/pages/place_form_page.dart` | develop의 기존 화면 흐름과 #47의 address required 검증을 함께 유지 |
| `AA` | `lib/features/plant/data/datasources/plant_remote_data_source.dart` | `placeCode` 및 query 제거가 포함된 #47 버전 우선 |
| `AA` | `lib/features/plant/data/dtos/plant_requests.dart` | create/update request의 최신 Swagger 필드가 포함된 #47 버전 우선 |
| `AA` | `lib/features/plant/data/repositories/plant_repository.dart` | Plant mapper 보강이 포함된 #47 버전 우선 |
| `AA` | `lib/features/plant/domain/entities/plant_detail.dart` | detail/edit image 필드 보강이 포함된 #47 버전 우선 |
| `AA` | `lib/features/plant/domain/entities/plant_summary.dart` | representative image mapping이 가능한 #47 버전 우선 |
| `UU` | `lib/features/plant/presentation/pages/plant_detail_page.dart` | `placeId` query 제거와 기존 UI fallback 모두 유지 |
| `UU` | `lib/features/plant/presentation/pages/plant_form_page.dart` | `placeCode` 기준 API 호출과 기존 로컬 화면 흐름 모두 유지 |
| `UU` | `lib/features/plant/presentation/providers/plant_list_provider.dart` | detail/edit provider family 입력을 최신 Swagger 기준으로 정리 |

## Work Order

1. **문서 충돌 정리**
   - `README.md`와 `docs/api-swagger-reference.md`를 먼저 해결한다.
   - 목표: #47에서 정리한 최신 Swagger 변경/남은 확인 항목을 유지한다.

2. **공통 API parser 정리**
   - `lib/core/network/api_response_parser.dart`를 해결한다.
   - 목표: 기존 wrapper 파싱과 `result.content.items` 목록 파싱을 함께 지원한다.

3. **Request/response DTO와 domain entity 정리**
   - Auth, Place, Plant DTO/entity 파일을 해결한다.
   - 목표: `newUser`, `placeCode`, Plant image/detail 필드, Place update request를 유지한다.

4. **Datasource/repository 정리**
   - Place/Plant datasource와 repository 파일을 해결한다.
   - 목표: 최신 Swagger path/query/content type과 mapper 보강을 유지한다.

5. **Presentation/provider 정리**
   - Place form, Plant detail/form/provider 충돌을 해결한다.
   - 목표: 화면의 기존 로컬 흐름을 깨지 않으면서 API 호출 인자를 최신 Swagger 기준으로 맞춘다.

6. **검증**
   - conflict marker 검색: source 파일 대상으로 conflict marker pattern을 확인한다.
   - 포맷: `fvm dart format --output=none --set-exit-if-changed .`
   - 분석: `fvm flutter analyze`
   - 테스트: `fvm flutter test`
   - 공백 검사: `git diff --check`
