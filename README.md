# 모두를 위한 식물 관리 애플리케이션, 커먼플랜트

![CommonPlant](https://github.com/UMC-CommonPlant/.github/assets/76817418/5edf01a4-dd8f-4615-a031-7729a03c1880)

커먼플랜트는 특정 장소에서 함께 키우는 식물의 데이터를 장소 구성원끼리 쉽게 공유하고 관리할 수 있도록 돕는 식물 관리 애플리케이션입니다.
환경에 맞는 식물 추천, 장소별 식물 관리, 식물 정보와 메모 공유를 통해 함께 기르는 식물을 더 체계적으로 관리할 수 있도록 돕습니다.

## 커먼플랜트는 이렇게 시작되었어요

- 같은 공간에서 함께 키우는 식물을 모두가 함께 관리하고 싶어요.
- 우리집 환경에 맞는 식물을 추천받고 싶어요.
- 장소별로 식물 관리와 정보 공유를 할 수 있는 서비스가 필요해요.
- 식물의 물주기와 관련 데이터를 체계적으로 관리하고 알려줄 무언가가 필요해요.

> 커먼플랜트는 위와 같은 문제를 바탕으로 장소별 식물 관리 서비스를 개발했습니다.
>
> `Place`: 함께할 장소를 만들고 친구를 초대할 수 있어요.  
> `Plant`: 식물의 정보와 물주기를 함께 관리할 수 있어요.  
> `Memo`: 식물의 상태를 메모로 기록하고 공유할 수 있어요.  
> `Calendar`: 식물과 관련된 일정을 하나의 캘린더에서 관리할 수 있어요.  
> `Information`: 식물 추천과 가이드북을 통해 필요한 정보를 확인할 수 있어요.

## 주요 기능

- 로그인 및 회원가입
- MyGarden 기반 개인 식물 관리
- MyPlace 기반 장소별 식물 관리 및 구성원 초대
- 식물별 메모와 물주기 기록 관리
- 식물 추천 및 가이드 정보 제공

## 현재 개발 범위

이 저장소는 커먼플랜트 Flutter 프론트엔드 앱 저장소입니다. 현재 단계에서는 Android/iOS 기반의 공통 개발환경, 테마 토큰, 공용 위젯 베이스를 우선 정리합니다.

## 프로젝트 개요

- 지원 플랫폼: Android, iOS
- 공통 기준 Flutter 버전: `3.35.7`
- 공통 기준 Dart 버전: `3.9.2`
- 기본 명령어 표기: `fvm flutter`
- Flutter 실행 기준: FVM (`.fvmrc`의 `3.35.7` 사용)

## 시작하기

### 1. 의존성 설치

```bash
fvm flutter pub get
```

### 2. 앱 실행

```bash
fvm flutter run -d android
fvm flutter run -d ios
```

### 3. 품질 검사

```bash
fvm flutter analyze
fvm flutter test
```

### 4. FVM 버전 설정

처음 환경을 구성한다면 아래처럼 저장소 기준 Flutter 버전을 맞춥니다.

```bash
fvm use 3.35.7
fvm flutter pub get
```

## 사용 라이브러리

### Runtime

| 이름 | 버전 | 목적 |
| --- | --- | --- |
| `cupertino_icons` | `^1.0.8` | iOS 스타일 아이콘 지원 |
| `go_router` | `^17.2.0` | 앱 라우팅 및 라우트 구조 관리 |
| `flutter_riverpod` | `^3.3.1` | 상태관리 및 의존성 주입 |
| `flutter_svg` | `^2.2.0` | SVG 아이콘 렌더링 |

### Development

| 이름 | 버전 | 목적 |
| --- | --- | --- |
| `flutter_test` | `sdk:flutter` | 위젯 테스트 및 기본 테스트 러너 |
| `flutter_lints` | `^5.0.0` | 정적 분석 및 공통 린트 규칙 |
| `lefthook` | 외부 도구 | pre-commit 품질 게이트 실행 |

## 프로젝트 구조

```text
lib/
  app/
    common_plant_app.dart
    router/
  core/
    assets/
    theme/
  shared/
    widgets/
  features/
    home/
      presentation/
```

## 공통 작업 규칙

- 화면에서 raw color, raw spacing, raw radius 값을 직접 찍지 않고 `core/theme` 토큰을 사용합니다.
- 공용 UI는 우선 `shared/widgets`를 통해 재사용하고, 기능별 화면은 `features` 아래에서 조합합니다.
- 팀 공통 기준은 `.fvmrc`의 Flutter 버전과 FVM 실행 흐름을 따르는 것입니다.
- 로컬 Flutter 명령은 `fvm flutter ...` 또는 `fvm dart ...` 형태로 실행합니다.

## 확정된 협업 및 기술 기준

- 브랜치는 `develop`을 통합 기준으로 사용하고, 각 작업 브랜치는 `develop`에서 생성합니다.
- `main`은 실제 publish/production 브랜치로 사용하고 직접 작업하지 않습니다.
- 배포 후보는 `develop`에서 `release/*` 브랜치를 생성해 안정화한 뒤 `main`으로 PR을 보냅니다.
- 운영 긴급 수정만 예외적으로 `main`에서 `hotfix/*` 브랜치를 생성하고, 배포 후 `develop`에 되돌려 반영합니다.
- HTTP 클라이언트는 API 연동 시점에 `dio`를 기준으로 도입합니다.
- 실제 API 사용 여부와 base URL은 `dart-define` 또는 CI/CD 환경값으로 주입하고, flavor는 앱 정체성 구분에 사용합니다.
- API 모델은 `freezed`와 `json_serializable` 기반 생성을 기본 방향으로 삼되, 실제 패키지 추가는 첫 API 연동 PR에서 함께 진행합니다.
- 인증 토큰은 `flutter_secure_storage` 기반 보관을 기본 방향으로 합니다.
- 백엔드 에러 코드는 아직 미정이므로, 확정 전까지는 공통 에러 타입으로 감쌀 수 있는 구조를 우선합니다.
- Golden test와 integration test 도입 범위는 아직 미정입니다.

## 프로젝트 문서

| 문서 | 설명 |
| --- | --- |
| [에이전트 작업 지침](AGENTS.md) | 작업 유형별 필수 참고 문서와 에이전트 작업 기준 |
| [디자인 토큰 규칙](docs/design-token-rules.md) | 색상, 폰트, 여백, radius, size 토큰 사용 기준 |
| [공용 위젯 사용 가이드](docs/shared-widget-guide.md) | `shared/widgets` 컴포넌트 사용법과 추가 기준 |
| [라우팅 구조 설명](docs/routing-guide.md) | `go_router` 기반 라우팅 구조, route 추가 기준, 인증 라우팅 확장 방향 |
| [Figma 프레임 매핑](docs/figma-frame-map.md) | Phase 0 화면별 Figma frame 이름, node-id, 상태, 구현 PR 연결표 |
| [Feature 작업 가이드](docs/feature-development-guide.md) | feature-first 구조, 계층 책임, API 모델 및 작업 순서 |
| [화면 퍼블리싱 작업 규칙](docs/screen-publishing-rules.md) | Figma 화면 구현 시 공용 컴포넌트, 상태 UI, 반응형 기준 |
| [Assets 및 Icons 규칙](docs/asset-icon-rules.md) | 아이콘/이미지 네이밍, 등록, 사용 기준 |
| [상태관리 Provider 작성 기준](docs/state-management-guide.md) | Riverpod Provider 선택, 파일 배치, async 상태 처리 기준 |
| [폼 검증 및 에러 메시지 작성 기준](docs/form-validation-error-guide.md) | 입력 검증 위치, helper/error 메시지, 서버 에러 처리 기준 |
| [테스트 작성 기준](docs/testing-guide.md) | unit/widget test 작성 기준, 실행 명령, CI/pre-commit 연계 |
| [lib 구조 리팩토링 개선 방향](docs/lib-refactoring-direction.md) | `lib` 구조, Riverpod, 라우팅, feature 경계 리팩토링 진단과 단계별 개선안 |
| [API Swagger 연계 참고 문서](docs/api-swagger-reference.md) | 서버 Swagger 변경사항, API 계층 반영 가능 항목, 백엔드 확인 필요 항목 |
| [백엔드 API 확인 질문 목록](docs/backend-api-open-questions.md) | Swagger와 API 계층 기준으로 분리한 백엔드 확인 질문 목록 |
| [후속 결정 체크리스트](docs/follow-up-decision-checklist.md) | 계획된 작업 완료 후 새 이슈로 분리할 결정/확인 항목 목록 |
| [Git 브랜치 및 커밋 전략](docs/git-workflow.md) | 브랜치 전략, 커밋 메시지, PR 체크리스트 |
| [배포 및 릴리즈 자동화 전략](docs/release-workflow.md) | `main` publish 전략, release 브랜치, Android/iOS 자동화 단계 |

## 품질 게이트

### Analyzer

기본 `flutter_lints`에 아래 규칙을 추가로 사용합니다.

- `always_use_package_imports`
- `avoid_print`
- `directives_ordering`
- `prefer_final_locals`
- `require_trailing_commas`

### Pre-commit

`lefthook.yml` 기준으로 아래 검사를 실행합니다.

- `fvm dart format --output=none --set-exit-if-changed .`
- `fvm flutter analyze`
- `fvm flutter test`

FVM이 없거나 `.fvmrc`가 없는 환경에서는 lefthook 설정에 따라 일반 `dart`/`flutter` 명령으로 fallback 됩니다.

macOS 환경에서는 아래 순서로 설치하면 됩니다.

```bash
brew install lefthook
lefthook install
```

### CI

GitHub Actions에서 Flutter `3.35.7` 기준으로 아래 작업을 실행합니다.

- `flutter pub get`
- `flutter analyze`
- `flutter test`

## 진행해야 할 작업 내역

남은 작업은 한 번에 묶지 않고 `이슈 생성 -> Project 10 등록 -> develop 기반 브랜치 생성 -> 작업 -> 검증 -> 커밋/푸시 -> PR 생성` 순서로 하나씩 진행합니다.
세부 순서와 이슈/브랜치 단위는 [남은 작업 진행 계획](docs/remaining-work-plan.md)을 기준으로 관리합니다.
계획된 작업 완료 후 새 이슈로 분리할 결정/확인 항목은 [후속 결정 체크리스트](docs/follow-up-decision-checklist.md)에서 관리합니다.

우선순위:

1. [ ] Figma frame map의 `확인 필요` node-id를 최신화합니다.
2. [ ] 프로필 설정, 식물 검색, 메모 화면처럼 백엔드와 무관한 프론트 UX를 보강합니다.
3. [ ] 장소/식물 상세 화면의 mock fallback과 loading/empty/error 상태를 정리합니다.
4. [ ] 공통 form submit/loading/error 패턴을 재사용 가능한 형태로 정리합니다.
5. [ ] User, Place, Plant, Image API 계층을 화면 Provider/Controller에 단계적으로 연결합니다.
6. [ ] 백엔드 확인 필요 항목을 별도 이슈로 분리하고 Swagger 문서를 갱신합니다.
7. [ ] Golden test, integration test, release/signing 정책처럼 아직 결정되지 않은 품질/배포 항목을 확정합니다.
