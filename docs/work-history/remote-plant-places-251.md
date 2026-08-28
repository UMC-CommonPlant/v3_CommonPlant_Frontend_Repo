# 원격 식물 등록 장소 상태 이력

## 작업 기준

- 이슈: [#251](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/251), AUDIT-04
- PR: [#261](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/261), `develop` 대상
- 상위 이슈: [#226](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/226)
- 작업일: 2026-08-28
- 기준 `develop`: `bc6e68ddbdc80acb0b923a06798cdaf8926e7a0d` (사용자 PR #260 병합)
- 브랜치: `fix/remote-plant-places-251`
- 상태: 구현·로컬 검증 완료, 사용자 병합 전. 이슈·PR은 Project 10의 `In Review`, category `Plant`, priority `high`로 관리합니다.
- 참고: [README](../../README.md), [감사 체크리스트](../development-audit-checklist.md), [Feature](../feature-development-guide.md), [상태관리](../state-management-guide.md), [폼 검증](../form-validation-error-guide.md), [퍼블리싱](../screen-publishing-rules.md), [Figma 매핑](../figma-frame-map.md), [공용 위젯](../shared-widget-guide.md), [디자인 토큰](../design-token-rules.md), [라우팅](../routing-guide.md), [테스트](../testing-guide.md), [QA 기준](../quality-testing-follow-up-plan.md), [Git](../git-workflow.md), [Swagger 계약](../api-swagger-reference.md)

열린 이슈 중복을 확인하고 기존 #251을 재사용했습니다. #250 종료와 PR #260 병합·Project `Done`을 확인한 뒤 최신 `develop`에서 분기했습니다. 상위 #226의 완료 하위 이슈는 14/20이며 #251은 병합 전 완료로 세지 않습니다. 미사용 공용 위젯은 보존하고, #252~#256·배포·CI·외부 정책은 변경하지 않습니다.

## 원인과 수정

기존 Controller는 원격 장소 목록의 loading/error를 빈 배열로 바꾸고 `_effectivePlaces`에서 샘플 장소 4개를 채웠습니다. 따라서 빈 응답이나 조회 실패에서도 샘플 식별자로 등록할 수 있었습니다. 수정 전 신규 Controller 회귀 11개 중 8개가 실패했고, 정상 장소 전송·진행 중 잠금·API 비사용 fixture 사례 3개는 통과했습니다.

| 원격 장소 상태 | 화면·선택 | 등록 |
| --- | --- | --- |
| loading/재조회 | 기존 `PlantStateScaffold` 로딩 안내, 이전 장소·선택값 숨김 | 차단 |
| error | 사용자용 오류와 `다시 시도` | 차단 |
| empty | `등록할 장소가 없어요`, 기존 홈으로 안내 | 차단 |
| success | 서버 목록의 id·이름만 표시·선택, 기존 날짜 입력과 폼 유지 | 현재 목록의 선택값·유효한 이름·미제출 상태에서 허용 |

- 기존 `GET /place/user` → `userPlaceSummariesProvider` → `plantRegistrationPlaceProvider`의 계약과 `POST /plants`의 `placeCode` 전달을 유지합니다. endpoint·DTO·mapper·Swagger 계약은 변경하지 않습니다.
- Controller가 `AsyncValue`의 이전 값을 제거하고 네 상태를 보존합니다. `canSubmit`을 버튼에 연결하며, 선택·제출 직전에도 최신 Provider를 읽어 재빌드 전 콜백을 보호합니다.
- 재시도는 파생 Provider만 갱신하지 않고 실제 repository 조회를 소유한 `userPlaceSummariesProvider`를 무효화합니다. 파생 Provider의 자동 재시도도 끄고 사용자 재시도로 복구합니다.
- 같은 세션의 목록 재조회는 이름·날짜 초안과 #250 제출 잠금을 유지합니다. 새 목록은 유효한 현재 선택 또는 첫 실제 장소를 선택합니다. 로딩 중 선택을 비우므로 재조회 완료 후에는 첫 장소가 선택됩니다.
- #249 데이터 세션 의존성과 늦은 요청 후처리 검사는 유지합니다. 계정 전환 시 이전 장소를 숨기고 폼을 초기화하며, 이전 계정의 늦은 응답은 새 폼에 반영하지 않습니다.
- API 비사용 모드의 초기·빈 목록에는 기존 fixture를 유지합니다. 공용 위젯·토큰을 새로 만들지 않고 `PlantStateScaffold`, `CommonButton`, 기존 등록 scaffold를 재사용합니다.

## 검증

신규 Controller 11개·widget 10개, 총 21개 회귀 테스트를 추가했습니다. 기존 Plant Form 대상 30개와 함께 51개가 통과했습니다.

| 테스트 | 검증 범위 |
| --- | --- |
| [Controller 회귀](../../test/features/plant/presentation/providers/plant_registration_state_test.dart) | loading/error/empty 차단, 실제 code·이름·날짜 전송, 실제 source 재시도, 재조회 직후 제출, 목록 교체·초안 보존, 늦은 계정 응답, 제출 중 재조회, API 비사용 fixture |
| [화면 회귀](../../test/features/plant/presentation/pages/plant_registration_state_page_test.dart) | 4개 viewport의 로딩→오류→실제 재시도→선택·등록·홈 이동과 빈 목록 안내, 이전 버튼 콜백 차단, B 계정 로딩·실패 중 A 장소 비노출 |

- Viewport: Reference `375×812`, Compact width `320×640`, Short height `375×667`, Wide `430×932`, DPR 1
- `fvm dart format --output=none --set-exit-if-changed .`: 307개 파일, 변경 0개
- `fvm flutter analyze`: 문제 없음
- `fvm flutter test --reporter expanded`: 457개 통과, 기존 non-Linux golden skip 1개
- `git diff --check`: 통과
- Markdown 43개, 로컬 링크 229개·anchor 11개: 누락 링크·미연결 문서 0개
- 최종 HEAD의 GitHub CI 결과는 [PR checks](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/261/checks)와 이슈 검증 코멘트에 기록합니다.

테스트는 실제 root/파생 Provider 체인에 fake repository를 주입했습니다. 실제 dev API 생성 요청·인증 E2E·Android/iOS 수동 smoke는 실행하지 않았습니다. 기존 화면 구조·공용 위젯·route는 유지했으며 시스템 back·SafeArea 등 플랫폼 수동 QA를 이 테스트로 완료했다고 보지 않습니다. 새 Figma 시안을 구현하거나 시각 일치 검증을 한 작업도 아닙니다.

## 남은 제한과 위험

- 장소 id·이름은 실제 목록을 사용하지만 카드 이미지는 기존 공통 placeholder입니다. 장소 사진 API 표현과 식물 학명·파일 선택은 별도입니다.
- 조회 후 서버에서 장소가 삭제되거나 권한이 바뀌면 생성 요청이 실패할 수 있습니다. 매 제출마다 원격 재조회를 강제하거나 서버 권한을 추정하지 않으며 기존 제출 오류를 표시합니다.
- 이미 서버에 도착한 등록 요청의 취소·롤백과 응답 유실 후 재시도의 멱등성은 보장하지 않습니다. 목록 재조회 중에도 첫 요청의 payload와 잠금을 유지합니다.
- 빈 목록의 `홈으로`는 기존 진입점 안내입니다. 주소 결과 전달 #253과 실제 검색 연결은 미완료이므로 새 장소 생성 전체 동선이 해결됐다는 뜻이 아닙니다.
- API 응답의 잘못된 목록 항목을 숨기는 파서 문제 #254는 이 수정에 포함하지 않습니다. 현재 typed repository가 반환한 목록에 대한 상태·선택을 보호합니다.
- #252 code 없는 식물 수정, #253 주소 결과 전달, #254~#256 추가 개선은 다음 작업입니다. 사진이 있는 Place 수정 제한도 유지합니다.

## 커밋별 작업 이력

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| `8e08457` | 원격 장소 상태·선택·제출 보호, 실제 조회 재시도와 기존 상태 화면 연결, Controller 회귀 11개 | 신규 Controller·기존 Plant Form 대상 41개 통과 |
| `d0ce294` | 4개 viewport의 상태·홈 안내, 이전 버튼과 계정 전환 widget 회귀 | 신규 widget 10개 통과, 전체 457개·기존 skip 1개, format·analyze |
| `585ac94` | #250 병합·#251 구현 상태, 가이드·매트릭스·감사 체크리스트와 검증·위험 기록 | Markdown 43개·로컬 링크 229개·anchor 11개, `git diff --check` |
| 이 문서의 최종 커밋 | PR #261·Project In Review 연결과 커밋별 이력 기록 | `git diff --check`, 담당자·milestone·Bug type·parent·Project 필드 확인 |

문서·PR 이력만 기록하는 마지막 커밋은 자기 자신의 해시를 생략할 수 있습니다.
