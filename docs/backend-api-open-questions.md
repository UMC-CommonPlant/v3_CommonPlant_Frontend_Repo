# 백엔드 API 확인 질문 목록

이 문서는 Swagger와 현재 프론트 API 계층을 비교하면서 남은 백엔드 확인 항목을 질문 단위로 분리한 목록이다. 답변이 오기 전까지 화면 동작, DTO 필드, 에러 메시지, 이미지 key/url 정책을 임의로 확정하지 않는다.

## 관리 기준

- 상태는 `Open`, `Answered`, `Blocked`, `Done` 중 하나로 관리한다.
- 백엔드 답변 또는 배포 기준과 일치하는 백엔드 Controller·DTO·Service 근거를 확인하면 `답변`과 `프론트 반영` 칸을 갱신한다.
- Swagger가 갱신되면 `docs/api-swagger-reference.md`의 최신 명세와 이 문서를 함께 갱신한다.
- 구현은 이 문서의 질문이 `Answered`가 된 뒤 별도 이슈에서 진행한다.

## 질문 요약

| ID | 영역 | 질문 | 현재 영향 | 상태 |
| --- | --- | --- | --- | --- |
| AUTH-01 | Auth | `POST /auth/register` request part의 실제 schema는 무엇인가? | #216 multipart datasource/repository 반영 완료 | Done |
| AUTH-02 | Auth | 회원가입은 이미지가 없어도 항상 multipart로 보내야 하는가? | #216 image optional 전송 기준 반영 완료 | Done |
| MULTIPART-01 | 공통 | multipart JSON part의 `Content-Type`은 `application/json`이 필수인가? | Auth/Place/Plant/User multipart 일관성 확인 필요 | Open |
| PLACE-01 | Place | Place 조회/생성/수정/삭제 성공 response body 구조는 무엇인가? | #239 목록·상세 반영, 생성·수정 결과 소비는 후속 | Answered |
| PLACE-02 | Place | `/place/myGarden`, `/place/user`, `/place/{code}`의 wrapper와 필드명은 무엇인가? | #239 목록·상세 mapper와 화면 반영 | Done |
| PLACE-03 | Place | `placeCode`, `placeId`, `code` 중 화면/요청에서 표준으로 쓸 식별자는 무엇인가? | API 경계는 `code`, 기존 route 모델명은 `id` 유지 | Answered |
| PLACE-04 | Place | `GET /place/{code}/members` 성공 response schema는 무엇인가? | 멤버 목록 계약 확인, 친구 관리 연결은 후속 | Answered |
| PLACE-05 | Place | owner가 아닌 구성원의 장소 나가기 endpoint는 무엇인가? | #239 API mode에서 member 나가기 action 숨김 | Blocked |
| FRIEND-01 | Friend | `GET /friends/requests` response schema는 무엇인가? | 요청 목록 수직 슬라이스 진행 가능 | Answered |
| FRIEND-02 | Friend | 친구 요청 전송/수락/거절 성공 response와 화면 갱신 정책은 무엇인가? | 성공 result 확인, invalidate 정책은 화면 작업에서 결정 | Answered |
| FRIEND-03 | Friend | `sendFriendReq.receiverName`은 display name인가, 고유 user id인가? | 표시 이름 사용 확인, 중복 이름 오매칭 위험은 백엔드 확인 필요 | Answered |
| FRIEND-04 | Friend | `friendDecisionReq.friendId`는 요청 id인가, 사용자 id인가? | 요청 PK 사용 확인, 수락·거절 연결 가능 | Answered |
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
| TESTENV-01 | 테스트 환경 | CI가 개인 소셜 계정 없이 매 run 인증을 발급받는 방법은 무엇인가? | authenticated probe와 UI E2E 보류 | Open |
| TESTENV-02 | 테스트 환경 | 테스트 token의 TTL, 갱신·재발급·폐기 정책은 무엇인가? | 장시간 run과 만료 복구 보류 | Open |
| TESTENV-03 | 테스트 환경 | backend 소유 fixture 사용자와 run별 데이터 격리 기준은 무엇인가? | 병렬 실행과 CRUD E2E 보류 | Open |
| TESTENV-04 | 테스트 환경 | 정상·실패 cleanup과 중단된 run의 TTL 정리 방법은 무엇인가? | dev 데이터 오염 방지 불가 | Open |
| TESTENV-05 | 테스트 환경 | CI 접근 권한, rate limit, 허용 실행 범위는 무엇인가? | GitHub Environment와 재시도 정책 보류 | Open |
| ENV-01-A | 환경 | dev backend와 Swagger endpoint는 무엇인가? | 로컬 remote API URL 확정 | Answered |
| ENV-01-B | 환경 | 백엔드 staging/prod full base URL과 API versioning 정책은 무엇인가? | 배포 환경값 주입 검증 필요 | Open |

