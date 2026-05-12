# Figma 프레임 매핑

이 문서는 Figma `phase 0` 화면을 구현할 때 화면, route, Figma frame 이름, node-id, 구현 PR을 빠르게 찾기 위한 탐색 지도입니다.
라우팅 정책은 `docs/routing-guide.md`를 기준으로 보고, 실제 Figma 노드 탐색은 이 문서를 먼저 확인합니다.

## 기준

- Figma 파일: `Common Plant 복제`
- Figma file key: `CyNKSHNXzhzhpy36ELMMbq`
- Figma page: `phase 0` (`0:1`)
- MCP tool에는 node-id를 `1:3308`처럼 콜론 형식으로 전달합니다.
- 브라우저 URL의 `node-id` query에는 `1-3308`처럼 하이픈 형식으로 전달합니다.
- Figma에 같은 이름의 프레임이 여러 개 있으면 이 문서의 `비고`에 적힌 기준을 우선합니다.

## 갱신 규칙

1. 새 화면을 구현하기 전에 이 문서에서 route와 frame 이름, node-id를 먼저 확인합니다.
2. node-id가 `확인 필요`이면 Figma metadata로 실제 프레임을 확인한 뒤 이 문서를 먼저 갱신합니다.
3. 검색 결과, 버튼 처리 결과, alert, bottom sheet는 별도 route가 아니라 `상태 프레임`으로 기록합니다.
4. 구현 PR이 생기면 `구현 PR` 칸에 PR 번호를 추가합니다.
5. 기존 Figma 프레임이 바뀌면 이전 node-id를 지우기보다 `비고`에 변경 근거를 남깁니다.

## Phase 0 Route-Level 화면

