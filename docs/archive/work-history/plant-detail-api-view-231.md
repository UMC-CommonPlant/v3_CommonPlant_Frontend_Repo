# 식물 상세 API 표시 모델 작업 이력 (#231)

## 목표

`GET /plants/{plantId}`의 Swagger 확인 필드만 식물 상세 화면에 표시하고, 원격 API 응답과 로컬 fixture가 실제 데이터처럼 섞이지 않도록 분리한다.

## 데이터 표시 계약

| 화면 정보 | 원격 API 기준 | 로컬 API-off 기준 |
| --- | --- | --- |
| 식물 식별자·이름·학명·장소명 | `plantId`, `scientificNameKo`, `scientificNameEn`, `placeName` | 기존 fixture |
| 식물 이미지 | `imageUrl` | 기존 asset |
| 처음 함께한 날·함께한 일수 | `registeredAt`의 날짜를 기준으로 계산 | 기존 fixture |
| 마지막으로 물 준 날짜 | `lastWateredDate` | 기존 fixture |
| 물주기 예정 D-day·주기 | Swagger에 근거 필드가 없어 미제공 상태 표시 | 기존 fixture |
| 대표 메모 | `memo`가 있으면 요약으로만 표시 | 기존 fixture 카드 목록 |
| 메모 목록·작성 | Memo CRUD API가 없어 미지원 상태 표시 | 기존 로컬 화면 이동 유지 |
| 식물 정보 | `plantInfo` | 기존 fixture |

날짜 계산은 mapper에 기준 시각을 주입한다. `registeredAt`의 달력 날짜부터 기준 날짜까지를 양끝 포함으로 계산해 등록 당일은 1일로 표시하며, 미래 날짜는 잘못된 서버 값으로 보고 일수 계산을 제공하지 않는다.

## 제외 범위

- Plant 생성·수정 form
- Memo API 또는 물주기 실행·주기 API 추정
- `docs/screen-api-integration-plan.md` 수정
- 백엔드 response schema 변경

## 커밋 계획

| 순서 | 범위 | 검증 |
| --- | --- | --- |
| 1 | 작업 기준과 데이터 표시 계약 기록 | `git diff --check` |
| 2 | 상세 ViewData·mapper·Provider와 날짜 계산 단위 테스트 | 관련 unit/provider test |
| 3 | 상세 page/widget의 원격 미제공 상태와 API-off 회귀 테스트 | 관련 widget test |
| 4 | 전체 검증 결과와 커밋별 이력 기록 | format, analyze, 전체 test, `git diff --check` |

## 커밋별 작업 이력

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| `fd8a1de` | 작업 기준과 데이터 표시 계약 | `git diff --check` |
| `4aa5b01` | 원격 상세 ViewData·날짜 계산·미제공 상태 UI와 상세 전용 unit/widget test | 상세 관련 test 20개, `fvm flutter analyze` |
| 이 문서의 최종 커밋 | 전체 검증 결과와 커밋별 이력 | format 270개, analyze, 전체 test 285개 통과·기존 skip 1개, `git diff --check` |

## 최종 검증

- `fvm dart format --output=none --set-exit-if-changed .`: 270개 파일, 변경 없음
- `fvm flutter analyze`: 통과
- `fvm flutter test --reporter compact`: 285개 통과, 기존 golden skip 1개
- `git diff --check develop...HEAD`: 통과

## 남은 서버 의존 항목

- 물주기 예정일과 주기는 상세 schema에 근거 필드가 없어 미제공 상태를 유지한다.
- Memo CRUD endpoint가 추가되기 전에는 대표 메모 문자열만 읽고 목록·작성 액션을 원격 데이터 기능으로 노출하지 않는다.
