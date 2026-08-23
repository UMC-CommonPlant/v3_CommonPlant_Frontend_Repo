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
- 확인일: 2026-08-23
- 접속 결과: Swagger UI, OpenAPI JSON, Swagger config HTTP 200
- 개발 서버 루트: HTTP 404. 루트 route가 없다는 의미이며 Swagger/API endpoint 상태와 분리한다.
- 인증 endpoint 확인: token 없이 `GET /api/v1/users` 요청 시 HTTP 401, code `A009`로 인증 요구 응답
- OpenAPI 버전: `3.1.0`
- API title: `Common Plant API Document`
- 서버 base path: `/api/v1`
- endpoint inventory: 19 paths, 27 operations
- 기존 문서 비교 기준: `docs/api-swagger-summary-43` 브랜치의 `docs/api-swagger-reference.md` 확인일 2026-05-20
- 코드 비교 기준: `feature/api-integration-45` 브랜치의 `lib/core/network`, `features/*/data` API 계층
- 참고: 2026-05-25의 상세 schema 비교 기록을 보존하고, 2026-08-23에는 dev 접속 정보와 현재 endpoint/schema 차이를 재검증했다.

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
- Place, Image, Friend API는 여전히 성공 response body schema가 없거나 `OK` 수준의 설명만 있다.

## Swagger 변경 요약

### 2026-08-23 dev Swagger 재확인

| 구분 | 확인 내용 | 프론트 판단 |
| --- | --- | --- |
| 실행 환경 | dev origin과 `/api/v1` base URL 제공 | 로컬 remote API 실행 시 명시적 `dart-define` 주입 가능 |
| API 문서 | Swagger UI, OpenAPI JSON/config 공개 접근 가능 | live spec 확인과 문서 대조 가능 |
| Place | `GET /place/{code}/members` 추가 | 친구 관리 화면 후보지만 성공 response schema가 없어 mapper 구현 보류 |
| Auth register | request/response가 `RegisterRequest`/`RegisterResponse`로 분리 | #216에서 JSON part와 optional image multipart datasource 반영 |
| Multipart encoding | Auth/User/Plant JSON part에 `application/json` 명시 | 해당 도메인 전송 기준 확인, Place는 encoding 미표기로 추가 확인 유지 |

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
| Place | GET | `/place/myGarden` | 내 정원 조회 | 필요 | 없음 |
| Place | GET | `/place/user` | 소속 장소 조회 | 필요 | 없음 |
| Place | GET | `/place/{code}` | 장소 조회 | 필요 | 없음 |
| Place | GET | `/place/{code}/members` | 장소 멤버 목록 조회 | 필요 | 없음 |
| Place | POST | `/place/create` | 장소 생성 | 필요 | 없음 |
| Place | PUT | `/place/update/{code}` | 장소 수정 | 필요 | 없음 |
| Place | DELETE | `/place/delete/{code}` | 장소 삭제 | 필요 | 없음 |
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
- 성공 response body schema는 없다.

#### GET `/place/user`

- 사용자가 속한 장소 리스트를 조회한다.
- 성공 response body schema는 없다.

#### GET `/place/{code}`

- Path parameter:
  - `code`: 장소 코드
- 성공 response body schema는 없다.
- Error:
  - `403`: 장소 접근 권한 없음
  - `404`: 장소 없음

#### GET `/place/{code}/members`

- 가입 순서대로 장소 멤버 목록을 조회한다.
- Path parameter:
  - `code`: 장소 코드, required
- 성공 response 설명은 `멤버 목록 조회 성공`이지만 body schema는 없다.
- Error:
  - `403`: 장소 접근 권한 없음
  - `404`: 장소 없음
- 친구 관리 화면에 연결하려면 member id, 이름, 프로필 이미지, 역할 필드와 wrapper를 백엔드에 확인해야 한다.

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
- 성공 response body schema는 없다.
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
  - `imageKey`
  - `name`: 최대 10자
  - `address`
- 성공 response body schema는 없다.
- Error:
  - `400`: 장소 이미지 키 오류
  - `403`: 장소 접근 권한 없음
  - `404`: 장소 없음

#### DELETE `/place/delete/{code}`

- Path parameter:
  - `code`: 장소 코드
- 성공 response body schema는 없다.
- Error:
  - `403`: 장소 접근 권한 없음
  - `404`: 장소 없음

