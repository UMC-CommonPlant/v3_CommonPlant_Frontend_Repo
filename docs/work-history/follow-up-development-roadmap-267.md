# 후속 개발 순서와 보류 범위 정리 이력

## 작업 기준

- 이슈: [#267](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/267)
- 작업일: 2026-08-30
- 기준 `develop`: `011ef7db1affb9b50fc241222b5f9408bc5eb5f5` (사용자 PR #266 병합)
- 브랜치: `docs/follow-up-development-roadmap-267`
- 상태: 문서 정리·로컬 검증 완료, PR 생성 후 사용자 병합 대기. Project 10의 category `Story`, priority `medium`, Issue Type `Task`, 담당자 `ywkim95`·`bbielo`, milestone `v1.0.0 - MVP (핵심 기능 개발)`을 사용합니다.
- 참고: [README](../../README.md), [문서 인덱스](../README.md), [감사 체크리스트](../development-audit-checklist.md), [화면·API 계획](../screen-api-integration-plan.md), [후속 결정](../follow-up-decision-checklist.md), [백엔드 질문](../backend-api-open-questions.md), [Git](../git-workflow.md)

clean 작업 트리와 `origin/develop`, 열린 이슈 중복을 확인했습니다. PR #266과 #256은 병합·Closed·Project `Done`, 상위 Epic #226은 하위 이슈 20/20 완료·Closed·`Done`이었습니다. 기존 열린 이슈는 스토어 계정 준비 #215 하나이며 사용자 결정에 따라 계속 `Backlog`로 보류합니다.

## 사용자 결정

### 순서대로 진행할 범위

1. 이번 #267에서 완료 상태와 후속 범위를 문서에 동기화합니다.
2. Home 친구 요청 배지 조회 실패를 정상 0건과 구분합니다.
3. Plant 소속 장소 code와 식물 검색 잔여 동선을 연결합니다.
4. 공통 API 오류 메시지와 토큰 만료·세션 종료를 연결합니다.
5. Place 멤버와 Friend 쓰기 동선을 고유 식별자 기반으로 연결합니다.
6. Memo 텍스트 CRUD·목록·pagination을 실제 API 상태로 연결합니다.

### 다음 작업으로 보류할 범위

- Kakao·Google·Apple 로그인 SDK와 credential·네이티브 설정
- 실제 주소 검색 서비스와 서비스·키·과금·adapter 결정
- 새 업로드 방식이 필요한 이미지 선택·업로드·교체·삭제
- 인증된 원격 E2E와 테스트 인증·격리·cleanup·Environment
- 스토어 계정·signing·build number·릴리즈 workflow

보류 항목은 삭제하거나 완료 처리하지 않습니다. 기존 `Open`·`Partial`·`Blocked` 질문과 준비 계약을 유지하고 사용자가 재개할 때 별도 이슈를 만듭니다.

## 실행 계약

| 단계 | 구현 전 확인 | 구현 완료 기준 |
| --- | --- | --- |
| Home | 현재 오류가 0건으로 표시되는 경로 재현 | loading·정상 0건·error·success 수와 retry 정책 검증 |
| Plant | `PLANT-01`, `SEARCH-02` 답변 | 실제 place code와 검색 결과만 사용하고 fixture 혼입·추정 식별자 차단 |
| 공통 오류·토큰 | `ERROR-01~02`, `TOKEN-01~02`, UX-01·STATE-01 결정 | code·field·화면 메시지와 복구/종료·세션 경쟁 검증 |
| Place·Friend | `PLACE-05`, 멤버 ID·변경 endpoint, Friend 고유 대상·부분 결과 계약 | 실제 ID·대상별 결과를 사용한 action과 실패·재시도 검증 |
| Memo | `MEMO-01~03` 답변 | 이미지 없이 텍스트 CRUD·pagination과 loading/empty/error/success 연결 |

계약이 없는 단계는 endpoint·필드·첫 항목·표시 이름을 추정하지 않습니다. 질문 답변과 구현은 분리된 이슈로 관리하며, 각 코드 작업은 화면 → 모델·상태 → repository·API → 회귀 테스트 순서를 따릅니다.

## 문서 변경

- README에 PR #266·Epic #226 완료와 후속 6단계·보류 5개를 반영합니다.
- 개발 감사 체크리스트를 #248~#256 전체 완료 기록으로 닫습니다.
- 화면·API 계획에 후속 실행 순서의 단일 원본을 추가합니다.
- 후속 결정 체크리스트에 사용자 보류 결정과 재개 조건을 기록합니다.
- #256 작업 이력에 병합 커밋·Project Done·최종 CI를 반영합니다.

## 검증

- 변경 파일 7개: 모두 Markdown
- `git diff --check`: 통과
- README·AGENTS·docs의 Markdown 48개, 로컬 링크 333개·anchor 20개: 누락 링크·미연결 문서 0개
- Flutter 코드·설정은 변경하지 않으므로 format·analyze·test는 실행하지 않습니다.

## 남은 제한

- 이번 작업은 실행 순서와 보류 범위를 확정하는 문서 변경이며 후속 기능을 구현한 것으로 계산하지 않습니다.
- 백엔드 질문의 상태는 답변 없이 변경하지 않습니다.
- 이미지의 새 업로드 방식, 외부 서비스·credential·secret·계정·과금·배포 정책을 정하지 않습니다.
- 각 후속 단계의 정확한 이슈 Type·category·priority·parent는 실제 계약과 변경 범위를 확인한 뒤 생성합니다.

## 커밋별 작업 이력

| 커밋 | 변경 범위 | 검증 |
| --- | --- | --- |
| 이 문서의 최종 커밋 | PR #266·Epic 완료 상태, 후속 6단계와 사용자 보류 5개를 현행 문서에 반영 | Markdown 링크·인덱스·`git diff --check` |

문서·PR 이력만 기록하는 마지막 커밋은 자기 자신의 해시를 생략할 수 있습니다.
