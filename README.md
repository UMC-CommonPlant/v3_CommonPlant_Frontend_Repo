# CommonPlant Frontend

커먼플랜트 프론트엔드 앱 저장소입니다. 현재 단계에서는 Android/iOS 기반의 공통 개발환경, 테마 토큰, 공용 위젯 베이스를 우선 정리합니다.

## 프로젝트 개요

- 지원 플랫폼: Android, iOS
- 공통 기준 Flutter 버전: `3.35.7`
- 공통 기준 Dart 버전: `3.9.2`
- 기본 명령어 표기: `flutter`
- 선택 사용 도구: FVM (`fvm flutter ...` 형태로 동일 버전에 맞춰 실행 가능)

## 시작하기

### 1. 의존성 설치

```bash
flutter pub get
```

### 2. 앱 실행

```bash
flutter run -d android
flutter run -d ios
```

### 3. 품질 검사

```bash
flutter analyze
flutter test
```

### 4. FVM 사용자 안내

FVM 사용자는 아래처럼 동일한 버전으로 실행하면 됩니다.

```bash
fvm use 3.35.7
fvm flutter pub get
fvm flutter run -d android
```

## 사용 라이브러리

### Runtime

| 이름 | 버전 | 목적 |
| --- | --- | --- |
| `cupertino_icons` | `^1.0.8` | iOS 스타일 아이콘 지원 |
| `go_router` | `^17.2.0` | 앱 라우팅 및 라우트 구조 관리 |
| `flutter_riverpod` | `^3.3.1` | 상태관리 및 의존성 주입 |

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
- 팀 공통 기준은 도구 통일이 아니라 Flutter 버전 통일입니다.
- README의 명령어는 `flutter` 기준으로 유지하고, FVM 사용자는 필요한 경우 `fvm`만 앞에 붙입니다.

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

- `dart format --output=none --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`

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

## 이후 작성 예정

- [ ] 디자인 토큰 규칙 문서
- [ ] 공용 위젯 사용 가이드
- [ ] 라우팅 구조 설명
- [ ] feature 작업 가이드
