# 문서 아카이브

완료된 구현·검증 기록과 현행 문서로 대체된 계획을 보관합니다. 새 작업은
[현행 문서 인덱스](../README.md)와 [진행 중 작업 기록](../work-history/README.md)에서 시작합니다.
이곳의 정책·계약·검증 수치는 기록 당시의 근거이며 현재 구현 상태를 보장하지 않습니다.

## 보관 기준

- 완료된 작업의 근거·커밋·검증 결과를 남길 필요가 있거나, 계획이 완료되어 현행 문서로 대체된 경우 보관합니다.
- 현행 개발 가이드, API 계약·미결 질문, 수용 위험, QA 기준은 `docs/`에 유지합니다.
- 후속 계약·실기기 검증·실제 서버 QA를 이어서 관리하는 기록은 `docs/work-history/`에 유지합니다.
- 이슈의 CLOSED 상태만으로 보관하지 않습니다. 구현 기록의 보관은 도메인 전체나 실제 서버·실기기 QA의 완료를 뜻하지 않습니다.
- 미완료 항목을 포함한 개별 구현 기록을 보관할 때에는 남은 조건을 원문에 유지하고 현행 가이드나 진행 기록에서 추적할 수 있게 연결합니다.
- 이동할 때 원문의 검증 범위를 보존하고 문서 안팎의 상대 링크·경로·인덱스를 함께 갱신합니다.

2026-11-05 #318에서 기존 문서 **30개**를 옮겼습니다. 완료 계획 1개와 작업 기록 29개입니다.
아래 작업 기록에는 이번 정리 기록 1개도 포함되어 있어, 보관 문서는 총 **31개**입니다.
진행 중 작업 기록 7개는 별도 폴더에 유지합니다.

## 완료 계획

- [개발 감사·개선 체크리스트](plans/development-audit-checklist.md): #247~#256 완료 기록. 후속 순서는 [화면·API 전환 계획](../screen-api-integration-plan.md#후속-개발-실행-순서-267)을 따릅니다.

## 인증·온보딩·사용자

- [Home 사용자 실데이터 상태 연결 이력](work-history/home-user-api-state-232.md)
- [User 프로필 화면·API 연결 이력](work-history/user-profile-flow-237.md)
- [계정별 캐시·진행 중 요청 격리 이력](work-history/session-cache-isolation-249.md)
- [소셜 로그인 SDK와 가입 분기 연결 이력](work-history/social-login-sdk-285.md)
- [온보딩·토큰 갱신 정책 문서화 #287](work-history/onboarding-refresh-policy-287.md)
- [온보딩 완료 상태 로컬 저장 #289](work-history/onboarding-local-state-289.md)
- [앱 시작 refresh-only 토큰 갱신 #311](work-history/startup-token-refresh-311.md)

## 장소·친구

- [Place 목록·상세 API 연결 이력](work-history/place-list-detail-api-239.md)
- [장소 친구 요청 API 연결 이력](work-history/friend-invitations-api-241.md)
- [장소 생성·수정 응답 후속 흐름 연결 이력](work-history/place-form-result-flow-243.md)
- [친구 관리 멤버 목록 API 연결 이력](work-history/place-members-api-245.md)
- [장소 주소 선택 결과 연결 이력](work-history/place-address-result-253.md)
- [장소 멤버 고유 ID·역할 조회 계약 반영 #277](work-history/place-members-contract-277.md)
- [장소 팀짱 위임 API 연결 #277](work-history/place-owner-api-277.md)
- [장소 탈퇴 API 연결 #277](work-history/place-leave-api-277.md)

#277의 미제공 계약과 실제 서버·실기기 QA는 [진행 기록](../work-history/place-api-update-277.md)에서 계속 추적합니다.

## 식물

- [Plant 등록·수정 API 폼 상태 작업 이력](work-history/plant-form-api-state-229.md)
- [식물 상세 API 표시 모델 작업 이력 (#231)](work-history/plant-detail-api-view-231.md)
- [원격 식물 등록 장소 상태 이력](work-history/remote-plant-places-251.md)
- [식물 수정 장소 코드 검증 이력](work-history/plant-edit-place-code-252.md)

## 폼·공통 검증

- [장소·식물 수정 이미지 보존 이력](work-history/form-image-preservation-248.md)
- [입력 변경 중 제출 잠금 유지 이력](work-history/form-submit-lock-250.md)
- [API 목록 항목 타입 검증 이력](work-history/api-list-item-validation-254.md)
- [비활성 공용 입력 clear 차단 이력](work-history/disabled-text-field-clear-255.md)
- [수정 정보 Provider 전달 단순화 이력](work-history/form-edit-provider-flow-256.md)

## 날씨

- [공공데이터 초단기 날씨 조회 준비 #304](work-history/place-weather-api-304.md)
- [장소 좌표 누락 시 판교역 날씨 #307](work-history/place-weather-fallback-307.md): 판교역 기본 위치 정책이 철회된 과거 기록입니다.

현행 조회 조건과 좌표 연결 후 변경·검증 항목은 [#309 진행 기록](../work-history/place-weather-unavailable-309.md)과 [#306 진행 기록](../work-history/place-weather-ui-306.md)을 따릅니다.

## 로드맵·화면·문서 정리

- [후속 개발 순서와 보류 범위 정리 이력](work-history/follow-up-development-roadmap-267.md)
- [메인 탭 라우팅과 모션 정리 #291](work-history/main-tab-routing-motion-291.md)
- [Swagger 기준 이미지 직접 업로드 정정 #297](work-history/image-upload-url-297.md)
- [완료 문서 아카이브 정리 #318](work-history/document-archive-318.md)
