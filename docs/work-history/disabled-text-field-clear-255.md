# 비활성 공용 입력 clear 차단 이력

## 작업 기준

- 이슈: [#255](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/255), AUDIT-08
- 상위 이슈: [#226](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/226)
- 작업일: 2026-08-30
- 기준 `develop`: `f723825da89cb7988fb49a02e745f229edd4c176` (사용자 PR #264 병합)
- 브랜치: `fix/disabled-text-field-clear-255`
- 상태: 구현·로컬 검증 완료, PR 생성 후 사용자 병합 대기. Project 10의 category `Story`, priority `medium`, Issue Type `Bug`, 담당자 `ywkim95`·`bbielo`, milestone `v1.0.0 - MVP (핵심 기능 개발)`을 유지합니다.
- 참고: [README](../../README.md), [감사 체크리스트](../development-audit-checklist.md), [화면·API 계획](../screen-api-integration-plan.md), [공용 위젯](../shared-widget-guide.md), [디자인 토큰](../design-token-rules.md), [테스트](../testing-guide.md), [Git](../git-workflow.md)

clean 작업 트리와 원격 `develop`, 이슈 중복을 확인하고 기존 #255를 재사용했습니다. 작업 시작 시 #254는 Closed이고 이슈·PR #264의 Project 상태는 Done, 상위 #226은 18/20 완료였습니다. 이번 문서 변경에서 #254의 병합 전 표기를 정정했습니다.

## 원인과 수정

`CommonTextField`의 내부 `TextField`는 `enabled`와 validation state를 함께 사용해 입력을 막았지만, clear trailing은 `forceFocusedDecoration`과 값 존재 여부만 확인했습니다. 이 때문에 강제 focus 장식을 사용하는 값 있는 필드는 비활성 상태에서도 clear가 남아 입력값과 `onChanged`를 바꿀 수 있었습니다.

| 경계 | 처리 |
| --- | --- |
| 활성 입력 | 포커스 또는 강제 focus 장식과 값이 있으면 기존 clear를 표시하고 controller를 비운 뒤 `onChanged('')` 호출 |
| `enabled: false` | 내부 `TextField` 입력을 막고 clear를 만들지 않아 값·콜백 보존 |
| disabled state | 직접 state 또는 validator가 반환한 disabled를 실제 비활성으로 판정해 clear 미노출·실행 차단 |
| 실행 시점 | 표시 조건 외에도 clear callback에서 현재 `enabled`와 validation state를 다시 확인 |
| 강제 focus 장식 | line·counter 등 시각 상태는 유지하되 disabled 입력 권한을 바꾸지 않음 |
| 기존 public API | 별도 trailing·counter·`showClearButton`과 활성 clear 계약 유지 |

새 위젯·디자인 토큰·패키지는 추가하지 않았습니다. `CommonSearchTextField`와 `CommonAddressOrPlaceField`는 각자 삭제 정책을 가진 별도 구현이므로 변경하지 않았습니다.

## 검증

기존 공용 위젯 테스트 파일에 회귀 실행 사례 3개를 추가했습니다. 수정 전에는 활성 clear 1개만 통과하고 두 비활성 사례가 clear 노출로 실패하는 것을 확인했습니다.

| 테스트 | 검증 범위 |
| --- | --- |
| [CommonTextField](../../test/shared/widgets/common_text_field_test.dart) | 신규 1개: 활성 강제 focus 장식에서 clear가 값을 비우고 `onChanged('')`를 한 번 호출 |
| [CommonTextField](../../test/shared/widgets/common_text_field_test.dart) | 신규 1개: `enabled: false`와 강제 focus 장식에서 입력 비활성·clear 미노출·값·콜백 보존 |
| [CommonTextField](../../test/shared/widgets/common_text_field_test.dart) | 신규 1개: disabled state와 강제 focus 장식에서 입력 비활성·clear 미노출·값·콜백 보존 |

- 공용 위젯 대상 테스트: 5개 통과
- `fvm dart format --output=none --set-exit-if-changed .`: 309개 파일, 변경 0개
- `fvm flutter analyze`: 문제 없음
- `fvm flutter test --reporter expanded`: 511개 통과, 기존 non-Linux golden skip 1개
- `git diff --check`: 통과
- README·AGENTS·docs의 Markdown 46개, 로컬 링크 316개·anchor 14개: 누락 링크·미연결 문서 0개
- 최종 PR의 기본 Flutter CI 결과는 PR checks와 이슈 검증 코멘트에 기록합니다.

## 남은 제한과 위험

- widget test는 Flutter의 enabled 상태와 clear 노출·값·콜백을 검증합니다. 실제 Android/iOS 키보드 입력, screen reader, switch control과 물리 기기 hit target을 수동 확인한 것은 아닙니다.
- 활성 화면의 시각 배치나 아이콘 asset을 바꾸지 않았고 새 golden baseline을 추가하지 않았습니다. 기존 golden은 전체 검사에 포함되지만 로컬 macOS에서는 기존 정책대로 skip됩니다.
- `CommonSearchTextField`와 `CommonAddressOrPlaceField`의 삭제 액션, feature Controller, 제출 잠금과 API payload는 이번 범위에서 변경하거나 검증 대상으로 확장하지 않았습니다.
- #248~#254 보호와 미사용 공용 위젯 5개·public 버튼 variant를 유지합니다. 사용자 병합 후 최신 `develop`에서 #256을 진행합니다.

## 커밋별 작업 이력

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| `008bbc6` | 실제 enabled 기반 clear 표시·실행 차단과 활성·비활성 회귀 테스트 3개 추가 | 대상 5개·전체 511개 통과, 기존 skip 1개, format·analyze·diff 검사 |
| 이 문서의 최종 커밋 | #254 병합 상태 정정, #255 계약·검증·남은 제한과 현행 문서 갱신 | 로컬 Markdown 링크·문서 인덱스 확인, `git diff --check` |

문서·PR 이력만 기록하는 마지막 커밋은 자기 자신의 해시를 생략할 수 있습니다.