| 도메인 | 화면 | Route | Figma frame | node-id | 상태 | 구현 PR | 비고 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Home | 홈 | `/` | `#2 Main` | 확인 필요 | 기본 | #16 | 홈 기본 프레임. 다음 홈 수정 시 재확인 |
| Home | 홈 | `/` | `#2 Main (요청있을 시)` | `1:6156` | 요청 있음 | #21 | 홈 요청 버튼 확인에 사용 |
| Home | 홈 | `/` | `#2 Main/D` | `1:6296` | 로그인 필요 안내 | #16 | route가 아닌 홈 상태 |
| Onboarding | 온보딩 | `/onboarding` | `#1-1` | `1:4822` | 기본 | #18 |  |
| Login | 로그인 | `/login` | `#1-2 Log in` | `2078:5377` | 기본 | #19 |  |
| Login | 프로필 설정 | `/profile/setup` | `#1-2-2 Log in` | `1:1660` | 기본 | #20 |  |
| Login | 프로필 설정 | `/profile/setup` | `#1-2-2 Log in / Clear` | `1:1772` | 입력 완료 | #20 |  |
| Login | 프로필 설정 | `/profile/setup` | `#1-2-2 Log in / Picture` | `1:1680` | 사진 선택 sheet | #20 | route가 아닌 상태 |
| Login | 프로필 설정 | `/profile/setup` | `#1-2-2 Log in / Picture` | `1:1702` | 사진 삭제 alert | #20 | 같은 frame 이름의 alert 상태 |
| Terms | 개인정보 이용약관 | `/terms/privacy` | `#1-2-3 Sign up / 2D` | `1:1747` | 기본 | #20 |  |
| Place | 장소 친구 요청 | `/places/invitations` | `#2-2 Main / 장소 친구 요청` | `1:4853` | 기본 | #21 |  |
| Place | 장소 친구 요청 | `/places/invitations` | `#2-2 Main / 장소 친구 요청 (BTN 결과값)` | `1:4914` | 버튼 처리 후 | #21 | route가 아닌 상태 |
| Place | 장소 등록 | `/places/new` | `#2-2-2 장소 등록` | `1:4132` | 기본 | #23 |  |
| Place | 주소 검색 | `/places/new/address-search` | `#2-2-2-2 장소 등록 / 주소 검색` | `1:4183` | 검색 전 | #24 | 결과 없는 기본 상태 |
| Place | 주소 검색 | `/places/new/address-search` | `#2-2-2-2 장소 등록 / 주소 검색` | `1:4201` | 키보드 표시 | #24 | route가 아닌 입력 상태 |
| Place | 주소 검색 | `/places/new/address-search` | `#2-2-2-2 장소 등록 / 주소 검색` | `1:4151` | 검색 결과 | #24 | 결과 리스트 기준 구현 |
| Place | 친구 추가 | `/places/new/friends` | `#2-2-2-2 장소 등록-친구 추가 (기존 친구x)` | `1:3308` | 기본 | #25 | 검색 전 결과 없음 |
| Place | 친구 추가 | `/places/new/friends` | `#2-2-2-2 장소 등록-친구 추가 (기존 친구x) 과정1` | `1:3351` | 검색 결과 | #25 | 검색어 `커먼` 입력 상태 |
| Place | 친구 추가 | `/places/new/friends` | `#2-2-2-2 장소 등록-친구 추가 (기존 친구x) 과정2` | `1:3660` | 친구 선택 후 | #29 | 검색어 `커먼` 입력 후 선택 친구 마크 표시 |
| Place | 장소 수정 | `/places/:placeId/edit` | `#2-2-2 장소 수정` | `1:4220` | 기본 | #31 | 중복 후보 `1:6261`보다 최신 위치의 프레임 우선 |
| Place | 친구 관리 | `/places/:placeId/friends` | `#2-3-2 친구 관리` | `1:3417` | 기본 | #32 |  |
| Place | 친구 관리 | `/places/:placeId/friends` | `#2-3-2 친구 관리 - 삭제 알럿 (리더` | `1:3491` | alert | #32 | 친구 삭제 확인 dialog |
| Place | 장소 상세 | `/places/:placeId` | `#2-3 My place 리더화면` | `1:2393` | 리더 | #33 | FAB: 식물 추가하기, 장소 수정하기, 장소 나가기 |
| Place | 장소 상세 | `/places/:placeId` | `#2-3 My place 팀원화면` | `1:2708` | 팀원 | #33 | FAB: 식물 추가하기, 장소 나가기 |
| Plant | 식물 등록 검색 | `/plants/new/search` | `#2-2-3 식물 등록` | `1:4513` | 기본 | #34 | 검색 전 결과 없음 |
| Plant | 식물 등록 검색 | `/plants/new/search` | `#2-2-3 식물 등록(검색 후)` | `1:4610` | 검색 결과 | #34 | 검색어 `몬스테라` 입력 상태 |
| Plant | 식물 등록 정보 입력 | `/plants/new/details` | `#2-2-3-2 식물 등록` | `1:4362` | 기본 | #34 | 1단계 검색 결과 선택 후 입력 화면 |
| Plant | 식물 수정 | `/plants/:plantId/edit` | `#2-2-3-3 식물 수정` | `1:4254` | 기본 | 대기 |  |
| Plant | 식물 상세 | `/plants/:plantId` | `#2-4 My plants` | 확인 필요 | 기본 | 대기 |  |
| Memo | 메모 작성 | `/plants/:plantId/memos/new` | `#2-4-2 메모 작성` | 확인 필요 | 기본 | 대기 |  |
| Memo | 메모 목록 | `/plants/:plantId/memos` | `#2-4-3 메모` | 확인 필요 | 기본 | 대기 |  |
| Memo | 메모 목록 | `/plants/:plantId/memos` | `#2-4-3 메모 수정/삭제` | 확인 필요 | 메뉴 | 대기 | route가 아닌 상태 |
| Memo | 메모 목록 | `/plants/:plantId/memos` | `#2-4-3 메모 삭제 alert` | 확인 필요 | alert | 대기 | route가 아닌 상태 |

## 구현 시 확인 순서

1. 위 표에서 대상 route와 상태 프레임을 찾습니다.
2. `node-id`가 있으면 `get_design_context`와 `get_screenshot`을 바로 호출합니다.
3. 같은 이름의 frame이 여러 개면 `상태`와 `비고`를 보고 구현 대상인지 확인합니다.
4. 구현 후 이 문서의 `구현 PR`과 상태 설명을 갱신합니다.
5. Figma와 코드가 다르게 결정된 부분은 PR 본문 또는 issue comment에 남깁니다.