### Friend

#### GET `/friends/requests`

- 친구 요청 목록 조회로 추정되지만 Swagger summary와 response schema가 없다.
- 성공 response 설명은 `OK`이다.

#### POST `/friends/request`

- Content-Type: `application/json;charset=UTF-8`
- Request schema: `sendFriendReq`
- Request properties:
  - `receiverName`: string array
  - `placeCode`: string
- 성공 response 설명은 `OK`이고 response schema는 없다.

#### POST `/friends/accept`

- Content-Type: `application/json;charset=UTF-8`
- Request schema: `friendDecisionReq`
- Request properties:
  - `friendId`: int64
- 성공 response 설명은 `OK`이고 response schema는 없다.

#### POST `/friends/decline`

- Content-Type: `application/json;charset=UTF-8`
- Request schema: `friendDecisionReq`
- Request properties:
  - `friendId`: int64
- 성공 response 설명은 `OK`이고 response schema는 없다.

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
  - `placeCode`: 식물이 속한 장소 코드
- Form parts:
  - `plant`: `UpdateRequest`
  - `image`: binary, optional
- `UpdateRequest` properties:
  - `imageKey`
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
| 프로필 설정 또는 마이페이지 | 미정 | `PUT /users` | User 수정 request/response schema가 보강되어 반영 가능 |
| 친구 추가 | `/places/new/friends` | `GET /users/{keyword}` | 사용자 이름 검색 DTO 반영 가능 |
| 친구 추가 | `/places/new/friends` | `POST /friends/request` | 요청 전송은 가능하나 response schema와 화면 성공 정책 확인 필요 |
| 장소 친구 요청 | `/places/invitations` | `GET /friends/requests` | 목록 response schema가 없어 백엔드 확인 필요 |
| 장소 친구 요청 | `/places/invitations` | `POST /friends/accept`, `POST /friends/decline` | accept/decline 요청은 가능하나 response와 갱신 정책 확인 필요 |
| 친구 관리 | `/places/:placeId/friends` | `GET /place/{code}/members` | endpoint는 확인됐지만 목록 response schema가 없어 백엔드 확인 필요 |
| 장소 수정 | `/places/:placeId/edit` | `PUT /place/update/{code}` | multipart 여부는 해소됐지만 성공 response schema 없음 |
| 식물 등록 정보 입력 | `/plants/new/details` | `POST /plants` | `placeCode` 기준으로 현재 코드 DTO 수정 필요 |
| 식물 상세 | `/plants/:plantId` | `GET /plants/{plantId}` | query parameter 제거 필요 |
| 식물 수정 | `/plants/:plantId/edit` | `GET /plants/{plantId}/edit` | query parameter 제거 필요 |
| 식물 수정 | `/plants/:plantId/edit` | `PUT /plants/{plantId}?placeCode=...` | `placeCode` 기준으로 현재 코드 수정 필요 |

아직 Swagger에 없는 화면 API:

- 주소 검색 API
- 식물 학명/추천 검색 API
- 메모 생성, 목록, 수정, 삭제 API
- 로그아웃 API
- refresh token 재발급 API

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
| Place 조회/생성/수정/삭제 성공 응답 body 구조 | 여전히 schema 없음 | 남음 |
| Plant 목록/상세/수정 화면 조회 성공 응답 body 구조 | 목록, 생성, 상세, 수정 정보, 삭제 schema 추가 | 해소 |
| Image 업로드/조회/수정/삭제 성공 응답 body 구조 | 여전히 schema 없음 | 남음 |
| `PUT /place/update/{code}` multipart 여부 | `multipart/form-data`로 변경 | 해소 |
| multipart 요청 JSON part content type | Auth/User/Plant는 `application/json` 명시, Place create/update는 encoding 미표기 | 일부 남음 |
| 장소 멤버 목록 API | `GET /place/{code}/members` 추가, 성공 response schema 없음 | endpoint 확인, schema 확인 필요 |
| Place create/update required와 validation | `name`, `address` required와 `name` maxLength 확인 | 일부 해소 |
| Plant create/update validation과 nullable 정책 | 문자열 maxLength와 date format 확인 | 일부 해소 |
| 에러 응답 body 구조와 code/message 필드명 | 성공 wrapper는 있으나 에러 body schema 없음 | 남음 |
| 공통 에러 코드 체계 | Auth/User 일부 code, Plant/Place/Image 설명 보강 | 일부 해소 |
| refresh token 재발급 API | 없음 | 남음 |
| 로그아웃 API | 없음 | 남음 |
| pagination 응답 구조와 total count | `PlantPageContent`에 `items`, `totalCount`, `page`, `size` 추가 | 해소 |
| 이미지 key 저장 주체와 업로드 후 반환 값 | Image API response schema 없음 | 남음 |
| 앱 flavor별 full base URL 정책 | 프론트 환경 전략은 `docs/release-workflow.md`에서 flavor와 CI/CD 주입 분리로 정리. Swagger server는 여전히 `/api/v1`만 제공 | 일부 해소 |

