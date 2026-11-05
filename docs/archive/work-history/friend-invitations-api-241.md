# 장소 친구 요청 API 연결 이력

## 작업 기준

- 이슈: #241 `[Feature] 장소 친구 요청 목록·수락·거절 API 연결`
- PR: #242 `[Feature] 장소 친구 요청 목록·수락·거절 API 연결`
- 상위 이슈: #226 `[Epic] MVP 화면·API 실연동 전환`
- 작업일: 2026-08-26
- 브랜치: `feature/friend-invitations-api-241`
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

- 백엔드 저장소 `UMC-CommonPlant/v3_CommonPlant_Backend_Repo` main
  `7d572cbcabc81a65926738b2a09e8479d0bd0c79`의 Friend Controller·DTO·Service를
  기준으로 사용합니다.
- `GET /friends/requests`의 result는 `{ requests: friendRequestItem[] }`입니다.
- 각 항목은 요청 PK `friendId`, 발신자 이름·이미지, 장소 code·이름·주소와
  status를 포함합니다.
- `POST /friends/accept`, `POST /friends/decline`은 요청 PK를 받고 성공 시
  null result를 반환합니다.

## 구현 범위

- Friend 요청 응답을 domain entity로 변환하는 mapper와 typed repository를
  구현합니다.
- 장소 친구 요청 화면은 원격 모드와 fixture 모드를 분리하고
  loading·success·empty·error 상태를 표시합니다.
- 항목별 수락·거절 처리 중 중복 submit을 막고 성공·실패 상태를 반영합니다.
- 원격 성공은 처리한 요청을 화면 상태에서 제거한 뒤 서버 목록을 다시
  확인합니다. fixture 모드는 Figma의 처리 결과 상태를 유지합니다.
- Home의 요청 배지는 같은 화면 상태의 미처리 요청 수를 표시합니다.

## 보류 경계

- 신규 요청 전송은 서버가 표시 이름 부분 검색의 첫 결과를 사용하므로,
  동명이인 오초대 정책이 해결될 때까지 화면에 연결하지 않습니다.
- 친구 관리·차단·삭제와 원격 인증 bootstrap은 이번 범위에 포함하지 않습니다.

## 커밋 계획

| 순서 | 변경 범위 | 검증 |
| --- | --- | --- |
| 1 | 작업 기준, API 계약과 구현 경계 기록 | `git diff --check` |
| 2 | Friend entity·mapper·typed repository와 단위 테스트 | Friend data test, format |
| 3 | 요청 화면 Controller·상태·Home 배지와 단위 테스트 | provider test, format |
| 4 | loading·empty·error·submit UI와 widget test | Place/Home widget test, analyze |
| 5 | 계획 문서 상태와 전체 검증·커밋 이력 갱신 | format, analyze, 전체 test |

## 커밋과 검증

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| `7ae68cf` | 작업 기준, API 계약, 구현·보류 경계, 커밋 계획 | `git diff --check` |
| `24079a6` | Friend 요청 entity·mapper와 typed repository | Friend data test 13개 |
| `a1761a8` | 요청 목록·action 상태와 Home 동적 요청 수 | Provider·Home test 9개 |
| `0141f74` | loading·empty·error·submit UI와 네트워크 프로필 이미지 | 관련 test 17개, analyze |
| 이 문서의 최종 커밋 | 계획·API 질문 상태와 전체 검증 이력 | format 289개, analyze, 전체 test 332개 통과·기존 skip 1개 |

작업 이력만 갱신하는 마지막 문서 커밋은 자기 자신의 해시를 생략할 수 있습니다.
