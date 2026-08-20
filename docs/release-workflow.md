# 배포 및 릴리즈 자동화 전략

커먼플랜트는 `develop`을 기본 개발/통합 브랜치로 사용하고, `main`을 실제 배포 가능한 publish 브랜치로 사용합니다. 앱 배포 자동화는 Android와 iOS의 서명 정보, 스토어 계정, 심사/승인 정책이 필요하므로 단계적으로 도입합니다.

## 현재 상태

| 항목 | 상태 |
| --- | --- |
| 기본 브랜치 | `develop` |
| 배포 브랜치 | `main` |
| CI | `.github/workflows/flutter_ci.yml`에서 analyze/test 실행 |
| Android 배포 자동화 | 보류: signing secret과 Play Console 계정 준비 후 도입 |
| iOS 배포 자동화 | 보류: Apple 계정과 signing asset 준비 후 도입 |
| Store 계정/secret | 저장소에 커밋하지 않고 GitHub Secrets/Environments에만 등록 |
| 환경값 주입 | `COMMONPLANT_USE_API`, `COMMONPLANT_API_BASE_URL`을 `dart-define` 또는 CI/CD에서 주입 |
| Flavor 전략 | MVP는 flavor 없는 단일 prod 앱으로 운영하고 환경값은 CI/CD로 주입 |

## MVP 릴리즈 정책

MVP 릴리즈는 자동 업로드보다 재현 가능한 빌드와 승인 흐름을 우선합니다. signing secret과 store 계정이 준비되지 않은 상태에서는 실패하는 workflow를 추가하지 않고 문서와 수동 체크리스트로 보류 사유를 남깁니다.

| 항목 | 확정 정책 |
| --- | --- |
| release branch | 배포 후보는 항상 최신 `develop`에서 `release/x.y.z`로 생성합니다. |
| publish branch | `main`은 실제 배포 가능한 코드만 유지하며 일반 작업을 직접 커밋하지 않습니다. |
| version/tag | release 브랜치에서 `pubspec.yaml` 버전을 올리고, `main` 병합 후 `vX.Y.Z` 태그를 생성합니다. |
| production approval | production 업로드는 자동 제출하지 않고 GitHub Environment manual approval 또는 수동 승인 단계를 둡니다. |
| secret 관리 | signing key, store token, API key는 GitHub Secrets/Environments에만 저장하고 저장소에는 커밋하지 않습니다. |
| store 계정 | Android/iOS store 계정과 앱 등록이 확인되기 전에는 store upload workflow를 만들지 않습니다. |
| release 자동화 | CI 품질 검사는 유지하고, release build 생성 -> 내부 테스트 배포 -> production 후보 순서로 단계 도입합니다. |

현재 단계에서 확정된 보류 기준은 아래와 같습니다.

| 항목 | 보류 사유 | 재개 조건 |
| --- | --- | --- |
| Android store upload | Play Console 앱, service account, signing key가 준비되지 않음 | tester group, Play service account, signing secret 확정 |
| iOS TestFlight upload | Apple Developer/App Store Connect 계정과 signing asset이 준비되지 않음 | Team ID, certificate, provisioning profile, ASC API key 확정 |
| production 자동 제출 | 심사 승인, rollback, release note 승인 흐름이 아직 없음 | 내부 테스트 배포가 안정화되고 manual approval 기준 확정 |
| flavor별 앱 분리 | MVP에서 별도 설치·배포할 dev/staging 앱이 필요하지 않음 | 동시 설치, 별도 배포 채널, 환경별 Firebase 중 하나가 실제로 필요해지는 시점 |

store 계정이 준비되면 Android는 Google Play Internal testing을 우선 검토하고, Play Console 준비가 지연될 때만 Firebase App Distribution을 대체 경로로 검토합니다. iOS는 TestFlight를 내부 테스트 배포 기준으로 사용합니다.

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

- Android: Google Play Internal testing 우선, Play Console 준비 지연 시 Firebase App Distribution 검토
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

## 환경과 flavor 전략

커먼플랜트는 앱 정체성과 실행 환경값을 분리합니다. MVP에서는 별도 Flutter flavor를 만들지 않고 기본 빌드를 단일 prod 앱으로 사용합니다. API 사용 여부와 base URL 같은 실행 환경값은 `dart-define` 또는 CI/CD variables/secrets로 주입합니다.

### MVP 앱 정체성

RELEASE-01은 #209에서 아래와 같이 확정했습니다.

