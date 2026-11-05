# 진행 중 작업 기록

후속 계약·실제 서버·실기기 검증 또는 다음 변경 지침을 계속 관리하는 기록 7개입니다.
완료된 구현과 미완료 검증을 구분하며, 이슈가 닫혔더라도 현재 후속 작업에 필요한 기록은 이곳에 유지합니다.
완료된 개별 구현·검증 기록은 [문서 아카이브](../archive/README.md)에서 확인합니다.

## 계속 확인할 기록

| 작업 | 기록 | 유지 이유 |
| --- | --- | --- |
| 스토어·배포 준비 #215 | [스토어 계정·배포 준비 재점검](store-readiness-215.md) | Play 소유자 인증·서명·앱/빌드 이력과 실제 배포 준비가 남아 있습니다. Apple 확인은 사용자 보류이며 Android 준비와 분리합니다. |
| 장소·Friend 쓰기 #277 | [업데이트된 장소 API 연결·검증 기록](place-api-update-277.md) | 멤버 조회·팀짱 위임·탈퇴 구현과 실제 서버 저장·재조회·실기기 QA를 구분합니다. Friend 고유 대상·부분 결과와 멤버 추가·제거 계약은 미제공입니다. |
| 소셜 로그인 #293 | [소셜 로그인 검증과 누락 보완](social-login-verification-293.md) | 실제 provider 설정·테스트 계정에 의한 신규 가입·재로그인·앱 재실행 QA가 남아 있습니다. Apple 확인은 사용자 보류를 유지합니다. |
| 사진 #295 | [폼 사진 선택·미리보기·교체](form-image-selection-295.md) | 도메인 multipart 구현과 실제 앨범 선택·서버 저장·재조회·앱 재실행 검증을 구분합니다. |
| 물주기 주기 #299 | [식물 생성·수정 물주기 주기](plant-watering-cycle-299.md) | 로컬 입력·메모리 보관과 원격 저장을 구분합니다. API 기본값·저장·조회 계약 확인과 DTO·mapper·repository 연결이 남아 있습니다. |
| 날씨 화면·연결 #306 | [장소 날씨 UI와 연결 경계](place-weather-ui-306.md) | 좌표 계약 확정 후 변경할 파일·모델·화면 검증 표와 실제 장소·기기·장애 재호출 QA를 유지합니다. |
| 날씨 조회 조건 #309 | [장소 좌표 없는 날씨 조회 차단](place-weather-unavailable-309.md) | 주소에 대응하는 확인된 좌표로만 조회하는 현행 기준과 좌표 생성·변경·소실 시 변경·검증 지침을 유지합니다. |

과거 기록의 수치와 계약은 해당 확인 시점에 적용됩니다. 자동 테스트 통과를 실제 서버·실기기 QA 완료로 계산하지 않습니다.
날씨의 판교역 기본 위치 정책과 이미지 업로드 URL 발급 API 대기는 철회된 과거 이력입니다.

## 현행 기준과 다음 작업

- [현행 문서 인덱스](../README.md): 작업별 가이드 진입점
- [화면·모델·API 실연동 전환 계획](../screen-api-integration-plan.md): 화면 연결 상태와 다음 실행 순서
- [API Swagger 연계 참고 문서](../api-swagger-reference.md): 확인된 endpoint·request·response 근거
- [백엔드 API 확인 질문 목록](../backend-api-open-questions.md): 미확정 계약과 프론트 반영 상태
- [후속 결정 체크리스트](../follow-up-decision-checklist.md): 미결정·사용자 보류 항목
- [구현 허용 위험 등록부](../accepted-implementation-risks.md): 수용 위험과 해소 조건
- [품질·테스트 후속 작업 계획](../quality-testing-follow-up-plan.md): 현재 QA profile과 검증 기준
- [Remote integration test 준비 계약](../remote-integration-test-readiness.md): 무인 원격 E2E의 준비 조건

작업 기록을 보관할 때는 남은 계약·QA·운영 조건을 위 현행 문서나 다른 진행 기록에서 계속 추적할 수 있는지 먼저 확인합니다.
