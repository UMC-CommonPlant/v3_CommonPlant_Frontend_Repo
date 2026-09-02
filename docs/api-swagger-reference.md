# API Swagger 연계 참고 문서

이 문서는 Flutter API 연계 작업 중 Swagger UI를 반복해서 확인하는 비용을 줄이기 위한 요약 문서입니다.
서버 명세가 부족하거나 현재 코드와 충돌하는 부분은 임의로 보정하지 않고 확인 필요 항목에 남깁니다.

## 확인 기준

- 환경: `dev`
- 개발 서버 origin: https://commonplant-dev.okbear.dev
- API base URL: https://commonplant-dev.okbear.dev/api/v1
- Swagger UI: https://commonplant-dev.okbear.dev/api/v1/swagger-ui/index.html#
- OpenAPI JSON: https://commonplant-dev.okbear.dev/api/v1/api-docs/json
- Swagger config: https://commonplant-dev.okbear.dev/api/v1/api-docs/json/swagger-config
- 확인일: 2026-08-25
- OpenAPI·Place 멤버·Place/Plant 이미지 수정 계약 재확인: 2026-08-28 (19 paths·27 operations, backend main 동일)
- Plant 수정의 필수 query·조회 schema 재확인: 2026-08-29, live OpenAPI JSON HTTP 200. 이 재확인은 Plant 범위이며 backend main 재검증이나 실제 인증 쓰기 검증을 뜻하지 않는다.
- Plant 소속 장소 조회·식물 검색 계약 재확인: 2026-08-31 (live OpenAPI 19 paths, backend main `7d572cb` 동일). Plant direct code·검색 endpoint는 없고 기존 Place 목록·상세의 code와 `plantList[].plantId` 조합은 사용 가능하다.
- 오류·token 계약 재확인: 2026-08-31. token 없는 사용자 조회는 HTTP 401 `A009`, 잘못된 bearer token은 `A003`을 반환했다. backend `ErrorResponse` 구조와 전체 error enum을 대조했으며 refresh·logout endpoint는 live OpenAPI와 Controller 모두에 없다.
- Place 멤버·Friend 쓰기 계약 재확인: 2026-08-31 (live OpenAPI, backend main `7d572cb` 동일). 멤버 ID·역할·변경 endpoint와 Friend 고유 대상·부분 결과 계약은 없으며 backend #150에 요청했다.
- 접속 결과: Swagger UI, OpenAPI JSON, Swagger config HTTP 200
- 개발 서버 루트: HTTP 404. 루트 route가 없다는 의미이며 Swagger/API endpoint 상태와 분리한다.
- 인증 endpoint 확인: token 없이 `GET /api/v1/users` 요청 시 HTTP 401, code `A009`로 인증 요구 응답
- OpenAPI 버전: `3.1.0`
- API title: `Common Plant API Document`
- 서버 base path: `/api/v1`
- endpoint inventory: 19 paths, 27 operations
- 기존 문서 비교 기준: `docs/api-swagger-summary-43` 브랜치의 `docs/api-swagger-reference.md` 확인일 2026-05-20
- 최초 코드 비교 기준: `feature/api-integration-45` 브랜치의 API 계층. 현재 화면·계층 대조 기준은 PR #276 병합 커밋 `5426768`이다.
- 백엔드 소스 비교 기준: `UMC-CommonPlant/v3_CommonPlant_Backend_Repo` main `7d572cbcabc81a65926738b2a09e8479d0bd0c79`
- 참고: 2026-05-25의 상세 schema 비교 기록을 보존하고, 2026-08-25에는 live OpenAPI와 백엔드 Controller·DTO·Service를 함께 재검증했다.

## 프론트엔드 연계 원칙

- 공통 HTTP client는 `lib/core/network`에 `dio` 기반으로 둔다.
- 화면에서 직접 JSON 파싱, Dio 생성, API 에러 문자열 분기를 하지 않는다.
- feature별 API는 `data/datasources`, `data/repositories`, 필요 시 `domain` 계층으로 분리한다.
- 화면 상태는 Riverpod의 `AsyncValue` 또는 Controller 상태로 `loading`, `success`, `empty`, `error`를 구분한다.
- Swagger에 response schema가 보강되었더라도, schema가 없거나 현재 코드와 충돌하는 항목은 DTO를 임의 확정하지 않는다.

## 공통 인증과 응답 wrapper

- Swagger 전역 security는 `bearerAuth`이다.
- Header 형식은 `Authorization: Bearer <JWT>`로 해석한다.
- `/auth/login`, `/auth/register`는 `security: []`로 인증 제외되어 있다.
- `/users`, `/users/{keyword}`는 operation에 bearer 인증이 명시되어 있다.
- 그 외 operation은 별도 security가 없으므로 전역 bearer 인증이 상속되는 것으로 본다.
- Auth, User, Plant 일부 API는 `timeStamp`, `success`, `status`, `message`, `result` 형태의 JSON response wrapper schema가 추가되었다.
- Place, Image, Friend API는 live OpenAPI에 여전히 성공 response body schema가 없거나 `OK` 수준의 설명만 있다.
- Place와 Friend는 백엔드 source의 `JsonResponse.result` 반환 타입을 추가 근거로 사용한다. machine-readable Swagger가 아니라는 점과 실제 인증 응답 smoke가 남았다는 점은 구분한다.

## Swagger 변경 요약

### 2026-08-31 공통 오류와 인증 만료 경계