## API 연계 코드에 반영 가능한 부분

현재 API 계층을 기준으로, 백엔드 추가 확인 없이도 Swagger와 맞춰 조정 가능한 항목이다.

- 반영: `ApiResponseParser`가 공통 wrapper의 `result.content.items` 목록을 읽도록 보강했다.
- 반영: Plant 목록 mapper가 Swagger `PlantSummary`의 `plantId`, `nickname`, `representativeImageUrl`을 화면 모델로 매핑한다.
- 반영: `CreatePlantRequest.placeId`를 `placeCode` 문자열로 변경했다.
- 반영: `GET /plants/{plantId}`와 `GET /plants/{plantId}/edit` 호출에서 `placeId` query parameter를 제거했다.
- 반영: `PUT /plants/{plantId}`와 `DELETE /plants/{plantId}` 호출은 query key를 `placeCode`로 변경했다.
- 반영: Plant 상세 DTO는 `DetailResponse` 기준으로 `plantId`, `scientificNameKo`, `scientificNameEn`, `registeredAt`, `lastWateredDate`, `imageUrl`, `memo`, `placeName`, `plantInfo`를 매핑한다.
- 반영: Plant 수정 정보 DTO는 `EditInfoResponse` 기준으로 `imageKey`, `imageUrl`, `nickname`, `lastWateredDate`를 매핑한다.
- 반영: `createPlaceReq`는 `address`가 required이므로 장소 생성 요청 DTO와 API mode 제출 전 검증을 조정했다.
- 반영: User 조회/수정/검색 DTO와 datasource/repository는 `UserResponse`, `UserListJsonResponse`, `UserUpdateMultipartRequest` 기준으로 추가했다.
- 반영: `PUT /users`는 multipart `user` JSON part와 optional `image` part를 사용하는 datasource로 구성했다.
- 반영: `UserRepository.updateMe`는 화면의 이미지 선택 흐름이 `MultipartFile`을 확보하면 optional `image` part를 전달할 수 있도록 열어두었다.
- 반영: `GET /users/{keyword}`는 사용자 검색 datasource/repository 후보로 추가했다.
- 반영: `POST /place/create`와 `PUT /place/update/{code}`는 optional `image` part를 datasource/repository 경계에서 전달할 수 있도록 보강했다.
- 반영: `PUT /place/update/{code}`는 multipart 전송 datasource/repository를 추가했다.
- 반영: `POST /plants`와 `PUT /plants/{plantId}`는 optional `image` part를 datasource/repository 경계에서 전달할 수 있도록 보강했다.
- 반영: Auth login DTO는 Swagger의 `newUser` 필드명을 명시적으로 보존한다.
- 반영: Friend 요청 목록/전송/수락/거절 endpoint는 response schema가 없으므로 raw 또는 void 경계로 datasource/repository만 추가했다.
- 반영: Image 업로드/조회/수정/삭제 endpoint는 response schema가 없으므로 raw 또는 void 경계로 datasource/repository만 추가했다.

### Image 화면 연결 판단

현재 화면에서 안전하게 열어둘 수 있는 범위는 도메인 API의 optional `image` multipart part까지이다. 프로필 수정, 장소 생성/수정, 식물 생성/수정은 실제 파일 선택기가 `MultipartFile`을 제공하면 repository에 전달할 수 있다.

독립형 Image API(`/s3/images`)는 response schema가 없어 화면에서 반환된 image key/url을 확정적으로 읽을 수 없다. 따라서 프로필, 장소, 식물, 메모 화면에서 `/s3/images` 업로드 결과를 `imageKey`, `imgUrl`, `imageUrl`로 임의 매핑하지 않는다.

