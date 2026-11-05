# 장소 탈퇴 API 연결 #277

2026-11-05 공개 OpenAPI와 backend `develop` `03ece0e`의
[Controller](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/blob/03ece0e466f2f47f72263085f3bfa737b3e1a53c/src/main/java/com/commonplant/garden/place/controller/PlaceController.java#L546)·
[탈퇴 구현](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/blob/03ece0e466f2f47f72263085f3bfa737b3e1a53c/src/main/java/com/commonplant/garden/place/service/PlaceServiceImpl.java#L216)을 대조했다.

## 계약과 사용자 동작

- 인증된 `DELETE /place/leave/{code}`, body·query 없음, 성공 200·result null.
  장소 없음은 404 `P101`, 멤버가 아니면 403 `P103`이다.
- 일반 멤버는 자신의 소속만 제거한다. 팀짱이면 가입 순서가 가장 빠른 다른 멤버에게
  서버가 자동 위임한다. 다른 멤버가 없으면 서버가 장소·식물·소속·장소 이미지를 삭제한다.
- 앱이 탈퇴 전에 별도 팀짱 위임 요청을 보내거나 다음 팀짱을 추측하지 않는다.
- API 모드의 일반 멤버에게 `장소 나가기`를 제공한다. 팀짱은 기존 `장소 삭제하기`와
  새 `장소 나가기`를 각각 선택한다. 모든 원격 나가기 확인창에는 자동 위임·혼자일 때 장소·식물 삭제를
  안내하고, 전체 삭제의 기존 경고·endpoint는 유지한다.
- `PlaceExitController.leave`가 탈퇴 endpoint를 호출하고 기존 `exit`는 전체 삭제를
  유지한다. 두 액션은 같은 제출 잠금을 사용한다. 실패 시 상세에 남아 안내하고 재시도하며
  성공할 때만 홈으로 이동한다. API 비사용 모드에서 원격 쓰기나 거짓 성공은 만들지 않는다.
- 확인창 전후와 요청 전후에 세션·화면 수명을 확인해 이전 계정의 확인·늦은 결과를 배제한다.
- 성공 후 장소 상세·요약·소유/소속 목록·멤버·식물 목록을 갱신한다. 이미 불러온 상세의
  식물은 해당 상세·편집 정보·장소 code 조회도 갱신해 탈퇴 전 접근 데이터를 재사용하지 않는다.
  캐시 갱신을 위해 새 상세 요청을 만들거나 관련 없는 장소를 일괄 갱신하지 않는다.

## 검증과 남은 범위

fake HTTP adapter·repository로 경로 인코딩·403/404·별도 endpoint 위임,
취소·실패·재시도·중복 제출·계정 전환·화면 폐기·관련 캐시 갱신과 홈 이동을 검증한다.
관련 data·Controller·화면 테스트 49개를 통과했고 상세 재조회 중 캐시 제거 회귀를 추가했다. 전체 품질 검사와 API별 커밋은 최종 검증 기록에 남긴다.

실제 계정으로 일반 멤버 탈퇴·팀짱 자동 위임·마지막 멤버 삭제와 서버 재조회·앱 재시작은
검증하지 않았다. 이 동작은 공개 명세·backend 소스 근거이며 실서버 QA 완료가 아니다.
Friend 고유 대상 요청·부분 결과 및 멤버 추가·제거는 미제공 계약으로 #277에 남긴다.
