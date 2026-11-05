# 문서 인덱스

문서 분류 기준일: 2026-11-05, develop `0a72bf0`의 구현·미완료 검증·후속 계약을 기준으로 정리했다.
작업 전 저장소 [README](../README.md)와 [에이전트 지침](../AGENTS.md)을 먼저 확인한다.

## 먼저 찾을 곳

| 목적 | 진입점 |
| --- | --- |
| 현재 개발 범위·화면/API 상태 | [화면·모델·API 연결 계획](screen-api-integration-plan.md) |
| 진행 중인 QA·서버 연동·스토어 준비 | [진행 중 작업 기록](work-history/README.md) |
| 확인된 API와 미확정 계약 | [Swagger 참고](api-swagger-reference.md), [백엔드 질문](backend-api-open-questions.md) |
| 외부 결정·준비 조건과 수용한 위험 | [후속 결정](follow-up-decision-checklist.md), [위험 등록부](accepted-implementation-risks.md) |
| 완료된 계획·구현·검증 이력 | [문서 아카이브](archive/README.md) |

## 현행 작업 가이드

| 작업 | 문서 |
| --- | --- |
| Feature 구조·DTO·repository | [Feature 작업 가이드](feature-development-guide.md) |
| Provider·Controller·비동기 상태 | [상태관리 기준](state-management-guide.md) |
| route·인증 redirect | [라우팅 가이드](routing-guide.md) |
| 소셜 로그인·가입 분기·SDK 설정 | [소셜 로그인 가이드](social-login-integration-guide.md) |
| Figma 화면 구현·반응형 | [퍼블리싱 규칙](screen-publishing-rules.md), [프레임 매핑](figma-frame-map.md) |
| 색·폰트·spacing·radius | [디자인 토큰](design-token-rules.md) |
| 공용 UI·소유권·미사용 위젯 보존 | [공용 위젯](shared-widget-guide.md) |
| 이미지·아이콘 | [Asset·icon 규칙](asset-icon-rules.md) |
| 입력 검증·제출 오류 | [폼 가이드](form-validation-error-guide.md) |
| unit·widget·golden·integration test | [테스트 가이드](testing-guide.md) |
| 이슈·브랜치·커밋·PR·Project | [Git 작업 규칙](git-workflow.md) |
| 배포·스토어·릴리즈 정책 | [릴리즈 가이드](release-workflow.md) |

## 현행 계획·계약

| 문서 | 계속 관리하는 내용 |
| --- | --- |
| [화면·API 연결 계획](screen-api-integration-plan.md) | 현재 구현과 남은 입력·상태·서버 연동 범위 |
| [API Swagger 참고](api-swagger-reference.md) | 확인 날짜별 endpoint·request·response와 소스 근거 |
| [백엔드 API 질문](backend-api-open-questions.md) | 계약 미확정 항목·답변·프런트 반영 상태 |
| [위험 등록부](accepted-implementation-risks.md) | 수용한 위험과 중단·해소 조건 |
| [후속 결정](follow-up-decision-checklist.md) | 팀 결정·외부 승인·백엔드 준비 조건 |
| [품질·테스트 계획](quality-testing-follow-up-plan.md) | 현재 QA profile·golden·smoke 기준과 미완료 원격 검증 |
| [원격 integration 준비 계약](remote-integration-test-readiness.md) | 인증·데이터 격리·cleanup·Environment 승인 조건 |

## 보관 구조와 갱신 기준

- `docs/`: 현재 적용하는 가이드·계획·계약을 유지한다.
- `docs/work-history/`: 진행 중이거나 후속 연동·QA의 상세 실행 지침이 남은 기록을 유지한다.
- `docs/archive/plans/`: 완료되거나 현행 문서로 대체된 계획을 보관한다.
- `docs/archive/work-history/`: 구현·검증이 끝난 범위의 작업 이력을 보관한다.
- 이슈가 닫혔거나 코드가 병합돼도 실제 서버·실기기 QA가 완료됐다고 판단하지 않는다.
  미확정 계약·재개 지침의 상세 원본은 현재 위치에 남기고, 보관 문서에도 당시 한계를 보존한다.
- 문서를 이동할 때 이 인덱스·하위 인덱스·참조 링크와 heading anchor를 함께 확인한다.
  보관본을 현재 정책의 단일 근거로 사용하거나 완료 계획을 다시 활성화하지 않는다.