- 표준 오류 응답은 `traceId`, `status`, `code`, `message`, `timestamp`, 선택적 `errors[]`를 사용한다. field 항목의 `value`는 사용자 입력 원문일 수 있으므로 프론트에서 읽거나 보존하지 않는다.
- #275는 HTTP·전송 오류를 안전한 사용자 메시지 범주로 변환하고 validation `field`·`reason`을 Place·Plant·User·가입 프로필 폼에 연결한다. top-level 서버 상세 문구와 미확인 code는 화면에 그대로 노출하지 않는다.
- 활성 access-token 요청의 확인된 `A003`, `A004`, `A009`만 현재 세션 만료로 처리한다. 한 세션에서 종료 요청은 한 번만 실행하며 계정 전환 뒤 도착한 이전 응답은 폐기한다.
- refresh 재발급과 서버 로그아웃은 제공되지 않는다. backend [#149](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/149)가 endpoint·rotation·invalidation 계약을 제공하기 전까지 refresh 요청이나 원요청 재시도를 만들지 않는다.

### 2026-08-31 Place 멤버·Friend 식별자 쓰기 경계

- `GET /place/{code}/members`는 성공 schema 없이 `{ name, image }[]`만 반환하고 멤버 ID·역할, self leave, owner의 멤버 제거·권한 변경 endpoint가 없다.
- `POST /friends/request`는 `receiverName[]`을 받아 부분 이름 검색 첫 결과를 사용하고, 응답 `receiverList`는 대상별 결과나 전체 원자성을 나타내지 않는다.
- #277은 [backend #150](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/150) 답변 전 #245의 조회 전용 UI, #239의 구성원 나가기 숨김, 임시 화면 key 비전송을 유지한다. 표시 이름 기반 요청은 #243에서 수용한 위험으로만 유지하고 새 고유 ID·부분 성공 계약을 추정하지 않는다.

### 2026-08-31 Plant 장소 code 조회와 검색 경계

- Plant 목록·상세·수정 정보에는 여전히 소속 장소 code가 없다. `GET /place/user`의 실제 장소 code와 `GET /place/{code}`의 `plantList[].plantId`를 정확히 대조하면 별도 추정 없이 code를 확인할 수 있다.
- #273은 route 또는 Plant 응답에 code가 없을 때만 이 읽기 전용 fallback을 사용한다. 이름·학명·첫 장소는 식별 근거로 사용하지 않으며, 오류는 상세 오류·재시도 상태로 전달한다.
- 식물 검색 endpoint·catalog는 live OpenAPI와 backend main에 없다. 백엔드 [#92](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/92)에 필요한 검색 계약을 요청했고, 제공 전까지 API 모드는 fixture 결과와 선택을 차단한다.

### 2026-08-29 식물 수정 장소 code 경계

- `PUT /plants/{plantId}`의 query `placeCode`는 required이다. `PlantSummary`, `DetailResponse`, `EditInfoResponse`에는 장소 code가 없으며 상세의 `placeName`으로 code를 추정할 수 없다.
- #252는 기존 장소 상세→식물 상세→수정 route의 `placeId`에 담긴 실제 code를 보존·정규화해 전송한다. null·빈 값·공백이면 원격 수정 없이 성공 처리하지 않고 기존 홈에서 장소를 통해 재진입하도록 안내한다.
- #273에서 [PLANT-01](backend-api-open-questions.md#plant-01-식물에서-소속-장소-code-조회)을 기존 Place 조회 계약으로 해결했다. direct field가 추가되기 전까지 순차 장소 상세 조회 비용은 [위험 등록부](accepted-implementation-risks.md#plant-소속-장소-code-조회)에 기록한다. 수정 성공 후 관련 목록·상세·편집 정보 갱신은 #252에서 검증했다([작업 이력](work-history/plant-edit-place-code-252.md)).

### 2026-08-28 감사 — 이미지 수정 계약과 프론트 누락

- Place/Plant의 `imageKey` 생략/null은 기존 이미지 삭제를 뜻한다. 새 파일 없이 유지하려면 기존 key를 보내야 한다.
- 감사 당시 Plant edit 응답의 key가 Form 상태로 전달되지 않았고 Place Form도 key를 누락했다. #248에서 Plant key 보존과 미확인 key 차단, Place 사진 수정 요청 차단을 구현했다. 이는 새 endpoint 변경이 아니라 기존 계약 누락의 수정이다.
- 연결 PR의 병합 상태와 실제 남은 화면 동선은 [화면·API 매트릭스](screen-api-integration-plan.md), 수정 순서는 [개발 감사 체크리스트](development-audit-checklist.md)에서 관리한다.

### 2026-08-28 장소 멤버 조회 연결

- live OpenAPI의 `GET /place/{code}/members` endpoint와 가입 순서 설명은 동일하다.
- backend main `7d572cb`는 `JsonResponse.result`에 `{ name, image }[]`를 반환한다.
- #245에서 typed 멤버 목록과 친구 관리 조회·검색·상태 UI를 연결했다.
- 멤버 고유 ID·역할·변경 endpoint는 없어 API 화면은 조회 전용이다.

### 2026-08-25 live Swagger·백엔드 source 재확인

| 구분 | 확인 내용 | 프론트 판단 |
| --- | --- | --- |
| Live OpenAPI | 19 paths, 27 operations이며 Place·Friend 성공 schema는 여전히 미노출 | endpoint 변화 없음 |
| Place 목록 | `getMainPage.placeList`, `getPlaceListRes`, `getPlaceBelongUser` 확인 | #239 목록 mapper와 Home 대표 이미지 연결 |
| Place 상세 | `getPlaceRes`가 `owner`, `userList`, `plantList`를 반환 | #239에서 remote fixture 병합 제거 가능 |
| Place 멤버 | `getPlaceResUser`는 `name`, `image`만 반환 | 상세 표시는 가능, 멤버 고유 id·역할 기반 변경은 보류 |
| Friend 요청 | `friendRequestListRes.requests`와 요청 PK `friendId` 확인 | 목록·수락·거절 후속 수직 슬라이스 진행 가능 |
| Friend 전송 | receiver는 표시 이름이며 부분 검색 첫 결과를 사용 | 중복 이름 오매칭이 해결되기 전 신규 초대 전송 보류 |

### 2026-08-23 dev Swagger 재확인

| 구분 | 확인 내용 | 프론트 판단 |
| --- | --- | --- |
| 실행 환경 | dev origin과 `/api/v1` base URL 제공 | 로컬 remote API 실행 시 명시적 `dart-define` 주입 가능 |
| API 문서 | Swagger UI, OpenAPI JSON/config 공개 접근 가능 | live spec 확인과 문서 대조 가능 |
| Place | `GET /place/{code}/members` 추가 | 친구 관리 화면 후보지만 성공 response schema가 없어 mapper 구현 보류 |
| Auth register | request/response가 `RegisterRequest`/`RegisterResponse`로 분리 | #216에서 JSON part와 optional image multipart datasource 반영 |
| Multipart encoding | Auth/User/Plant JSON part에 `application/json` 명시 | 해당 도메인 전송 기준 확인, Place는 encoding 미표기로 추가 확인 유지 |
| Test environment | 19개 path에 test/seed/fixture/cleanup 전용 endpoint가 없고 login은 소셜 SDK token을 요구 | #220 준비 계약의 인증, 데이터 격리·cleanup gate가 해결되기 전 TEST-02-B 유지 |

TEST-02-B의 backend/frontend/CI 준비 조건과 첫 read-only probe 범위는 `docs/remote-integration-test-readiness.md`에서 관리한다. 이 문서의 endpoint inventory만으로 테스트 계정이나 cleanup 정책이 제공된 것으로 해석하지 않는다.

아래의 추가/삭제/변경 표는 2026-05-25 상세 비교 기록이며, 위 표는 2026-08-23 재확인에서 달라진 항목입니다.

### 2026-05-25 추가된 API

| Domain | Method | Path | Summary | 상태 |
| --- | --- | --- | --- | --- |
| Friend | GET | `/friends/requests` | 없음 | 응답 schema 없음 |
| Friend | POST | `/friends/request` | 없음 | 요청 schema만 있음 |
| Friend | POST | `/friends/accept` | 없음 | 요청 schema만 있음 |
| Friend | POST | `/friends/decline` | 없음 | 요청 schema만 있음 |
| User | GET | `/users/{keyword}` | 사용자 이름 검색 | 응답 schema 있음 |

### 2026-05-25 삭제된 API

| Domain | Method | Path | 비고 |
| --- | --- | --- | --- |
| 없음 | - | - | 기존 문서의 API 중 삭제된 endpoint는 확인되지 않는다. |

### 2026-05-25 변경된 API

| Domain | API | 변경 내용 | 프론트 영향 |
| --- | --- | --- | --- |
| Auth | `POST /auth/login` | 성공 response가 `LoginSuccessJsonResponse` 또는 `LoginNewUserJsonResponse` `oneOf`로 보강됨 | wrapper의 `result`와 `newUser` 기준으로 DTO를 정리할 수 있음 |
| Auth | `POST /auth/register` | request content type이 `multipart/form-data`로 변경되고 `RegisterMultipartRequest`가 연결됨 | 현재 코드의 JSON body 전송과 충돌. 단, 연결된 `Register` schema가 응답 필드처럼 보여 백엔드 확인 필요 |
| User | `GET /users` | `UserJsonResponse`와 `UserResponse` schema 추가 | 내 정보 DTO 작성 가능 |
| User | `PUT /users` | 식물 `UpdateRequest` 오연결이 해소되고 `UserUpdateMultipartRequest`로 변경됨 | 프로필 이미지 포함 수정 API 설계 가능 |
| User | `DELETE /users` | `UserDeleteJsonResponse` schema 추가 | 성공 wrapper 처리 가능 |
| Place | `POST /place/create` | `createPlaceReq`에 `name`, `address` required와 `name` maxLength 10 추가 | 현재 코드의 optional address 정책 수정 필요 |
| Place | `PUT /place/update/{code}` | content type이 `multipart/form-data`로 보강됨 | 기존 확인 필요 항목 일부 해소. 장소 수정 API 연계 가능성이 생김 |
| Plant | `GET /plants` | `PlantListJsonResponse`와 pagination schema 추가 | 목록 mapper가 `result.content.items`를 읽도록 보강 필요 |
| Plant | `POST /plants` | request required가 `placeId`에서 `placeCode`로 변경되고 response schema 추가 | 현재 코드의 `int placeId` 요청 DTO와 충돌 |
| Plant | `GET /plants/{plantId}` | `placeId` query parameter가 사라지고 response schema 추가 | 현재 코드의 `placeId` query 전달 제거 필요 |
| Plant | `PUT /plants/{plantId}` | query parameter가 `placeId`에서 `placeCode`로 변경되고 response schema 추가 | 현재 코드의 query key와 호출 입력 변경 필요 |
| Plant | `DELETE /plants/{plantId}` | query parameter가 `placeId`에서 `placeCode`로 변경되고 response schema 추가 | 현재 코드의 query key와 호출 입력 변경 필요 |
| Plant | `GET /plants/{plantId}/edit` | `placeId` query parameter가 사라지고 response schema 추가 | 현재 코드의 `placeId` query 전달 제거 필요 |

## 최신 API 목록

| Domain | Method | Path | Summary | 인증 | Response schema |
| --- | --- | --- | --- | --- | --- |
| Auth | POST | `/auth/login` | 로그인 | 불필요 | `LoginSuccessJsonResponse` 또는 `LoginNewUserJsonResponse` |
| Auth | POST | `/auth/register` | 회원가입 완료 | 불필요 | `RegisterJsonResponse` |
| User | GET | `/users` | 내 정보 조회 | 필요 | `UserJsonResponse` |
| User | PUT | `/users` | 내 정보 수정 | 필요 | `UserJsonResponse` |
| User | DELETE | `/users` | 회원 탈퇴 | 필요 | `UserDeleteJsonResponse` |
| User | GET | `/users/{keyword}` | 사용자 이름 검색 | 필요 | `UserListJsonResponse` |
| Place | GET | `/place/myGarden` | 내 정원 조회 | 필요 | Swagger 없음; source `getMainPage` |
| Place | GET | `/place/user` | 소속 장소 조회 | 필요 | Swagger 없음; source `getPlaceBelongUser[]` |
| Place | GET | `/place/{code}` | 장소 조회 | 필요 | Swagger 없음; source `getPlaceRes` |
| Place | GET | `/place/{code}/members` | 장소 멤버 목록 조회 | 필요 | Swagger 없음; source `getPlaceResUser[]` |
| Place | POST | `/place/create` | 장소 생성 | 필요 | Swagger 없음; source place code 문자열 |
| Place | PUT | `/place/update/{code}` | 장소 수정 | 필요 | Swagger 없음; source `updatePlaceRes` |
| Place | DELETE | `/place/delete/{code}` | 장소 삭제 | 필요 | Swagger 없음; source null |
| Friend | GET | `/friends/requests` | 없음 | 필요 | 없음 |
| Friend | POST | `/friends/request` | 없음 | 필요 | 없음 |
| Friend | POST | `/friends/accept` | 없음 | 필요 | 없음 |
| Friend | POST | `/friends/decline` | 없음 | 필요 | 없음 |
| Plant | GET | `/plants` | 내 식물 목록 조회 | 필요 | `PlantListJsonResponse` |
| Plant | POST | `/plants` | 식물 생성 | 필요 | `CreateJsonResponse` |
| Plant | GET | `/plants/{plantId}` | 식물 상세 조회 | 필요 | `DetailJsonResponse` |
| Plant | PUT | `/plants/{plantId}` | 식물 수정 | 필요 | `EditInfoJsonResponse` |
| Plant | DELETE | `/plants/{plantId}` | 식물 삭제 | 필요 | `DeleteJsonResponse` |
| Plant | GET | `/plants/{plantId}/edit` | 식물 수정 정보 조회 | 필요 | `EditInfoJsonResponse` |
| Image | GET | `/s3/images` | 이미지 다운로드 URL 조회 | 필요 | 없음 |
| Image | POST | `/s3/images` | 이미지 다중 업로드 | 필요 | 없음 |
| Image | PUT | `/s3/images` | 이미지 수정 | 필요 | 없음 |
| Image | DELETE | `/s3/images` | 이미지 삭제 | 필요 | 없음 |

## 도메인별 최신 명세

### Auth

#### POST `/auth/login`

- Content-Type: `application/json;charset=UTF-8`
- Request schema: `Login`
- Required: `provider`, `token`
- `provider`: `GOOGLE`, `KAKAO`, `APPLE`
- 성공 response: `oneOf`
  - 기존 유저: `LoginSuccessJsonResponse.result` -> `LoginSuccess`
  - 신규 유저: `LoginNewUserJsonResponse.result` -> `LoginFailed`
- `LoginSuccess` fields:
  - `accessToken`
  - `refreshToken`
  - `newUser`
- `LoginFailed` fields:
  - `signupToken`
  - `suggestedName`
  - `suggestedImgUrl`
  - `newUser`
- Error:
  - `400`: `A005`, `A008`
  - `401`: `A001`, `A002`
  - `409`: `A007`

현재 코드 영향:

- #45의 `authResultFromJson`은 wrapper `result`를 unwrap할 수 있다.
- 신규 여부 판단 키는 현재 코드의 `isNewUser`가 아니라 Swagger의 `newUser`가 기준이다.
- 현재 구현은 `signupToken` 존재 여부로도 신규 유저를 판단하므로 동작 가능성이 있지만, DTO 필드명은 `newUser`로 정리하는 편이 안전하다.

#### POST `/auth/register`

- Content-Type: `multipart/form-data`
- Request schema: `RegisterMultipartRequest`
- Form parts:
  - `register`: `RegisterRequest`, required, `Content-Type: application/json`
  - `image`: binary, optional
- `RegisterRequest` required:
  - `signupToken`
  - `name`
- `RegisterRequest` optional:
  - `introduction`
- 성공 response: `RegisterJsonResponse.result` -> `RegisterResponse`
- `RegisterResponse` fields:
  - `accessToken`
  - `refreshToken`
  - `newUser`
- Error:
  - `400`: `A005`
  - `401`: `A006`, `A004`
  - `409`: `A007`, `A011`

현재 판단:

- 기존의 request/response `Register` schema 충돌은 해소됐다.
- 프로필 이미지는 `RegisterMultipartRequest.image` optional part이며 request JSON에는 `imgUrl`이 없다.
- 성공 example의 `isNewUser`와 schema의 `newUser` 명칭은 여전히 일치하지 않으므로 response DTO는 schema와 실제 응답을 함께 확인한다.
- #216에서 `AuthRemoteDataSource.register`를 `register` JSON part와 optional `image` part를 보내는 multipart 요청으로 전환했다.
- `RegisterRequest`에서는 명세에 없는 `imgUrl`을 제거했다.
- repository까지 optional `MultipartFile` 전달 경계를 열었으며 실제 profile image 파일 생성과 화면 연결은 별도 UI 작업으로 진행한다.

### User

#### GET `/users`

- 내 정보 조회 API이다.
- 성공 response: `UserJsonResponse.result` -> `UserResponse`
- `UserResponse` fields:
  - `name`
  - `id`
  - `email`
  - `provider`
  - `imgUrl`
  - `introduction`
- Error:
  - `401`: `A003`, `A004`
  - `404`: `U101`

#### PUT `/users`

- Content-Type: `multipart/form-data`
- Request schema: `UserUpdateMultipartRequest`
- Form parts:
  - `user`: `UserUpdateRequest`
  - `image`: binary, optional
- `UserUpdateRequest` fields:
  - `name`: 1~20자, 한글/영문/공백 허용
  - `introduction`: 200자 이내
  - `imgUrl`: 기존 프로필 이미지 URL
- 성공 response: `UserJsonResponse.result` -> `UserResponse`
- Error:
  - `401`: `A003`, `A004`
  - `404`: `U101`

#### DELETE `/users`

- 회원 탈퇴 API이며 soft delete 처리된다.
- 성공 response: `UserDeleteJsonResponse`
- `result`는 null로 설명되어 있다.
- Error:
  - `401`: `A003`, `A004`
  - `404`: `U101`

#### GET `/users/{keyword}`

- 사용자 이름 검색 API이다.
- Path parameter:
  - `keyword`: 검색 키워드, required
- 성공 response: `UserListJsonResponse.result` -> `UserResponse[]`
- Error:
  - `400`: `U002`
  - `401`: `A003`, `A004`
  - `404`: `U101`

### Place

#### GET `/place/myGarden`

- 사용자의 정원 정보를 조회한다.
- live Swagger 성공 response body schema는 없다.
- 백엔드 source의 `JsonResponse.result`는 `getMainPage`이다.
- `getMainPage` fields:
  - `name`: 현재 사용자 이름
  - `placeList`: `getPlaceListRes[]`
- `getPlaceListRes` fields:
  - `image`
  - `code`
  - `name`
  - `member`: 문자열 멤버 수
  - `plant`: 문자열 식물 수

#### GET `/place/user`

- 사용자가 속한 장소 리스트를 조회한다.
- live Swagger 성공 response body schema는 없다.
- 백엔드 source의 `JsonResponse.result`는 `getPlaceBelongUser[]`이다.
- 항목 fields: `code`, `name`, `imgUrl`

#### GET `/place/{code}`

- Path parameter:
  - `code`: 장소 코드
- live Swagger 성공 response body schema는 없다.
- 백엔드 source의 `JsonResponse.result`는 `getPlaceRes`이다.
- `getPlaceRes` fields:
  - `name`, `code`, `address`, `imgUrl`
  - `owner`: 현재 사용자의 장소 소유자 여부
  - `userList`: `{ name, image }[]`
  - `plantList`: Plant `DetailResponse[]`
- #239는 위 계약을 별도 `PlaceDetail` 도메인 모델로 파싱하고 API 모드의 fixture 환경값·멤버·식물을 제거한다.
- Error:
  - `403`: 장소 접근 권한 없음
  - `404`: 장소 없음

#### GET `/place/{code}/members`

- 가입 순서대로 장소 멤버 목록을 조회한다.
- Path parameter:
  - `code`: 장소 코드, required
- 성공 response 설명은 `멤버 목록 조회 성공`이지만 live Swagger body schema는 없다.
- 백엔드 source의 result는 가입 순서의 `{ name, image }[]`이다.
- Error:
  - `403`: 장소 접근 권한 없음
  - `404`: 장소 없음
- 고유 member id와 역할은 제공되지 않으므로 멤버 변경·권한 UI에는 별도 endpoint 또는 응답 확장이 필요하다.
- #245는 이름·이미지·가입 순서를 보존하는 typed 목록과 친구 관리 조회 전용 화면을 연결한다.

#### POST `/place/create`

- Content-Type: `multipart/form-data`
- Form parts:
  - `place`: `createPlaceReq`, required
  - `image`: binary, optional
- `createPlaceReq` required:
  - `name`
  - `address`
- `createPlaceReq` properties:
  - `name`: 최대 10자
  - `address`: 필수
- live Swagger 성공 response body schema는 없다.
- 백엔드 source의 성공 result는 생성된 place code 문자열이다.
- Error:
  - `400`: 요청 값 검증 실패, 주소 누락/공백

#### PUT `/place/update/{code}`

- Content-Type: `multipart/form-data`
- Path parameter:
  - `code`: 장소 코드
- Form parts:
  - `place`: `updatePlaceReq`, required
  - `image`: binary, optional
- `updatePlaceReq` required:
  - `name`
  - `address`
- `updatePlaceReq` properties:
  - `imageKey`: 새 image 파일이 없으면 기존 key는 유지, 생략/null은 삭제. 새 파일이 있으면 교체
  - `name`: 최대 10자
  - `address`
- live Swagger 성공 response body schema는 없다.
- 백엔드 source의 성공 result는 `{ code, name, address, imgUrl }`이다.
- Error:
  - `400`: 장소 이미지 키 오류
  - `403`: 장소 접근 권한 없음
  - `404`: 장소 없음

#### DELETE `/place/delete/{code}`

- Path parameter:
  - `code`: 장소 코드
- live Swagger 성공 response body schema는 없다.
- 백엔드 source의 성공 result는 null이다.
- Error:
  - `403`: 장소 접근 권한 없음
  - `404`: 장소 없음

### Friend

#### GET `/friends/requests`

- live Swagger summary와 response schema는 없고 성공 설명은 `OK`이다.
- 백엔드 source의 result는 `{ requests: friendRequestItem[] }`이다.
- `friendRequestItem` fields:
  - `friendId`: 친구 요청 PK
  - `senderName`, `senderImgUrl`
  - `placeCode`, `placeName`, `placeAddress`
  - `status`

#### POST `/friends/request`

- Content-Type: `application/json;charset=UTF-8`
- Request schema: `sendFriendReq`
- Request properties:
  - `receiverName`: string array
  - `placeCode`: string
- live Swagger 성공 response 설명은 `OK`이고 response schema는 없다.
- 백엔드 source의 result는 `{ placeCode, receiverList }`이다.
- 현재 Service는 `receiverName`을 표시 이름 부분 검색에 넣고 첫 결과를 사용하므로 중복 이름 오매칭 위험이 있다.

#### POST `/friends/accept`

- Content-Type: `application/json;charset=UTF-8`
- Request schema: `friendDecisionReq`
- Request properties:
  - `friendId`: int64
- `friendId`는 친구 요청 PK이다.
- 성공 result는 null이다.

#### POST `/friends/decline`

- Content-Type: `application/json;charset=UTF-8`
- Request schema: `friendDecisionReq`
- Request properties:
  - `friendId`: int64
- `friendId`는 친구 요청 PK이다.
- 성공 result는 null이다.

### Plant

#### GET `/plants`

- 사용자가 속한 모든 장소의 식물을 페이지 단위로 조회한다.
- Query parameters:
  - `page`: optional, default `0`
  - `size`: optional, default `20`, 최대 `50`
- 성공 response: `PlantListJsonResponse.result.content`
- `PlantPageContent` fields:
  - `items`: `PlantSummary[]`
  - `totalCount`
  - `page`
  - `size`
- `PlantSummary` fields:
  - `plantId`
  - `nickname`
  - `representativeImageUrl`

#### POST `/plants`

- Content-Type: `multipart/form-data`
- Form parts:
  - `plant`: `CreateRequest`, required
  - `image`: binary, optional
- `CreateRequest` required:
  - `placeCode`
  - `nickname`
- `CreateRequest` optional:
  - `scientificNameKo`
  - `scientificNameEn`
  - `lastWateredDate`
  - `description`
- Validation:
  - `scientificNameKo`: 최대 20자
  - `scientificNameEn`: 최대 20자
  - `nickname`: 최대 20자
  - `description`: 최대 200자
  - `lastWateredDate`: `yyyy-MM-dd`
- 성공 response: `CreateJsonResponse.result.plantId`
- Error:
  - `400`: 요청 값 검증 실패
  - `403`: 장소 접근 권한 없음

#### GET `/plants/{plantId}`

- 식물 상세 정보와 장소명, 대표 메모 정보를 조회한다.
- Path parameter:
  - `plantId`: 식물 ID
- 성공 response: `DetailJsonResponse.result` -> `DetailResponse`
- `DetailResponse` fields:
  - `plantId`
  - `scientificNameKo`
  - `scientificNameEn`
  - `registeredAt`
  - `lastWateredDate`
  - `imageUrl`
  - `memo`
  - `placeName`
  - `plantInfo`
- Error:
  - `403`: 장소 접근 권한 없음
  - `404`: 식물 없음

#### PUT `/plants/{plantId}`

- Content-Type: `multipart/form-data`
- Path parameter:
  - `plantId`: 식물 ID
- Query parameter:
  - `placeCode`: 식물이 속한 장소 코드, required
- Form parts:
  - `plant`: `UpdateRequest`
  - `image`: binary, optional
- `UpdateRequest` properties:
  - `imageKey`: 새 image 파일이 없으면 기존 key는 유지, 생략/null은 삭제. 새 파일이 있으면 교체
  - `nickname`: 최대 20자
  - `lastWateredDate`: `yyyy-MM-dd`
- 성공 response: `EditInfoJsonResponse.result` -> `EditInfoResponse`
- Error:
  - `400`: 수정 요청 값 오류
  - `403`: 장소 접근 권한 없음
  - `404`: 식물 없음

#### DELETE `/plants/{plantId}`

- Path parameter:
  - `plantId`: 식물 ID
- Query parameter:
  - `placeCode`: 식물이 속한 장소 코드
- 성공 response: `DeleteJsonResponse.result.plantId`
- Error:
  - `403`: 장소 접근 권한 없음
  - `404`: 식물 없음

#### GET `/plants/{plantId}/edit`

- 식물 수정 화면에 필요한 현재 이미지, 애칭, 마지막 물 준 날짜를 조회한다.
- Path parameter:
  - `plantId`: 식물 ID
- 성공 response: `EditInfoJsonResponse.result` -> `EditInfoResponse`
- `EditInfoResponse` fields:
  - `imageKey`
  - `imageUrl`
  - `nickname`
  - `lastWateredDate`
- Error:
  - `403`: 장소 접근 권한 없음
  - `404`: 식물 없음

### Image

#### GET `/s3/images`

- 이미지 key로 presigned download URL을 조회한다.
- Query parameter:
  - `key`: 이미지 key, required
- 성공 response body schema는 없다.
- Error:
  - `401`: 인증 실패
  - `404`: 이미지 없음

#### POST `/s3/images`

- Content-Type: `multipart/form-data`
- Form part:
  - `images`: binary array, required
- 업로드 개수는 1개 이상 5개 이하이다.
- 허용 타입은 `jpeg`, `png`, `webp`이다.
- 파일당 최대 크기는 10MB이다.
- 성공 response body schema는 없다.
- Error:
  - `400`: 이미지 개수/파일 형식/크기 오류

#### PUT `/s3/images`

- 기존 이미지 key에 해당하는 이미지를 새 이미지 파일로 교체한다.
- Content-Type: `multipart/form-data`
- Query parameter:
  - `key`: 교체 대상 이미지 key, required
- Form part:
  - `image`: binary, required
- 허용 타입은 `jpeg`, `png`, `webp`이다.
- 파일당 최대 크기는 10MB이다.
- 성공 response body schema는 없다.
- Error:
  - `400`: 이미지 파일 형식/크기 오류
  - `401`: 인증 실패
  - `404`: 이미지 없음

#### DELETE `/s3/images`

- 이미지 key에 해당하는 S3 객체와 이미지 메타데이터를 삭제한다.
- Query parameter:
  - `key`: 이미지 key, required
- 성공 response body schema는 없다.
- Error:
  - `401`: 인증 실패
  - `404`: 이미지 없음

## 화면별 API 매핑 변경

아래 표는 기존 문서에서 제외되었으나 최신 Swagger 기준으로 화면 연결 가능성이 생긴 API이다.
단, response schema가 없거나 요청/응답 정책이 불명확한 항목은 바로 구현하지 않고 백엔드 확인 후 진행한다.

| 화면 | Route | 새로 연결 가능한 API | 판단 |
| --- | --- | --- | --- |
| 프로필 설정 | `/profile/setup` | `POST /auth/register` | #216에서 multipart datasource/repository 반영 완료, 실제 image picker 파일과 submit 연결은 별도 구현 필요 |
| 마이페이지·회원 정보 수정 | `/me`, `/me/edit` | `GET/PUT/DELETE /users` | #237에서 조회·이름 수정·회원 탈퇴 화면 흐름 연결, 실제 image picker는 별도 정책 필요 |
| 장소 등록 | `/places/new` | `POST /place/create` | #243에서 생성 result code와 친구 추가 route 문맥 연결 |
| 친구 추가 | `/places/new/friends` | `GET /users/{keyword}` | 사용자 이름 검색 DTO 반영 가능 |
| 친구 추가 | `/places/new/friends` | `POST /friends/request` | #243에서 선택 이름·place code submit 연결, 표시 이름 오매칭 위험은 별도 등록 |
| 장소 친구 요청 | `/places/invitations` | `GET /friends/requests` | #241에서 `requests[]` typed mapper와 화면 상태 연결 |
| 장소 친구 요청 | `/places/invitations` | `POST /friends/accept`, `POST /friends/decline` | #241에서 요청 PK submit·목록 갱신 연결 |
| 장소 상세 | `/places/:placeId` | `GET /place/{code}` | #239에서 장소·owner·멤버·식물 실데이터 연결 |
| 친구 관리 | `/places/:placeId/friends` | `GET /place/{code}/members` | #245 실제 멤버·이미지 조회와 필터·상태 UI 연결, 변경 endpoint는 없음 |
| 장소 수정 | `/places/:placeId/edit` | `PUT /place/update/{code}` | #243에서 수정 result를 typed 장소 요약으로 연결, image key 조회는 별도 확인 필요 |
| 식물 등록 정보 입력 | `/plants/new/details` | `POST /plants` | #229 submit 연결, #251 실제 장소 code·상태·선택·제출 보호 병합 |
| 식물 상세 | `/plants/:plantId` | `GET /plants/{plantId}`, `GET /place/user`, `GET /place/{code}` | #231 상세 연결, #273에서 route code가 없을 때 정확한 plant ID로 소속 code 복원 |
| 식물 수정 | `/plants/:plantId/edit` | `GET /plants/{plantId}/edit` | #229 화면 연결, GET 요청은 장소 query 불필요. 응답에 장소 code는 없음 |
| 식물 수정 | `/plants/:plantId/edit` | `PUT /plants/{plantId}?placeCode=...` | #252 필수 code 검증·누락 안내, #273 Home 진입 code 복원과 관련 캐시 갱신 구현 |

아직 Swagger에 없는 화면 API:

- 주소 검색 API
- 식물 학명/추천 검색 API
- 메모 생성, 목록, 수정, 삭제 API
- 로그아웃 API
- refresh token 재발급 API

2026-09-01 live OpenAPI는 여전히 19개 path이며 Memo path/schema는 0개다. backend #50~#55에는 `/plants/{plantUuid}/memos` 생성·조회·수정·삭제 계획이 있지만 구현과 OpenAPI가 아니며 content 200/500자, image 생략 시 유지/삭제, 작성자·권한, pagination, 성공 wrapper가 확정되지 않았다. #283은 [backend #50 계약 확인](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/50#issuecomment-5488630254) 답변 전까지 이를 프론트 DTO 근거로 사용하지 않는다.

## 기존 확인 필요 항목 처리 현황

| 기존 확인 필요 항목 | 최신 Swagger 상태 | 판단 |
| --- | --- | --- |
| 모든 API의 response body schema 부재 | Auth/User/Plant 일부 response schema 추가 | 일부 해소 |
| 공통 응답 wrapper 사용 여부 | `timeStamp`, `success`, `status`, `message`, `result` wrapper 확인 | 일부 해소 |
| `/auth/login` 성공 응답 body 구조 | 기존/신규 유저 `oneOf` schema 추가 | 해소 |
| `/auth/register` 성공 응답 body 구조 | `RegisterJsonResponse` 추가 | 해소 |
| `/auth/register` 요청 body 구조 | `RegisterRequest`/`RegisterResponse` 분리와 `register` JSON part encoding 확인 | 해소 |
| `/users` 조회 성공 응답 body 구조 | `UserJsonResponse`, `UserResponse` 추가 | 해소 |
| `PUT /users` request schema 오연결 | `UserUpdateMultipartRequest`로 변경 | 해소 |
| Place 조회/생성/수정/삭제 성공 응답 body 구조 | live Swagger schema는 없지만 backend source 반환 타입 확인 | source 기준 해소, 인증 smoke 남음 |
| Plant 목록/상세/수정 화면 조회 성공 응답 body 구조 | 목록, 생성, 상세, 수정 정보, 삭제 schema 추가 | 해소 |
| Image 업로드/조회/수정/삭제 성공 응답 body 구조 | 여전히 schema 없음 | 남음 |
| `PUT /place/update/{code}` multipart 여부 | `multipart/form-data`로 변경 | 해소 |
| multipart 요청 JSON part content type | Auth/User/Plant는 `application/json` 명시, Place create/update는 encoding 미표기 | 일부 남음 |
| 장소 멤버 목록 API | source에서 `{ name, image }[]` 확인, 쓰기 endpoint 없음 | 표시 계약 해소, #277은 backend #150 전까지 고유 id·역할·변경 API Blocked |
| Place create/update required와 validation | `name`, `address` required와 `name` maxLength 확인 | 일부 해소 |
| Plant create/update validation과 nullable 정책 | 문자열 maxLength와 date format 확인 | 일부 해소 |
| 에러 응답 body 구조와 code/message 필드명 | live 401 응답과 backend `ErrorResponse` source 대조 | #275 typed 파싱·field 오류·민감 value 폐기 반영, 인증 쓰기 smoke 남음 |
| 공통 에러 코드 체계 | backend 도메인 error enum 대조, `A006` 중복 확인 | #275 HTTP 범주·확인 코드만 매핑, 미확인 code는 안전 fallback |
| refresh token 재발급 API | 없음 | 남음 |
| 로그아웃 API | 없음 | 남음 |
| pagination 응답 구조와 total count | `PlantPageContent`에 `items`, `totalCount`, `page`, `size` 추가 | 해소 |
| 이미지 key 저장 주체와 업로드 후 반환 값 | Place/Plant 도메인 수정의 유지·교체·삭제 계약은 확인, 독립 Image 응답과 Place key 조회는 미확정 | #248 key 보존·안전 차단 구현, 계약 일부 미확정 |
| 앱 flavor별 full base URL 정책 | 프론트 환경 전략은 `docs/release-workflow.md`에서 flavor와 CI/CD 주입 분리로 정리. Swagger server는 여전히 `/api/v1`만 제공 | 일부 해소 |

## API 연계 코드에 반영 가능한 부분

현재 API 계층을 기준으로, 백엔드 추가 확인 없이도 Swagger와 맞춰 조정 가능한 항목이다.

- 반영: `ApiResponseParser`가 공통 wrapper의 `result.content.items` 목록을 읽도록 보강했다.
- 반영: #275에서 표준 오류의 status·code·traceId·field reason을 `ApiException`으로 파싱하고 rejected `value`를 폐기한다. 주요 폼과 변경 action은 안전한 범주 메시지를 사용한다.
- 반영: active access-token 요청의 `A003`, `A004`, `A009`는 현재 인증·데이터 세션을 종료하고 로그인 만료 안내로 연결한다. refresh와 서버 로그아웃은 backend #149 전까지 미구현이다.
- 반영: Plant 목록 mapper가 Swagger `PlantSummary`의 `plantId`, `nickname`, `representativeImageUrl`을 화면 모델로 매핑한다.
- 반영: `CreatePlantRequest.placeId`를 `placeCode` 문자열로 변경했다.
- 반영: `GET /plants/{plantId}`와 `GET /plants/{plantId}/edit` 호출에서 `placeId` query parameter를 제거했다.
- 반영: `PUT /plants/{plantId}`와 `DELETE /plants/{plantId}` 호출은 query key를 `placeCode`로 변경했다.
- 반영: #273에서 route·Plant 응답에 code가 없으면 Place 목록·상세의 정확한 plant ID를 대조해 소속 code를 복원한다. direct code를 우선하고 이름·첫 장소는 추정값으로 쓰지 않는다.
- 반영: Plant 상세 DTO는 `DetailResponse` 기준으로 `plantId`, `scientificNameKo`, `scientificNameEn`, `registeredAt`, `lastWateredDate`, `imageUrl`, `memo`, `placeName`, `plantInfo`를 매핑한다.
- 반영: Plant 수정 정보 DTO는 `EditInfoResponse` 기준으로 `imageKey`, `imageUrl`, `nickname`, `lastWateredDate`를 매핑한다.
- 반영: `createPlaceReq`는 `address`가 required이므로 장소 생성 요청 DTO와 API mode 제출 전 검증을 조정했다.
- 반영: User 조회/수정/검색 DTO와 datasource/repository는 `UserResponse`, `UserListJsonResponse`, `UserUpdateMultipartRequest` 기준으로 추가했다.
- 반영: `PUT /users`는 multipart `user` JSON part와 optional `image` part를 사용하는 datasource로 구성했다.
- 반영: `UserRepository.updateMe`는 화면의 이미지 선택 흐름이 `MultipartFile`을 확보하면 optional `image` part를 전달할 수 있도록 열어두었다.
- 반영: #237에서 `/me`, `/me/settings`, `/me/edit` 화면을 추가하고 `GET/PUT/DELETE /users`를 현재 사용자 조회·이름 수정·회원 탈퇴 흐름에 연결했다.
- 반영: `GET /users/{keyword}`는 사용자 검색 datasource/repository 후보로 추가했다.
- 반영: `POST /place/create`와 `PUT /place/update/{code}`는 optional `image` part를 datasource/repository 경계에서 전달할 수 있도록 보강했다.
- 반영: `PUT /place/update/{code}`는 multipart 전송 datasource/repository를 추가했다.
- 반영: #239에서 `GET /place/myGarden`의 `result.placeList`와 대표 이미지를 Home 장소 카드에 연결했다.
- 반영: #239에서 `GET /place/{code}`를 `PlaceDetail`로 파싱하고 owner·멤버·식물·이미지·날짜를 상세 화면에 연결했다.
- 반영: #239 remote 상세에서는 서버가 주지 않는 햇빛·습도와 fixture 멤버·식물을 표시하지 않는다.
- 반영: #243에서 `POST /place/create`의 result 문자열을 place code로 파싱하고 친구 추가 route에 전달한다.
- 반영: #243에서 `PUT /place/update/{code}`의 result를 typed `PlaceSummary`로 파싱한다.
- 반영: #245에서 `GET /place/{code}/members`의 result 배열을 `PlaceMember`로 파싱하고 친구 관리 조회·검색에 연결했다. API 모드는 임시 렌더링 키를 사용자 ID로 사용하지 않고 멤버 변경을 제공하지 않는다.
- 유지: #277에서 live OpenAPI와 backend main을 다시 확인했으나 멤버·Friend 쓰기 계약은 추가되지 않았다. backend #150 전까지 `receiverId` 같은 필드, 임시 멤버 key, 표시 이름 검색 첫 항목을 새 원격 쓰기 계약으로 사용하지 않는다.
- 반영: #241에서 `GET /friends/requests`를 typed `FriendInvitation` 목록으로 파싱하고 Home 요청 수와 장소 친구 요청 화면에 연결했다.
- 반영: #241에서 `POST /friends/accept`, `POST /friends/decline`을 항목별 submit 상태와 목록 invalidate 정책에 연결했다.
- 반영: `POST /plants`와 `PUT /plants/{plantId}`는 optional `image` part를 datasource/repository 경계에서 전달할 수 있도록 보강했다.
- 반영: Auth login DTO는 Swagger의 `newUser` 필드명을 명시적으로 보존한다.
- 반영: #243에서 Friend 신규 요청을 화면 submit까지 연결했다. 표시 이름 중복 오매칭과 대상별 결과 미검증 위험은 `docs/accepted-implementation-risks.md`에서 수용 상태로 추적한다.
- 반영: Image 업로드/조회/수정/삭제 endpoint는 response schema가 없으므로 raw 또는 void 경계로 datasource/repository만 추가했다.

### Image 화면 연결 판단

프로필 수정, 장소 생성/수정, 식물 생성/수정은 실제 파일 선택기가 `MultipartFile`을 제공하면 repository의 optional `image` part로 전달할 수 있다. 파일 선택기 도입과 기존 이미지 보존은 별도 작업이다.

Place/Plant 수정 요청의 `imageKey`는 단순 optional 장식 필드가 아니다.

| 요청 | 확인된 서버 처리 |
| --- | --- |
| 새 image 파일 있음 | 기존 이미지 교체 |
| 새 파일 없음 + 기존과 동일한 key | 기존 이미지 유지 |
| 새 파일 없음 + key 생략/null | 기존 이미지 삭제 |
| 새 파일 없음 + 기존과 다른 key | 잘못된 요청으로 거절 |

근거: [dev OpenAPI](https://commonplant-dev.okbear.dev/api/v1/api-docs/json)의 두 update schema와 backend `7d572cb`의 [PlaceServiceImpl](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/blob/7d572cbcabc81a65926738b2a09e8479d0bd0c79/src/main/java/com/commonplant/garden/place/service/PlaceServiceImpl.java), [PlantServiceImpl](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/blob/7d572cbcabc81a65926738b2a09e8479d0bd0c79/src/main/java/com/commonplant/garden/plant/service/PlantServiceImpl.java)의 `resolveUpdatedImageKey`를 대조했다. 실제 원격 삭제 요청은 실행하지 않았다.

[#248](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/248)에서 Plant Form의 초기 key·URL을 보존하고 이름·날짜 수정 요청에 key를 전달한다. URL이 있지만 key가 없으면 요청을 차단한다. Place는 key를 조회할 수 없어 사진이 있는 장소의 수정 요청을 차단·안내하며 사진이 없는 장소는 기존 수정 동작을 유지한다. key 확보와 동시 수정의 조건부 보호 계약은 [IMAGE-04](backend-api-open-questions.md#image-04-이미지-key-생명주기)로 남기고, [작업 이력](work-history/form-image-preservation-248.md)에 제한을 기록한다. URL에서 key를 추측하지 않는다.

독립형 Image API(`/s3/images`)는 response schema가 없어 화면에서 반환된 image key/url을 확정적으로 읽을 수 없다. 따라서 프로필, 장소, 식물, 메모 화면에서 `/s3/images` 업로드 결과를 `imageKey`, `imgUrl`, `imageUrl`로 임의 매핑하지 않는다.

현재 보류 범위:

- 프로필 설정의 회원가입 multipart는 #216, 화면 submit은 #227에서 연결했다. 실제 image picker 파일 연결은 남아 있다.
- 장소/식물 화면은 도메인 multipart `image` part 전달 경계까지만 열어두고, 실제 파일 선택기 도입은 별도 UI 작업에서 진행한다.
- 메모 화면은 아직 Memo API가 없어 로컬 사진 상태만 유지한다.
- `/s3/images` 다운로드 URL 조회는 성공 response의 URL 필드 또는 wrapper 구조가 확정된 뒤 화면 fallback 정책과 함께 연결한다.

## 백엔드에 다시 확인해야 할 부분

상세 질문 목록은 `docs/backend-api-open-questions.md`에서 관리한다. 아래 표는 Swagger 참고 문서 관점의 요약이다.

| 영역 | 대표 확인 항목 | 프론트 영향 |
| --- | --- | --- |
| Auth | `POST /auth/register` response example의 `isNewUser`와 schema `newUser` 불일치 | 회원가입 응답 DTO의 실제 필드 확인 필요 |
| 공통 Multipart | JSON part의 `Content-Type: application/json` 필요 여부 | Auth/Place/Plant/User multipart 전송 정책 정합성 |
| Place | 멤버 ID·역할, self leave, owner 멤버 관리 endpoint와 권한·오류 | #277은 backend #150 전까지 조회 전용·member 나가기 숨김 유지 |
| Friend | 고유 대상 request, 사용자 검색 정책, 다중 대상 원자성·부분 결과·멱등 | #277은 backend #150 전까지 이름 기반 위험 수용 경계를 확장하지 않음 |
| Image | `/s3/images` 성공 response, image key/url 필드, 업로드 흐름 | 프로필/장소/식물/메모 이미지 key/url 매핑 보류 |
| Error | live/backend source와 dev 배포의 실제 인증 쓰기 오류 일치 여부 | #275 공통 사용자 메시지와 field error 매핑 완료, 원격 validation smoke 보류 |
| Token | refresh token 재발급, 로그아웃 API 제공 여부 | #275 로컬 세션 종료 적용, backend #149 전까지 자동 복구·서버 invalidation 차단 |
| 검색 | 주소 검색, 식물 검색 API 제공 여부와 사용자 검색 매칭 정책 | 주소 검색은 보류, 식물 검색은 백엔드 #92 대기 중이며 API mode fixture 차단 |
| Memo | backend #50~#55의 메모 CRUD, 작성자·권한·pagination·오류와 이미지 생략 정책 | #283 계약 확인과 live OpenAPI 동기화 전 텍스트 CRUD 연결 Blocked, 이미지 별도 보류 |
| 환경 | dev URL은 확인, staging/prod full base URL과 API versioning 정책은 미확정 | dev 로컬 실행 가능, release 검증 보류 |

## 현재 후속 작업 안내

초기 Auth·Home·Plant·User·Place·Friend 연결과 감사 회귀 수정 PR은 병합됐다. 현행 우선순위와 미완료 동선은 [화면·API 매트릭스](screen-api-integration-plan.md)를 따른다.

소셜 SDK credential 획득, 실제 주소 검색과 이미지 파일 선택·key 조회는 여전히 별도 준비가 필요하다. Memo 텍스트 CRUD는 backend #50 계약 답변·구현·live OpenAPI 동기화를, Place 멤버 변경·나가기와 Friend 고유 대상·부분 결과는 backend #150을 선행 조건으로 둔다. 식물 검색은 백엔드 #92 전까지 API mode에서 비활성화한다. 이미 수용한 Friend 이름 오매칭과 Plant 장소 조회 비용은 위험 등록부로 추적하고, 새 프론트 결함을 자동으로 수용한 것으로 해석하지 않는다.

## DEV API 문서화 작업 이력

| 이슈 | 커밋 | 변경 범위 | 검증 |
| --- | --- | --- | --- |
| #213 | `6a9fbc9` | dev origin/API base, Swagger UI/OpenAPI/config, 현재 endpoint 차이와 환경별 Ready/Blocked 경계 문서화 | endpoint HTTP status, OpenAPI metadata, 19 paths·27 operations와 schema 대조, `git diff --check` |
| #216 | `ae134d0` | Auth register JSON part와 optional image multipart datasource/repository, Swagger request DTO 반영 | Auth unit test 5개, macOS 전체 263개와 Ubuntu golden 포함 264개, format 260개 파일, analyze |
| #227 | `111373a`, `a065188`, `e9543fc` | Auth 세션과 social credential 경계, 로그인·회원가입 화면 submit, 인증 route redirect 연결 | format 270개 파일, analyze, 전체 test 280개 통과·기존 skip 1개 |
| #241 | `24079a6`, `a1761a8`, `0141f74` | Friend 수신 요청 typed mapper, 수락·거절 상태, Home 요청 수와 화면 상태 연결 | format 289개 파일, analyze, 전체 test 332개 통과·기존 skip 1개 |
| #243 | `c5fbca2`, `d38e031`, `3b2198c` | Place 생성 code·수정 요약, 친구 추가 route와 이름 기반 요청 submit 연결 | format 291개, analyze, 전체 test 344개 통과·기존 skip 1개 |
| #245 | `b090581`, `8e46fd8` | 장소 멤버 typed 조회와 친구 관리 read-only·filter·상태 UI 연결 | format 294개, analyze, 전체 test 362개 통과·기존 skip 1개 |
| #275 | `e507656`, `022e8ba` | 표준 API 오류·field 메시지와 확인된 인증 만료의 로컬 세션 종료, refresh·logout 차단 경계 | format·analyze·diff 검사, 전체 547개 통과·기존 skip 1개 |
| #277 | 이 문서의 최종 커밋 | Place 멤버·Friend 쓰기 계약 재검증, backend #150 질문과 안전 차단 유지 | live OpenAPI·backend main·중복 이슈 확인, `git diff --check` |

작업 이력만 갱신하는 후속 문서 커밋은 자기 자신의 해시를 생략할 수 있다.
