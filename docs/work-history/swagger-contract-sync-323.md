# 배포 Swagger와 프론트 계약 동기화 #323

2026-11-15 dev OpenAPI 3.1.0이 HTTP 200으로 응답했다. 경로 22개와 동작 30개는 11월 5일 기록과 같다. 9월 기록의 19개 경로와 비교하면 토큰 갱신, 장소 팀짱 위임, 장소 탈퇴가 추가됐다. 세 동작과 멤버의 `nanoId`·`owner`는 프론트 `develop`의 #311·#277에 연결돼 있다.

[Dev OpenAPI](https://commonplant-dev.okbear.dev/api/v1/api-docs/json)와 [백엔드 develop 03ece0e](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/tree/03ece0e466f2f47f72263085f3bfa737b3e1a53c)를 대조했다. 이미지 API의 성공 본문은 OpenAPI에 없고, 아래 응답 구조는 `S3Controller`, `S3Response`, `GarageImageService`를 근거로 확인했다.

| 단계 | 완료 조건 | 검증 |
| --- | --- | --- |
| Garage 이미지 API | 조회는 `result.imageUrl`과 메타데이터를 반환한다. 업로드는 `result.images`, 교체는 `result`의 새 key를 보존한다. 다중 업로드는 1~5개의 `images` multipart part를 전송한다. | 모의 HTTP 응답과 multipart 회귀 테스트 |
| 프로필 수정 API | `user` JSON part는 `name`, `introduction`만 담는다. 이미지 파일은 선택 part `image`로 전달한다. | 요청 DTO와 기존 프로필·사진 폼 테스트 |
| 계약 문서 | 이미 반영된 API와 응답 근거, 보류된 연동과 검증 범위를 기록한다. | diff와 문서 링크 확인 |

실제 계정의 토큰 갱신, 장소 권한 변경, 이미지 업로드·저장·재조회는 전용 QA 계정과 격리한 데이터가 준비된 환경에서 검증한다.

| 후속 계약 | 확정 시 반영 위치 | 검증 |
| --- | --- | --- |
| 장소 대표 이미지 key 제공·조건부 수정 | 장소 상세 mapper·수정 폼 Controller | 파일 없이 수정할 때 이미지 보존, 동시 수정 충돌 |
| Memo CRUD, 식물 검색, 물주기 주기, 장소 좌표, Friend 고유 대상 및 결과 | 도메인별 datasource·repository·화면 Provider. [백엔드 질문 목록](../backend-api-open-questions.md) 참조 | endpoint와 샘플 응답을 확인한 뒤 해당 화면과 데이터 회귀 검증 |
