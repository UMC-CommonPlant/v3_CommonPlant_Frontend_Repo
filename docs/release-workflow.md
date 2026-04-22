# 배포 및 릴리즈 자동화 전략

커먼플랜트는 `develop`을 기본 개발/통합 브랜치로 사용하고, `main`을 실제 배포 가능한 publish 브랜치로 사용합니다. 앱 배포 자동화는 Android와 iOS의 서명 정보, 스토어 계정, 심사/승인 정책이 필요하므로 단계적으로 도입합니다.

## 현재 상태

| 항목 | 상태 |
| --- | --- |
| 기본 브랜치 | `develop` |
| 배포 브랜치 | `main` |
| CI | `.github/workflows/flutter_ci.yml`에서 analyze/test 실행 |
| Android 배포 자동화 | 미구현 |
| iOS 배포 자동화 | 미구현 |
| Store 계정/secret | 미정 |

## 브랜치 전략

모든 일반 작업은 `develop`에서 파생합니다.

```text
develop
  ├─ feature/login
  ├─ feature/place-list
  ├─ fix/plant-card-overflow
  ├─ docs/release-workflow
  └─ release/1.0.0

main
  └─ v1.0.0
```

| 브랜치 | 역할 | 생성 기준 | 병합 대상 |
| --- | --- | --- | --- |
| `develop` | 기본 개발/통합 브랜치 | 기본 브랜치 | 없음 |
| `feature/*` | 기능 개발 | `develop` | `develop` |
| `fix/*` | 일반 버그 수정 | `develop` | `develop` |
| `docs/*` | 문서 작업 | `develop` | `develop` |
| `chore/*` | 설정/빌드/의존성 작업 | `develop` | `develop` |
| `release/*` | 배포 후보 안정화 | `develop` | `main`, 필요 시 `develop` |
| `hotfix/*` | 운영 긴급 수정 | `main` | `main`, 이후 `develop` |
| `main` | 실제 publish/production 브랜치 | 직접 작업 금지 | 없음 |

`hotfix/*`는 운영 배포 이후 긴급 수정이 필요한 예외 상황에서만 `main`에서 파생합니다. 일반 기능, 문서, 리팩터링, 설정 작업은 항상 `develop`에서 시작합니다.

## 릴리즈 흐름

1. 일반 작업은 `develop`에서 브랜치를 생성합니다.
2. PR을 통해 `develop`에 병합합니다.
3. 배포 후보가 준비되면 `develop`에서 `release/x.y.z` 브랜치를 생성합니다.
4. `release/x.y.z`에서 버전, 빌드번호, 릴리즈 노트, 스토어 메타데이터를 정리합니다.
5. QA가 끝나면 `release/x.y.z`를 `main`으로 PR 보냅니다.
6. `main`에 병합한 뒤 `vX.Y.Z` 태그를 생성합니다.
7. 태그 또는 `main` push를 기준으로 스토어 배포 workflow를 실행합니다.
8. release 브랜치에서만 발생한 버전/문서 수정이 있으면 `develop`에도 반영합니다.

## 배포 자동화 단계

한 번에 production 배포까지 자동화하지 않고 아래 순서로 도입합니다.

### 1단계: Release Build 생성

- Android `.aab` 생성
- iOS archive 생성
- 빌드 산출물을 GitHub Actions artifact로 보관

목표는 서명과 스토어 업로드 전에 release build가 안정적으로 만들어지는지 확인하는 것입니다.

### 2단계: 내부 테스트 배포

- Android: Google Play Internal testing 또는 Firebase App Distribution
- iOS: TestFlight

실제 사용자 배포 전 QA용 빌드를 자동으로 배포합니다.

### 3단계: Production 배포 준비

- `main` 또는 `v*` 태그 기준으로 production candidate를 생성합니다.
- GitHub Environments의 manual approval을 사용해 실수로 운영 배포되는 것을 막습니다.
- Android production track, App Store 제출은 승인 단계 이후 진행합니다.

### 4단계: Production 배포 자동화

- Android production track 업로드
- iOS App Store 제출 또는 TestFlight에서 심사 제출
- 릴리즈 노트와 버전 태그를 함께 관리

초기에는 production 자동 제출보다 internal/test 배포 자동화를 우선합니다.

## 추천 트리거

| 이벤트 | 실행 작업 |
| --- | --- |
| PR to `develop` | format, analyze, test |
| push to `develop` | QA build 또는 내부 테스트 배포 후보 |
| PR to `main` | release quality gate |
| push to `main` | publish build 생성 |
| tag `v*` | 스토어 업로드 workflow 실행 |

운영 배포는 `tag v*` 기준을 추천합니다. `main`에 병합된 모든 커밋이 자동 배포되는 것보다 명시적인 릴리즈 의도가 드러나기 때문입니다.

