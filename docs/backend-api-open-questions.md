# 백엔드 API 확인 질문 목록

이 문서는 Swagger와 현재 프론트 API 계층을 비교하면서 남은 백엔드 확인 항목을 질문 단위로 분리한 목록이다. 답변이 오기 전까지 화면 동작, DTO 필드, 에러 메시지, 이미지 key/url 정책을 임의로 확정하지 않는다.

## 관리 기준

- 상태는 `Open`, `Answered`, `Blocked`, `Done` 중 하나로 관리한다.
- 백엔드 답변을 받으면 `답변`과 `프론트 반영` 칸을 갱신한다.
- Swagger가 갱신되면 `docs/api-swagger-reference.md`의 최신 명세와 이 문서를 함께 갱신한다.
- 구현은 이 문서의 질문이 `Answered`가 된 뒤 별도 이슈에서 진행한다.

## 질문 요약

| ID | 영역 | 질문 | 현재 영향 | 상태 |
| --- | --- | --- | --- | --- |
| AUTH-01 | Auth | `POST /auth/register` request part의 실제 schema는 무엇인가? | 프로필 설정 회원가입 API 연결 보류 | Open |
| AUTH-02 | Auth | 회원가입은 이미지가 없어도 항상 multipart로 보내야 하는가? | 회원가입 datasource 전송 방식 보류 | Open |
| MULTIPART-01 | 공통 | multipart JSON part의 `Content-Type`은 `application/json`이 필수인가? | Auth/Place/Plant/User multipart 일관성 확인 필요 | Open |
| PLACE-01 | Place | Place 조회/생성/수정/삭제 성공 response body 구조는 무엇인가? | Place mapper와 화면 성공 정책 제한 | Open |
| PLACE-02 | Place | `/place/myGarden`, `/place/user`, `/place/{code}`의 wrapper와 필드명은 무엇인가? | 장소 목록/상세 실데이터 신뢰도 제한 | Open |
| PLACE-03 | Place | `placeCode`, `placeId`, `code` 중 화면/요청에서 표준으로 쓸 식별자는 무엇인가? | route query와 API 요청 이름 혼재 가능성 | Open |
| FRIEND-01 | Friend | `GET /friends/requests` response schema는 무엇인가? | 장소 친구 요청 화면 API 연결 보류 | Open |
| FRIEND-02 | Friend | 친구 요청 전송/수락/거절 성공 response와 화면 갱신 정책은 무엇인가? | 친구 요청 액션 성공 처리 제한 | Open |
| FRIEND-03 | Friend | `sendFriendReq.receiverName`은 display name인가, 고유 user id인가? | 친구 추가 요청 payload 확정 불가 | Open |
| FRIEND-04 | Friend | `friendDecisionReq.friendId`는 요청 id인가, 사용자 id인가? | 수락/거절 payload 확정 불가 | Open |
| IMAGE-01 | Image | `/s3/images` upload/download/update/delete 성공 response schema는 무엇인가? | image key/url mapper 보류 | Open |
| IMAGE-02 | Image | 화면 이미지는 `/s3/images` 선업로드 방식인가, 도메인 multipart 직접 전송 방식인가? | 프로필/장소/식물/메모 이미지 흐름 확정 불가 | Open |
| IMAGE-03 | Image | presigned download URL 응답 필드와 wrapper 구조는 무엇인가? | 네트워크 이미지 fallback 정책 보류 | Open |
| IMAGE-04 | Image | 이미지 key 저장, 교체, 삭제 책임은 어느 API가 갖는가? | 이미지 생명주기와 cleanup 정책 보류 | Open |
| ERROR-01 | Error | 에러 response body의 공통 `code`, `message` 필드명은 무엇인가? | 사용자 메시지 매핑 제한 | Open |
| ERROR-02 | Error | 도메인별 에러 코드 표준과 의미는 무엇인가? | `ApiException` mapping table 보류 | Open |
| TOKEN-01 | Token | refresh token 재발급 API가 제공되는가? | 인증 만료 복구 흐름 보류 | Open |
| TOKEN-02 | Token | 로그아웃 API와 서버 token invalidation 정책이 있는가? | 로그아웃/세션 종료 구현 보류 | Open |
| SEARCH-01 | 검색 | 주소 검색 API를 백엔드가 제공하는가? | 장소 등록 주소 검색 실데이터 보류 | Open |
| SEARCH-02 | 검색 | 식물 학명/추천 검색 API를 백엔드가 제공하는가? | 식물 등록 검색 실데이터 보류 | Open |
| SEARCH-03 | 검색 | `GET /users/{keyword}`는 부분 검색인가, exact 검색인가? | 친구 추가 검색 UX와 empty 정책 확인 필요 | Open |
| MEMO-01 | Memo | 메모 생성, 목록, 수정, 삭제 API 제공 계획은 무엇인가? | 메모 화면 실데이터 연결 보류 | Open |
| MEMO-02 | Memo | 메모 이미지 첨부는 어떤 API와 필드로 연결하는가? | 메모 사진 업로드 흐름 보류 | Open |
| MEMO-03 | Memo | 메모 목록 response의 작성자, 이미지, 작성일, pagination 구조는 무엇인가? | 메모 목록 mapper와 카드 상태 보류 | Open |
| ENV-01 | 환경 | 백엔드 staging/prod full base URL과 API versioning 정책은 무엇인가? | 배포 환경값 주입 검증 필요 | Open |

