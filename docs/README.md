# 문서 인덱스

문서 분류 기준일: 2026-08-31, `develop` PR #268 및 #267 후속 순서 반영.

작업 전 저장소 [README](../README.md)와 [에이전트 지침](../AGENTS.md)을 먼저 확인합니다. 현재 코드를 기준으로 판단하며, 완료되어 대체된 계획은 Git 이력과 기존 이슈·PR에서 확인합니다.

## 지금 볼 문서

- 완료된 감사 #248~#256: [개발 감사·개선 체크리스트](development-audit-checklist.md)
- 다음 개발 순서와 화면별 API 상태: [화면·모델·API 실연동 전환 계획](screen-api-integration-plan.md#후속-개발-실행-순서-267)
- 외부 답변이나 팀 결정이 필요한 항목: [후속 결정 체크리스트](follow-up-decision-checklist.md)

## 현행 작업 가이드

| 작업 | 문서 |
| --- | --- |
| Feature 구조·DTO·repository | [Feature 작업 가이드](feature-development-guide.md) |
| Provider·Controller·비동기 상태 | [상태관리 기준](state-management-guide.md) |
| route·인증 redirect | [라우팅 가이드](routing-guide.md) |
| 소셜 로그인·신규 사용자 분기·SDK 설정 | [소셜 로그인 연동 가이드](social-login-integration-guide.md) |
| Figma 화면 구현·반응형 | [퍼블리싱 규칙](screen-publishing-rules.md), [Figma 프레임 매핑](figma-frame-map.md) |
| 색·폰트·spacing·radius | [디자인 토큰 규칙](design-token-rules.md) |
| 공용 UI·소유권·미사용 위젯 보존 | [공용 위젯 가이드](shared-widget-guide.md) |
| 이미지·아이콘 파일 | [Asset·icon 규칙](asset-icon-rules.md) |
| 입력 검증·제출 오류 | [폼 검증·에러 메시지 가이드](form-validation-error-guide.md) |
| unit·widget·golden·integration test | [테스트 가이드](testing-guide.md) |
| 이슈·브랜치·커밋·PR·Project | [Git 작업 규칙](git-workflow.md) |
| 배포·스토어·릴리즈 정책 | [릴리즈 가이드](release-workflow.md) — 구현 재개는 외부 준비 후 |

## 실행 계획·계약·결정

| 문서 | 용도 |
| --- | --- |
| [개발 감사·개선 체크리스트](development-audit-checklist.md) | 문서 정리와 우선 수정할 문제, 개별 이슈, 완료 기준 |
| [화면·모델·API 실연동 전환 계획](screen-api-integration-plan.md) | 병합된 연결 범위와 미완료 입력·상태·API 동선 구분 |
| [API Swagger 참고](api-swagger-reference.md) | 확인된 endpoint·request·response와 백엔드 source 근거 |
| [백엔드 API 질문](backend-api-open-questions.md) | 계약 미확정 항목과 확인된 답변, 프론트 반영 상태 |
| [구현 허용 위험 등록부](accepted-implementation-risks.md) | 사용자가 수용한 위험과 중단·해소 조건. 새 회귀 버그를 자동 수용하지 않음 |
| [후속 결정 체크리스트](follow-up-decision-checklist.md) | 팀 결정·외부 승인·백엔드 준비가 필요한 항목 |
| [품질·테스트 후속 계획](quality-testing-follow-up-plan.md) | QA·golden·smoke 결정 이력과 남은 품질 항목 |
| [원격 integration 준비 계약](remote-integration-test-readiness.md) | 인증·데이터 격리·cleanup·Environment 승인 gate |
| [소셜 로그인 연동 가이드](social-login-integration-guide.md) | `isNewUser` 가입 분기, provider token, iOS 전용 Apple 노출과 SDK 설정 |

## 기능별 작업 이력

과거 커밋의 검증 결과는 해당 시점에만 적용합니다. 현재 연결 상태는 화면 매트릭스, 다음 작업은 개발 감사 체크리스트에서 확인합니다.

| 작업 | 이력 |
| --- | --- |
| Plant 생성·수정 #229 | [Plant Form](work-history/plant-form-api-state-229.md) |
| Plant 상세 #231 | [Plant Detail](work-history/plant-detail-api-view-231.md) |
| Home 사용자 #232 | [Home User](work-history/home-user-api-state-232.md) |
| User 프로필 #237 | [User Profile](work-history/user-profile-flow-237.md) |
| Place 목록·상세 #239 | [Place List·Detail](work-history/place-list-detail-api-239.md) |
| Friend 수신 요청 #241 | [Friend Invitations](work-history/friend-invitations-api-241.md) |
| Place 폼 결과 #243 | [Place Form Result](work-history/place-form-result-flow-243.md) |
| Place 멤버 조회 #245 | [Place Members](work-history/place-members-api-245.md) |
| Place·Plant 이미지 보존 #248 | [Form Image Preservation](work-history/form-image-preservation-248.md) |
| 계정별 캐시·진행 중 요청 격리 #249 | [Session Cache Isolation](work-history/session-cache-isolation-249.md) |
| 입력 변경 중 제출 잠금 #250 | [Form Submit Lock](work-history/form-submit-lock-250.md) |
| 원격 식물 등록 장소 상태 #251 | [Remote Plant Places](work-history/remote-plant-places-251.md) |
| 식물 수정 장소 코드 검증 #252 | [Plant Edit Place Code](work-history/plant-edit-place-code-252.md) |
| 장소 주소 선택 결과 연결 #253 | [Place Address Result](work-history/place-address-result-253.md) |
| API 목록 항목 타입 검증 #254 | [API List Item Validation](work-history/api-list-item-validation-254.md) |
| 비활성 공용 입력 clear 차단 #255 | [Disabled Text Field Clear](work-history/disabled-text-field-clear-255.md) |
| 수정 정보 Provider 전달 단순화 #256 | [Form Edit Provider Flow](work-history/form-edit-provider-flow-256.md) |
| 후속 개발 순서·보류 범위 #267 | [Follow-up Development Roadmap](work-history/follow-up-development-roadmap-267.md) |
| 소셜 로그인 SDK·가입 분기 #285 | [Social Login SDK](work-history/social-login-sdk-285.md) |
| 온보딩·토큰 갱신 정책 #287 | [Onboarding·Refresh Policy](work-history/onboarding-refresh-policy-287.md) |

Auth #227 등 중앙 계획에 남긴 이력은 [화면·API 전환 계획의 작업 이력](screen-api-integration-plan.md#작업-이력), 문서 정리 #247은 [개발 감사 체크리스트](development-audit-checklist.md)에서 확인합니다.

## 갱신 기준

- 작업 규칙은 현행 가이드, 구현 진척은 매트릭스·체크리스트, 커밋 증거는 작업 이력에 기록합니다.
- 완료된 계획을 다시 활성화하지 않습니다. 남은 문제는 현재 코드에서 재현하고 별도 이슈로 추적합니다.
- 문서를 추가하거나 제거할 때 이 인덱스를 갱신하고 기존 링크를 검증합니다.
- 완료되어 현행 문서로 대체된 계획은 저장소에 중복 보관하지 않고 Git 이력과 기존 이슈·PR에서 조회합니다.
