# Git 브랜치 및 커밋 전략

커먼플랜트는 기능 단위 브랜치와 작은 커밋을 기준으로 협업합니다. `develop`을 기본 개발 브랜치로 사용하고, `main`은 실제 publish/production 브랜치로만 사용합니다. `main`과 `develop`에는 직접 작업하지 않고, 작업 단위별 브랜치에서 PR을 통해 병합합니다.

## 브랜치 원칙

- `main`: 실제 publish/production 브랜치
- `develop`: 기본 개발/통합 브랜치
- `feature/*`: 기능 개발
- `fix/*`: 버그 수정
- `refactor/*`: 구조 개선
- `docs/*`: 문서 작업
- `chore/*`: 설정, 빌드, 의존성 등 기타 작업
- `release/*`: `develop`에서 생성하는 배포 후보 안정화 브랜치
- `hotfix/*`: 운영 긴급 수정 시에만 `main`에서 생성하는 예외 브랜치

브랜치 이름은 작업 의도를 드러내는 영어 kebab-case를 사용합니다.

```text
feature/login-page
feature/place-list
fix/plant-card-overflow
docs/project-guides
chore/update-lefthook
release/1.0.0
hotfix/1.0.1
```

## 작업 시작 기준

1. 요구사항을 도메인, 작업 유형, 영향 범위, 검증 범위로 나누어 분석합니다.
2. 기존 이슈와 중복되는지 확인합니다.
3. 기존 이슈가 있으면 이슈 번호와 범위를 확인합니다.
4. 기존 이슈가 없으면 작업 전 GitHub 이슈를 생성합니다.
5. 기준 브랜치인 `develop`을 최신화합니다.
6. `develop`에서 작업 브랜치를 생성합니다.
7. 한 브랜치에는 하나의 Feature 또는 Task 범위만 담습니다.

```bash
git switch develop
git pull --ff-only
git switch -c feature/place-list
```

`develop` 브랜치는 다음 배포를 준비하는 통합 브랜치이며, 모든 기능 브랜치는 `develop`에서 시작합니다.

## GitHub 이슈 기반 작업 흐름

코드, 문서, 설정 등 저장소 변경이 필요한 요구사항은 GitHub 이슈를 기준으로 추적합니다. 단순 질의, 현황 확인, 명시적으로 보류된 요청은 이슈 생성 없이 답변할 수 있습니다.

작업 전 이슈 생성 기준:

- 요구사항 분석 후 작업 범위가 드러나는 제목을 작성합니다.
- 본문에는 작업 개요, 목표, 완료 조건, 검증 기준을 포함합니다.
- 관련 도메인이나 작업 유형에 맞는 라벨을 지정합니다.
- 담당자가 명확하면 assignee를 지정합니다.
- 기존 이슈가 같은 범위를 이미 다루고 있으면 새 이슈를 만들지 않고 기존 이슈를 사용합니다.

작업 중 연결 기준:

- 브랜치, 커밋, PR에는 가능한 한 이슈 번호를 함께 남깁니다.
- 커밋 메시지는 `Type: 한글 설명 #이슈번호` 형식을 우선 사용합니다.
- 작업 범위가 커져 이슈의 완료 조건을 벗어나면 별도 이슈로 분리합니다.

작업 완료 처리 기준:

- 필요한 포맷, 분석, 테스트를 통과한 뒤 이슈에 완료 코멘트를 남깁니다.
- 완료 코멘트에는 관련 커밋, 검증 명령, 남은 후속 작업 여부를 포함합니다.
- 완료 조건을 충족한 이슈는 `completed` 사유로 닫습니다.
- 완료하지 않기로 결정한 이슈는 사유를 명시하고 `not planned`로 닫습니다.

## 배포 브랜치 전략

`main`은 실제 배포 가능한 코드만 유지합니다. 일반 기능 개발, 문서 작업, 리팩터링, 설정 변경은 모두 `develop`에서 파생한 브랜치로 진행하고 `develop`에 PR을 보냅니다.

