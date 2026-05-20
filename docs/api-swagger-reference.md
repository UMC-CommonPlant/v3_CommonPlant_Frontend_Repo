# API Swagger 연계 참고 문서

이 문서는 Flutter API 연계 작업 중 Swagger UI를 반복해서 확인하는 비용을 줄이기 위한 요약 문서입니다.
서버 명세가 부족하거나 충돌하는 부분은 임의로 보정하지 않고 `확인 필요` 항목에 남깁니다.

## 확인 기준

- Swagger UI: https://commonplant.site/api/v1/swagger-ui/index.html
- OpenAPI JSON: https://commonplant.site/api/v1/api-docs/json
- Swagger config: https://commonplant.site/api/v1/api-docs/json/swagger-config
- 확인일: 2026-05-20
- OpenAPI 버전: `3.1.0`
- API title: `Common Plant API Document`
- 서버 base path: `/api/v1`

## 프론트엔드 연계 원칙

- 공통 HTTP client는 `lib/core/network`에 `dio` 기반으로 둔다.
- 화면에서 직접 JSON 파싱, Dio 생성, API 에러 문자열 분기를 하지 않는다.
- feature별 API는 `data/datasources`, `data/repositories`, 필요 시 `domain` 계층으로 분리한다.
- 화면 상태는 Riverpod의 `AsyncValue` 또는 Controller 상태로 `loading`, `success`, `empty`, `error`를 구분한다.
- Swagger에 응답 body schema가 없으므로, DTO는 서버 응답 예시나 백엔드 확인 후 확정한다.

## 공통 인증

- Swagger 전역 security는 `bearerAuth`이다.
- Header 형식은 `Authorization: Bearer <JWT>`로 해석한다.
- `/auth/login`, `/auth/register`는 `security: []`로 인증 제외되어 있다.
- 나머지 operation은 별도 security가 없어 전역 bearer 인증이 상속되는 것으로 본다.

## API 목록

| Domain | Method | Path | Summary | 인증 |
| --- | --- | --- | --- | --- |
| Auth | POST | `/auth/login` | 소셜 로그인 | 불필요 |
| Auth | POST | `/auth/register` | 회원가입 완료 | 불필요 |
| User | GET | `/users` | 내 정보 조회 | 필요 |
| User | PUT | `/users` | 내 정보 수정 | 필요 |
| User | DELETE | `/users` | 회원 탈퇴 | 필요 |
| Place | GET | `/place/myGarden` | 내 정원 조회 | 필요 |
| Place | GET | `/place/user` | 소속 장소 조회 | 필요 |
| Place | GET | `/place/{code}` | 장소 조회 | 필요 |
| Place | POST | `/place/create` | 장소 생성 | 필요 |
| Place | PUT | `/place/update/{code}` | 장소 수정 | 필요 |
| Place | DELETE | `/place/delete/{code}` | 장소 삭제 | 필요 |
| Plant | GET | `/plants` | 내 식물 목록 조회 | 필요 |
| Plant | POST | `/plants` | 식물 생성 | 필요 |
| Plant | GET | `/plants/{plantId}` | 식물 상세 조회 | 필요 |
| Plant | PUT | `/plants/{plantId}` | 식물 수정 | 필요 |
| Plant | DELETE | `/plants/{plantId}` | 식물 삭제 | 필요 |
| Plant | GET | `/plants/{plantId}/edit` | 식물 수정 정보 조회 | 필요 |
| Image | GET | `/s3/images` | 이미지 다운로드 URL 조회 | 필요 |
| Image | POST | `/s3/images` | 이미지 다중 업로드 | 필요 |
| Image | PUT | `/s3/images` | 이미지 수정 | 필요 |
| Image | DELETE | `/s3/images` | 이미지 삭제 | 필요 |

## Auth

### POST `/auth/login`

- Content-Type: `application/json;charset=UTF-8`
- Request schema: `Login`
- Required: `provider`, `token`
- `provider`: `GOOGLE`, `APPLE`, `KAKAO`
- 성공 시 기존 유저는 `accessToken`, `refreshToken` 반환, 신규 유저는 `signupToken`, `suggestedName`, `suggestedImgUrl` 반환이라고 설명되어 있다.
- Error:
  - `400`: `A005`, `A008`
  - `401`: `A001`, `A002`
  - `409`: `A007`

### POST `/auth/register`

