# Plant 등록·수정 API 폼 상태 작업 이력

## 작업 기준

- 이슈: #229
- 브랜치: `feature/plant-form-api-state-229`
- 기준 브랜치: `develop`
- 도메인: Plant

## 목표

- 등록 화면의 고정 물주기 날짜를 제거하고 사용자가 선택한 날짜를 폼 상태로 관리한다.
- 수정 정보 API의 `lastWateredDate`를 폼 상태에 복원한다.
- 등록·수정 요청에 현재 폼의 `lastWateredDate`를 Swagger 형식인 `yyyy-MM-dd`로 전달한다.
- API 사용 여부와 관계없이 loading, failure, submitting, retry 동작을 유지한다.

## 범위와 경계

| 구분 | 처리 |
| --- | --- |
| Plant form state/controller | 이름과 마지막 물 준 날짜의 초기값·현재값·변경 여부 관리 |
| Plant create/edit page | 날짜 선택 UI와 제출 상태 연결 |
| Plant repository 호출 | `POST /plants`, `PUT /plants/{plantId}`에 현재 날짜 전달 |
| 식물 학명 | 검색 결과가 한글명·영문명·애칭을 구분하지 않아 임의 매핑하지 않음 |
| 이미지 | 파일 선택 정책과 picker 의존성이 없어 기존 multipart 경계만 유지 |
| 검색 | Swagger에 식물 검색 API가 없어 fixture 교체 범위에서 제외 |

## 커밋 계획과 이력

| 순서 | 커밋 | 변경 범위 | 검증 |
| --- | --- | --- | --- |
| 1 | `3816e05` | 작업 계약과 병렬 작업 파일 경계 기록 | `git diff --check` |
| 2 | `97d6e3c` | 폼의 초기·현재 물주기 날짜 상태, 변경 감지, create/update 요청 전달과 unit test | Plant form state/controller/edit provider test 13개 통과 |
| 3 | `9eeae52` | 등록·수정 날짜 선택 UI, API 날짜 표시와 widget test | Plant form page/provider test 18개 통과 |
| 4 | `f689495` | 원격 등록의 submitting/failure/retry와 Swagger 날짜 fixture 보강 | Plant form page/edit provider test 15개 통과 |
| 5 | 이 문서의 최종 커밋 | 전체 검증 결과와 최종 이력 | format, analyze, 전체 test, `git diff --check` |

## 최종 검증

- `fvm dart format --output=none --set-exit-if-changed .`: 270개 파일 변경 없음
- `fvm flutter analyze`: 문제 없음
- `fvm flutter test --reporter compact`: 284개 통과, 기존 golden skip 1개
- `git diff --check origin/develop...HEAD`: 통과

## 남은 후속 작업

- 식물 검색 결과의 한글 학명, 영문 학명, 사용자가 정할 애칭을 구분하는 API·화면 계약이 필요하다.
- Plant create/update의 optional image part에 전달할 실제 파일 선택 정책과 picker 도입은 별도 이슈로 진행한다.
- Swagger에 식물 검색 endpoint가 추가되기 전까지 현재 fixture 검색과 remote API 모델을 섞지 않는다.