배포가 필요할 때는 아래 흐름을 사용합니다.

```bash
git switch develop
git pull --ff-only
git switch -c release/1.0.0
```

`release/*` 브랜치에서는 버전, 빌드번호, 릴리즈 노트, 배포 전 QA 수정만 진행합니다. QA가 끝나면 `release/*`에서 `main`으로 PR을 보내고, `main` 병합 후 `vX.Y.Z` 태그를 생성합니다.

운영 배포 후 긴급 수정이 필요한 경우에만 `main`에서 `hotfix/*`를 생성할 수 있습니다.

```bash
git switch main
git pull --ff-only
git switch -c hotfix/1.0.1
```

`hotfix/*`는 `main`으로 먼저 PR을 보내 배포하고, 동일 수정 사항을 반드시 `develop`에도 반영합니다.

## 커밋 메시지 규칙

형식:

```text
Type: 한글 설명 #이슈번호
```

이슈 번호가 없는 작업은 이슈 번호를 생략할 수 있습니다.

```text
Docs: 프로젝트 문서 가이드 추가
Feat: 로그인 화면 입력 검증 구현 #12
Fix: 식물 카드 긴 이름 말줄임 처리 #18
Refactor: Place 상태관리 로직 분리 #24
```

커밋 제목은 30자 이내를 권장합니다.

## 커밋 유형

| 유형 | 사용 상황 |
| --- | --- |
| `Feat` | 사용자 기능 추가 |
| `Fix` | 버그 수정 |
| `Docs` | 문서 변경 |
| `Style` | 포맷, 세미콜론 등 동작 변화 없는 스타일 변경 |
| `Refactor` | 동작 변화 없는 코드 구조 개선 |
| `Test` | 테스트 추가 또는 수정 |
| `Chore` | 빌드, 설정, 의존성, 기타 관리 작업 |

## 커밋 본문

변경 이유나 리뷰 포인트가 있으면 본문을 작성합니다.

```text
Feat: 장소 목록 화면 추가 #21

- 장소 목록 empty/success 상태 UI 추가
- Place 목록 Provider 연결
- 공용 카드 컴포넌트 재사용
```

본문은 무엇을 했는지와 왜 했는지를 중심으로 씁니다.

## 커밋 단위

좋은 커밋 단위:

- 공용 위젯 하나 추가
- 특정 화면 퍼블리싱
- API DTO와 repository 추가
- 테스트 추가
- README와 문서 링크 정리

피해야 할 커밋:

- 여러 feature를 한 번에 섞은 커밋
- 포맷 변경과 기능 변경이 섞인 커밋
- WIP 상태 그대로 남은 커밋
- 사용하지 않는 파일 또는 임시 mock이 남은 커밋

## PR 기준

PR에는 아래 항목을 포함합니다.

- 관련 이슈
- 구현 범위
- 주요 변경사항
- 테스트 여부
- 리뷰 포인트
- 문서 반영 여부
- Breaking change 여부

PR 제목 예시:

```text
Feat: Place 화면 퍼블리싱 및 상태관리 적용 #21
Docs: 프로젝트 작업 가이드 추가
```

## PR 체크리스트

- [ ] 기준 브랜치가 올바른가?
- [ ] 일반 작업 PR의 base가 `develop`인가?
- [ ] 배포 PR의 base가 `main`이고 head가 `release/*`인가?
- [ ] 커밋이 논리적 단위로 정리되었는가?
- [ ] `fvm dart format --output=none --set-exit-if-changed .`를 통과했는가?
- [ ] `fvm flutter analyze`를 통과했는가?
- [ ] `fvm flutter test`를 통과했는가?
- [ ] 관련 문서를 갱신했는가?
- [ ] 리뷰어가 집중해서 볼 부분을 PR 본문에 적었는가?

## 결정 필요

- PR template 파일을 추가할지 결정해야 합니다.
