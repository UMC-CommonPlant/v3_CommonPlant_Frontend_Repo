# 백엔드 API 확인 질문 목록

이 문서는 Swagger와 현재 프론트 API 계층을 비교하면서 남은 백엔드 확인 항목을 질문 단위로 분리한 목록이다. 답변이 오기 전까지 화면 동작, DTO 필드, 에러 메시지, 이미지 key/url 정책을 임의로 확정하지 않는다.

## 관리 기준

- 상태는 `Open`, `Partial`, `Answered`, `Blocked`, `Done` 중 하나로 관리한다. `Partial`은 질문 범위의 일부만 확인된 경우다.
- 백엔드 답변 또는 배포 기준과 일치하는 백엔드 Controller·DTO·Service 근거를 확인하면 `답변`과 `프론트 반영` 칸을 갱신한다.
- Swagger가 갱신되면 `docs/api-swagger-reference.md`의 최신 명세와 이 문서를 함께 갱신한다.
- 구현은 이 문서의 질문이 `Answered`가 된 뒤 별도 이슈에서 진행한다.
- 일부 계약이 확인됐거나 사용자가 위험을 수용한 경우에는 확인된 범위와 남은 위험을 분리한다. 알려진 프론트 회귀 문제는 [개발 감사 체크리스트](development-audit-checklist.md)에서 추적하며 백엔드 질문으로만 남기지 않는다.

## 질문 요약