현재 보류 범위:

- 프로필 설정의 회원가입 multipart datasource/repository는 #216에서 반영했으며 실제 image picker 파일과 submit 연결은 별도 UI 작업으로 진행한다.
- 장소/식물 화면은 도메인 multipart `image` part 전달 경계까지만 열어두고, 실제 파일 선택기 도입은 별도 UI 작업에서 진행한다.
- 메모 화면은 아직 Memo API가 없어 로컬 사진 상태만 유지한다.
- `/s3/images` 다운로드 URL 조회는 성공 response의 URL 필드 또는 wrapper 구조가 확정된 뒤 화면 fallback 정책과 함께 연결한다.

## 백엔드에 다시 확인해야 할 부분

상세 질문 목록은 `docs/backend-api-open-questions.md`에서 관리한다. 아래 표는 Swagger 참고 문서 관점의 요약이다.

| 영역 | 대표 확인 항목 | 프론트 영향 |
| --- | --- | --- |
| Auth | `POST /auth/register` response example의 `isNewUser`와 schema `newUser` 불일치 | 회원가입 응답 DTO의 실제 필드 확인 필요 |
| 공통 Multipart | JSON part의 `Content-Type: application/json` 필요 여부 | Auth/Place/Plant/User multipart 전송 정책 정합성 |
| Place | 조회/생성/수정/삭제 성공 response, 목록/상세/멤버 wrapper와 필드명 | 장소 mapper와 실데이터 화면 정책 제한 |
| Friend | 요청 목록/전송/수락/거절 response, `receiverName`, `friendId` 의미 | 친구 요청 화면과 액션 payload 확정 불가 |
| Image | `/s3/images` 성공 response, image key/url 필드, 업로드 흐름 | 프로필/장소/식물/메모 이미지 key/url 매핑 보류 |
| Error | 에러 body의 `code`, `message`, field error 구조 | 공통 사용자 메시지와 field error 매핑 보류 |
| Token | refresh token 재발급, 로그아웃 API 제공 여부 | 인증 만료 복구와 세션 종료 정책 보류 |
| 검색 | 주소 검색, 식물 검색 API 제공 여부와 사용자 검색 매칭 정책 | 주소/식물 검색 실데이터 연결 보류 |
| Memo | 메모 CRUD API, 이미지 첨부, 목록 response 구조 | 메모 화면 실데이터 연결 보류 |
| 환경 | dev URL은 확인, staging/prod full base URL과 API versioning 정책은 미확정 | dev 로컬 실행 가능, release 검증 보류 |

## 첫 API 연계 보강 우선순위 제안

1. Auth register multipart datasource/repository는 #216에서 반영했다. profile image 파일 생성과 화면 submit 연결은 별도 구현 이슈로 진행한다.
2. User 조회/검색/수정 datasource는 추가됐으므로, 화면 적용 시 상태 Provider와 UI 성공/실패 정책을 별도 작업으로 연결한다.
3. Place update는 multipart 전송까지만 추가했으므로, response schema가 확정될 때까지 mapper는 넓히지 않는다.
4. Friend API는 transport만 추가했으므로, 목록 response schema 확인 후 초대 요청 화면에 연결한다.
5. Image API는 transport만 추가했으므로, 반환 image key/url schema와 에러 body가 보강되면 이미지 업로드 흐름을 연결한다.

## DEV API 문서화 작업 이력

| 이슈 | 커밋 | 변경 범위 | 검증 |
| --- | --- | --- | --- |
| #213 | `6a9fbc9` | dev origin/API base, Swagger UI/OpenAPI/config, 현재 endpoint 차이와 환경별 Ready/Blocked 경계 문서화 | endpoint HTTP status, OpenAPI metadata, 19 paths·27 operations와 schema 대조, `git diff --check` |
| #216 | `ae134d0` | Auth register JSON part와 optional image multipart datasource/repository, Swagger request DTO 반영 | Auth unit test 5개, macOS 전체 263개와 Ubuntu golden 포함 264개, format 260개 파일, analyze |

작업 이력만 갱신하는 후속 문서 커밋은 자기 자신의 해시를 생략할 수 있다.