- Content-Type: `application/json;charset=UTF-8`
- Request schema: `Register`
- Required: `signupToken`, `name`
- Optional: `introduction`, `imgUrl`
- 성공 시 `accessToken`, `refreshToken` 반환이라고 설명되어 있다.
- `signupToken` 유효 시간은 10분이다.
- Error:
  - `400`: `A005`
  - `401`: `A003`, `A004`
  - `409`: `A007`, `A011`

## User

### GET `/users`

- 내 정보 조회 API이다.
- Error:
  - `401`: `A003`, `A004`
  - `404`: `U101`

### PUT `/users`

- 전달한 필드만 수정한다고 설명되어 있다.
- Content-Type: `application/json;charset=UTF-8`
- 현재 Swagger상 request schema가 `UpdateRequest`로 연결되어 있으나, 해당 schema 설명과 필드는 식물 수정 정보이다.
- Error:
  - `401`: `A003`, `A004`
  - `404`: `U101`

### DELETE `/users`

- 회원 탈퇴 API이며 soft delete 처리된다.
- Error:
  - `401`: `A003`, `A004`
  - `404`: `U101`

## Place

### GET `/place/myGarden`

- 사용자가 속한 장소 목록과 메인 정보를 조회한다.

### GET `/place/user`

- 사용자가 속한 장소 리스트를 조회한다.

### GET `/place/{code}`

- Path parameter:
  - `code`: 장소 코드
- Error:
  - `404`: 장소 없음

### POST `/place/create`

- Content-Type: `multipart/form-data`
- Form parts:
  - `place`: `createPlaceReq`, required
  - `image`: binary, optional
- `createPlaceReq` properties:
  - `name`
  - `address`
- Error:
  - `400`: 요청 형식 오류

### PUT `/place/update/{code}`

- Path parameter:
  - `code`: 장소 코드
- Swagger 설명은 `place` JSON과 선택 `image` 업로드라고 되어 있다.
- Swagger content type은 `application/json;charset=UTF-8`로 등록되어 있다.
- Request properties:
  - `place`: `updatePlaceReq`, required
  - `image`: binary, optional
- `updatePlaceReq` properties:
  - `name`
  - `address`
- Error:
  - `404`: 장소 없음

### DELETE `/place/delete/{code}`

- Path parameter:
  - `code`: 장소 코드
- Error:
  - `404`: 장소 없음

## Plant

### GET `/plants`

- 사용자가 속한 모든 장소의 식물을 페이지 단위로 조회한다.
- Query parameters:
  - `page`: optional, default `0`
  - `size`: optional, default `20`, 최대 `50`

### POST `/plants`

- Content-Type: `multipart/form-data`
- Form parts:
  - `plant`: `CreateRequest`, required
  - `image`: binary, optional
- `CreateRequest` required:
  - `placeId`
  - `nickname`
- `CreateRequest` optional:
  - `scientificNameKo`
  - `scientificNameEn`
  - `lastWateredDate`
  - `description`
- Error:
  - `400`: 요청 값 검증 실패
  - `403`: 장소 접근 권한 없음

### GET `/plants/{plantId}`

- 식물 상세 정보와 장소명, 대표 메모 정보를 조회한다.
- Path parameter:
  - `plantId`: 식물 ID
- Query parameter:
  - `placeId`: 식물이 속한 장소 ID
- Error:
  - `403`: 장소 접근 권한 없음
  - `404`: 식물 없음

### PUT `/plants/{plantId}`

- 식물 이미지 파일, 애칭, 마지막 물 준 날짜 중 전달된 값만 수정한다.
- Content-Type: `multipart/form-data`
- Path parameter:
  - `plantId`: 식물 ID
- Query parameter:
  - `placeId`: 식물이 속한 장소 ID
- Form parts:
  - `plant`: `UpdateRequest`
  - `image`: binary, optional
- `UpdateRequest` properties:
  - `imageKey`
  - `nickname`
  - `lastWateredDate`
- Error:
  - `400`: 수정 요청 값 오류
  - `403`: 장소 접근 권한 없음
  - `404`: 식물 없음

### DELETE `/plants/{plantId}`

- Path parameter:
  - `plantId`: 식물 ID
- Query parameter:
  - `placeId`: 식물이 속한 장소 ID
- Error:
  - `403`: 장소 접근 권한 없음
  - `404`: 식물 없음

### GET `/plants/{plantId}/edit`

