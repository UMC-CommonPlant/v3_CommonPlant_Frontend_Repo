# 식물 생성·수정 물주기 주기 #299

- 기준: develop `db481f5`, 브랜치 `feature/plant-watering-cycle-299`
- 이슈: [#299](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/299), 상위 #72

## 사용자 정책

마지막으로 물 준 날짜와 별개로 일 단위 물주기 주기를 생성·수정 화면에 표시한다. 주기는 필수 입력이며 API가 기본값을 제공하면 그 값을 사용하고 없으면 null로 시작한다. 임의의 7일·10일 기본값은 만들지 않는다. 입력 가능한 화면은 빈 값 상태에서 완료할 수 없고 1 이상의 정수를 받는다. 임의의 최대 일수는 정하지 않았다.

## 구현

- 기존 CommonTextField와 토큰을 조합한 PlantWateringCycleField를 두 폼에서 재사용한다. 숫자 키보드, 일마다 단위와 필수 안내·오류를 표시한다.
- 기존 PlantFormController/State가 초기 주기, 현재 입력, 유효성 및 변경 감지를 관리한다. 제출 중에는 주기 변경을 막는다.
- 기본 API 비사용 모드에서는 기존 plantListProvider에 주기를 보관한다. 생성·수정 후 상세 주기 표시와 수정 재진입에 반영한다. 샘플 식물 수정도 같은 목록에 보관하고 새 로컬 ID가 충돌하지 않게 한다.
- 로컬 보관은 앱 실행 중 메모리 수명이다. 앱 재실행 복원, 원격 저장, 알림·다음 물주기 날짜 계산을 구현한 것은 아니다.
- PlantEditInfo에 값이 있으면 폼 초기값으로 사용한다. 현재 원격 mapper에는 추정한 필드를 추가하지 않는다. 생성 화면의 API 추천 주기도 제공 endpoint가 없어 null이다.

## 백엔드 연동 경계

현재 backend develop의 PlantRequest create/update, PlantResponse edit, Plant entity에는 lastWateredDate만 있고 주기 필드가 없다. 이전 원격 상세도 wateringCycleLabel을 null로 표시한다. 따라서 API 모드는 주기 입력을 비활성화하고 ‘물주기 주기 저장 기능을 준비 중이에요’를 표시한다. 원격 생성·수정은 기존 요청 계약을 유지하며 새 주기를 저장한 것처럼 표시하지 않는다.

다음 계약이 필요하다: 식물 검색/추천 기본 주기, 사용자가 입력하는 주기의 생성·수정 요청 필드와 범위, 수정·상세 조회 값, 기존 데이터 null 처리. API가 준비되면 입력 활성화·DTO·mapper·repository 전송과 원격 재조회 테스트를 연결한다. 이미지 업로드는 #297에서 Swagger API 직접 multipart 전송으로 정정됐으며 URL 발급 대기는 철회됐다. 실제 업로드·서버 재조회 QA는 #295에서 추적한다.

## 검증 범위

- unit: null 초기값, 필수·정수 검증, 주기만 수정, 생성→수정 재진입, 로컬 상세 표시, 원격 미지원 입력 차단, 로컬 ID 충돌 방지
- widget: 생성/수정 × 375×812·320×640·375×667, 오류와 완료 버튼, 키보드 300px에서도 필드 스크롤과 완료 버튼 접근, 원격 비활성 안내
- 기존 마지막 물 준 날짜·원격 제출 실패 및 재시도·이미지 회귀 테스트 유지
- 실제 기기 주기 입력 및 서버 주기 저장은 미검증이다.

최초 구현 검증: `fvm dart format --output=none --set-exit-if-changed .` 336개 파일 변경 없음, `fvm flutter analyze` 이상 없음, `fvm flutter test` 689개 통과·기존 Linux 전용 golden 1개 스킵, `git diff --check` 통과.

## 2026-09-19 PR #300 재검토

### develop 충돌 해결

최신 develop `318df53`을 기존 기능 브랜치에 반영했다. 충돌은 `docs/README.md` 한 파일로, #299의 물주기 문서 링크 추가와 #301의 #297 업로드 설명 정정이 같은 부분을 수정한 결과였다. Swagger 직접 multipart 전송·URL 발급 대기 철회 설명과 #299 링크를 함께 보존했다. Flutter 코드 충돌은 없었다.

개인 Team 설정이 있는 원래 작업 폴더는 그대로 두고 별도 worktree에서 작업했다. iOS Bundle ID `com.commonplant.umc`, Debug의 Apple 로그인 비활성 및 Profile/Release 설정을 변경하지 않았다.

### 백엔드 계약 재확인

2026-09-19 [live OpenAPI](https://commonplant-dev.okbear.dev/api/v1/api-docs/json)와 백엔드 develop [`e0e8cada565e2e1c00a86d56da7ae3e6aa00b148`](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/commit/e0e8cada565e2e1c00a86d56da7ae3e6aa00b148)의 PlantRequest·PlantResponse·Plant entity·PlantServiceImpl·PlantController를 대조했다.

- 생성 `CreateRequest`, 수정 `UpdateRequest`, 수정 조회 `EditInfoResponse`, 상세 `DetailResponse`에 물주기 간격·추천 기본값 필드는 여전히 없다. 날짜는 `lastWateredDate`만 제공한다.
- `POST /plants`, `PUT /plants/{plantId}`는 `plant` JSON(`application/json`) + optional `image`의 multipart를 유지한다.
- API 모드의 주기 입력은 계속 비활성이며 DTO·mapper에 추정 필드나 임의 기본값을 추가하지 않았다. #299의 원격 연동은 미완료로 남긴다.

### 수정 초안 보존 보완

로컬 수정 폼이 전체 식물 목록을 구독해 다른 식물을 추가·수정하면 현재 이름·주기·마지막 물 준 날짜 초안이 초기화되는 문제를 재현했다. 수정 정보 Provider가 현재 식물만 `select`로 구독하도록 변경했다. 새 상태관리 계층은 추가하지 않았다.

추가 회귀 테스트는 다른 식물의 추가·수정 이후 세 입력을 보존하고 입력한 주기로 제출되는지 검증한다. 수정 전 테스트 실패를 확인했고, 보완 후 물주기 Provider·화면 테스트 12개가 통과했다.

### 전체 검증과 제한

Flutter/Dart 명령은 FVM으로 순차 실행했다.

- `fvm dart format --output=none --set-exit-if-changed .`: 336개 파일 변경 없음.
- `fvm flutter analyze`: 이상 없음.
- `fvm flutter test`: 690개 통과, 기존 Linux 전용 golden 1개 스킵.
- `git diff --check`: 통과.

현재 Xcode의 라이선스 미동의 오류가 있어 이번 Git·Dart·Flutter 검사 명령에만 `DEVELOPER_DIR=/Library/Developer/CommandLineTools`를 지정했다. 시스템의 Xcode 선택과 라이선스 동의 상태는 변경하지 않았다. 실제 iOS 빌드·설치는 이번 검증에 포함하지 않는다.

자동 테스트와 API 명세 확인은 실제 소셜 로그인·사진 업로드·서버 재조회·서버 주기 저장 검증을 뜻하지 않는다. #299는 원격 주기 계약이 없어 열어 두며, 실제 이미지 업로드 QA는 #295에 유지한다. PR #300의 병합은 사용자가 진행한다.

### 후속 커밋

| 커밋 | 범위 | 검증 |
| --- | --- | --- |
| `269204c` | 최신 develop 반영, 문서 인덱스 충돌 해결 | diff 검사 통과 |
| `e5dbe49` | 다른 식물 변경 시 수정 초안 보존, 회귀 테스트 | 물주기 12개·전체 690개 통과, format/analyze 통과 |

문서 마무리 커밋은 자기 해시를 같은 커밋에 기록하지 않는다.
