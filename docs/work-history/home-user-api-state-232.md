# Home 사용자 실데이터 상태 연결 이력

## 작업 기준

- 이슈: #232 `[Feature] Home 사용자 실데이터 상태 연결`
- 작업일: 2026-08-25
- 참고 문서:
  - `README.md`
  - `docs/feature-development-guide.md`
  - `docs/state-management-guide.md`
  - `docs/api-swagger-reference.md`
  - `docs/testing-guide.md`
  - `docs/git-workflow.md`

## 목표와 범위

Home hero의 고정 사용자명을 현재 사용자 상태로 교체하고, API 사용 모드에서 기존 `UserRepository.fetchMe()`가 `GET /users`를 호출하도록 연결했다. Place·Plant 목록 상태와 Friend 데이터는 범위에 포함하지 않았다.

| 모드 | 사용자 데이터 | Home 표시 |
| --- | --- | --- |
| API 비사용 | 로컬 `UserProfile` fixture | 기존 `커먼(유저 네임` 표시 계약 보존 |
| API 사용 | `UserRepository.fetchMe()` | `GET /users` 결과의 `name` 표시 |
| API 최초 조회 중 | `AsyncLoading` | 진행 표시와 접근성 label 노출 |
| API 조회 실패 | `AsyncError` | 오류 안내와 `다시 시도` 제공 |
| API 재시도 성공 | `AsyncData<UserProfile>` | 복구된 사용자명 표시 |

## 구현 경계

- `currentUserProvider`는 환경 설정을 확인한 뒤 API 사용 모드에서만 repository를 호출한다.
- Home 위젯은 repository와 JSON 구조를 알지 않고 `AsyncValue<UserProfile>` 상태만 표시한다.
- Provider 자동 재시도를 비활성화하여 오류 표시와 재시도 호출 횟수를 Home의 명시적 재시도 UI가 소유한다.
- 재시도는 `currentUserProvider`만 invalidate하여 Place·Plant 목록을 다시 조회하지 않는다.
- API 비사용 Home과 Android smoke의 결정적 텍스트는 유지한다.

## 보류 항목

Home의 `요청 3건`은 기존 고정값을 유지한다. Swagger의 `GET /friends/requests`에 성공 response schema가 없어 목록 wrapper, 식별자, 상태, 초대 요청 판별 기준을 안전하게 mapping할 수 없다. response schema와 갱신 정책이 확정되면 Friend 전용 이슈에서 목록·count·수락·거절 상태를 함께 연결한다.

## 커밋별 작업 이력

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| `1480c59` | API on/off 분기와 `UserRepository.fetchMe()`를 사용하는 `currentUserProvider`, Provider 단위 테스트 | Provider 테스트 3개, `git diff --check` |
| `90e46c6` | Home hero 사용자명·loading·error·retry UI, Reference/Compact width 위젯 테스트 | Home/widget 테스트 8개, `fvm flutter analyze`, `git diff --check` |
| `00a36b8` | 작업 경계, Friend count blocker, 최초 전체 검증 결과 기록 | `git diff --check` |
| `5d2cdad` | `currentUserProvider` 자동 재시도 비활성화, 명시적 retry 정책 테스트 | Provider/Home 집중 테스트 7개, `fvm flutter analyze`, `git diff --check` |
| 이 문서 후속 커밋 | 자동·명시적 retry 경계와 최종 검증 결과 갱신 | `git diff --check` |

## 최종 검증

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test
git diff --check
```

- format: 273개 파일 변경 없음
- analyze: issue 없음
- test: 287개 통과, 기존 golden 1개 skip
- diff check: 통과
