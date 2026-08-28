# 장소·식물 수정 이미지 보존 이력

## 작업 기준

- 이슈: [#248](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/248), AUDIT-01
- 상위 이슈: #226
- 작업일: 2026-08-28
- 기준 `develop`: `f1331b2e850bea19793c708c183417b1554bc172` (문서 PR #257 병합)
- 브랜치: `fix/form-image-preservation-248`
- 참고: [개발 감사 체크리스트](../development-audit-checklist.md), [Swagger 참고](../api-swagger-reference.md), [Feature](../feature-development-guide.md), [상태관리](../state-management-guide.md), [폼 검증](../form-validation-error-guide.md), [공용 위젯](../shared-widget-guide.md), [테스트](../testing-guide.md), [Git](../git-workflow.md) 가이드

## 확인한 계약과 구현

dev OpenAPI와 backend main `7d572cbcabc81a65926738b2a09e8479d0bd0c79`를 재확인했습니다. 새 image 파일이 없으면 기존 `imageKey`는 유지, key 생략/null은 삭제를 뜻합니다. 새 파일이 있으면 교체합니다.

| 상황 | 이번 처리 |
| --- | --- |
| Plant에 기존 key가 있음 | Form 초기값으로 보존하고 이름·날짜 변경, 실패 후 재시도에서도 같은 key 전송 |
| Plant에 사진 URL이 있으나 key가 없거나 공백 | 수정 API를 호출하지 않고 기존 Snackbar 경로로 안내, 입력과 화면 유지 |
| Place에 기존 사진 URL이 있음 | 유지에 필요한 key를 조회할 수 없어 수정 요청 차단·안내, 입력과 화면 유지 |
| 조회 시 사진이 없음 | 기존 이름·날짜·주소 수정 동작 유지 |
| API 비사용 fixture 모드 | 기존 화면 개발·smoke 동작 유지 |
| 하위 multipart API의 명시적 삭제·새 파일 교체 | 기존 계약 유지 및 전송 body 테스트. 삭제·선택 UI는 이번에 추가하지 않음 |

`initialImageKey`·`initialImageUrl`은 수정할 수 없는 초기 스냅샷입니다. 일반 입력용 `copyWith`가 이미지 의도를 변경하지 않도록 보존합니다. 기존 `FormSubmitState`와 오류 표시를 재사용했으며 공용 위젯·라우터·의존성은 변경하지 않았습니다.

Place 조회의 `imgUrl`은 [PlaceFacade](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/blob/7d572cbcabc81a65926738b2a09e8479d0bd0c79/src/main/java/com/commonplant/garden/place/facade/PlaceFacade.java)가 기존 key가 없을 때 null, 있을 때 다운로드 URL로 반환합니다. [S3ServiceImpl](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/blob/7d572cbcabc81a65926738b2a09e8479d0bd0c79/src/main/java/com/commonplant/garden/s3/service/S3ServiceImpl.java)의 URL 생성은 확인했지만 URL을 key로 역변환하지 않습니다.

## 남은 제한과 위험

- **사진이 있는 장소의 수정은 임시 제한됩니다.** 백엔드가 기존 key 조회 또는 명시적 이미지 유지 계약을 제공하면 [IMAGE-04](../backend-api-open-questions.md#image-04-이미지-key-생명주기)를 갱신하고 별도 이슈에서 제한을 해제합니다.
- 사진 표시 URL과 저장 key는 다른 값입니다. 임의 key 추정, URL 재다운로드 후 재업로드, 의도하지 않은 삭제로 우회하지 않습니다.
- 조회 스냅샷 이후 다른 클라이언트가 사진을 바꾸는 동시 수정은 원자적으로 보호되지 않습니다. 특히 사진이 없던 조회 뒤 다른 클라이언트가 사진을 추가하면 null/생략 update의 삭제 의미와 충돌할 수 있습니다. 조건부 수정·버전 확인 또는 명시적 유지 동작은 백엔드 계약 확인이 필요합니다.
- 실제 인증 dev 요청, 원격 사진 삭제·교체 검증은 실행하지 않았습니다. source와 배포 상태의 정합성은 인증 smoke 준비 후 검증합니다.
- 이미지 파일 선택·명시적 삭제 UI, 다른 감사 항목 #249~#256, 스토어·CI 설정은 이번 범위가 아닙니다. 기존 이미지 유실을 수용 위험으로 처리한 것이 아니라 확인 가능한 요청 보존과 안전 차단을 구현한 것입니다.

## 검증

1. 수정 전 새 Controller 회귀 테스트 6개 실패를 확인했습니다(기존 테스트 9개 통과).
2. 수정 후 Controller·State 테스트 26개와 Place·Plant 전체 테스트 205개가 통과했습니다.
3. multipart 전송 body에서 기존 key 유지, null key 삭제 계약, 새 image 파일 전달을 확인했습니다. 테스트는 fake repository와 HTTP adapter를 사용합니다.
4. `fvm dart format --output=none --set-exit-if-changed .`: 294개 파일, 변경 0개
5. `fvm flutter analyze`: 문제 없음
6. `fvm flutter test`: 376개 통과, 기존 non-Linux golden skip 1개
7. `git diff --check`: 통과
8. Markdown 38개, 로컬 링크 153개·anchor 5개 검증: 누락 링크·미연결 문서 0개

기존 362개 대비 회귀 테스트 14개를 추가했습니다. Android 수동 smoke는 fixture·앱 셸·route를 바꾸지 않아 이번에는 별도로 실행하지 않습니다.

## 커밋별 작업 이력

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| `7aee5e8` | Plant 이미지 초기값·submit key 보존, 불완전 이미지 정보 차단 | Plant Controller·State 15개 통과, format |
| `cda0aa2` | Place 이미지 정보 전달·요청 차단, 화면 안내와 multipart 계약 테스트 | Place·Plant 205개, format 294개, analyze, 전체 376개 통과·기존 skip 1개 |

문서·PR 이력만 기록하는 마지막 커밋은 자기 자신의 해시를 생략할 수 있습니다.