## Auth

### AUTH-01. `POST /auth/register` request part의 실제 schema

- 현재 근거: Swagger의 `RegisterMultipartRequest.register`가 `Register` schema를 참조하지만, `Register` fields는 `accessToken`, `refreshToken`, `newUser`이다.
- 프론트 영향: 현재 `RegisterRequest(signupToken, name, introduction, imgUrl)`와 충돌한다.
- 확인 질문: `register` JSON part의 실제 필드가 `signupToken`, `name`, `introduction`, `imgUrl`인지, 아니면 다른 schema가 있는지 확인한다.
- 프론트 반영: 답변 전까지 프로필 설정 화면에서 회원가입 API 전송 방식을 바꾸지 않는다.
- 답변: 미확인
- 상태: Open

### AUTH-02. 회원가입 multipart 전송 정책

- 현재 근거: Swagger는 `multipart/form-data`와 optional `image` part를 명시한다.
- 프론트 영향: 이미지가 없는 회원가입도 multipart로 보내야 하는지, JSON body fallback이 가능한지 불명확하다.
- 확인 질문: 이미지가 없을 때도 `register` part만 포함한 multipart로 전송해야 하는가?
- 프론트 반영: 답변 전까지 `AuthRemoteDataSource.register`의 기존 JSON body를 임의 변경하지 않는다.
- 답변: 미확인
- 상태: Open

## 공통 Multipart

### MULTIPART-01. JSON part `Content-Type` 정책

- 현재 근거: User/Place/Plant datasource는 JSON part를 `application/json`으로 전송하도록 구성되어 있다.
- 프론트 영향: 백엔드 multipart parser가 part별 content type을 요구하는지에 따라 Auth/Place/Plant/User 전송 안정성이 달라진다.
- 확인 질문: `user`, `place`, `plant`, `register` JSON part에는 `Content-Type: application/json`이 필수인가?
- 프론트 반영: 필수라면 모든 multipart JSON part에 동일 정책을 유지하고, 아니라면 호환 범위를 문서화한다.
- 답변: 미확인
- 상태: Open

## Place

### PLACE-01. Place 성공 response body 구조

- 현재 근거: Swagger의 Place 조회/생성/수정/삭제 성공 response body schema가 없다.
- 프론트 영향: create/update/delete는 `void` 경계로만 처리하고, 조회 mapper는 넓은 fallback에 의존한다.
- 확인 질문: 각 API의 성공 response wrapper와 `result` 구조는 무엇인가?
- 프론트 반영: schema가 확정되면 `PlaceSummary` mapper와 화면 success/empty 정책을 좁힌다.
- 답변: 미확인
- 상태: Open

