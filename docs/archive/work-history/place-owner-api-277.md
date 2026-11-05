# 장소 팀짱 위임 API 연결 #277

2026-11-05 공개 OpenAPI와 backend `develop` `03ece0e`를 확인했다.
이 API는 [멤버 조회 계약](place-members-contract-277.md)의 실제 `nanoId`를 사용한다.

## 계약과 화면 연결

- `PUT /place/{code}/owner/{targetNanoId}`, 인증 필수, body·query 없음.
- 성공은 HTTP 200, `JsonResponse.result: null`이다.
- 현재 팀짱만 다른 현재 멤버에게 위임할 수 있다. 404 `P101`은 장소 없음,
  403 `P103`은 장소 멤버 아님, `P110`은 팀짱 아님, `P111`은 자기 자신 대상이다.
- [Controller](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/blob/03ece0e466f2f47f72263085f3bfa737b3e1a53c/src/main/java/com/commonplant/garden/place/controller/PlaceController.java#L574)와
  [Service](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/blob/03ece0e466f2f47f72263085f3bfa737b3e1a53c/src/main/java/com/commonplant/garden/place/service/PlaceServiceImpl.java#L246)를 근거로 한다.
- 친구 관리 화면에서 현재 사용자에게 팀짱 권한이 확인되면 비팀짱 멤버에만
  `팀짱 위임`을 제공한다. 확인창에 대상과 내 팀짱 권한이 사라지는 영향을 표시한다.
  멤버 추가·제거는 이 API의 역할이 아니므로 준비 중 안내를 유지한다.
- Controller가 제출 직전에 최신 상세 권한과 실제 멤버 목록을 확인한다. loading·error의
  이전 값, 팀짱·미확인 대상·fixture는 쓰기에 사용하지 않는다. 서버 권한 오류도 처리한다.
- 중복 제출을 차단하고 실패 시 재시도한다. 이전 계정·폐기된 화면의 늦은 완료는
  현재 상태·조회·이동에 반영하지 않는다.
- 확인창을 열 때의 세션·화면 수명도 검사한다. 확인 전에 계정이 바뀌거나 화면이
  폐기되면 남은 확인창으로 새 계정의 요청을 보내지 않는다.
- 성공 후 상세·장소 요약·멤버·myGarden·소속 장소 목록을 갱신한다. 낙관적으로
  역할을 바꾸지 않고 서버를 재조회하며 이후 조회 오류는 쓰기 실패로 바꾸지 않는다.
- 기존 팀짱의 장소 소속은 유지된다. 서버 `myGarden.placeList`는 소유 장소만 반환하므로
  위임 후 그 목록에서 빠지고 `/place/user` 소속 목록에는 남을 수 있다.

## 검증

자동 검증은 fake HTTP adapter·repository를 사용한다. 인코딩된 경로·빈 body·403/404,
실제 ID 전달·위임 대상/권한 재확인·중복 제출·실패 재시도·계정 전환/폐기 후 완료,
관련 조회 갱신과 확인창·휴대폰 화면의 액션 상태를 확인한다. 관련 data·Controller·
화면 테스트 52개 통과 후 확인 전 계정 전환·화면 폐기 회귀를 보강했고 화면 테스트
8개가 통과했다. 전체 format·analyze·test 결과는 최종 검증 기록에 남긴다.

실제 계정으로 위임·서버 재조회·앱 재시작을 검증하지 않았다. 공개 문서·소스 확인과
자동 테스트 성공을 실제 서버 저장 완료로 해석하지 않는다.
