# 구현 허용 위험 등록부

이 문서는 API 계약이 완전하지 않아도 MVP 개발 우선순위에 따라 구현하기로 결정한
항목의 위험과 해소 조건을 기록합니다. `Accepted`는 위험이 해결됐다는 의미가
아니며, 현재 제약을 인지한 상태로 구현과 검증을 계속한다는 의미입니다.

## 관리 기준

- 위험을 수용한 날짜, 근거 이슈·PR, 현재 동작과 해소 조건을 함께 기록합니다.
- Swagger나 백엔드 구현이 바뀌면 영향도와 상태를 다시 평가합니다.
- 고유 식별자 오매칭, 데이터 손실, 권한 오류 가능성이 현실화되면 해당 동작을
  비활성화하거나 이전 안전 경계로 되돌립니다.
- 실제 credential, token, 개인정보는 기록하지 않습니다.

## 상태 정의

| 상태 | 의미 |
| --- | --- |
| `Accepted` | 위험을 인지하고 현재 구현을 허용함 |
| `Monitoring` | 구현 후 실제 환경에서 발생 여부를 관찰 중 |
| `Resolved` | 계약 또는 구현 변경으로 위험이 해소됨 |
| `Rolled back` | 위험이 현실화되어 기능을 이전 안전 경계로 되돌림 |

## Friend 신규 요청

2026-08-26 사용자 결정에 따라 #243 / PR #244에서 신규 친구 요청 전송을 우선
연결하고 아래 위험을 수용했습니다.

