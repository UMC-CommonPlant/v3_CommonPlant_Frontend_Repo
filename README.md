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

이 저장소는 커먼플랜트 Flutter 프론트엔드 앱 저장소입니다. Android/iOS 공통 개발환경 위에서 인증, 장소, 식물, 메모 도메인의 화면·상태관리·API 경계를 구현하고 있습니다.

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

### 5. 개발 API 확인

- 개발 서버 origin: `https://commonplant-dev.okbear.dev`
- 개발 API base URL: `https://commonplant-dev.okbear.dev/api/v1`
- Swagger UI: [CommonPlant dev Swagger](https://commonplant-dev.okbear.dev/api/v1/swagger-ui/index.html#)
- OpenAPI JSON: [CommonPlant dev OpenAPI](https://commonplant-dev.okbear.dev/api/v1/api-docs/json)

개발 서버 루트에는 화면이나 API route가 없어 `https://commonplant-dev.okbear.dev/` 요청은 `404`가 정상입니다. 서버 확인은 Swagger UI 또는 실제 `/api/v1` endpoint를 사용합니다.

현재 앱 코드의 기본 URL은 별도 변경 전까지 이전 값을 유지하므로 dev API를 실행할 때는 base URL을 명시합니다.

```bash
fvm flutter run \
  --dart-define=COMMONPLANT_USE_API=true \
  --dart-define=COMMONPLANT_API_BASE_URL=https://commonplant-dev.okbear.dev/api/v1
```

## 사용 라이브러리

### Runtime

| 이름 | 버전 | 목적 |
| --- | --- | --- |
| `cupertino_icons` | `^1.0.8` | iOS 스타일 아이콘 지원 |
| `go_router` | `^17.2.0` | 앱 라우팅 및 라우트 구조 관리 |
| `flutter_riverpod` | `^3.3.1` | 상태관리 및 의존성 주입 |
| `flutter_svg` | `^2.2.0` | SVG 아이콘 렌더링 |
| `dio` | `^5.9.2` | 공통 HTTP client와 multipart API 요청 |
| `flutter_secure_storage` | `^10.2.0` | 인증 access/refresh token 보관 |

### Development

| 이름 | 버전 | 목적 |
| --- | --- | --- |
| `flutter_test` | `sdk:flutter` | 위젯 테스트 및 기본 테스트 러너 |
| `integration_test` | `sdk:flutter` | 실제 앱과 디바이스 기반 integration smoke 실행 |
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
    config/
    network/
    theme/
  shared/
    forms/
    widgets/
  features/
    <feature>/
      data/
      domain/
      presentation/
test/
  app/router/
  core/
  features/
  helpers/
  shared/widgets/
integration_test/
  app_smoke_test.dart
tool/
  svg/                         # SVG 최적화 보수 설정
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
- HTTP 클라이언트는 `core/network`의 공통 `dio` client를 사용하며 feature datasource에 주입합니다.
- MVP 앱은 `커먼플랜트`, Android/iOS 식별자 `com.plant.common`인 단일 prod 앱으로 운영합니다.
- 실제 API 사용 여부와 base URL은 `dart-define` 또는 CI/CD 환경값으로 주입합니다. dev/staging flavor는 별도 설치·배포 채널·환경별 Firebase가 필요해질 때 도입합니다.
- dev API base URL은 `https://commonplant-dev.okbear.dev/api/v1`이며, staging/prod URL은 별도 확인 전까지 확정하지 않습니다.
- 앱 version과 build number는 `pubspec.yaml`의 `X.Y.Z+N`을 단일 원본으로 사용하고 release 브랜치에서 수동 증가합니다. store 이력 확인 전에는 CI 실행 번호로 덮어쓰지 않습니다.
- Production 제출은 내부 테스트에서 검증한 동일 artifact를 승격하고, 심사 제출과 사용자 공개를 분리해 실행자 외 승인을 받습니다. 최초 MVP 출시는 Android/iOS 모두 수동 공개하며 unattended full rollout은 사용하지 않습니다.
- 현재 API 모델은 수기 DTO·mapper로 구현되어 있습니다. `freezed`·`json_serializable` 도입은 미적용 제안이며, 별도 이슈에서 필요성과 생성 규칙을 정하기 전까지 현행 방식을 따릅니다.
- 인증 토큰은 `flutter_secure_storage`에 보관합니다. #249에서 계정별 데이터 세션과 토큰 저장·삭제 순서를 분리해 이전 계정의 조회·후처리가 새 계정에 섞이지 않도록 구현했습니다. 서버 token 갱신·로그아웃 API와 실제 인증 E2E는 별도이며, [작업 이력](docs/work-history/session-cache-isolation-249.md)에서 검증 범위와 제한을 확인합니다.
- 백엔드 에러 코드는 아직 미정이므로, 확정 전까지는 공통 에러 타입으로 감쌀 수 있는 구조를 우선합니다.
- Golden test는 `OnboardingPage`의 `375×812`, DPR 1 pilot과 Ubuntu canonical baseline을 기준으로 사용합니다.
- Integration test는 remote API를 사용하지 않는 Home 진입과 장소 친구 요청 이동을 Android smoke pilot으로 사용합니다. dev API URL은 준비됐지만 [remote integration test 준비 계약](docs/remote-integration-test-readiness.md)의 인증, 데이터 격리, cleanup, secret 승인 gate가 충족되기 전까지 end-to-end 범위는 `Blocked`입니다.

## 프로젝트 문서

새 작업은 현행 가이드와 실행 체크리스트를 기준으로 시작합니다. 기능별 구현·검증 이력은 [문서 인덱스](docs/README.md)에서 확인하고, 제거된 과거 계획은 Git 이력과 기존 이슈·PR에서 조회합니다.

| 문서 | 설명 |
| --- | --- |
| [문서 인덱스](docs/README.md) | 현행 가이드, 실행 계획, 과거 기록, 작업 이력의 진입점 |
| [개발 감사·개선 체크리스트](docs/development-audit-checklist.md) | 문서 우선 정리, 순차 수정할 문제와 개별 이슈, 미사용 위젯 보존 결정 |
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
| [품질·테스트 후속 작업 계획](docs/quality-testing-follow-up-plan.md) | QA 필수 viewport, golden/integration test 도입 순서, Ready/Blocked 경계 |
| [Remote integration test 준비 계약](docs/remote-integration-test-readiness.md) | dev API E2E의 인증, fixture, cleanup, secret과 단계별 도입 gate |
| [화면·모델·API 실연동 전환 계획](docs/screen-api-integration-plan.md) | mock 화면을 사용자 동선별 상태·모델·dev API 수직 슬라이스로 전환하는 우선순위와 완료 기준 |
| [API Swagger 연계 참고 문서](docs/api-swagger-reference.md) | 서버 Swagger 변경사항, API 계층 반영 가능 항목, 백엔드 확인 필요 항목 |
| [백엔드 API 확인 질문 목록](docs/backend-api-open-questions.md) | Swagger와 API 계층 기준으로 분리한 백엔드 확인 질문 목록 |
| [구현 허용 위험 등록부](docs/accepted-implementation-risks.md) | MVP 우선 구현으로 수용한 API·데이터 위험과 해소·중단 조건 |
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

기본 `Flutter CI / quality`는 `develop` 대상 PR에서 자동 실행되는 required check입니다. `develop` push에서도 병합 후 통합 상태를 다시 검증하며, feature branch push와 PR 이벤트의 중복 실행은 만들지 않습니다.

`Android Integration Smoke`는 Android emulator에서 API 비사용 앱 시작과 route 이동을 확인하는 수동 workflow입니다. #218에서 `develop` 수동 실행 3회가 재시도 없이 연속 성공했고 job 실행 시간은 5분 1초~7분 32초였습니다. #224에서 기본 Flutter CI만 필수 게이트로 사용하고 Android smoke는 관련 변경과 release candidate에서 선택 실행하기로 결정했습니다.

## 현재 진행 상태와 다음 작업

2026-08-31 `develop`의 PR #270 병합 상태(`dac3001`)를 기준으로 합니다. Epic #226의 하위 이슈 20/20과 감사 #248~#256이 완료되어 Epic과 Project 상태를 `Done`으로 종료했습니다. 이는 실제 인증 E2E나 모든 화면 동선의 완성을 뜻하지 않으며, 후속 실행 범위는 [화면·모델·API 연결 계획](docs/screen-api-integration-plan.md#후속-개발-실행-순서-267)에서 관리합니다.

현재 우선순위는 사용자 결정에 따라 다음과 같습니다.

1. #267 / PR #268에서 #256·Epic #226의 병합 완료 상태와 아래 실행·보류 범위를 문서에 동기화했습니다.
2. #271에서 Home 친구 요청 배지의 loading·조회 실패·정상 0건·성공 수를 구분하고 오류 재시도를 연결합니다.
3. `PLANT-01`·`SEARCH-02` 계약 확인 뒤 Plant 소속 장소 code와 식물 검색 잔여 동선을 연결합니다.
4. `ERROR-01~02`·`TOKEN-01~02` 답변 뒤 공통 오류 메시지와 인증 만료·세션 종료 흐름을 연결합니다.
5. Place 멤버 식별자·변경 endpoint와 Friend 고유 대상·부분 결과 계약 뒤 쓰기 동선을 연결합니다.
6. `MEMO-01~03` 계약 뒤 Memo 생성·목록·수정·삭제를 화면 상태부터 API까지 연결합니다.

로그인 SDK, 실제 주소 검색 서비스, 업로드 방식 변경이 필요한 이미지 흐름, 인증된 원격 E2E, 스토어·릴리즈 준비는 사용자가 다음 작업으로 보류했습니다. 기존 안전 차단과 질문·위험 기록은 유지하며 이 항목들이 위 실행 순서를 막는 전역 blocker가 되지 않게 분리합니다.

완료되어 현행 문서로 대체된 초기 계획은 저장소에 중복 보관하지 않으며 Git 이력과 기존 이슈·PR에서 조회합니다. 새 작업도 `중복 확인·이슈 생성 -> Project 10 등록 -> develop 기반 브랜치 -> 검증·커밋·푸시 -> PR` 순서를 따르고, PR 병합은 사용자가 진행합니다.
