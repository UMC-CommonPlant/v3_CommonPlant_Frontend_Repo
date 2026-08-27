# 친구 관리 멤버 목록 API 연결 이력

## 작업 기준

- 이슈: #245 `[Feature] 친구 관리 멤버 목록 API 연결`
- PR: [#246](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/246) (`develop` 병합 완료, `2a01babb185ef5056b361c477717759194c53ec1`)
- 상위 이슈: #226 `[Epic] MVP 화면·API 실연동 전환`
- 작업일: 2026-08-28
- 기준 develop: `9281f06539c4738196a4308b30910e1166d137d1`
- 브랜치: `feature/place-members-api-245`
- 참고 문서: `README.md`, `docs/screen-api-integration-plan.md`,
  `docs/api-swagger-reference.md`, `docs/backend-api-open-questions.md`,
  `docs/accepted-implementation-risks.md`, `docs/feature-development-guide.md`,
  `docs/state-management-guide.md`, `docs/screen-publishing-rules.md`,
  `docs/shared-widget-guide.md`, `docs/design-token-rules.md`,
  `docs/testing-guide.md`, `docs/git-workflow.md`

## 계약과 작업 경계

- 2026-08-28 dev OpenAPI는 19 paths·27 operations로 기존과 동일합니다.
- `GET /place/{code}/members`는 장소 코드로 가입 순서의 멤버를 조회합니다.
- live 성공 schema는 없지만 backend main `7d572cb`의 Controller·DTO·Service는
  `JsonResponse.result`에 `{ name, image }[]`를 반환합니다.
- 기존 `PlaceMember`를 재사용하고 화면용 식별자는 조회 결과의 렌더링에만
  사용합니다. 고유 사용자 ID나 삭제 요청 ID로 해석하지 않습니다.
- API 모드에서는 멤버 조회·닉네임 필터만 제공하고 변경 불가 안내를 표시합니다.
- fixture 모드의 기존 선택·삭제 동작은 화면 개발·테스트를 위해 유지합니다.
- 멤버 추가·삭제·권한 변경 endpoint, 실제 이미지 파일 선택, 원격 인증 smoke는
  이번 범위에 포함하지 않습니다.

## 커밋 계획

| 순서 | 변경 범위 | 검증 |
| --- | --- | --- |
| 1 | 작업 기준·계약·위험 경계 기록 | `git diff --check` |
| 2 | datasource·mapper·repository와 typed 멤버 조회 | Place data test, format |
| 3 | 조회 Provider·검색 상태·친구 관리 화면 | Provider·widget test, analyze |
| 4 | 매트릭스·API·위험 문서와 전체 검증 | format, analyze, 전체 test |

## 커밋과 검증

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| `f6178ba` | 작업 기준·계약·위험 경계 | `git diff --check` |
| `b090581` | 장소 멤버 datasource·mapper·typed repository | Place data test 24개 |
| `8e46fd8` | 조회 Provider·검색 상태·친구 관리 화면 | 관련 test 28개, analyze |
| `1611fd0` | API·위험·매트릭스와 전체 검증 기록 | format 294개, analyze, 전체 test 362개 통과·기존 skip 1개 |
| `4815274` | PR #246·Project In Review 연결 기록(당시 상태) | `git diff --check` |

2026-08-28 문서 정리 #247에서 PR #246의 병합을 확인했습니다. 후속 회귀 수정은 [개발 감사 체크리스트](../development-audit-checklist.md)에서 별도로 추적합니다.

작업 이력만 갱신하는 마지막 문서 커밋은 자기 자신의 해시를 생략할 수 있습니다.
