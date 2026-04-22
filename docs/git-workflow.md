# Git 브랜치 및 커밋 전략

커먼플랜트는 기능 단위 브랜치와 작은 커밋을 기준으로 협업합니다. `main`과 `develop`에는 직접 작업하지 않고, 작업 단위별 브랜치에서 PR을 통해 병합합니다.

## 브랜치 원칙

- `main`: 배포 가능한 안정 버전
- `develop`: 다음 배포를 준비하는 통합 브랜치
- `feature/*`: 기능 개발
- `fix/*`: 버그 수정
- `refactor/*`: 구조 개선
- `docs/*`: 문서 작업
- `chore/*`: 설정, 빌드, 의존성 등 기타 작업

브랜치 이름은 작업 의도를 드러내는 영어 kebab-case를 사용합니다.

```text
feature/login-page
feature/place-list
fix/plant-card-overflow
docs/project-guides
chore/update-lefthook
```

## 작업 시작 기준

1. 이슈가 있으면 이슈 번호와 범위를 확인합니다.
2. 기준 브랜치인 `develop`을 최신화합니다.
3. `develop`에서 작업 브랜치를 생성합니다.
4. 한 브랜치에는 하나의 Feature 또는 Task 범위만 담습니다.

```bash
git switch develop
git pull --ff-only
git switch -c feature/place-list
```

`develop` 브랜치는 다음 배포를 준비하는 통합 브랜치이며, 모든 기능 브랜치는 `develop`에서 시작합니다.

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
- [ ] 커밋이 논리적 단위로 정리되었는가?
- [ ] `fvm dart format --output=none --set-exit-if-changed .`를 통과했는가?
- [ ] `fvm flutter analyze`를 통과했는가?
- [ ] `fvm flutter test`를 통과했는가?
- [ ] 관련 문서를 갱신했는가?
- [ ] 리뷰어가 집중해서 볼 부분을 PR 본문에 적었는가?

## 결정 필요

- 이슈 번호가 없는 커밋을 허용할지, 모든 작업에 Task 이슈를 요구할지 결정이 필요합니다.
- PR template 파일을 추가할지 결정해야 합니다.
