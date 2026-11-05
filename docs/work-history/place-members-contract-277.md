# 장소 멤버 고유 ID·역할 조회 계약 반영 #277

2026-11-05에 [개발 OpenAPI](https://commonplant-dev.okbear.dev/api/v1/api-docs/json)와
백엔드 `develop`의 `03ece0e466f2f47f72263085f3bfa737b3e1a53c`를 대조했다.
기존 #245의 조회·검색 흐름에 새 멤버 식별자와 팀짱 여부를 연결한다.

## 확인한 API 계약

- `GET /place/{code}/members`는 `JsonResponse.result` 배열을 반환한다.
- 멤버 항목은 `nanoId: String`, `name: String`, `image: String?`,
  `owner: boolean`이다. `owner`는 사용자별 팀짱 여부다.
- [멤버 DTO](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/blob/03ece0e466f2f47f72263085f3bfa737b3e1a53c/src/main/java/com/commonplant/garden/place/dto/PlaceDto.java#L97)와
  [조회 구현](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/blob/03ece0e466f2f47f72263085f3bfa737b3e1a53c/src/main/java/com/commonplant/garden/place/service/PlaceServiceImpl.java#L114)을
  근거로 필드명과 타입을 확인했다. OpenAPI 성공 예시는 아직 이전 `name`·`image`만
  포함하며 성공 응답 schema가 없다.
- [장소 상세 조합](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/blob/03ece0e466f2f47f72263085f3bfa737b3e1a53c/src/main/java/com/commonplant/garden/place/facade/PlaceFacade.java#L31)의
  `userList`도 같은 멤버 DTO를 사용한다. 상세 조회는 이전 응답과의 호환을 위해
  새 두 필드의 부재를 허용하되 제공된 필드는 보존한다.

## 프런트 반영

- `PlaceMember`에 선택적 `nanoId`·`isOwner`를 보관한다. 멤버 목록 조회는
  공백이 아닌 실제 문자열 `nanoId`와 boolean `owner`를 필수로 검증한다.
- 누락·잘못된 타입·중복 ID는 전체 조회 실패로 처리한다. 숫자·boolean ID의
  문자열 변환, 이름 기반 대체, 항목 누락이나 중복 합치기를 사용하지 않는다.
- 친구 관리 Provider는 실제 `nanoId`를 화면 ID로 사용하고 `isOwner`를 전달한다.
  기존 `member-N` 임시 ID를 멤버 목록에서 제거했다. 도메인 override도 불완전한
  멤버를 임시 ID로 바꾸지 않고 실패한다.
- API가 `owner: true`로 확인한 멤버에게 `팀짱` 표시를 제공한다. 역할이 없는
  로컬 fixture·사용자 검색 결과에는 역할을 추측해 표시하지 않는다.
- 기존 로컬 선택·해제와 API 목록의 조회·검색·로딩·빈 목록·오류·재시도를 유지한다.
  팀짱 변경·장소 나가기 API 연결은 각각 별도 커밋과 기록으로 구분한다.

## 검증 범위

자동 검증에 다음 회귀 항목을 추가했다. 해당 10개 파일 format과 mapper·repository·
멤버 Provider·친구 관리 화면·세션 격리 테스트 55개가 통과했다. 전체 품질 검사는
나머지 API 연결 후 순차 실행한다.

- mapper: 실제 ID·역할·이미지·가입 순서·동명이인 보존, 필드 누락/타입 오류,
  중복 ID 및 일부만 잘못된 목록의 전체 실패, 상세의 이전/신규 멤버 필드.
- repository·Provider: 실제 ID·역할 전달, 불완전한 모델의 실패,
  fixture 비대체와 계정별 조회 fixture.
- widget: 팀짱 표시와 조회·검색·오류 재시도·휴대폰 크기·긴 이름 회귀.

공개 문서와 소스 확인은 인증된 실제 서버 응답이나 휴대폰 QA를 대신하지 않는다.
실제 계정으로 멤버 ID·역할 조회 및 앱 재진입을 검증한 결과는 아직 없다.