## Auth

### AUTH-01. `POST /auth/register` request part의 실제 schema

- 현재 근거: 2026-08-23 dev Swagger에서 `RegisterMultipartRequest.register`가 `RegisterRequest`를 참조하고 request/response schema가 분리됐다.
- 프론트 영향: `signupToken`, `name` required와 optional `introduction` 기준으로 multipart JSON part를 만들 수 있다. `imgUrl`은 request JSON에 없고 `image` binary part가 optional이다.
- 확인 질문: 해결됨.
- 프론트 반영: #216에서 `register` JSON part와 optional `image` part를 보내도록 datasource/repository를 전환하고 request JSON의 `imgUrl`을 제거했다.
- 답변: `register`는 `RegisterRequest(signupToken, name, introduction)`이고 `image`는 별도 optional binary part이다.
- 상태: Done

### AUTH-02. 회원가입 multipart 전송 정책

- 현재 근거: 2026-08-23 dev Swagger는 request content type을 `multipart/form-data` 하나로 정의하고 `register`를 required, `image`를 optional로 명시한다.
- 프론트 영향: 이미지 유무와 관계없이 `register` JSON part를 포함한 multipart로 전송해야 한다.
- 확인 질문: 해결됨.
- 프론트 반영: #216에서 `FormData` 기반으로 바꾸고 image가 있을 때만 binary part를 추가했다. 실제 파일 생성과 화면 submit 연결은 별도 UI 작업이다.
- 답변: 이미지가 없어도 multipart이며 `image` part만 생략한다.
- 상태: Done

## 공통 Multipart

### MULTIPART-01. JSON part `Content-Type` 정책

- 현재 근거: dev Swagger encoding은 Auth `register`, User `user`, Plant `plant` JSON part에 `application/json`을 명시한다. Place create/update의 `place` part에는 encoding이 없다.
- 프론트 영향: Auth/User/Plant는 명세대로 전송할 수 있지만 Place multipart parser 요구사항은 여전히 확인이 필요하다.
- 확인 질문: Place `place` JSON part에도 `Content-Type: application/json`이 필수인가?
- 프론트 반영: Auth/User/Plant는 명시된 content type을 유지하고 Place는 답변 전까지 현재 호환 경계를 바꾸지 않는다.
- 답변: Auth/User/Plant는 `application/json`; Place는 미확인.
- 상태: Open

## Place

### PLACE-01. Place 성공 response body 구조

- 현재 근거: 2026-08-25 dev Swagger의 machine-readable schema는 여전히 없지만, 백엔드 `7d572cb`의 `PlaceController`와 `PlaceDto`가 각 성공 응답을 `JsonResponse.result`로 반환한다.
- 프론트 영향: 조회 mapper를 실제 필드로 좁힐 수 있고 생성 code, 수정 결과, 삭제 null 계약을 구분할 수 있다.
- 확인 질문: 해결됨. 단, dev 배포와 백엔드 main commit의 동기화는 실제 인증 smoke 전까지 별도 검증한다.
- 프론트 반영: #239에서 목록·상세 응답을 실제 도메인 모델로 연결했다. 생성 code와 수정 결과 소비는 친구 추가·수정 후속 이슈에서 연결한다.
- 답변: 생성은 place code 문자열, 상세는 `getPlaceRes`, 수정은 `updatePlaceRes`, 삭제는 null이며 모두 공통 `JsonResponse.result`에 담긴다.
- 상태: Answered

