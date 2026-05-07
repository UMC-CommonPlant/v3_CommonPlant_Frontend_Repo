# CommonPlant Agent Instructions

이 저장소에서 작업하는 에이전트는 단순 구현보다 구조, 재사용성, 상태관리, API 연동 가능성, 협업 흐름을 우선한다. 작업 전 현재 코드베이스와 관련 문서를 먼저 확인하고, 문서와 코드가 충돌하면 현재 코드 상태를 기준으로 판단한 뒤 문서 갱신 필요 여부를 함께 검토한다.

## 기본 작업 기준

- Flutter 명령은 `fvm flutter ...` 또는 `fvm dart ...` 형태로 실행한다.
- `main`과 `develop`에는 직접 작업하지 않는다.
- 모든 일반 작업 브랜치는 `develop`에서 생성한다.
- `main`은 publish/production 브랜치로만 사용한다.
- 운영 긴급 수정이 아닌 경우 `main`에서 브랜치를 파생하지 않는다.
- 코드, 문서, 설정 등 저장소 변경이 필요한 요구사항을 받으면 먼저 요구사항을 분석하고 GitHub 이슈를 생성한 뒤 작업을 진행한다.
- 작업 완료 후에는 검증 결과와 관련 커밋을 이슈에 남기고 완료 처리한다.
- 화면 구현 전 공통 위젯과 디자인 토큰 재사용 가능 여부를 먼저 확인한다.
- API 응답 파싱, 비즈니스 로직, 비동기 상태 처리를 화면 위젯에 직접 넣지 않는다.
- 결정되지 않은 정책은 임의로 확정하지 않고 사용자에게 질문한다.

## 문서 확인 규칙

모든 작업은 먼저 `README.md`의 프로젝트 문서 섹션을 확인한다. 작업 유형에 따라 아래 문서를 함께 참고한다.

| 작업 유형 | 반드시 참고할 문서 |
| --- | --- |
| 라우팅, 화면 이동, 인증 redirect | `docs/routing-guide.md` |
| feature 구조, API 모델, repository, datasource | `docs/feature-development-guide.md` |
| 화면 퍼블리싱, Figma 반영, 반응형 UI | `docs/screen-publishing-rules.md` |
| 색상, 폰트, spacing, radius, size | `docs/design-token-rules.md` |
| 공용 버튼, 입력창, 카드, FAB, Dialog | `docs/shared-widget-guide.md` |
| asset, icon, image 추가 | `docs/asset-icon-rules.md` |
| Riverpod Provider, Controller, 상태관리 | `docs/state-management-guide.md` |
| form validation, helper/error message | `docs/form-validation-error-guide.md` |
| unit/widget test 추가 또는 수정 | `docs/testing-guide.md` |
| 브랜치, 커밋, PR | `docs/git-workflow.md` |
| 배포, 릴리즈, 스토어 자동화 | `docs/release-workflow.md` |

작업 시작 시 참고한 문서를 짧게 언급한다.

예:

```text
참고 문서: docs/feature-development-guide.md, docs/state-management-guide.md
```

## 구현 전 체크

1. 요구사항이 Login, Place, Plant, Memo 중 어떤 도메인에 속하는지 확인한다.
2. 기존 GitHub 이슈와 중복되는지 확인하고, 없으면 작업 범위가 드러나는 이슈를 생성한다.
3. 기존 `lib/shared/widgets`와 `lib/core/theme` 토큰으로 해결 가능한지 확인한다.
4. 라우팅, 상태관리, API 모델, 테스트 영향 범위를 먼저 판단한다.
5. mock 데이터와 실제 API 연동 코드를 섞지 않는다.
6. loading, success, empty, error 상태를 명확히 나눈다.

## 문서 갱신 기준

아래 상황에서는 코드 변경과 함께 문서 갱신을 검토한다.

- 새 공용 위젯, 디자인 토큰, asset 규칙이 추가되는 경우
- 새로운 feature 구조나 Provider 패턴이 생기는 경우
- API client, 인증 토큰, 에러 처리 정책이 확정되는 경우
- 테스트 방식이나 품질 게이트가 바뀌는 경우
- 브랜치, 커밋, PR 규칙이 바뀌는 경우

## 커밋 규칙

- 커밋은 작고 의미 있는 단위로 나눈다.
- 커밋 메시지는 `Type: 한글 설명` 형식을 사용한다.
- 설명은 30자 이내로 간단히 작성한다.
- 이슈 번호가 있으면 뒤에 `#이슈번호`를 붙인다.

예:

```text
Feat: 로그인 화면 구현 #12
Fix: 식물 카드 말줄임 수정 #18
Docs: 문서 참고 규칙 추가
```

## 검증 기준

문서만 수정한 경우:

```bash
git diff --check
```

Flutter 코드가 변경된 경우:

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test
```