### PLACE-02. Place 목록/상세 필드명

- 현재 근거: `/place/myGarden`, `/place/user`, `/place/{code}`의 list/object wrapper와 필드명이 명시되지 않았다.
- 프론트 영향: 장소 목록, 식물 등록 장소 선택, 장소 상세의 실데이터 표시가 제한된다.
- 확인 질문: 장소 id/code, 이름, 주소, 대표 이미지, 멤버/역할 정보의 정확한 필드명은 무엇인가?
- 프론트 반영: 답변 후 repository mapper와 상태 UI를 보강한다.
- 답변: 미확인
- 상태: Open

### PLACE-03. Place 식별자 명칭

- 현재 근거: Swagger와 기존 코드에서 `placeCode`, `placeId`, `code`가 함께 등장한다.
- 프론트 영향: route parameter, query parameter, request DTO 이름이 섞일 수 있다.
- 확인 질문: 프론트가 저장하고 전달해야 하는 표준 식별자는 `placeCode`인가, `placeId`인가?
- 프론트 반영: 표준이 확정되면 route helper, provider key, request DTO naming을 정리한다.
- 답변: 미확인
- 상태: Open

## Friend

### FRIEND-01. 친구 요청 목록 response schema

- 현재 근거: `GET /friends/requests`는 Swagger summary와 response schema가 없다.
- 프론트 영향: 장소 친구 요청 화면을 raw response 없이 연결할 수 없다.
- 확인 질문: 요청 id, 요청자, 대상 장소, 상태, 생성일, 프로필 이미지 필드가 포함되는가?
- 프론트 반영: 답변 후 초대 요청 목록 Provider와 empty/error/success UI를 연결한다.
- 답변: 미확인
- 상태: Open

### FRIEND-02. 친구 요청 액션 성공 response와 갱신 정책

- 현재 근거: `POST /friends/request`, `/friends/accept`, `/friends/decline` 성공 response 설명은 `OK`뿐이다.
- 프론트 영향: 액션 후 snackbar, 목록 remove, 재조회 중 어떤 정책을 적용할지 확정할 수 없다.
- 확인 질문: 성공 시 body가 있는가? 없다면 액션 후 목록 재조회가 권장되는가?
- 프론트 반영: 답변 후 액션 Controller와 목록 invalidate 정책을 확정한다.
- 답변: 미확인
- 상태: Open

### FRIEND-03. `receiverName` 의미

- 현재 근거: `sendFriendReq.receiverName`은 string array로만 명시되어 있다.
- 프론트 영향: 사용자 검색 결과의 display name을 보낼지, user id를 보낼지 불명확하다.
- 확인 질문: `receiverName`은 사용자 표시 이름 배열인가, 고유 user id 배열인가? 중복 이름은 어떻게 처리하는가?
- 프론트 반영: 답변 후 친구 추가 선택 모델과 request DTO를 조정한다.
- 답변: 미확인
- 상태: Open

### FRIEND-04. `friendId` 의미

- 현재 근거: `friendDecisionReq.friendId`는 int64로만 명시되어 있다.
- 프론트 영향: 수락/거절 payload에 요청 id를 넣어야 하는지 사용자 id를 넣어야 하는지 알 수 없다.
- 확인 질문: `friendId`는 친구 요청 id인가, 요청자 user id인가, 친구 관계 id인가?
- 프론트 반영: 답변 후 초대 요청 entity의 id 필드를 확정한다.
- 답변: 미확인
- 상태: Open

## Image

### IMAGE-01. `/s3/images` 성공 response schema

- 현재 근거: Image upload/download/update/delete 모두 성공 response body schema가 없다.
- 프론트 영향: upload 결과에서 image key/url을 읽는 mapper를 만들 수 없다.
- 확인 질문: 각 API의 성공 response wrapper와 `result` 필드는 무엇인가?
- 프론트 반영: 답변 전까지 ImageRepository는 raw 또는 void 경계를 유지한다.
- 답변: 미확인
- 상태: Open

