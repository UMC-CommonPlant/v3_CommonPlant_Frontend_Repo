# 문서 인덱스

문서 분류 기준일: 2026-08-28, `develop` PR #260 병합 및 #251 작업 반영.

작업 전 저장소 [README](../README.md)와 [에이전트 지침](../AGENTS.md)을 먼저 확인합니다. 현재 코드를 기준으로 판단하며, 과거 계획의 파일 수·상태·명령은 현행 지침으로 해석하지 않습니다.

## 지금 볼 문서

- 다음 수정 순서와 개별 이슈: [개발 감사·개선 체크리스트](development-audit-checklist.md)
- 화면별 API 연결 상태와 남은 동선: [화면·모델·API 실연동 전환 계획](screen-api-integration-plan.md)
- 외부 답변이나 팀 결정이 필요한 항목: [후속 결정 체크리스트](follow-up-decision-checklist.md)

## 현행 작업 가이드

| 작업 | 문서 |
| --- | --- |
| Feature 구조·DTO·repository | [Feature 작업 가이드](feature-development-guide.md) |
| Provider·Controller·비동기 상태 | [상태관리 기준](state-management-guide.md) |
| route·인증 redirect | [라우팅 가이드](routing-guide.md) |
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

## 과거 기록 — 새 작업 지침으로 사용하지 않음

기존 이슈·PR 링크를 보존하기 위해 파일을 이동하거나 삭제하지 않고 상단에 보관 표시를 둡니다. 아래의 미체크 박스, 파일 통계와 구현 명령은 당시 기록입니다. 새로 작업할 내용은 현행 체크리스트와 별도 이슈에서 결정합니다.

| 기록 | 보존 목적 |
| --- | --- |
| [PR #47 충돌 해결 계획](pr-47-conflict-resolution-plan.md) | 2026-05-25 충돌 원인과 당시 해결 절차 |
| [초기 남은 작업 완료 현황](remaining-work-plan.md) | 2026-06-28 완료된 0~15번 작업 |
| [lib 구조 리팩토링 진단](lib-refactoring-direction.md) | 1~3차 리팩토링 이전 문제와 구조 제안 |
| [가독성 리팩토링 1차](code-readability-refactoring-plan.md) | 2026-06-28 완료된 Task 1~7 |
| [가독성 리팩토링 2차](code-readability-refactoring-round-2-plan.md) | 2026-08-04 완료된 Task 1~8 |
| [가독성 리팩토링 3차](code-readability-refactoring-round-3-plan.md) | 2026-08-12 완료된 Task 1~11 |
| [가독성 리팩토링 검증 기록](code-readability-refactoring-validation.md) | 당시 구조 감사·테스트·빌드 결과와 검증 한계 |

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

Auth #227 등 중앙 계획에 남긴 이력은 [화면·API 전환 계획의 작업 이력](screen-api-integration-plan.md#작업-이력), 문서 정리 #247은 [개발 감사 체크리스트](development-audit-checklist.md)에서 확인합니다.

## 갱신 기준

- 작업 규칙은 현행 가이드, 구현 진척은 매트릭스·체크리스트, 커밋 증거는 작업 이력에 기록합니다.
- 완료된 계획을 다시 활성화하지 않습니다. 남은 문제는 현재 코드에서 재현하고 별도 이슈로 추적합니다.
- 문서를 추가하거나 보관 분류할 때 이 인덱스를 갱신하고 기존 링크를 검증합니다.