2026-08-31 #277에서 live OpenAPI와 backend main `7d572cb`를 재확인했으며 위험은
여전히 유효합니다. 고유 대상·부분 결과·멱등 계약은
[backend #150](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/150)에서
추적하고, 답변 전 현재 payload를 새 고유 ID 계약으로 해석하지 않습니다.

| ID | 상태 | 위험과 영향 | 현재 구현·완화 | 해소 또는 중단 조건 |
| --- | --- | --- | --- | --- |
| FRIEND-RISK-01 | `Accepted` | `receiverName`은 고유 ID가 아니며 백엔드는 표시 이름 부분 검색의 첫 결과를 사용합니다. 동명이인·유사 이름이 있으면 화면에서 선택한 사용자와 다른 사용자에게 요청이 갈 수 있습니다. | 화면에서 직접 선택한 프로필의 이름만 전송하고 중복 submit을 막습니다. 이는 오초대 가능성을 제거하지 않습니다. | 요청 payload를 고유 user ID로 변경하거나 exact unique name을 서버가 보장합니다. 실제 오초대가 확인되면 전송 연결을 비활성화합니다. |
| FRIEND-RISK-02 | `Accepted` | `receiverName[]` 일괄 요청의 사용자별 성공·실패 규칙이 Swagger에 없습니다. 일부 대상만 처리돼도 앱이 전체 성공으로 이동할 가능성이 있습니다. | 현재는 HTTP 요청 전체 성공 여부만 판단하고 실패 시 화면에 남아 재시도할 수 있게 합니다. | 서버가 대상별 결과와 원자성 정책을 명세하고 프론트가 `receiverList`를 검증합니다. 부분 성공이 확인되면 전체 성공 이동을 중단합니다. |
| FRIEND-RISK-03 | `Accepted` | 인증된 dev 환경 smoke가 없어 backend source와 실제 배포 동작의 차이를 자동 검출하지 못합니다. | DTO·datasource·Controller·widget 테스트로 request path, payload, 중복 제출과 실패 복구를 검증합니다. | CI 인증 bootstrap과 격리·cleanup 수단을 준비해 원격 요청 smoke를 통과합니다. 계약 불일치가 확인되면 mapper 또는 기능 gate를 수정합니다. |

## 추적 정보

- 이슈: #243 `[Feature] 장소 생성·수정 응답과 후속 흐름 연결`
- PR: #244 `[Feature] 장소 생성·수정 응답과 후속 흐름 연결`
- 구현 커밋: `3b2198c`
- 후속 이슈: #277, backend #150
- 관련 확인 항목: `FRIEND-02`, `FRIEND-03`, `FRIEND-05`, `SEARCH-03`, `TESTENV-01`~`05`

## Place 멤버 조회

2026-08-28 #245는 미확정 항목을 별도로 기록하면서 조회 가능한 화면부터 연결하는
기준으로 진행했습니다. 쓰기 동작을 추정하지 않고 실제 조회 결과만 사용합니다.

2026-08-31 #277 재검증에서도 멤버 ID·역할과 변경 endpoint는 제공되지 않았습니다.
[backend #150](https://github.com/UMC-CommonPlant/v3_CommonPlant_Backend_Repo/issues/150)이
live 계약을 제공할 때까지 조회 전용과 구성원 나가기 숨김을 유지합니다.

| ID | 상태 | 위험과 영향 | 현재 구현·완화 | 해소 조건 |
| --- | --- | --- | --- | --- |
| MEMBER-RISK-01 | `Accepted` | 응답에 멤버 고유 ID와 역할이 없어 항목을 지속적으로 식별하거나 삭제·권한 변경 대상으로 사용할 수 없습니다. | 가입 순서별 임시 화면 키로 동명이인을 구분하되 API payload에는 사용하지 않습니다. 조회 전용 안내를 표시하고 선택·삭제 액션을 노출하지 않습니다. | 서버가 멤버 ID·역할과 변경 endpoint를 제공하면 별도 작업에서 연결합니다. |
| MEMBER-RISK-02 | `Accepted` | live Swagger에 성공 schema가 없고 인증 smoke가 없어 source와 배포 계약이 다른지 확인하지 못했습니다. | backend main `7d572cb`를 근거로 strict result 배열을 파싱하고 오류 시 fixture 대신 실패·재시도를 표시합니다. | machine-readable schema와 인증된 dev 조회 검증이 확보되면 해소합니다. |

- 관련 이슈: #245 `[Feature] 친구 관리 멤버 목록 API 연결`
- 관련 PR: [#246](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/pull/246)
- 구현 커밋: `b090581`, `8e46fd8`
- 후속 이슈: #277, backend #150
- 관련 확인 항목: `PLACE-04`~`06`, `TESTENV-01`~`05`

## Plant 소속 장소 code 조회

2026-08-31 #273은 Plant 응답에 direct `placeCode`가 없는 현재 계약에서 Home 식물의
수정·삭제 code를 확보하기 위해 기존 Place 조회 API를 조합했습니다.

| ID | 상태 | 위험과 영향 | 현재 구현·완화 | 해소 또는 중단 조건 |
| --- | --- | --- | --- | --- |
| PLANT-RISK-01 | `Accepted` | route와 Plant 응답에 code가 없으면 장소 목록 뒤 각 장소 상세를 순차 조회하므로 장소 수에 따라 지연·요청 수가 늘어납니다. 중간 상세 하나가 실패해도 code를 확정할 수 없어 식물 상세가 오류 상태가 됩니다. | 실제 사용자 장소 code만 조회하고 `plantList[].plantId`를 정확히 비교합니다. 이름·학명·첫 장소를 추정하지 않으며 오류 재시도를 제공합니다. route·Plant code가 있으면 fallback을 실행하지 않습니다. | Plant 목록·상세가 direct `placeCode`를 제공하거나 전용 조회 endpoint가 생기면 fallback을 제거합니다. 실제 지연·rate limit·상세 가용성 저하가 확인되면 code 없는 수정·삭제 경계를 유지한 채 조회 방식을 재설계합니다. |

- 관련 이슈: #273 `[Feature] Plant 장소 코드 조회와 검색 계약 경계`
- 구현 커밋: `8a51642`
- 관련 확인 항목: `PLANT-01`, `TESTENV-01`~`05`
