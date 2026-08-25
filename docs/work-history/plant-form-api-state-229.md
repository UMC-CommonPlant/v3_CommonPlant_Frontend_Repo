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
| 1 | 이 문서의 최초 커밋 | 작업 계약과 병렬 작업 파일 경계 기록 | `git diff --check` |
| 2 | 예정 | 날짜 상태·Controller·API 요청과 unit test | 관련 Plant provider test |
| 3 | 예정 | 등록·수정 날짜 선택 UI와 widget test | Plant form page test |
| 4 | 예정 | 전체 검증 결과와 최종 이력 | format, analyze, 전체 test, `git diff --check` |

## 최종 검증

작업 완료 후 기록한다.