| 항목 | MVP 기준 |
| --- | --- |
| 운영 형태 | 별도 flavor 없는 단일 prod 앱 |
| 사용자 표시 이름 | `커먼플랜트` |
| Android namespace/application id | `com.plant.common` |
| iOS Runner bundle identifier | `com.plant.common` |
| iOS RunnerTests bundle identifier | `com.plant.common.RunnerTests` |
| 앱 아이콘 | v1/v2에서 사용한 집·새싹 브랜드 아이콘 재사용 |
| Firebase | 현재 패키지와 설정 파일이 없고 MVP 요구 기능도 없어 `Not needed` |

아이콘 원본은 같은 GitHub organization의 [v2 iOS appstore 아이콘](https://raw.githubusercontent.com/UMC-CommonPlant/v2_CommonPlant-iOS-refactoring/develop/CommonPlant/CommonPlant/Resource/Assets.xcassets/AppIcon.appiconset/appstore.png)을 사용합니다. 내려받은 원본의 SHA-256은 `c9248b746382f311801fac16808a68a6bd9dae68b41507ebad966df2887135c6`이고, iOS용 알파 채널을 제거한 1024px 기준 파일의 SHA-256은 `35ba51f6505f5e88be39f0019ea65fda50fe841ad299a67a759282c4397424c2`입니다.

dev/staging 앱명과 식별자 suffix는 미리 정하지 않습니다. 별도 설치, 별도 배포 채널, 환경별 Firebase 설정 중 하나가 실제 요구사항이 되면 Android product flavor와 iOS scheme/configuration을 같은 작업에서 도입하고 식별값을 다시 결정합니다.

| 구분 | 관리 대상 | 관리 방식 | 기준 |
| --- | --- | --- | --- |
| Flutter flavor | dev/staging/prod 앱 구분, 앱 이름, application id, bundle id, 아이콘, Firebase 설정 | Android/iOS flavor 설정 | 앱이 설치/배포 채널별로 분리되어야 할 때만 도입 |
| `dart-define` 환경값 | `COMMONPLANT_USE_API`, `COMMONPLANT_API_BASE_URL` | 로컬 실행 명령 또는 CI/CD variables/secrets | 실행 시점마다 바뀌는 값으로 관리 |
| 민감 정보 | signing key, store token, 비공개 API key | GitHub Secrets 또는 배포 도구 secret 저장소 | 저장소에 커밋하지 않음 |

### Flavor 역할

- 현재 기본 빌드는 단일 prod 앱이며 Flutter flavor를 사용하지 않습니다.
- dev/staging 앱은 별도 설치, 배포 채널, 아이콘 또는 Firebase 설정이 필요해질 때만 추가합니다.
- flavor 안에 API base URL을 직접 하드코딩하지 않습니다.
- 명시적인 `prod` flavor를 도입한 뒤에는 `release/*`, `main`, `v*` 태그 기반 workflow에서 사용합니다.
- flavor가 없는 현재 단계에서는 `dart-define` 주입만으로 remote API 모드를 켭니다.

### 환경값 주입

로컬 개발에서는 필요할 때 `dart-define`으로 API mode를 켭니다.

```bash
fvm flutter run \
  --dart-define=COMMONPLANT_USE_API=true \
  --dart-define=COMMONPLANT_API_BASE_URL=https://commonplant.site/api/v1
```

배포 빌드에서는 CI/CD가 환경별 값을 주입합니다.

```bash
fvm flutter build appbundle --release \
  --dart-define=COMMONPLANT_USE_API=true \
  --dart-define=COMMONPLANT_API_BASE_URL=$COMMONPLANT_API_BASE_URL
```

환경값 파일을 사용할 경우 실제 값 파일은 커밋하지 않고, 필요하면 `.example` 파일만 문서용으로 둡니다.

```bash
fvm flutter run --dart-define-from-file=env/local.api.json
fvm flutter build appbundle --release --dart-define-from-file=env/prod.json
```

### 단계별 도입

1. 현재 단계에서는 단일 prod 앱 정체성과 `COMMONPLANT_USE_API`, `COMMONPLANT_API_BASE_URL` 주입 기준을 유지합니다.
2. release workflow를 만들 때 GitHub Environment별 variables/secrets로 환경값을 주입합니다.
3. 별도 앱 설치나 스토어 채널 분리가 필요해지면 Android/iOS `dev`, `staging`, `prod` flavor를 추가합니다.
4. flavor가 추가된 뒤에도 API base URL과 API mode는 CI/CD 주입값을 우선합니다.

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

추천 GitHub Variables:

```text
ANDROID_PACKAGE_NAME
```

초기 workflow는 signing secret과 package name이 준비된 뒤 `fvm flutter build appbundle --release`까지 먼저 자동화합니다. Play Console service account와 internal testing track이 준비되기 전에는 store upload step을 추가하지 않습니다.

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
- MVP 초기에는 GitHub Secrets 기반으로 인증서/프로비저닝을 직접 주입합니다.
- Fastlane match는 팀 공용 signing 저장소와 운영 규칙이 필요해지는 시점에 별도 후속 작업으로 전환합니다.
- 초기에는 TestFlight 업로드까지만 자동화하고, App Store production 제출은 수동 승인 후 진행합니다.

추천 GitHub Secrets:

```text
APP_STORE_CONNECT_API_KEY_ID
APP_STORE_CONNECT_ISSUER_ID
APP_STORE_CONNECT_API_KEY
APPLE_TEAM_ID
IOS_BUNDLE_IDENTIFIER
IOS_CERTIFICATE_P12_BASE64
IOS_CERTIFICATE_PASSWORD
IOS_PROVISIONING_PROFILE_BASE64
MATCH_PASSWORD
```

`MATCH_PASSWORD`는 Fastlane match를 도입할 때만 사용합니다. GitHub Secrets 직접 주입 방식만 사용하는 동안에는 certificate와 provisioning profile secret을 우선합니다.

## Workflow 파일 계획

| 파일 | 목적 | 도입 시점 |
| --- | --- | --- |
| `.github/workflows/flutter_ci.yml` | PR/Push 품질 검사 | 이미 사용 중 |
| `.github/workflows/android_release.yml` | Android release build 및 내부 테스트 업로드 | Android signing, package name, Play 계정 준비 후 |
| `.github/workflows/ios_testflight.yml` | iOS archive 및 TestFlight 업로드 | Apple signing, bundle id, ASC API key 준비 후 |
| `.github/workflows/publish.yml` | `v*` 태그 기반 production 배포 | 내부 배포 안정화와 manual approval 기준 확정 후 |

secret이 준비되기 전에는 release workflow를 추가하지 않습니다. 실패하는 workflow가 기본 브랜치 품질 게이트를 방해할 수 있기 때문입니다.

## 릴리즈 체크리스트

- [ ] `develop`의 주요 PR이 모두 병합되었는가?
- [ ] `release/x.y.z` 브랜치를 `develop`에서 생성했는가?
- [ ] `pubspec.yaml` 버전을 갱신했는가?
- [ ] 릴리즈 노트를 작성했는가?
- [ ] `fvm flutter analyze`를 통과했는가?
- [ ] `fvm flutter test`를 통과했는가?
- [ ] 단일 prod 앱 정체성 또는 도입된 flavor와 환경값 주입 경로가 의도한 대상인가?
- [ ] 운영 배포에서 `COMMONPLANT_USE_API`, `COMMONPLANT_API_BASE_URL` 값이 CI/CD로 주입되는가?
- [ ] Android release build가 생성되거나, signing/store 준비 전 보류 사유가 기록되었는가?
- [ ] iOS archive가 생성되거나, signing/store 준비 전 보류 사유가 기록되었는가?
- [ ] 필요한 signing secret과 store token이 GitHub Secrets/Environments에 등록되었는가?
- [ ] production 환경에 manual approval이 걸려 있는가?
- [ ] QA 승인 또는 내부 테스트 승인이 완료되었는가?
- [ ] `main` PR 리뷰가 완료되었는가?
- [ ] `main` 병합 후 `vX.Y.Z` 태그를 생성했는가?

## 후속 결정 필요

- 별도 설치, 배포 채널, 환경별 Firebase가 필요해지면 dev/staging flavor와 식별값을 새 작업에서 정해야 합니다.
- staging/prod 서버 full base URL과 API versioning 정책을 정해야 합니다.
- 앱 버전과 build number 자동 증가 방식을 정해야 합니다.
- Android Play Console과 Apple Developer/App Store Connect 계정 준비 여부를 확인해야 합니다.
- 내부 테스트 배포 안정화 후 production 제출 자동화 범위를 다시 판단합니다.

## RELEASE-01 작업 이력

| 이슈 | 커밋 | 변경 범위 | 검증 |
| --- | --- | --- | --- |
| #209 | `07c2477` | Android/iOS 표시 이름과 prod application/bundle identifier 적용 | Android debug APK와 iOS simulator app 빌드, 산출물 식별값 확인 |
| #209 | `83945d7` | 기존 v1/v2 브랜드 앱 아이콘을 Android/iOS 전체 규격에 적용 | 20개 파일 크기와 알파 채널 확인, 1024px 원본 시각 검토 |
| #209 | - | 단일 prod 운영, flavor 도입 조건, Firebase `Not needed`와 보류 경계 문서화 | `git diff --check`, format, analyze, 전체 test, Android/iOS debug build |