### PLACE-02. Place 목록/상세 필드명

- 현재 근거: 백엔드 `PlaceDto`에서 `getMainPage`, `getPlaceListRes`, `getPlaceBelongUser`, `getPlaceRes` 필드를 확인했다.
- 프론트 영향: Home 장소 목록과 장소 상세가 fixture 없이 서버 필드를 사용할 수 있다.
- 확인 질문: 해결됨.
- 프론트 반영: #239에서 `result.placeList`와 `result.userList`, `result.plantList`, `owner`를 목록·상세 mapper와 화면 상태에 반영했다.
- 답변: myGarden은 `{ name, placeList[] }`, user는 장소 배열, 상세는 `{ name, code, address, imgUrl, owner, userList[], plantList[] }`이다.
- 상태: Done

### PLACE-03. Place 식별자 명칭

- 현재 근거: 백엔드 Place DTO와 모든 Place path parameter는 문자열 `code`를 사용하고 Plant 요청은 `placeCode`로 같은 값을 전달한다.
- 프론트 영향: API 경계에서는 정수 Place ID를 만들지 않고 code 문자열을 보존해야 한다.
- 확인 질문: 해결됨.
- 프론트 반영: #239의 `PlaceDetail.code`와 `PlaceSummary.id`는 서버 code 문자열을 저장한다. 기존 route의 `placeId` 이름 변경은 별도 routing 정리 범위로 남긴다.
- 답변: Place의 외부 식별자는 code 문자열이며 요청 JSON에서는 `placeCode`, Place path에서는 `code`로 표현한다.
- 상태: Answered

### PLACE-04. 장소 멤버 목록 response schema

- 현재 근거: 백엔드 Controller는 `List<PlaceDto.getPlaceResUser>`를 `JsonResponse.result`로 반환한다.
- 프론트 영향: 이름과 프로필 이미지는 연결할 수 있지만 member id, 역할, 가입일은 응답에 없어 삭제·권한 UI에 사용할 수 없다.
- 확인 질문: 부분 해결됨. 멤버 변경 endpoint와 고유 member id가 필요하면 백엔드 확장이 필요하다.
- 프론트 반영: #239 상세 화면은 `/place/{code}`에 포함된 동일 멤버 타입을 표시한다. 친구 관리 화면의 조회·변경은 후속 이슈로 남긴다.
- 답변: 멤버 항목은 `{ name, image }`이며 가입 순서 배열이다.
- 상태: Answered

### PLACE-05. 구성원 장소 나가기 endpoint

- 현재 근거: 백엔드 `PlaceServiceImpl.deletePlace`는 owner만 허용하고 장소와 식물·메모·Belong을 모두 삭제한다. 구성원 leave endpoint는 Controller에 없다.
- 프론트 영향: owner 전체 삭제와 구성원 나가기를 같은 action으로 호출하면 구성원은 403이 발생하고 owner는 파괴 범위를 오해할 수 있다.
- 확인 질문: owner가 아닌 구성원이 Belong만 제거하고 장소에서 나가는 endpoint가 제공되는가?
- 프론트 반영: #239 API 모드는 owner에게만 전체 삭제 action과 경고를 표시하고 구성원 나가기는 숨긴다.
- 답변: 현재 제공 endpoint 없음.
- 상태: Blocked

## Friend

### FRIEND-01. 친구 요청 목록 response schema

- 현재 근거: 백엔드 `7d572cb`의 `FriendController`, `FriendDto`, `FriendServiceImpl`에서 목록 응답과 생성 로직을 확인했다.
- 프론트 영향: 장소 친구 요청 화면의 DTO와 loading/empty/error/success 상태를 확정할 수 있다.
- 확인 질문: 해결됨. 생성일은 응답에 포함되지 않는다.
- 프론트 반영: 별도 Friend 수직 슬라이스에서 요청 목록 Provider와 화면을 연결한다.
- 답변: `result.requests[]` 항목은 `friendId`, `senderName`, `senderImgUrl`, `placeCode`, `placeName`, `placeAddress`, `status`를 가진다.
- 상태: Answered

