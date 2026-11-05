# Swagger 기준 이미지 직접 업로드 정정 #297

- 이슈: [#297](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/297), 상위 #74, 선행 #295
- 기존 URL 발급 방식 검토 기록은 PR #298에 있으며, 최신 사용자 설명과 Swagger에 따라 아래 내용으로 정정한다.

## 확정된 흐름

사용자가 말한 업로드 URL은 Swagger에 제공된 API 주소다. 별도 업로드용 URL 발급 요청이나 presigned URL 발급 대기 조건은 없다. 프런트가 해당 API에 파일을 직접 전송하고 서버가 저장한다. 기존 문서의 “URL 발급 API가 있어야 진행 가능” 판단은 잘못된 전제였으므로 철회한다.

## live Swagger 재확인

[dev Swagger](https://commonplant-dev.okbear.dev/api/v1/swagger-ui/index.html)와 [OpenAPI](https://commonplant-dev.okbear.dev/api/v1/api-docs/json)의 base path는 `/api/v1`이다.

| 목적 | 메서드·경로 | 전송 |
| --- | --- | --- |
| 독립 이미지 업로드 | `POST /s3/images` | multipart `images`, 1~5개 |
| 독립 이미지 교체 | `PUT /s3/images?key=...` | multipart `image` |
| 공개 조회 URL 확인 | `GET /s3/images?key=...` | 기존 key 조회. 업로드 URL 발급이 아님 |
| 가입 | `POST /auth/register` | JSON `register` + optional 파일 `image` |
| 회원 정보 수정 | `PUT /users` | JSON `user` + optional 파일 `image` |
| 식물 생성·수정 | `POST /plants`, `PUT /plants/{plantId}` | JSON `plant` + optional 파일 `image` |
| 장소 생성·수정 | `POST /place/create`, `PUT /place/update/{code}` | JSON `place` + optional 파일 `image` |

독립 업로드는 JPEG/PNG/WebP, 파일당 최대 10MB이며 Swagger가 레거시 범용 경로라고 설명한다. 현재 폼은 #295에서 연결한 도메인 multipart를 그대로 사용한다. 독립 선업로드 후 새 key를 도메인에 넣는 전환도 필요하지 않다.

기존 ImageRemoteDataSource도 위 독립 POST/PUT multipart 계약을 사용한다. 파일 선택·미리보기·교체와 기존 이미지 보존 가드는 유지한다. multipart boundary는 Dio가 생성하며 URL에 raw bytes를 임의로 PUT하지 않는다.

## 남아 있는 검증

URL 발급 API 미구현은 더 이상 차단 사유가 아니다. 실제 테스트 계정으로 선택 → 저장 → 서버 재조회 및 앱 재실행 확인은 #295에 남아 있다. 독립 Image API 성공 응답의 OpenAPI schema 누락, 장소 기존 key 조회 및 Memo 계약 문제는 별도이며 직접 multipart 업로드 전체를 막는 조건으로 취급하지 않는다.

문서 정정만 수행했다. `git diff --check`로 검증하고 새로운 업로드 코드나 실기기 검증을 완료했다고 표시하지 않는다.