### IMAGE-02. 화면 이미지 업로드 흐름

- 현재 근거: User/Place/Plant API는 optional `image` multipart part가 있고, 별도 `/s3/images` API도 존재한다.
- 프론트 영향: 화면에서 먼저 `/s3/images`를 호출해야 하는지, 도메인 API에 파일을 직접 넣어야 하는지 불명확하다.
- 확인 질문: 프로필, 장소, 식물, 메모 각각의 권장 이미지 업로드 흐름은 무엇인가?
- 프론트 반영: 답변 후 이미지 선택 Controller와 도메인 제출 흐름을 연결한다.
- 답변: 미확인
- 상태: Open

### IMAGE-03. Presigned download URL 응답

- 현재 근거: `GET /s3/images?key=...`는 URL 조회 API로 설명되지만 schema가 없다.
- 프론트 영향: 네트워크 이미지 fallback과 캐싱 정책을 정할 수 없다.
- 확인 질문: 응답은 문자열인가, `{ url }`, `{ imageUrl }`, `{ downloadUrl }` 같은 object인가, 공통 wrapper `result` 안에 들어가는가?
- 프론트 반영: 답변 후 image key 기반 표시 helper를 추가한다.
- 답변: 미확인
- 상태: Open

### IMAGE-04. 이미지 key 생명주기

- 현재 근거: Place/Plant update request에는 `imageKey`가 있고, User update에는 `imgUrl`이 있다.
- 프론트 영향: 이미지 교체/삭제 시 기존 key cleanup과 도메인 데이터 저장 주체가 불명확하다.
- 확인 질문: 이미지 key 저장, 교체, 삭제는 도메인 API가 처리하는가, `/s3/images`를 별도로 호출해야 하는가?
- 프론트 반영: 답변 후 삭제/교체 UI의 API 호출 순서를 확정한다.
- 답변: 미확인
- 상태: Open

## Error

### ERROR-01. 공통 에러 response body

- 현재 근거: 성공 wrapper는 확인됐지만 에러 response body schema는 없다.
- 프론트 영향: `ApiException`이 사용자 메시지와 field error를 안정적으로 분리할 수 없다.
- 확인 질문: 에러 응답의 공통 필드는 `code`, `message`, `errors`, `fieldErrors` 중 무엇인가?
- 프론트 반영: 답변 후 `api_exception.dart`와 form-level/field-level 메시지 매핑을 보강한다.
- 답변: 미확인
- 상태: Open

### ERROR-02. 도메인별 에러 코드 표준

- 현재 근거: Auth/User 일부 코드만 Swagger에 보인다.
- 프론트 영향: Place/Plant/Friend/Image 에러를 raw 문자열 없이 안내하기 어렵다.
- 확인 질문: 도메인별 에러 코드와 사용자에게 보여줄 의미는 무엇인가?
- 프론트 반영: 답변 후 공통 에러 매핑표와 테스트를 추가한다.
- 답변: 미확인
- 상태: Open

## Token

### TOKEN-01. Refresh token 재발급 API

- 현재 근거: Swagger에 refresh token 재발급 API가 없다.
- 프론트 영향: access token 만료 시 자동 복구 흐름을 구현할 수 없다.
- 확인 질문: refresh token으로 access token을 재발급하는 endpoint, request, response는 무엇인가?
- 프론트 반영: 답변 후 auth interceptor와 token store 갱신 흐름을 추가한다.
- 답변: 미확인
- 상태: Open

### TOKEN-02. 로그아웃 API와 token invalidation

- 현재 근거: Swagger에 로그아웃 API가 없다.
- 프론트 영향: 로그아웃 시 로컬 토큰 삭제만 해야 하는지 서버 invalidate가 필요한지 불명확하다.
- 확인 질문: 로그아웃 endpoint가 제공되는가? refresh token 폐기 정책은 무엇인가?
- 프론트 반영: 답변 후 로그아웃 repository와 인증 상태 전환 정책을 확정한다.
- 답변: 미확인
- 상태: Open

