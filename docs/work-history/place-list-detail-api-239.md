# Place 목록·상세 API 연결 이력

## 작업 기준

- 이슈: #239 `[Feature] 장소 목록·상세 API 실데이터 연결`
- 상위 이슈: #226 `[Epic] MVP 화면·API 실연동 전환`
- 작업일: 2026-08-25
- 브랜치: `feature/place-list-detail-api-239`
- 참고 문서:
  - `docs/screen-api-integration-plan.md`
  - `docs/api-swagger-reference.md`
  - `docs/backend-api-open-questions.md`
  - `docs/feature-development-guide.md`
  - `docs/state-management-guide.md`
  - `docs/screen-publishing-rules.md`
  - `docs/design-token-rules.md`
  - `docs/shared-widget-guide.md`
  - `docs/testing-guide.md`
  - `docs/git-workflow.md`

## API 계약 근거

- 2026-08-25 live OpenAPI는 19 paths, 27 operations이며 Place·Friend 성공 response schema가 여전히 노출되지 않았습니다.
- 백엔드 저장소 `UMC-CommonPlant/v3_CommonPlant_Backend_Repo` main `7d572cbcabc81a65926738b2a09e8479d0bd0c79`의 Controller·DTO·Service를 추가 근거로 사용했습니다.
- Place 목록은 `getMainPage.placeList`, 상세는 `getPlaceRes`, 멤버는 `getPlaceResUser`, 식물은 `PlantResponse.DetailResponse` 계약을 따릅니다.
- `DELETE /place/delete/{code}`는 owner 전용 전체 삭제이며 장소와 식물·메모·멤버 관계를 함께 정리합니다. 구성원 leave endpoint는 없습니다.

## 구현 범위

- `GET /place/myGarden`의 `result.placeList`에서 code, 이름, 이미지, 멤버 수, 식물 수를 파싱합니다.
- Home의 장소 카드는 응답 대표 이미지가 있으면 네트워크 이미지를 표시합니다.
- 장소 상세를 `PlaceDetail`, `PlaceMember`, `PlacePlant` 도메인 모델로 분리했습니다.
- API 모드는 owner 여부, 멤버 이름·이미지, 식물 학명·이미지·설명·마지막 물주기 날짜를 실제 응답에서 표시합니다.
- 서버가 제공하지 않는 햇빛·습도, 물주기 예정값, fixture 멤버·식물은 API 모드에서 표시하지 않습니다.
- 멤버와 식물이 비어 있는 상태, loading, error, retry를 기존 `AsyncValue` 흐름에서 유지합니다.
- owner는 API 모드에서만 장소 삭제 action과 전체 삭제 경고를 확인할 수 있고, 구성원에게는 동작하지 않는 나가기 action을 노출하지 않습니다.
- API 비사용 모드는 기존 fixture 화면과 장소 나가기 UI를 유지합니다.

## 보류 경계와 다음 후보

- 구성원 장소 나가기는 백엔드 leave endpoint가 없어 Blocked입니다.
- 장소 환경 수치와 물주기 action은 응답·endpoint가 없어 추가하지 않았습니다.
- 친구 관리의 멤버 고유 id와 변경 endpoint는 제공되지 않습니다.
- Friend source에서 요청 목록과 수락·거절 계약을 확인했으므로, 다음 수직 슬라이스 후보는 장소 친구 요청 목록·수락·거절입니다.
- 신규 친구 요청 전송은 백엔드가 표시 이름 부분 검색의 첫 사용자를 선택하므로 중복 이름 오매칭 정책이 해결될 때까지 보류합니다.

## 커밋과 검증

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| `893d201` | Place 목록·상세 도메인 모델, mapper, repository, Provider, remote UI와 테스트 | Place test 81개, analyze 통과 |
| `7ac4bc1` | owner 삭제와 member 나가기 권한·문구 분리 | 상세·FAB·삭제 Controller test 통과 |
| 이 문서 후속 커밋 | API 계약 문서, 우선순위, PR·Project 연결 이력 | format 286개, analyze, 전체 test 321개 통과·기존 golden 1개 skip |