- 식물 수정 화면에 필요한 현재 이미지, 애칭, 마지막 물 준 날짜를 조회한다.
- Path parameter:
  - `plantId`: 식물 ID
- Query parameter:
  - `placeId`: 식물이 속한 장소 ID
- Error:
  - `403`: 장소 접근 권한 없음
  - `404`: 식물 없음

## Image

### GET `/s3/images`

- 이미지 key로 presigned download URL을 조회한다.
- Query parameter:
  - `key`: 이미지 key, required
- Error:
  - `401`: 인증 실패
  - `404`: 이미지 없음

### POST `/s3/images`

- Content-Type: `multipart/form-data`
- Form part:
  - `images`: binary array, required
- 업로드 개수는 1개 이상 5개 이하이다.
- 허용 타입은 `jpeg`, `png`, `webp`이다.
- 파일당 최대 크기는 10MB이다.
- Error:
  - `400`: 이미지 개수/파일 형식/크기 오류

### PUT `/s3/images`

- 기존 이미지 key에 해당하는 이미지를 새 이미지 파일로 교체한다.
- Content-Type: `multipart/form-data`
- Query parameter:
  - `key`: 교체 대상 이미지 key, required
- Form part:
  - `image`: binary, required
- 허용 타입은 `jpeg`, `png`, `webp`이다.
- 파일당 최대 크기는 10MB이다.
- Error:
  - `400`: 이미지 파일 형식/크기 오류
  - `401`: 인증 실패
  - `404`: 이미지 없음

### DELETE `/s3/images`

- 이미지 key에 해당하는 S3 객체와 이미지 메타데이터를 삭제한다.
- Query parameter:
  - `key`: 이미지 key, required
- Error:
  - `401`: 인증 실패
  - `404`: 이미지 없음

## 확인 필요

- 모든 API의 response body schema가 Swagger에 없다. DTO를 확정하려면 성공 응답 예시 또는 schema가 필요하다.
- API 공통 응답 wrapper 사용 여부가 명세에 없다.
- `/auth/login`의 기존 유저/신규 유저 성공 응답 body 구조가 schema로 정의되어 있지 않다.
- `/auth/register` 성공 응답 body 구조가 schema로 정의되어 있지 않다.
- `/users` 조회 성공 응답 body 구조가 없다.
- `PUT /users` request schema가 식물 수정용 `UpdateRequest`로 연결되어 있다. 사용자 수정 DTO 명세 확인이 필요하다.
- Place 조회/생성/수정/삭제 성공 응답 body 구조가 없다.
- Plant 목록/상세/수정 화면 조회 성공 응답 body 구조가 없다.
- Image 업로드/조회/수정/삭제 성공 응답 body 구조가 없다.
- `PUT /place/update/{code}`는 설명상 이미지 업로드가 있으나 content type이 `application/json;charset=UTF-8`이다. `multipart/form-data` 여부 확인이 필요하다.
- multipart 요청에서 JSON part를 어떤 content type으로 보내야 하는지 명시되어 있지 않다.
- Place create/update의 `name`, `address` required 여부와 validation rule이 없다.
- Plant create/update의 문자열 길이, 날짜 범위, nullable 정책이 없다.
- 에러 응답 body 구조와 code/message 필드명이 없다.
- 401/403/404 등 공통 에러 코드 체계가 일부 API에만 구체적으로 적혀 있다.
- refresh token 재발급 API가 Swagger에 없다.
- 로그아웃 API가 Swagger에 없다.
- pagination 응답 구조와 total count 제공 여부가 없다.
- 이미지 key 저장 주체와 이미지 업로드 후 반환되는 값의 구조가 없다.
- 서버 base URL은 Swagger server 기준 `/api/v1`만 있으므로 앱 flavor별 full base URL 정책은 별도 결정이 필요하다.

## 첫 API 연계 시 우선순위 제안

1. `core/network`에 Dio client, auth interceptor, 공통 exception 타입을 먼저 추가한다.
2. Auth 성공 응답 schema를 확인한 뒤 token 저장소와 `authStateProvider`를 연결한다.
3. Place 또는 Plant 중 화면 전환 흐름에 필요한 목록 조회 API부터 read-only로 연결한다.
4. multipart가 필요한 생성/수정 API는 JSON part content type과 응답 구조 확인 후 진행한다.
5. Swagger schema가 보강되기 전에는 임시 DTO를 넓게 만들지 않고, 확인된 필드만 최소 범위로 둔다.
