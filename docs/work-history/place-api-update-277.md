# 업데이트된 장소 API 연결·검증 기록 #277

2026-11-05 최신 `origin/develop` `d46470d`에서
`feature/place-member-api-277` 브랜치를 만들었다. 원본 저장소의 미커밋 iOS 설정과
폴더블 PR #314, 인증 복원 PR #312를 보존하고 별도 worktree에서 작업했다.

## API별 커밋

각 커밋에는 구현·관련 회귀 테스트·API 문서를 함께 포함했다.

| 커밋 | API | 구현·검증 범위 |
| --- | --- | --- |
| `c91f7bb` | `GET /place/{code}/members` | 실제 nanoId·owner 검증, 중복/누락 차단, 팀짱 표시. [기록](../archive/work-history/place-members-contract-277.md), 관련 테스트 55개 통과 |
| `e3bb653` | `PUT /place/{code}/owner/{targetNanoId}` | 현재 팀짱·멤버 확인, 확인창·제출 잠금·관련 조회 갱신. [기록](../archive/work-history/place-owner-api-277.md), 관련 테스트 52개 및 보강 후 화면 테스트 8개 통과 |
| `0665211` | `DELETE /place/leave/{code}` | 나가기/전체 삭제 분리, 서버 자동 위임·마지막 멤버 삭제 안내, 세션·캐시 경계. [기록](../archive/work-history/place-leave-api-277.md), 관련 테스트 49개 및 캐시 보강 후 28개 통과 |

## 순차 품질 검사

- `fvm dart format --output=none --set-exit-if-changed .`: 359개 파일, 변경 0개.
- `fvm flutter analyze`: 문제 없음.
- `fvm flutter test`: **831개 통과**, 기존 Linux 전용 golden 1개는 macOS에서 skip.
- `git diff --check`: 통과. 변경 문서의 상대 파일 링크 118개 확인, 누락 없음.

테스트는 fake HTTP adapter·repository를 사용한 unit/widget 검증이다. 휴대폰 폭·긴 이름,
확인·취소·실패·재시도·중복 제출, 계정 전환 전후·화면 폐기 후 응답,
상세 재조회 중 탈퇴와 관련 캐시 제거를 포함한다.

## 공개 계약 확인과 실제 서버 QA의 구분

- 공개 OpenAPI HTTP 200: 22 paths·30 operations. backend `develop`
  `03ece0e466f2f47f72263085f3bfa737b3e1a53c`의 DTO·Controller·Service와 대조했다.
- 멤버 성공 schema·Swagger 예시는 불완전해 소스 근거를 각 API 문서에 링크했다.
  인증된 실제 GET 응답·위임/탈퇴 저장·서버 재조회·앱 재시작·실기기 QA는 미실행이다.
- `GET /place/myGarden`의 page/size는 식물 목록에 적용된다. 현재 Home 장소 목록은
  `placeList`만 소비하므로 기존 호출을 유지하며 식물 전체 페이지 탐색은 별도 범위다.
- 최초 구현 시 refresh-only 시작 복원은 당시 별도 PR #312의 코드였다.
  이후 develop 병합·동기화 상태는 아래 기록을 따른다. 폴더블 변경은 포함하지 않았다.
- Friend 고유 대상 요청·부분 결과와 멤버 추가·제거는 미제공 계약으로 #277에 남긴다.
  날씨 좌표·물주기 주기 저장/조회·Memo API도 아직 명세에 없어 연결하지 않았다.
  #277 전체 완료와 이번 장소 API 구현 완료를 구분한다.

## PR #315 충돌 해결·develop 동기화

PR #312가 develop `5b95ddf`에 병합된 뒤 인증·장소 문서의 같은 영역이 충돌했다.
기존 API별 커밋을 유지한 채 최신 develop을 작업 브랜치에 통합했다.

- README·API 참고·미결 질문·화면 계획 4개 문서에서 인증 복원과 Place API 내용을
  함께 보존했다. 최신 endpoint 수 22 paths·30 operations와 상세 refresh 계약을 유지한다.
- `TOKEN-01`은 초기 복원 구현과 TTL·동시 갱신 후속을 구분해 `Partial`을 유지한다.
  현재 상태의 PR #312 미병합·브랜치 미포함 안내를 제거했다.
- 런타임 코드 충돌은 없었으며 들어온 인증 복원 코드와 기존 Place API 구현을 유지한다.
  실제 서버·실기기 QA, 폴더블 변경, 담당자 규칙 PR #317은 이번 동기화 범위가 아니다.
- 통합 후 순차 검증: format 359개 파일·변경 0개, analyze 문제 없음, 전체 test
  **879개 통과**·기존 Linux 전용 golden 1개 macOS skip. 문서 diff 검사와 상대 파일
  링크 168개 확인이 통과했다. 자동 검증은 실제 서버·실기기 QA와 구분한다.
