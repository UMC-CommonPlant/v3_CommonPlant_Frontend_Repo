# User 프로필 화면·API 연결 이력

## 작업 기준

- 이슈: #237 `[Feature] 마이페이지·설정·회원정보 API 연결`
- 상위 이슈: #226 `[Epic] MVP 화면·API 실연동 전환`
- 작업일: 2026-08-25
- 브랜치: `feature/user-profile-flow-237`
- 참고 문서:
  - `docs/screen-publishing-rules.md`
  - `docs/figma-frame-map.md`
  - `docs/design-token-rules.md`
  - `docs/asset-icon-rules.md`
  - `docs/shared-widget-guide.md`
  - `docs/feature-development-guide.md`
  - `docs/state-management-guide.md`
  - `docs/routing-guide.md`
  - `docs/api-swagger-reference.md`
  - `docs/testing-guide.md`
  - `docs/git-workflow.md`

## Figma 기준

| 화면 | node-id | Route | 핵심 액션 |
| --- | --- | --- | --- |
| 마이페이지 | `1:22439` | `/me` | 설정, 회원 정보 수정, Home 복귀 |
| 설정 | `1:22196` | `/me/settings` | 알림 토글, 로그아웃, 회원 탈퇴 |
| 회원 정보 수정 | `1:22313` | `/me/edit` | 이름 검증과 수정 완료 |

## 구현 범위

- `currentUserProvider`를 수정 결과를 보존할 수 있는 `AsyncNotifier`로 전환했습니다.
- 마이페이지에서 `GET /users`의 loading/error/success 상태와 이름·이메일·프로필 이미지를 표시합니다.
- 회원 정보 수정 Controller가 변경된 이름을 `PUT /users`로 전송하고 성공 응답으로 현재 사용자 상태를 교체합니다.
- 설정의 회원 탈퇴는 `DELETE /users` 성공 후 secure token과 인증 세션을 제거합니다.
- 서버 endpoint가 없는 로그아웃은 로컬 secure token과 인증 세션만 제거합니다.
- 알림 토글은 endpoint가 없으므로 화면 세션의 auto-dispose Provider 상태로 유지합니다.
- Home 하단 탭을 선택 상태와 callback을 받도록 확장해 Home과 마이페이지를 연결했습니다.

## 보류 경계

- 실제 프로필 이미지 선택은 파일 선택기, 카메라·사진 권한 문구, 이미지 source 정책이 확정되지 않아 추가하지 않았습니다.
- `UserRepository.updateMe`의 optional `MultipartFile image` 경계는 유지했으며, 화면에는 현재 이미지와 카메라 action 안내를 제공합니다.
- 알림 설정은 서버 저장 또는 기기 로컬 영속화 정책이 생기기 전까지 앱 재진입 시 복원하지 않습니다.

## 커밋과 검증

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| `684d55b` | User 화면·상태·API·라우팅·테스트 | format 284개 파일, analyze, 전체 test 314개 통과·기존 golden 1개 skip |
| 이 문서 후속 커밋 | Figma frame map, route, Swagger 연결 상태와 구현 경계 기록 | `git diff --check` |

추가 asset 검증으로 신규 SVG 3개의 XML parse와 `vector_graphics_compiler` 변환, 전체 SVG 39개 rasterize test를 통과했습니다. 마이페이지는 임시 375×812 golden probe로 Figma 원본과 시각 대조했으며 probe 파일은 저장소에 남기지 않았습니다.