### FRIEND-02. 친구 요청 액션 성공 response와 갱신 정책

- 현재 근거: 백엔드 Controller에서 전송은 `sendFriendRes`, 수락·거절은 null을 `JsonResponse.result`로 반환한다.
- 프론트 영향: 수락·거절 성공은 HTTP 성공 후 해당 요청을 로컬 목록에서 제거하고 목록 Provider를 invalidate하는 정책으로 구현할 수 있다.
- 확인 질문: response 구조는 해결됨. 화면 갱신은 프론트 수직 슬라이스에서 optimistic remove 후 invalidate로 검증한다.
- 프론트 반영: 별도 Friend 수직 슬라이스에서 Controller와 목록 재조회 정책을 구현한다.
- 답변: 전송 result는 `{ placeCode, receiverList }`, 수락·거절 result는 null이다.
- 상태: Answered

### FRIEND-03. `receiverName` 의미

- 현재 근거: `FriendServiceImpl`은 `receiverName`의 각 문자열을 사용자 이름 검색에 넣고 첫 결과를 receiver로 사용한다.
- 프론트 영향: payload 타입은 확정됐지만 표시 이름이 중복되면 잘못된 사용자가 선택될 수 있어 신규 초대 전송을 안전하게 완료할 수 없다.
- 확인 질문: receiver를 고유 user id로 바꾸거나 exact unique name을 보장할지 백엔드 결정이 필요하다.
- 프론트 반영: 요청 DTO는 표시 이름 배열로 유지하되, 중복 이름 정책이 해결되기 전 실제 전송 화면 연결은 보류한다.
- 답변: 현재 구현은 사용자 표시 이름 배열이며 부분 검색 결과의 첫 사용자를 선택한다.
- 상태: Answered

### FRIEND-04. `friendId` 의미

- 현재 근거: `FriendServiceImpl`은 `findByFriendIdxAndReceiver(friendId, currentUserName)`로 요청을 찾는다.
- 프론트 영향: 요청 목록의 `friendId`를 그대로 수락·거절 payload에 넣을 수 있다.
- 확인 질문: 해결됨.
- 프론트 반영: 별도 Friend 수직 슬라이스의 요청 entity id와 action request에 반영한다.
- 답변: `friendId`는 친구 요청 테이블의 `friendIdx`, 즉 요청 PK이다.
- 상태: Answered

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

## 테스트 환경

TESTENV 질문의 상세 수용 조건과 단계별 도입 범위는 `docs/remote-integration-test-readiness.md`에서 관리한다. 실제 credential이나 secret 값은 이 문서의 답변에 기록하지 않는다.

### TESTENV-01. CI 인증 bootstrap

- 현재 근거: Swagger `POST /auth/login`은 Google/Kakao/Apple SDK token을 요구하며 test auth endpoint는 없다.
- 프론트 영향: 개인 계정이나 수동 복사 token 없이 authenticated probe를 반복 실행할 수 없다.
- 확인 질문: dev CI가 실행마다 기존 테스트 사용자의 짧은 수명 token을 얻을 수 있는 방식은 무엇인가?
- 프론트 반영: 답변 후 실제 값이 아닌 필요한 secret 종류와 workflow 호출 계약만 문서화한다.
- 답변: 미확인
- 상태: Open

### TESTENV-02. 테스트 token lifecycle

- 현재 근거: 로그인은 access/refresh token을 반환하지만 Swagger에는 refresh 재발급과 logout endpoint가 없다.
- 프론트 영향: token 만료가 앱 실패인지 환경 실패인지 구분할 수 없고 장기 고정 token은 재현성이 없다.
- 확인 질문: 테스트 token의 TTL, 갱신 또는 재발급, 폐기 방법과 관련 오류 코드는 무엇인가?
- 프론트 반영: 답변 후 probe timeout, 만료 판정, 재시도 금지 범위를 정한다.
- 답변: 미확인
- 상태: Open

