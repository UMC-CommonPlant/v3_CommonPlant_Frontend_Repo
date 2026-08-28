# 입력 변경 중 제출 잠금 유지 이력

## 작업 기준

- 이슈: [#250](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/250), AUDIT-03
- PR: [#260](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/260), `develop` 병합 완료. 이슈·PR은 Project 10의 `Done`, category `Story`, priority `high`입니다.
- 상위 이슈: [#226](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/226)
- 작업일: 2026-08-28
- 기준 `develop`: `b15cdd7b9b73aa5892dbc6e0cddb86fa23c5f2be` (사용자 PR #259 병합)
- 브랜치: `fix/form-submit-lock-250`
- 상태: 사용자 병합 완료(`bc6e68ddbdc80acb0b923a06798cdaf8926e7a0d`), 이슈 종료·감사 체크 완료. 아래 검증은 #250 당시 결과이며 후속 #251과 구분합니다.
- 참고: [README](../../README.md), [감사 체크리스트](../development-audit-checklist.md), [Feature](../feature-development-guide.md), [상태관리](../state-management-guide.md), [폼 검증](../form-validation-error-guide.md), [공용 위젯](../shared-widget-guide.md), [라우팅](../routing-guide.md), [테스트](../testing-guide.md), [Git](../git-workflow.md)

열린 이슈의 중복을 확인하고 기존 #250을 재사용했습니다. #249 종료와 PR #259 병합·Project `Done`을 확인한 뒤 최신 `develop`에서 분기했습니다. 미사용 공용 위젯 5개는 보존하며, 디자인·route·API endpoint·DTO·배포·CI 설정은 변경하지 않습니다.

## 원인과 구현

Place·Plant·회원정보 수정·가입 프로필의 입력 변경 메서드가 진행 중 제출 상태를 `idle`로 되돌렸습니다. 느린 요청을 기다리는 동안 입력을 바꾸면 두 번째 `submit()`이 통과했습니다. 수정 전 새 Controller 회귀 테스트 13개가 실패했고 기존 대상 27개는 통과했습니다.

| 대상 | 변경 |
| --- | --- |
| Place Form | 이름·주소 변경과 주소 삭제에서 기존 `submitting` 상태 유지 |
| Plant Form | 이름·날짜·장소 선택 변경에서 기존 `submitting` 상태 유지 |
| User Profile Edit | 이름을 수정해도 첫 요청 완료 전 추가 제출 차단 |
| Profile Setup | 닉네임 변경 중 상태 유지, 인증 세션을 기다리기 전에 제출 닉네임 캡처. 사진·약관 변경도 잠금 유지 검증 |

입력은 기존처럼 수정할 수 있습니다. 진행 중 요청은 제출 시점 값을 사용하고 실패하면 최신 초안으로 재시도합니다. 성공 결과는 진행 중이던 최초 호출에만 반환하고 기존 화면 이동을 유지합니다. 별도 잠금 flag·공용 Controller·패키지는 추가하지 않고 `FormSubmitState`·`ProfileSetupSubmitStatus`와 `CommonButton`의 loading/disabled 표현을 그대로 사용합니다.

#249의 요청 시작 Ref·데이터 세션 검사와 계정 전환 시 초기화는 유지했습니다. 서버 요청 자체를 취소하거나 재시도 정책을 추가한 변경은 아닙니다.

## 검증

Controller 회귀 13개를 추가했습니다. 화면에서는 5개 흐름을 Reference `375×812`, Compact width `320×640`, Short height `375×667`에서 검증합니다. 기존 화면 테스트 2개를 확장한 것을 포함해 제출 잠금 widget 사례는 15개이며, 전체 실행 수는 기존보다 26개 늘었습니다.

| 대상 | 검증 내용 | 증거 |
| --- | --- | --- |
| Place Controller | 생성·수정 × 성공·실패, 이름·주소·삭제, 최초 payload와 수정값 재시도 | [test](../../test/features/place/presentation/providers/place_form_controller_test.dart) |
| Plant Controller | 생성·수정 × 성공·실패, 이름·날짜·장소, 최초 payload와 수정값 재시도 | [test](../../test/features/plant/presentation/providers/plant_form_controller_test.dart) |
| User Controller | 중복 차단, 첫 이름 반영, 실패 후 새 이름 재시도 | [test](../../test/features/user/presentation/providers/user_profile_edit_controller_test.dart) |
| Profile Setup Controller | 닉네임·사진·약관 변경, 실패 복구, 세션 대기 전 이름 캡처 | [test](../../test/features/login/presentation/providers/profile_setup_controller_test.dart) |
| Place 화면 | 수정 중 입력·이전 버튼 콜백 재전달, 요청 1회와 홈 이동 | [test](../../test/features/place/presentation/pages/place_form_page_test.dart) |
| Plant 화면 | 생성 중 장소 변경·수정 중 이름 변경, 중복 차단과 실패 후 잠금 해제 | [test](../../test/features/plant/presentation/pages/plant_form_page_test.dart) |
| User 화면 | 이름 변경 중 잠금, 오류 표시, 수정값 재시도와 프로필 이동 | [test](../../test/features/user/presentation/pages/user_profile_edit_page_test.dart) |
| 가입 프로필 화면 | 닉네임 변경 중 잠금, 실패 후 수정값 재시도, 인증 전환·홈 이동 | [test](../../test/features/login/presentation/pages/profile_setup_submit_test.dart) |

- 관련 대상 테스트: 71개 통과(Controller 40개, 화면 31개)
- `fvm dart format --output=none --set-exit-if-changed .`: 305개 파일, 변경 0개
- `fvm flutter analyze`: 문제 없음
- `fvm flutter test --reporter expanded`: 436개 통과, 기존 non-Linux golden skip 1개
- `git diff --check`: 통과
- Markdown 41개(README·AGENTS 포함), 로컬 링크 206개·anchor 10개: 누락 링크·미연결 문서 0개
- GitHub CI는 최종 문서 커밋까지 포함한 HEAD에서 확인하며 결과는 [최신 PR checks](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/260/checks)와 이슈 검증 코멘트에 남깁니다.

실제 dev API의 생성·수정·회원가입 요청, 인증 E2E와 Android 수동 smoke는 실행하지 않았습니다. 기존 DTO·repository 계약, 앱 셸·route·공용 위젯 구조는 바뀌지 않았으며 #248 이미지 보존과 #249 세션 격리 회귀를 전체 테스트에 포함했습니다.

## 남은 제한과 위험

- 현재 Controller 인스턴스의 진행 중 요청만 보호합니다. 서로 다른 화면·기기·프로세스, 응답 유실 후 재시도까지 서버 중복 처리를 보장하지 않습니다. 서버 멱등성·요청 식별자 계약을 임의로 추가하지 않습니다.
- 성공 후 이동하는 동안 대기 중 새로 입력한 값을 자동 저장하지 않습니다. 성공 시 기존 이동 정책을 유지하며, 성공 이후의 새 요청까지 영구 차단하는 잠금은 추가하지 않았습니다.
- 네트워크 오류는 서버 미반영을 뜻하지 않습니다. 실패 후 재시도는 기존 동작이며 서버가 먼저 반영한 경우의 중복 위험은 별도 계약이 필요합니다.
- #251 원격 식물 등록의 샘플 장소 혼입, #252 code 없는 식물 수정, #253 주소 결과 전달, #254~#256 파서·위젯·Provider 개선은 해결한 것으로 표시하지 않습니다. Plant 테스트의 장소 목록은 명시적 fake override이며 실제 원격 목록 검증이 아닙니다.
- 사진이 있는 Place 수정 제한과 실제 이미지 선택, 소셜 SDK·원격 E2E 준비 조건은 기존 기록을 유지합니다.

## 커밋별 작업 이력

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| `2103498` | Place·Plant 입력 변경 중 제출 상태 유지, 생성·수정 회귀와 화면 잠금 검증 | 관련 Controller 23개·화면 25개 통과 |
| `8ff9cf5` | 회원정보·가입 프로필 잠금 유지와 닉네임 캡처, 오류 복구·이동 검증 | 관련 Controller 17개·화면 6개 통과 |
| `69e494d` | #249 병합·#250 구현 상태, 가이드·매트릭스와 위험·검증 기록 | 전체 436개 통과·기존 skip 1개, format·analyze·문서 링크 검사 |
| `0667451` | PR #260·Project In Review 연결과 커밋별 이력 기록(당시 상태) | `git diff --check`, 담당자·milestone·Bug type·parent·Project 필드 확인 |
| #251 후속 문서 커밋 | PR #260 병합·이슈 종료·Project Done 및 감사 체크 완료 반영 | merge `bc6e68d`, parent #226의 완료 하위 이슈 14/20 확인 |

문서·PR 이력만 기록하는 마지막 커밋은 자기 자신의 해시를 생략할 수 있습니다.
