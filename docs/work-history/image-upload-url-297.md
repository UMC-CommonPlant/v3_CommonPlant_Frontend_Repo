# 발급 URL 기반 이미지 업로드 전환 #297

- 기준: frontend develop `9b6b4e3` (PR #296 병합), 브랜치 `feature/image-upload-url-297`
- 이슈: [#297](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/297), 상위 #74, 선행 #295
- 현재 상태: **백엔드 API 미구현 — 사용자 확인, 전송 코드 변경 미착수**

## 사용자 확정 방향

백엔드에 업로드용 URL을 요청하고, 응답받은 URL로 파일을 전송한 뒤 그 이미지 참조를 도메인 저장에 연결한다. #295의 직접 multipart 전송은 현행 코드 상태이며 최종 방향이 아니다. URL 조회와 URL 발급을 같은 API로 취급하지 않는다. 기존 파일 선택·미리보기·교체·취소와 휴대폰 우선 정책을 유지한다.

## 2026-09-08 확인 근거

- backend main: `f67ee6c9fb38ff33c69ebbdfa4e454d330eeb084`
- backend develop: `e0e8cada565e2e1c00a86d56da7ae3e6aa00b148`
- [dev OpenAPI](https://commonplant-dev.okbear.dev/api/v1/api-docs/json): Image 경로는 `/s3/images` GET/POST/PUT/DELETE이며 업로드용 URL 발급 경로는 없다.
- [S3Controller](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/blob/e0e8cada565e2e1c00a86d56da7ae3e6aa00b148/src/main/java/com/commonplant/garden/s3/controller/S3Controller.java): POST는 `images` multipart 파일 목록, PUT은 `image` 파일을 받는다. GET은 기존 key의 공개 조회 URL을 반환한다.
- [GarageImageService](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/blob/e0e8cada565e2e1c00a86d56da7ae3e6aa00b148/src/main/java/com/commonplant/garden/image/service/GarageImageService.java): 파일을 받아 서버의 `garageClient.putObject`로 저장한다. URL 발급 후 클라이언트 업로드 구현은 확인되지 않았다.
- [S3Response](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/blob/e0e8cada565e2e1c00a86d56da7ae3e6aa00b148/src/main/java/com/commonplant/garden/s3/dto/S3Response.java): `CompletedImages.images`와 `ImageInfo.key/placeId/contentType/sizeBytes/imageUrl`이 있다. 현재 upload는 `ImageInfo.from`으로 key를 반환하고 조회에서 공개 imageUrl을 채운다. 이 DTO를 업로드용 URL 응답으로 해석할 수 없다. live OpenAPI 성공 schema 누락은 별개다.
- Place/Plant 수정은 기존 key와 다른 key만 제출하면 `INVALID_IMAGE_KEY`로 거절한다. 새 업로드 key 연결을 위해 최종 도메인 저장 계약도 필요하다.
- 가입은 계정 생성 후 서버에서 파일을 올리는 현행 구조다. 가입 전 signupToken만 있는 사용자의 URL 발급 권한도 확인해야 한다.

## 구현에 필요한 계약

| 단계 | 필요한 정보 |
| --- | --- |
| 발급 | 서버 origin/path, HTTP 메서드, 인증 방식, 파일명·MIME·크기·용도 등 실제 요청 필드 |
| 발급 응답 | wrapper, 업로드 URL, key/ID, 필수 헤더 또는 form fields, 만료 표현 |
| 파일 전송 | PUT raw bytes인지 POST form인지, Content-Type 등 서명 조건, 성공 상태와 응답 |
| 도메인 연결 | 가입·프로필·장소·식물의 정확한 key/ID 필드와 사전 업로드 이미지 수락 조건 |
| 실패·수명 | URL 만료 재발급, 업로드 성공 후 저장 실패 재시도, 미사용 파일 정리와 기존 이미지 교체 시점 |

2026-09-08 사용자가 업로드용 URL 발급 API가 아직 없음을 확인했다. 발급 API와 도메인 이미지 연결 계약이 준비되면 이 이슈에서 전환을 재개한다. 공개 조회 URL로 PUT하거나 미확인 endpoint/필드를 만들지 않는다.

## 코드 변경 지점과 검증 계획

- `features/image/data`: 계약이 확인되면 기존 ImageRepository·datasource에 URL 발급/전송을 연결한다. 외부 저장소 요청에 앱 API bearer token이 자동 전달되지 않게 한다.
- 기존 Form Controller: 선택 파일 초안은 유지하고 업로드 성공 후 도메인 저장을 실행한다. 파일/계정/폼 수명이 바뀐 늦은 결과는 반영하지 않는다.
- Auth/User/Place/Plant 요청 DTO·repository: 계약에 명시된 이미지 참조 필드로 변경한다. 이미지 미선택 유지·삭제 의미를 추정하지 않는다.
- 테스트: 잘못된 발급 응답, 전송 실패·만료, 저장 실패·재시도, 중복 탭, 파일 교체·계정 변경, 인증 헤더 분리 및 기존 미리보기 회귀.
- 실제 계정과 업로드 URL을 쓰는 원격 검증은 아직 실행하지 않았다. 문서 변경만 수행했으므로 `git diff --check`로 검증하며 Flutter 테스트 통과를 새 전송 흐름 검증으로 표시하지 않는다.