| ID | 영역 | 질문 | 현재 영향 | 상태 |
| --- | --- | --- | --- | --- |
| AUTH-01 | Auth | `POST /auth/register` request part의 실제 schema는 무엇인가? | #216 multipart datasource/repository 반영 완료 | Done |
| AUTH-02 | Auth | 회원가입은 이미지가 없어도 항상 multipart로 보내야 하는가? | #216 image optional 전송 기준 반영 완료 | Done |
| MULTIPART-01 | 공통 | multipart JSON part의 `Content-Type`은 `application/json`이 필수인가? | Auth/Place/Plant/User multipart 일관성 확인 필요 | Open |
| PLACE-01 | Place | Place 조회/생성/수정/삭제 성공 response body 구조는 무엇인가? | #239 목록·상세, #243 생성 code·수정 결과 반영 | Answered |
| PLACE-02 | Place | `/place/myGarden`, `/place/user`, `/place/{code}`의 wrapper와 필드명은 무엇인가? | #239 목록·상세 mapper와 화면 반영 | Done |
| PLACE-03 | Place | `placeCode`, `placeId`, `code` 중 화면/요청에서 표준으로 쓸 식별자는 무엇인가? | API 경계는 `code`, 기존 route 모델명은 `id` 유지 | Answered |
| PLACE-04 | Place | `GET /place/{code}/members` 성공 response schema는 무엇인가? | #245 친구 관리 조회 연결, 멤버 변경은 별도 계약 필요 | Answered |
| PLACE-05 | Place | owner가 아닌 구성원의 장소 나가기 endpoint는 무엇인가? | #239 숨김 유지, #277은 backend #150 답변 대기 | Blocked |
| PLACE-06 | Place | 멤버 고유 ID·역할과 owner의 제거·권한 변경 endpoint는 무엇인가? | #245 조회 전용 유지, #277 쓰기 연결 보류 | Blocked |
| PLANT-01 | Plant | 식물에서 소속 장소 code를 조회할 수 있는 계약을 제공하는가? | #273에서 기존 Place 목록·상세의 정확한 plant ID 대조로 code 복원 | Answered |
| FRIEND-01 | Friend | `GET /friends/requests` response schema는 무엇인가? | #241 요청 목록·Home 배지 연결 | Answered |
| FRIEND-02 | Friend | 친구 요청 전송/수락/거절 성공 response와 화면 갱신 정책은 무엇인가? | #241 수락·거절·갱신, #243 전송 연결 | Answered |
| FRIEND-03 | Friend | `sendFriendReq.receiverName`은 display name인가, 고유 user id인가? | #243에서 위험 수용 후 연결, 고유 ID 전환 필요 | Answered |
| FRIEND-04 | Friend | `friendDecisionReq.friendId`는 요청 id인가, 사용자 id인가? | 요청 PK 사용 확인, 수락·거절 연결 가능 | Answered |
| FRIEND-05 | Friend | 고유 대상 요청과 다중 대상 원자성·부분 결과 계약은 무엇인가? | #277 고유 ID payload·대상별 상태 연결 보류 | Blocked |
| IMAGE-01 | Image | `/s3/images` upload/download/update/delete 성공 response schema는 무엇인가? | image key/url mapper 보류 | Open |
| IMAGE-02 | Image | 화면 이미지는 `/s3/images` 선업로드 방식인가, 도메인 multipart 직접 전송 방식인가? | 프로필/장소/식물/메모 이미지 흐름 확정 불가 | Open |
| IMAGE-03 | Image | presigned download URL 응답 필드와 wrapper 구조는 무엇인가? | 네트워크 이미지 fallback 정책 보류 | Open |
| IMAGE-04 | Image | 이미지 key 저장, 교체, 삭제 책임은 어느 API가 갖는가? | #248 Plant key 보존·Place 사진 수정 차단 구현, Place key 조회·동시 수정 보호 계약 필요 | Partial |
| ERROR-01 | Error | 에러 response body의 공통 `code`, `message` 필드명은 무엇인가? | #275 표준 오류·field error 파싱 반영 | Answered |
| ERROR-02 | Error | 도메인별 에러 코드 표준과 의미는 무엇인가? | #275 HTTP 범주·확인 코드 매핑, 미확인 코드는 안전 fallback | Answered |
| TOKEN-01 | Token | refresh token 재발급 API가 제공되는가? | 백엔드 #149 전까지 자동 갱신 없이 인증 만료 시 로컬 세션 종료 | Blocked |
| TOKEN-02 | Token | 로그아웃 API와 서버 token invalidation 정책이 있는가? | 백엔드 #149 전까지 로컬 token·세션만 제거 | Blocked |
| SEARCH-01 | 검색 | 주소 검색 API를 백엔드가 제공하는가? | 장소 등록 주소 검색 실데이터 보류 | Open |
| SEARCH-02 | 검색 | 식물 학명/추천 검색 API를 백엔드가 제공하는가? | 백엔드 #92 대기, #273에서 API mode fixture 차단 | Blocked |
| SEARCH-03 | 검색 | `GET /users/{keyword}`는 부분 검색인가, exact 검색인가? | #277 친구 선택·중복 이름 UX, backend #150 답변 필요 | Open |
| MEMO-01 | Memo | 메모 생성, 목록, 수정, 삭제 API 제공 계획은 무엇인가? | backend #50 계약 답변·구현·OpenAPI 전 텍스트 CRUD 연결 보류 | Blocked |
| MEMO-02 | Memo | 메모 이미지 첨부는 어떤 API와 필드로 연결하는가? | 사용자 보류 범위, 텍스트 CRUD와 분리 | Blocked |
| MEMO-03 | Memo | 메모 목록 response의 작성자, 이미지, 작성일, pagination 구조는 무엇인가? | backend #50 계약 답변·OpenAPI schema 전 mapper 보류 | Blocked |
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
- 프론트 반영: #216에서 `FormData` 기반으로 바꾸고 image가 있을 때만 binary part를 추가했다. #227에서 화면 submit을 연결했으며 실제 이미지 파일 선택은 별도 UI 작업으로 남아 있다.
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

- 현재 근거: 2026-08-26 dev Swagger의 machine-readable schema는 여전히 없지만, 백엔드 `7d572cb`의 `PlaceController`와 `PlaceDto`가 각 성공 응답을 `JsonResponse.result`로 반환한다.
- 프론트 영향: 조회 mapper를 실제 필드로 좁힐 수 있고 생성 code, 수정 결과, 삭제 null 계약을 구분할 수 있다.
- 확인 질문: 해결됨. 단, dev 배포와 백엔드 main commit의 동기화는 실제 인증 smoke 전까지 별도 검증한다.
- 프론트 반영: #239에서 목록·상세 응답을 연결했고, #243에서 생성 code와
  수정 결과를 typed repository·Form 결과·친구 추가 route 문맥에 연결했다.
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
- 프론트 반영: #239 상세 화면은 `/place/{code}`에 포함된 동일 멤버 타입을 표시한다. #245는 2026-08-28 동일 source 계약을 재확인하고 친구 관리 조회·검색·이미지와 상태 UI를 연결했다. 변경 endpoint가 없어 API 모드의 추가·삭제는 제공하지 않는다.
- 답변: 멤버 항목은 `{ name, image }`이며 가입 순서 배열이다.
- 상태: Answered