## 검색

### SEARCH-01. 주소 검색 API 제공 여부

- 현재 근거: 장소 등록의 주소 검색 화면은 존재하지만 Swagger에 주소 검색 API가 없다.
- 프론트 영향: 현재 주소 검색은 로컬 후보 UI에 머문다.
- 확인 질문: 주소 검색은 백엔드 API로 제공되는가, 외부 SDK/API를 프론트가 직접 사용해야 하는가?
- 프론트 반영: 답변 후 address search datasource 또는 외부 adapter를 설계한다.
- 답변: 미확인
- 상태: Open

### SEARCH-02. 식물 학명/추천 검색 API 제공 여부

- 현재 근거: 식물 등록 검색 화면은 존재하지만 Swagger에 식물 검색 API가 없다.
- 프론트 영향: 식물 검색은 로컬 후보 UI에 머문다.
- 확인 질문: 식물 이름, 국문 학명, 영문 학명 검색 endpoint와 response fields는 무엇인가?
- 프론트 반영: 답변 후 plant search provider와 empty/error/loading UI를 API mode로 연결한다.
- 답변: 미확인
- 상태: Open

### SEARCH-03. 사용자 검색 매칭 정책

- 현재 근거: `GET /users/{keyword}`는 schema가 있지만 검색 매칭 방식은 명시되지 않았다.
- 프론트 영향: 친구 추가 화면의 debounce, empty text, 중복 이름 처리 정책이 모호하다.
- 확인 질문: keyword는 부분 검색인가, exact 검색인가? 자기 자신과 이미 초대된 사용자는 포함되는가?
- 프론트 반영: 답변 후 친구 추가 UX와 필터링 정책을 조정한다.
- 답변: 미확인
- 상태: Open

## Memo

### MEMO-01. Memo API 제공 계획

- 현재 근거: Swagger에 메모 생성, 목록, 수정, 삭제 API가 없다.
- 프론트 영향: 메모 화면은 로컬 상태만 사용할 수 있다.
- 확인 질문: 메모 CRUD endpoint, request, response, 권한 정책은 어떻게 제공되는가?
- 프론트 반영: 답변 후 memo data/repository/provider 계층을 추가한다.
- 답변: 미확인
- 상태: Open

### MEMO-02. 메모 이미지 첨부 정책

- 현재 근거: 메모 작성 화면에는 사진 UI가 있으나 Memo API와 Image API 연결 방식이 없다.
- 프론트 영향: 메모 사진 업로드와 목록 표시를 확정할 수 없다.
- 확인 질문: 메모 이미지는 `/s3/images` key를 참조하는가, Memo API multipart part로 직접 받는가?
- 프론트 반영: 답변 후 메모 작성 Controller와 이미지 업로드 순서를 확정한다.
- 답변: 미확인
- 상태: Open

### MEMO-03. 메모 목록 response 구조

- 현재 근거: 메모 목록 화면은 작성자, 본문, 이미지, 삭제 액션을 표시한다.
- 프론트 영향: 메모 카드 mapper와 pagination 정책을 정할 수 없다.
- 확인 질문: 메모 id, 작성자, 작성일, 이미지 url/key, 권한, pagination 필드는 무엇인가?
- 프론트 반영: 답변 후 memo list provider와 삭제/수정 액션을 API mode로 연결한다.
- 답변: 미확인
- 상태: Open

## 환경

### ENV-01. 백엔드 환경 URL과 API versioning

- 현재 근거: Swagger server는 `/api/v1`만 제공하고, 프론트는 `COMMONPLANT_API_BASE_URL` 주입 전략을 문서화했다.
- 프론트 영향: staging/prod 배포 검증에서 실제 full base URL이 필요하다.
- 확인 질문: staging/prod full base URL과 API versioning 정책은 무엇인가?
- 프론트 반영: 답변 후 CI/CD 환경값과 release 체크리스트를 갱신한다.
- 답변: 미확인
- 상태: Open