## 버전 전략

`pubspec.yaml`의 버전은 아래 형식을 따릅니다.

```yaml
version: 1.0.0+1
```

| 값 | 의미 | 관리 기준 |
| --- | --- | --- |
| `1.0.0` | 사용자에게 보이는 앱 버전 | release 브랜치에서 수동 변경 |
| `+1` | store build number | 초기에는 수동, 자동화 후 GitHub run number 검토 |

추천 방향:

- 앱 버전은 `release/x.y.z` 브랜치에서 명시적으로 올립니다.
- build number는 자동화가 안정화되면 GitHub Actions run number 또는 별도 버전 관리 액션으로 전환합니다.
- 태그는 앱 버전과 맞춰 `v1.0.0` 형식으로 생성합니다.

## Android 자동화 기준

Android 배포 자동화에는 아래가 필요합니다.

| 항목 | 설명 |
| --- | --- |
| Keystore | release signing용 keystore |
| Keystore password | keystore 비밀번호 |
| Key alias | signing key alias |
| Key password | signing key 비밀번호 |
| Google Play service account | Play Console 업로드 권한 JSON |
| Package name | Android application id |

추천 GitHub Secrets:

```text
ANDROID_KEYSTORE_BASE64
ANDROID_KEYSTORE_PASSWORD
ANDROID_KEY_ALIAS
ANDROID_KEY_PASSWORD
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON
```

초기 workflow는 `fvm flutter build appbundle --release`까지 먼저 자동화하고, 서명/업로드는 secret 준비 후 추가합니다.

## iOS 자동화 기준

iOS 배포 자동화에는 macOS runner와 Apple 서명 자산이 필요합니다.

| 항목 | 설명 |
| --- | --- |
| App Store Connect API Key | TestFlight/App Store 업로드 권한 |
| Certificate | iOS distribution certificate |
| Provisioning profile | bundle id에 맞는 profile |
| Bundle identifier | iOS 앱 bundle id |
| Team ID | Apple Developer Team ID |

추천 방식:

- Fastlane을 사용해 build, signing, TestFlight 업로드를 관리합니다.
- 인증서/프로비저닝은 Fastlane match 또는 GitHub Secrets 기반으로 관리합니다.
- 초기에는 TestFlight 업로드까지만 자동화하고, App Store production 제출은 수동 승인 후 진행합니다.

추천 GitHub Secrets:

```text
APP_STORE_CONNECT_API_KEY_ID
APP_STORE_CONNECT_ISSUER_ID
APP_STORE_CONNECT_API_KEY
APPLE_TEAM_ID
IOS_BUNDLE_IDENTIFIER
MATCH_PASSWORD
```

## Workflow 파일 계획

| 파일 | 목적 | 도입 시점 |
| --- | --- | --- |
| `.github/workflows/flutter_ci.yml` | PR/Push 품질 검사 | 이미 사용 중 |
| `.github/workflows/android_release.yml` | Android release build 및 내부 테스트 업로드 | Android signing 준비 후 |
| `.github/workflows/ios_testflight.yml` | iOS archive 및 TestFlight 업로드 | Apple signing 준비 후 |
| `.github/workflows/publish.yml` | `v*` 태그 기반 production 배포 | 내부 배포 안정화 후 |

secret이 준비되기 전에는 release workflow를 추가하지 않습니다. 실패하는 workflow가 기본 브랜치 품질 게이트를 방해할 수 있기 때문입니다.

## 릴리즈 체크리스트

- [ ] `develop`의 주요 PR이 모두 병합되었는가?
- [ ] `release/x.y.z` 브랜치를 `develop`에서 생성했는가?
- [ ] `pubspec.yaml` 버전을 갱신했는가?
- [ ] 릴리즈 노트를 작성했는가?
- [ ] `fvm flutter analyze`를 통과했는가?
- [ ] `fvm flutter test`를 통과했는가?
- [ ] Android release build가 생성되는가?
- [ ] iOS archive가 생성되는가?
- [ ] QA 승인 또는 내부 테스트 승인이 완료되었는가?
- [ ] `main` PR 리뷰가 완료되었는가?
- [ ] `main` 병합 후 `vX.Y.Z` 태그를 생성했는가?

## 결정 필요

- Android 배포 대상을 Google Play Internal testing으로 할지 Firebase App Distribution으로 할지 정해야 합니다.
- iOS 인증서 관리를 Fastlane match로 할지 GitHub Secrets로 직접 관리할지 정해야 합니다.
- dev/staging/prod flavor를 둘지 결정해야 합니다.
- 앱 버전과 build number 자동 증가 방식을 정해야 합니다.
- production 배포를 완전 자동화할지, manual approval을 둘지 정해야 합니다.