### PLACE-05. 구성원 장소 나가기 endpoint

- 현재 근거: 백엔드 `PlaceServiceImpl.deletePlace`는 owner만 허용하고 장소와 식물·메모·Belong을 모두 삭제한다. 구성원 leave endpoint는 Controller에 없다.
- 프론트 영향: owner 전체 삭제와 구성원 나가기를 같은 action으로 호출하면 구성원은 403이 발생하고 owner는 파괴 범위를 오해할 수 있다.
- 확인 질문: owner가 아닌 구성원이 Belong만 제거하고 장소에서 나가는 endpoint가 제공되는가?
- 프론트 반영: #239 API 모드는 owner에게만 전체 삭제 action과 경고를 표시하고 구성원 나가기는 숨긴다.
- 답변: 현재 제공 endpoint 없음. 2026-08-31 backend [#150](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/150)에 self leave 계약을 요청했다.
- 상태: Blocked

### PLACE-06. 멤버 고유 식별자·역할과 owner 관리 endpoint

- 현재 근거: live OpenAPI의 `GET /place/{code}/members`에는 성공 schema가 없고 backend main `7d572cb`의 `getPlaceResUser`는 `name`, `image`만 제공한다. 멤버 제거·역할 변경 Controller도 없다.
- 프론트 영향: 가입 순서 기반 임시 화면 key는 렌더링에만 쓸 수 있고 특정 멤버의 삭제·권한 변경 payload에는 사용할 수 없다.
- 확인 질문: 멤버의 안정적인 user ID와 역할은 어떤 필드로 제공하는가? owner가 멤버를 제거하거나 역할을 위임·변경하는 endpoint, 권한·owner 보호·최소 인원·멱등 규칙은 무엇인가?
- 프론트 반영: #277은 [backend #150](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/150) 답변과 live OpenAPI schema 전까지 #245의 조회 전용 UI와 임시 key 비전송 경계를 유지한다.
- 답변: 미확인
- 상태: Blocked

## Plant

### PLANT-01. 식물에서 소속 장소 code 조회

- 현재 근거: 2026-08-31 [live OpenAPI](https://commonplant-dev.okbear.dev/api/v1/api-docs/json)의 `PUT /plants/{plantId}`는 query `placeCode`를 필수로 요구하지만 `PlantSummary`, `DetailResponse`, `EditInfoResponse`에는 code가 없다. 같은 명세의 `GET /place/user`는 실제 장소 code 목록을, `GET /place/{code}`는 `plantList[].plantId`를 제공한다. 백엔드 main `7d572cb`에도 Plant 응답의 direct code나 별도 조회 endpoint는 없다.
- 프론트 영향: direct field 없이도 사용자의 장소 상세를 순회하며 정확한 plant ID를 비교하면 Home 식물의 소속 code를 확인할 수 있다. 장소명 매칭·첫 장소 선택은 사용하지 않는다.
- 확인 질문: 현재 명세 안에서 지원 가능한 방법을 확인했다. Plant 응답의 direct `placeCode`는 향후 요청 수를 줄이는 최적화 계약으로 남는다.
- 프론트 반영: #273은 route code와 Plant 응답 code를 우선하고, 둘 다 없을 때만 Place 목록·상세로 code를 복원한다. resolver의 loading·오류·미발견·성공·재시도와 계정 전환을 상세 상태에서 검증했다. code를 끝내 찾지 못하면 #252의 수정·삭제 차단을 유지한다.
- 답변: 기존 Place API 조합으로 조회 가능하다. `GET /place/user`의 각 code에 대해 `GET /place/{code}`를 조회하고 `plantList[].plantId`를 정확히 대조한다.
- 상태: Answered

## Friend

### FRIEND-01. 친구 요청 목록 response schema

- 현재 근거: 백엔드 `7d572cb`의 `FriendController`, `FriendDto`, `FriendServiceImpl`에서 목록 응답과 생성 로직을 확인했다.
- 프론트 영향: 장소 친구 요청 화면의 DTO와 loading/empty/error/success 상태를 확정할 수 있다.
- 확인 질문: 해결됨. 생성일은 응답에 포함되지 않는다.
- 프론트 반영: #241에서 typed 요청 목록 Provider와 Home 요청 수,
  loading/empty/error/success 화면을 연결했다.
- 답변: `result.requests[]` 항목은 `friendId`, `senderName`, `senderImgUrl`, `placeCode`, `placeName`, `placeAddress`, `status`를 가진다.
- 상태: Answered

### FRIEND-02. 친구 요청 액션 성공 response와 갱신 정책

- 현재 근거: 백엔드 Controller에서 전송은 `sendFriendRes`, 수락·거절은 null을 `JsonResponse.result`로 반환한다.
- 프론트 영향: 수락·거절 성공은 HTTP 성공 후 해당 요청을 로컬 목록에서 제거하고 목록 Provider를 invalidate하는 정책으로 구현할 수 있다.
- 확인 질문: 해결됨. 원격 성공 항목을 화면에서 제거하고 목록 Provider를
  invalidate하는 정책을 #241에서 검증했다.
- 프론트 반영: #241에서 항목별 중복 submit 방지, 실패 복구, 수락·거절 후
  목록과 Home 요청 수 갱신을 구현했다.
- 답변: 전송 result는 `{ placeCode, receiverList }`, 수락·거절 result는 null이다.
- 상태: Answered

### FRIEND-03. `receiverName` 의미

- 현재 근거: `FriendServiceImpl`은 `receiverName`의 각 문자열을 사용자 이름 검색에 넣고 첫 결과를 receiver로 사용한다.
- 프론트 영향: payload 타입은 확정됐지만 표시 이름이 중복되면 화면에서 선택한 사용자와 다른 사용자가 초대될 수 있다.
- 확인 질문: receiver를 고유 user id로 바꾸거나 exact unique name을 보장할지 백엔드 결정이 필요하다.
- 프론트 반영: 사용자 결정에 따라 #243에서 표시 이름 배열 전송을 화면에 연결했다. 오초대·부분 성공 위험과 중단 조건은 `docs/accepted-implementation-risks.md`에서 추적한다.
- 답변: 현재 구현은 사용자 표시 이름 배열이며 부분 검색 결과의 첫 사용자를 선택한다.
- 상태: Answered

### FRIEND-04. `friendId` 의미

- 현재 근거: `FriendServiceImpl`은 `findByFriendIdxAndReceiver(friendId, currentUserName)`로 요청을 찾는다.
- 프론트 영향: 요청 목록의 `friendId`를 그대로 수락·거절 payload에 넣을 수 있다.
- 확인 질문: 해결됨.
- 프론트 반영: #241의 `FriendInvitation.id`와 수락·거절
  `FriendDecisionRequest.friendId`에 반영했다.
- 답변: `friendId`는 친구 요청 테이블의 `friendIdx`, 즉 요청 PK이다.
- 상태: Answered

### FRIEND-05. 고유 대상 요청과 다중 대상 결과

- 현재 근거: live OpenAPI와 backend main `7d572cb`의 `sendFriendReq`는 `receiverName[]`을 받는다. 서비스는 각 이름의 부분 검색 첫 결과를 검사한 뒤 별도 loop에서 요청을 저장하고, 응답은 입력 이름을 담은 `receiverList`뿐이다.
- 프론트 영향: 검색 결과의 고유 `UserResponse.id`를 선택 상태에 보존해도 요청 payload로 전달할 수 없다. 서버의 transaction 원자성·대상별 결과가 명세되지 않아 전체 성공·실패·부분 성공 UI를 결정할 수 없다.
- 확인 질문: 대상 payload를 고유 user ID로 바꾸는가? 여러 대상은 전체 원자성인가, 부분 성공인가? 부분 성공이면 ID별 성공·실패와 안전한 오류 code, 중복·재시도 멱등 규칙은 무엇인가?
- 프론트 반영: #277은 [backend #150](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/150) 답변 전 `receiverId` 같은 미확인 필드를 만들거나 `receiverList`를 대상별 성공으로 해석하지 않는다. #243의 사용자 승인 아래 수용한 현재 경계는 위험 등록부에서 계속 추적한다.
- 답변: 미확인
- 상태: Blocked

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

- 현재 근거: 2026-08-28 dev OpenAPI의 `updatePlaceReq.imageKey`와 `UpdateRequest.imageKey`, backend `7d572cb`의 `PlaceServiceImpl`·`PlantServiceImpl` 수정 로직을 대조했다. 자세한 근거는 [Swagger 참고](api-swagger-reference.md#image-화면-연결-판단)에 있다.
- 답변: Place/Plant 도메인 수정 API는 새 파일이 있으면 교체하고, 파일이 없으면 기존 key와 같은 값일 때 유지한다. key 생략/null은 기존 이미지 삭제를 뜻하며, 다른 key는 허용하지 않는다. 이는 독립 `/s3/images` 응답 계약이 확인됐다는 의미가 아니다.
- 프론트 영향: 이미지 선택기가 없어도 텍스트 수정 요청에서 기존 key를 잃으면 이미지가 삭제될 수 있다. Plant edit 응답은 key를 제공하지만 Place 상세에는 `imgUrl`만 있다.
- 확인 질문: Place의 기존 image key를 안전하게 조회하는 계약은 무엇인가? 조회 이후 다른 클라이언트가 사진을 변경한 경우의 조건부 수정·명시적 유지 동작은 어떻게 보장하는가? User·Memo와 독립 `/s3/images`의 생명주기 정책은 별도 확인이 필요하다.
- 프론트 반영: [#248](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/248)에서 Plant의 초기 key를 상태와 요청에 보존하고 URL만 있는 불완전 정보는 차단한다. Place는 기존 사진 URL을 폼까지 전달하고 사진이 있으면 수정 API를 호출하지 않는다. 사진 없는 장소·fixture 수정은 유지하며 URL에서 key를 추측하지 않는다. 원격 삭제 검증은 실행하지 않았다.
- 제한 해제: Place key 조회 또는 명시적 유지 계약 확인 후 별도 이슈에서 사진이 있는 장소 수정과 동시 수정 보호를 구현한다. [작업 이력](work-history/form-image-preservation-248.md)에 현재 제한과 검증을 기록했다.
- 상태: Partial

## Error

### ERROR-01. 공통 에러 response body

- 현재 근거: 2026-08-31 dev에서 token 없는 `GET /users`는 HTTP 401과 `status`, `code=A009`, `message`, `traceId`, `timestamp`를 반환했다. 잘못된 bearer token은 `A003`을 반환했다. backend main `7d572cb`의 `ErrorResponse`는 여기에 validation 전용 `errors[]`의 `field`, `value`, `reason`을 추가한다.
- 답변: 공통 오류 필드는 `traceId`, `status`, `code`, `message`, `timestamp`, 선택적 `errors[]`이다. 이 구조는 live OpenAPI schema에는 노출되지 않아 dev 응답과 backend source를 함께 근거로 사용한다.
- 프론트 반영: #275에서 `ApiException`이 공통 필드와 field error를 typed 값으로 파싱한다. `value`는 개인정보가 될 수 있어 읽거나 상태·로그에 보존하지 않는다. 화면은 서버의 top-level 상세 문구를 그대로 표시하지 않고 안전한 범주 메시지와 field `reason`만 사용한다.
- 남은 검증: 실제 인증 쓰기 요청의 validation 응답과 배포 source 일치 여부는 원격 E2E 보류 범위다.
- 상태: Answered

### ERROR-02. 도메인별 에러 코드 표준

- 현재 근거: backend main `7d572cb`의 `CommonErrorCode`, `AuthErrorCode`, `UserErrorCode`, `PlaceErrorCode`, `PlantErrorCode`, `FriendErrorCode`, `S3ErrorCode`에서 HTTP status·code·message를 확인했다. Auth의 `A006`은 signup token 오류와 사용자 미발견에 중복되어 code 단독 분기를 금지한다.
- 답변: HTTP 400/401/403/404/409/429/5xx와 전송 오류를 공통 범주로 사용한다. 검증 응답의 `errors[]`를 우선하고, field 목록 없이 반환되는 확인된 Place `P107~P109`와 Plant `P004`만 필드 안내로 보완한다.
- 프론트 반영: #275에서 미확인·중복 코드는 기능별 안전 fallback으로 처리하고 raw 서버 문구를 노출하지 않는다. 인증 세션 종료는 active access-token 요청의 `A003`, `A004`, `A009`에만 적용한다.
- 상태: Answered

## Token

### TOKEN-01. Refresh token 재발급 API

- 현재 근거: 2026-08-31 live OpenAPI 19 paths와 backend main Controller에 refresh token 재발급 endpoint가 없다. backend 내부에는 refresh token 저장·발급 코드가 있으나 호출 계약은 제공되지 않는다.
- 프론트 영향: access token 만료 시 자동 복구 흐름을 구현할 수 없다.
- 확인 질문: refresh token으로 access token을 재발급하는 endpoint, request, response는 무엇인가?
- 프론트 반영: #275는 `A003`, `A004`, `A009`를 받은 현재 access-token 세션을 한 번만 종료하고 로그인 화면에서 만료 이유를 안내한다. refresh 요청·원요청 재시도·동시 갱신은 구현하지 않는다.
- 답변: backend [#149](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/149)에 endpoint·rotation·오류 코드·single-flight 계약을 요청했다.
- 상태: Blocked

### TOKEN-02. 로그아웃 API와 token invalidation

- 현재 근거: 2026-08-31 live OpenAPI와 backend main Controller에 로그아웃 endpoint가 없다.
- 프론트 영향: 로그아웃 시 로컬 토큰 삭제만 해야 하는지 서버 invalidate가 필요한지 불명확하다.
- 확인 질문: 로그아웃 endpoint가 제공되는가? refresh token 폐기 정책은 무엇인가?
- 프론트 반영: 명시적 로그아웃과 #275 인증 만료는 사용자 데이터 세션과 인증 상태를 먼저 닫고 secure token을 로컬에서 삭제한다. 서버 폐기를 성공한 것처럼 표시하지 않는다.
- 답변: backend [#149](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/149)에 invalidation·다중 기기·TTL 정책을 함께 요청했다.
- 상태: Blocked

## 검색

### SEARCH-01. 주소 검색 API 제공 여부

- 현재 근거: 장소 등록의 주소 검색 화면은 존재하지만 Swagger에 주소 검색 API가 없다.
- 프론트 영향: 현재 주소 검색은 로컬 후보 UI에 머문다.
- 확인 질문: 주소 검색은 백엔드 API로 제공되는가, 외부 SDK/API를 프론트가 직접 사용해야 하는가?
- 프론트 반영: 답변 후 address search datasource 또는 외부 adapter를 설계한다.
- 답변: 미확인
- 상태: Open

### SEARCH-02. 식물 학명/추천 검색 API 제공 여부

- 현재 근거: 2026-08-31 live OpenAPI의 19개 path와 백엔드 main `7d572cb`에 식물 검색 endpoint·catalog가 없다. 백엔드 [#92](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/92)는 `Open / Backlog`이고 구현 PR이 없다.
- 프론트 영향: API 모드에서 로컬 fixture를 실제 검색 결과로 사용하면 존재하지 않는 식물을 등록할 수 있다.
- 확인 질문: 백엔드 #92에 endpoint/query, 안정 식별자, 표시 이름·국문/영문 학명, 매칭·정렬·pagination, empty/error schema를 요청했다.
- 프론트 반영: #273은 API 모드 검색·선택을 차단하고 미연결 안내를 표시한다. API 비사용 모드의 fixture 검색·empty·선택 흐름은 유지한다. 백엔드 #92가 완료되면 별도 이슈에서 datasource·repository와 loading/empty/error/success를 연결한다.
- 답변: 현재 제공되지 않는다.
- 상태: Blocked

### SEARCH-03. 사용자 검색 매칭 정책

- 현재 근거: `GET /users/{keyword}`는 schema가 있지만 검색 매칭 방식은 명시되지 않았다. backend main `7d572cb`는 `findByNameContainingAndStatus`로 부분 검색하나 정렬·exact 우선·중복 이름 정책은 없다.
- 프론트 영향: 친구 추가 화면의 debounce, empty text, 중복 이름 처리 정책이 모호하다.
- 확인 질문: keyword는 부분 검색인가, exact 검색인가? 자기 자신과 이미 초대된 사용자는 포함되는가?
- 프론트 반영: #277에서 backend #150 답변 후 친구 추가 UX와 고유 ID 요청 경계를 함께 조정한다.
- 답변: 미확인
- 상태: Open

## Memo

### MEMO-01. Memo API 제공 계획

- 현재 근거: 2026-09-01 live OpenAPI 19개 path에 Memo path/schema가 없고 backend main `7d572cb`에도 Memo 구현 파일이 없다. backend [#50](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/50)~#55는 모두 Open인 구현 계획이다.
- 프론트 영향: 계획의 `/plants/{plantUuid}/memos`를 배포 endpoint로 간주할 수 없다. 생성 #51과 validation #55의 content 최대 길이는 200/500자로 충돌하고 성공 wrapper·멱등·오류 계약도 없다.
- 확인 질문: plant 식별자, 장소 구성원/작성자 권한, 이미지 없는 생성 request part, 생성·수정 result, 삭제 status, validation·오류 code는 무엇인가?
- 프론트 반영: #283은 [backend #50 계약 확인](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/50#issuecomment-5488630254) 답변과 live OpenAPI 동기화 전까지 로컬 Memo 화면을 유지하고 data/repository/provider 계층을 추가하지 않는다.
- 답변: backend #50 답변 대기
- 상태: Blocked

### MEMO-02. 메모 이미지 첨부 정책

- 현재 근거: 메모 작성 화면에는 사진 UI가 있고 backend #51·#53 계획은 Memo multipart의 direct image part를 제안하지만 구현과 OpenAPI가 없다. #53은 image 생략 시 기존 이미지 삭제와 null field 미갱신을 함께 적어 동작이 충돌한다.
- 프론트 영향: 텍스트만 수정해도 기존 이미지를 잃을 수 있으므로 image 없는 update 정책 없이는 요청을 만들 수 없다.
- 확인 질문: image 생략은 유지인지 삭제인지, 교체·명시적 삭제 part와 실패 시 정리 책임은 무엇인가?
- 프론트 반영: 이미지 첨부는 사용자 보류 범위로 유지한다. 텍스트 CRUD는 image를 보내지 않아도 생성 가능하고 수정 시 기존 이미지를 보존한다는 계약만 선행 확인한다.
- 답변: backend #50 답변 대기, 이미지 UI 연결은 사용자 재개 결정 필요
- 상태: Blocked

### MEMO-03. 메모 목록 response 구조

- 현재 근거: backend #52 계획은 `memoIdx`, `content`, `imgUrl`, `createdAt`, `updatedAt`만 제안하고 pagination은 명시하지 않는다. 현재 화면은 작성자 이름·프로필과 수정·삭제 메뉴를 표시한다.
- 프론트 영향: 작성자 식별자·표시값·권한·목록 page 계약 없이 첫 항목, 표시 이름이나 임의 page wrapper로 mapper를 만들 수 없다.
- 확인 질문: 안정적인 memo/author ID, 작성자 이름·프로필, `canEdit`/`canDelete` 또는 권한 판단 기준, 날짜 timezone, 정렬, empty, page/cursor 구조는 무엇인가?
- 프론트 반영: backend #50 답변과 OpenAPI schema 뒤 memo list 상태와 mapper를 추가한다. 부분 항목을 버리거나 로컬 fixture와 병합하지 않는다.
- 답변: backend #50 답변 대기
- 상태: Blocked

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