### TESTENV-03. Fixture와 run별 데이터 격리

- 현재 근거: 19개 OpenAPI path에 seed/fixture 전용 endpoint가 없고 일부 CRUD endpoint만 있다.
- 프론트 영향: 공유 사용자와 장소를 수정하면 병렬 run이 충돌하고 실제 dev 데이터를 오염시킬 수 있다.
- 확인 질문: backend 소유 테스트 사용자, 초기 fixture 범위, run별 소유권 또는 격리 key는 어떻게 제공하는가?
- 프론트 반영: 답변 후 첫 단계는 공유 fixture의 `GET /users` read-only probe로 제한하고 mutation 범위를 별도 확정한다.
- 답변: 미확인
- 상태: Open

### TESTENV-04. Cleanup과 TTL fallback

- 현재 근거: public API 일부에는 delete가 있지만 runner 강제 종료 시 cleanup 실행을 보장할 수 없고 전용 정리 API가 없다.
- 프론트 영향: 실패 run이 남긴 Place, Plant, Image, Friend 데이터를 안전하게 식별·삭제할 수 없다.
- 확인 질문: 정상·실패 cleanup 순서와 실행이 중단된 fixture를 정리할 TTL 또는 관리자 수단은 무엇인가?
- 프론트 반영: 답변 후 `always` cleanup과 cleanup 실패 판정을 workflow에 반영한다.
- 답변: 미확인
- 상태: Open

### TESTENV-05. CI 접근과 실행 제한

- 현재 근거: dev Swagger는 공개 접근 가능하지만 authenticated test의 runner IP, rate limit, 허용 시간과 동시 실행 정책은 명시되지 않았다.
- 프론트 영향: 일시적 429/5xx와 앱 회귀의 구분, concurrency와 재시도 범위를 정할 수 없다.
- 확인 질문: GitHub-hosted runner 접근 허용 여부, rate limit, 허용 동시 실행 수, 점검 시간대 정책은 무엇인가?
- 프론트 반영: 답변 후 GitHub Environment, 직렬/병렬 실행, 외부 장애 재시도 정책을 별도 이슈에서 적용한다.
- 답변: 미확인
- 상태: Open

## 환경

### ENV-01-A. dev backend와 Swagger endpoint

- 현재 근거: 2026-08-23 dev Swagger config와 OpenAPI JSON의 `servers` 값을 직접 확인했다.
- 프론트 영향: 로컬 remote API mode에서 full base URL을 명시적으로 주입할 수 있다.
- 확인 질문: 해결됨.
- 프론트 반영: 문서와 로컬 실행 명령에 dev base URL을 반영한다. 코드 기본 URL 변경은 별도 구현 범위로 둔다.
- 답변:
  - origin: `https://commonplant-dev.okbear.dev`
  - API base URL: `https://commonplant-dev.okbear.dev/api/v1`
  - Swagger UI: `https://commonplant-dev.okbear.dev/api/v1/swagger-ui/index.html#`
  - OpenAPI JSON: `https://commonplant-dev.okbear.dev/api/v1/api-docs/json`
  - Swagger config: `https://commonplant-dev.okbear.dev/api/v1/api-docs/json/swagger-config`
- 상태: Answered

### ENV-01-B. staging/prod 환경 URL과 API versioning

- 현재 근거: dev는 `/api/v1`로 확인됐지만 staging/prod endpoint는 제공되지 않았다.
- 프론트 영향: staging/prod 배포 검증에서 실제 full base URL이 필요하다.
- 확인 질문: staging/prod full base URL과 API versioning 정책은 무엇인가?
- 프론트 반영: 답변 후 CI/CD 환경값과 release 체크리스트를 갱신한다.
- 답변: 미확인
- 상태: Open
