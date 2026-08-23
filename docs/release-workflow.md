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
| Dev API | `https://commonplant-dev.okbear.dev/api/v1` 확인, 로컬에서 명시적으로 주입 |
| Flavor 전략 | MVP는 flavor 없는 단일 prod 앱으로 운영하고 환경값은 CI/CD로 주입 |
| Version 전략 | `pubspec.yaml`의 `X.Y.Z+N`을 공통 원본으로 두고 release 브랜치에서 수동 증가 |
| Production 제출 정책 | #222에서 동일 artifact 승격, 비실행자 승인, 최초 출시 수동 공개를 확정. 실제 workflow는 외부 준비 전까지 보류 |

## MVP 릴리즈 정책

MVP 릴리즈는 자동 업로드보다 재현 가능한 빌드와 승인 흐름을 우선합니다. signing secret과 store 계정이 준비되지 않은 상태에서는 실패하는 workflow를 추가하지 않고 문서와 수동 체크리스트로 보류 사유를 남깁니다.

| 항목 | 확정 정책 |
| --- | --- |
| release branch | 배포 후보는 항상 최신 `develop`에서 `release/x.y.z`로 생성합니다. |
| publish branch | `main`은 실제 배포 가능한 코드만 유지하며 일반 작업을 직접 커밋하지 않습니다. |
| version/tag | release 브랜치에서 `pubspec.yaml`의 version과 build number를 올리고, `main` 병합 후 version과 같은 `vX.Y.Z` 태그를 생성합니다. |
| production approval | build, store 심사 제출, 사용자 공개를 분리하고 production에 영향을 주는 job은 실행자 외 required reviewer 승인을 거칩니다. |
| secret 관리 | signing key, store token, API key는 GitHub Secrets/Environments에만 저장하고 저장소에는 커밋하지 않습니다. |
| store 계정 | Android/iOS store 계정과 앱 등록이 확인되기 전에는 store upload workflow를 만들지 않습니다. |
| release 자동화 | CI 품질 검사는 유지하고, release build 생성 -> 내부 테스트 배포 -> production 후보 순서로 단계 도입합니다. |

현재 단계에서 확정된 보류 기준은 아래와 같습니다.

| 항목 | 보류 사유 | 재개 조건 |
| --- | --- | --- |
| Android store upload | Play Console 앱, service account, signing key가 준비되지 않음 | tester group, Play service account, signing secret 확정 |
| iOS TestFlight upload | Apple Developer/App Store Connect 계정과 signing asset이 준비되지 않음 | Team ID, certificate, provisioning profile, ASC API key 확정 |
| production workflow 구현 | RELEASE-04 승인 정책은 #222에서 확정했지만 계정, signing, build number, prod API와 내부 배포가 준비되지 않음 | RELEASE-02-B, RELEASE-03, ENV-01-B와 내부 배포 안정성 기준 충족 |
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
4. `release/x.y.z`에서 version, 배포 candidate build number, 릴리즈 노트, 스토어 메타데이터를 정리합니다.
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

- 승인된 `main` 커밋의 `v*` 태그와 내부 테스트에서 검증한 동일 artifact를 production candidate로 고정합니다.
- store metadata, release note, prod 환경값, QA 결과와 중단/hotfix 계획을 검토합니다.
- 심사 제출 job은 GitHub Environment의 비실행자 승인 이후에만 store credential에 접근합니다.

### 4단계: 사용자 공개

- 최초 MVP 출시는 Android/iOS 모두 store 측 수동 공개로 유지합니다.
- 후속 Android 업데이트는 승인된 비율의 staged rollout을, iOS 업데이트는 manual release와 phased release를 선택할 수 있습니다.
- 사용자 공개는 심사 제출과 분리된 두 번째 승인으로 진행하며 unattended full rollout은 허용하지 않습니다.

초기에는 production workflow 구현보다 internal/test 배포 자동화를 우선합니다.

## RELEASE-04 Production 제출 승인 정책

### 결정 요약

RELEASE-04는 정책을 `Decided`로 관리하되 실제 workflow 구현은 `Blocked`로 분리합니다. 허용하는 자동화는 승인된 artifact의 검증, 업로드, 심사 제출 같은 기계적 작업이며, 승인 없이 사용자에게 공개하는 fully automated release는 MVP 범위에서 허용하지 않습니다.

| 단계 | 자동화 허용 범위 | 필요한 승인 | 사용자 노출 |
| --- | --- | --- | --- |
| Candidate | release build, checksum, provenance, artifact 보관 | `main` PR review | 없음 |
| Internal | Google Play Internal testing, TestFlight 업로드 | 내부 배포 권한 | 내부 tester만 |
| Submission | 동일 artifact의 store version 연결, metadata 검증, 심사 제출 | production Environment 비실행자 승인 | 없음 |
| Release | Android rollout 시작 또는 Apple 수동 출시 | 제출 승인과 분리된 명시적 출시 승인 | 있음 |
| Expansion | staged/phased rollout 확대 또는 완료 | 각 확대 시 release owner 확인 | 증가 |

### Build once, promote same artifact

- `release/x.y.z`의 승인된 commit에서 Android/iOS artifact를 한 번 생성합니다.
- artifact에는 commit SHA, `X.Y.Z+N`, 플랫폼, checksum과 build workflow run을 연결합니다.
- 내부 테스트에서 검증한 동일한 signed build를 production으로 승격하며 승인 후 다시 빌드하지 않습니다.
- 코드, 환경값, signing, metadata 변경이 필요하면 기존 candidate를 폐기하고 `N`을 증가한 새 candidate를 만듭니다.
- `vX.Y.Z` 태그를 이동하거나 같은 store build number의 artifact를 교체하지 않습니다.

Android와 iOS는 store 심사와 공개 시점이 다를 수 있으므로 플랫폼별 승인 상태를 따로 기록합니다. 한 플랫폼만 먼저 공개할 경우 release note와 이슈에 비대칭 상태와 후속 일정을 남깁니다.

### 승인 gate

#### Gate 1. Candidate 승인

`release/x.y.z`에서 `main`으로 보내는 PR review가 첫 승인입니다. 아래 증거가 모두 있어야 `main` 병합과 태그 생성을 진행합니다.

- commit SHA와 `X.Y.Z+N`, Android/iOS artifact checksum
- Flutter CI와 release build 결과
- 플랫폼별 내부 테스트 링크와 QA 승인
- production API URL과 `COMMONPLANT_USE_API=true` 주입 확인
- store metadata, 개인정보 표시, release note 검토
- 알려진 문제와 사용자 영향
- rollout 중단 조건, hotfix 담당과 모니터링 방법

#### Gate 2. Store 심사 제출 승인

- production credential을 쓰는 job은 GitHub Environment를 참조합니다.
- Environment에는 required reviewer와 prevent self-review를 적용해 workflow 실행자가 자기 배포를 승인하지 못하게 합니다.
- environment secret은 승인된 job에서만 읽고 candidate build job에는 제공하지 않습니다.
- tag만 push했다고 심사 제출이나 production track 변경이 자동 실행되지 않습니다.
- 2026-08-23 읽기 전용 확인 기준 저장소는 public, 조직은 GitHub Free plan이고 Environment는 0개입니다. public repository의 required reviewer 사용 조건은 충족하지만 계정 소유자와 운영 책임자가 승인하기 전에는 생성하지 않습니다.

#### Gate 3. 사용자 공개 승인

- store 심사 제출과 실제 사용자 공개를 하나의 job으로 합치지 않습니다.
- 심사 승인 결과, 최신 QA 상태, 장애 공지 여부와 출시 시점을 다시 확인합니다.
- 최초 MVP 출시는 store console의 명시적 수동 공개를 사용합니다.
- 후속 업데이트의 staged/phased rollout도 시작 비율 또는 방식이 해당 release 기록에 승인된 경우에만 실행합니다.

GitHub Environment required reviewer는 최대 여섯 사용자/팀을 지정할 수 있지만 한 명의 승인으로 job이 진행될 수 있습니다. 따라서 기술 설정만으로 다중 승인을 가정하지 않고 `main` PR review와 prevent self-review가 적용된 Environment 승인을 서로 다른 gate로 유지합니다.

### 최초 MVP 출시

| 플랫폼 | 제출 이후 정책 | 이유 |
| --- | --- | --- |
| Android | production 공개는 Play Console에서 수동 실행 | Google Play staged rollout은 첫 출시에 사용할 수 없음 |
| iOS | `Manually release this version`을 사용하고 승인 후 `Pending Developer Release`에서 수동 실행 | 심사 승인과 사용자 공개 시점을 분리할 수 있음 |

최초 출시에는 자동 full rollout, 예약 시각 자동 공개, 태그 push 직후 production 공개를 사용하지 않습니다.

### 후속 업데이트 rollout

#### Android

- production update는 release별로 승인한 `userFraction`을 사용하는 staged rollout으로 시작할 수 있습니다.
- 시작 비율을 workflow에 고정하지 않고 release 승인 기록에 남깁니다.
- 확대는 crash/ANR, 핵심 smoke, backend 상태와 사용자 피드백을 확인한 뒤 별도 승인합니다.
- 문제 발견 시 rollout을 `halted`로 바꿔 신규 노출을 중단합니다.
- 이미 업데이트한 사용자는 이전 version으로 자동 복귀하지 않으므로 수정 build number의 hotfix를 준비합니다.
- 첫 출시에는 staged rollout을 적용하지 않습니다.

#### iOS

- 심사 제출 시 자동 공개 대신 manual release를 기본으로 유지합니다.
- 후속 업데이트는 승인 후 7일 phased release를 선택할 수 있습니다.
- phased release는 누적 30일까지 pause할 수 있지만 사용자는 App Store에서 수동으로 update를 받을 수 있습니다.
- pause는 신규 자동 update를 늦출 뿐 이미 설치된 version을 되돌리지 않으므로 문제 시 새 build의 hotfix가 필요합니다.

### 중단과 hotfix 기준

아래 중 하나가 발생하면 rollout 확대 또는 공개를 중단합니다.

- release candidate와 승인된 SHA, version/build, checksum이 다름
- production API/환경값 검증 실패
- 로그인, 핵심 데이터 조회 또는 앱 시작 smoke 실패
- store 심사 metadata와 실제 기능/권한 사용이 일치하지 않음
- blocker 수준의 crash, 데이터 손상, 인증/결제/개인정보 문제가 확인됨
- backend 장애 또는 데이터 무결성 문제로 안전한 사용자 흐름을 보장할 수 없음

`halt`와 `pause`는 rollback이 아닙니다. 이미 배포된 binary를 되돌리기 위해 태그를 이동하거나 기존 build number를 재사용하지 않고 `main`에서 `hotfix/x.y.z`를 만들고 더 큰 `N`의 새 artifact를 제출합니다. 최초 출시 또는 full rollout 이후의 긴급 제거·판매 중지는 store 소유자가 영향과 복구 방법을 확인한 뒤 별도 incident 절차로 수행합니다.

### Workflow 구현 재개 조건

- [ ] RELEASE-02-B에서 양쪽 store 기존 이력보다 큰 최초 build number를 확정했습니다.
- [ ] RELEASE-03에서 앱 등록, role, signing asset과 store credential 소유자를 확인했습니다.
- [ ] ENV-01-B에서 production API full base URL과 versioning을 확정했습니다.
- [ ] Android Internal testing과 iOS TestFlight workflow가 각각 재실행 없는 연속 3회 성공했습니다.
- [ ] 플랫폼별 내부 candidate가 QA 체크리스트를 한 번 이상 완료했습니다.
- [ ] release owner, QA approver, incident/hotfix 담당 역할을 지정했습니다.
- [ ] GitHub Environment 생성과 required reviewer 설정을 계정 소유자/팀이 승인했습니다.
- [ ] release note, 모니터링, halt/pause/hotfix 기록 양식을 준비했습니다.

조건을 충족하면 candidate build, internal upload, store submission, user release를 하나의 무인 workflow로 합치지 않고 독립 job 또는 workflow로 구현합니다.

### RELEASE-04 공식 근거

- [GitHub Deployments and environments](https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments)
- [Google Play tracks API](https://developers.google.com/android-publisher/api-ref/rest/v3/edits.tracks)
- [Google Play staged rollout](https://support.google.com/googleplay/android-developer/answer/6346149)
- [Apple App Store version release option](https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/select-an-app-store-version-release-option)
- [Apple phased release](https://developer.apple.com/help/app-store-connect/update-your-app/release-a-version-update-in-phases)

## 추천 트리거

| 이벤트 | 실행 작업 |
| --- | --- |
| PR to `develop` | format, analyze, test |
| push to `develop` | QA build 또는 내부 테스트 배포 후보 |
| PR to `main` | release quality gate |
| push to `main` | publish build 생성 |
| tag `v*` | production candidate 검증. 승인 없이 심사 제출·사용자 공개하지 않음 |

운영 candidate는 `tag v*` 기준을 사용합니다. tag는 릴리즈 의도를 표시하고 artifact를 고정하지만 배포 승인 자체를 뜻하지 않습니다.

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

| 환경 | Origin | API base URL | 상태 |
| --- | --- | --- | --- |
| dev | `https://commonplant-dev.okbear.dev` | `https://commonplant-dev.okbear.dev/api/v1` | 확인 완료 |
| staging | 미확정 | 미확정 | ENV-01-B Open |
| prod | 미확정 | 미확정 | ENV-01-B Open |

dev Swagger UI는 `https://commonplant-dev.okbear.dev/api/v1/swagger-ui/index.html#`, OpenAPI JSON은 `https://commonplant-dev.okbear.dev/api/v1/api-docs/json`입니다. origin 루트의 `404`는 루트 route가 없다는 뜻이며 Swagger와 `/api/v1` 가용성 판정에 사용하지 않습니다.

로컬 개발에서는 필요할 때 `dart-define`으로 API mode를 켭니다.

```bash
fvm flutter run \
  --dart-define=COMMONPLANT_USE_API=true \
  --dart-define=COMMONPLANT_API_BASE_URL=https://commonplant-dev.okbear.dev/api/v1
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

1. 현재 단계에서는 단일 prod 앱 정체성과 확인된 dev API의 `COMMONPLANT_USE_API`, `COMMONPLANT_API_BASE_URL` 명시적 주입 기준을 유지합니다.
2. release workflow를 만들 때 GitHub Environment별 variables/secrets로 환경값을 주입합니다.
3. 별도 앱 설치나 스토어 채널 분리가 필요해지면 Android/iOS `dev`, `staging`, `prod` flavor를 추가합니다.
4. flavor가 추가된 뒤에도 API base URL과 API mode는 CI/CD 주입값을 우선합니다.

## 버전 전략

RELEASE-02는 #211에서 `pubspec.yaml`을 Android/iOS 공통 단일 원본으로 사용하는 수동 증가 정책으로 확정했습니다.

### 단일 원본과 플랫폼 매핑

버전은 아래 형식을 따릅니다.

```yaml
version: 1.0.0+1
```

| 값 | 역할 | 플랫폼 매핑 | 관리 기준 |
| --- | --- | --- | --- |
| `X.Y.Z` | 사용자에게 보이는 version | Android `versionName`, iOS `CFBundleShortVersionString` | `release/x.y.z`에서 수동 변경 |
| `N` | 배포 artifact를 구분하는 build number | Android `versionCode`, iOS `CFBundleVersion` | 새 배포 candidate마다 수동 증가 후 커밋 |

Android의 `flutter.versionName`/`flutter.versionCode`와 iOS의 `FLUTTER_BUILD_NAME`/`FLUTTER_BUILD_NUMBER`는 Flutter가 `pubspec.yaml`에서 생성한 값을 사용합니다. 플랫폼 프로젝트에 version을 중복 하드코딩하지 않습니다.

### 증가 규칙

- `X.Y.Z`는 `release/x.y.z` 브랜치명, 스토어 version, `vX.Y.Z` 태그와 일치시킵니다.
- 같은 candidate commit에서 만든 Android/iOS artifact는 같은 양의 정수 `N`을 사용하며 두 스토어에 함께 올릴 수 있습니다.
- 로컬 빌드가 실패해 어느 스토어에도 업로드하지 않았다면 같은 `N`으로 수정 빌드를 만들 수 있습니다.
- Android 또는 iOS 배포 채널에 업로드를 시도한 candidate를 대체하는 새 artifact를 만들 때는 두 플랫폼 모두 `N`을 증가합니다.
- 같은 `X.Y.Z`의 TestFlight/Internal testing 후보를 다시 만들 때는 `X.Y.Z`는 유지하고 `N`만 증가합니다.
- 새 정식 version이나 hotfix에서도 Android의 단조 증가 기준을 따르기 위해 `N`을 이전 version보다 크게 유지합니다.
- release 브랜치에서 바뀐 `pubspec.yaml`은 publish 후 `develop`에도 반영해 다음 작업이 이전 번호에서 시작하지 않게 합니다.

### Release build override 기준

- store에 올릴 build는 `pubspec.yaml` 값을 그대로 사용합니다.
- release workflow에서 `--build-name` 또는 `--build-number`로 커밋된 값을 임시 덮어쓰지 않습니다.
- 진단용 로컬 override artifact는 배포하지 않으며 검증 기록에도 release candidate로 남기지 않습니다.
- `vX.Y.Z` 태그는 build number를 포함하지 않고, 최종 승인된 `X.Y.Z+N` 커밋을 가리킵니다.

### MVP 자동 증가 결정

MVP에서는 `GITHUB_RUN_NUMBER`나 별도 versioning action을 build number 원본으로 사용하지 않습니다.

- `GITHUB_RUN_NUMBER`는 특정 workflow별 번호이므로 Android/iOS workflow가 나뉘거나 workflow가 교체되면 공통 store 이력과 일치한다고 보장할 수 없습니다.
- CI에서만 값을 덮어쓰면 Git commit과 실제 배포 artifact의 version이 달라져 재현과 추적이 어려워집니다.
- 별도 action은 현재 필요한 수동 변경 하나보다 의존성과 실패 지점을 늘립니다.

자동 증가는 RELEASE-03에서 Play Console/App Store Connect 조회 권한과 기존 최대 build number를 확인한 뒤 store-aware 방식으로 다시 검토합니다. 도입할 때는 두 플랫폼의 기존 번호보다 큰 하나의 `N`을 결정하고, 그 값을 source에 반영하는 경계까지 함께 설계합니다.

### 최초 업로드 전 확인

현재 `version: 1.0.0+1`은 개발 기본값이며 store upload 번호로 확정된 값이 아닙니다. 같은 `com.plant.common` bundle identifier를 사용한 [v2 iOS 프로젝트](https://github.com/UMC-CommonPlant/v2_CommonPlant-iOS-refactoring/blob/develop/CommonPlant/CommonPlant.xcodeproj/project.pbxproj)에 marketing version `1.0`, build `1` 설정이 남아 있으므로 `+1`은 이전 업로드와 충돌할 수 있습니다.

Play Console과 App Store Connect가 준비되면 아래 순서로 최초 번호를 확정합니다.

1. 두 스토어에서 `com.plant.common`의 기존 version/build 이력을 확인합니다.
2. Android의 최대 `versionCode`와 iOS의 대상 version/build 이력보다 큰 공통 `N`을 선택합니다.
3. `release/x.y.z`의 `pubspec.yaml`에 `X.Y.Z+N`을 커밋합니다.
4. 기본 Flutter build 명령으로 Android/iOS artifact를 만들고 산출물의 version을 다시 확인합니다.

이 확인은 store 계정과 권한이 필요한 RELEASE-02-B/RELEASE-03 범위이며, 확인 전에는 현재 `+1` artifact를 업로드하지 않습니다.

### Release version 검증

- release 브랜치의 `x.y.z`와 `pubspec.yaml`의 `X.Y.Z`가 같은가?
- `N`이 양의 정수이고 두 스토어에서 이미 사용한 최대 번호보다 큰가?
- 새 배포 candidate라면 이전 업로드 시도보다 `N`이 증가했는가?
- build 명령에 version override가 없는가?
- Android artifact의 `versionName`/`versionCode`가 `X.Y.Z`/`N`과 같은가?
- iOS artifact의 `CFBundleShortVersionString`/`CFBundleVersion`이 `X.Y.Z`/`N`과 같은가?
- `vX.Y.Z` 태그가 최종 승인된 `X.Y.Z+N` 커밋을 가리키는가?

### 공식 참고

- [Flutter Android version 갱신](https://docs.flutter.dev/deployment/android#update-the-apps-version-number)
- [Android 앱 version 관리](https://developer.android.com/studio/publish/versioning)
- [Apple 배포용 version과 build string](https://developer.apple.com/documentation/Xcode/preparing-your-app-for-distribution)
- [App Store Connect build 업로드](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds)
- [GitHub Actions 기본 변수](https://docs.github.com/en/actions/reference/workflows-and-actions/variables)

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
| `.github/workflows/publish.yml` | 승인된 `v*` candidate의 심사 제출과 사용자 공개 gate | RELEASE-04 재개 조건 전체 충족 후 |

secret이 준비되기 전에는 release workflow를 추가하지 않습니다. 실패하는 workflow가 기본 브랜치 품질 게이트를 방해할 수 있기 때문입니다.
release workflow를 추가할 때도 `GITHUB_RUN_NUMBER`로 `pubspec.yaml`의 build number를 덮어쓰지 않습니다.

## 릴리즈 체크리스트

- [ ] `develop`의 주요 PR이 모두 병합되었는가?
- [ ] `release/x.y.z` 브랜치를 `develop`에서 생성했는가?
- [ ] `pubspec.yaml`의 `X.Y.Z+N`을 갱신하고 release 브랜치명과 version을 일치시켰는가?
- [ ] `N`이 두 스토어의 기존 최대 build number보다 크고 이전 업로드에서 재사용되지 않았는가?
- [ ] 릴리즈 노트를 작성했는가?
- [ ] `fvm flutter analyze`를 통과했는가?
- [ ] `fvm flutter test`를 통과했는가?
- [ ] 단일 prod 앱 정체성 또는 도입된 flavor와 환경값 주입 경로가 의도한 대상인가?
- [ ] 운영 배포에서 `COMMONPLANT_USE_API`, `COMMONPLANT_API_BASE_URL` 값이 CI/CD로 주입되는가?
- [ ] Android release build가 생성되거나, signing/store 준비 전 보류 사유가 기록되었는가?
- [ ] iOS archive가 생성되거나, signing/store 준비 전 보류 사유가 기록되었는가?
- [ ] 필요한 signing secret과 store token이 GitHub Secrets/Environments에 등록되었는가?
- [ ] production Environment에 required reviewer와 prevent self-review가 적용되었는가?
- [ ] QA 승인 또는 내부 테스트 승인이 완료되었는가?
- [ ] 내부 테스트와 production이 동일 checksum의 artifact를 사용하는가?
- [ ] store 심사 제출과 사용자 공개 승인이 분리되어 있는가?
- [ ] 최초 출시라면 Android staged rollout을 사용하지 않고 양쪽 store 수동 공개를 선택했는가?
- [ ] 업데이트라면 Android 시작 비율 또는 iOS phased release 선택을 기록했는가?
- [ ] halt/pause가 rollback이 아님을 반영한 hotfix 담당과 새 build number 계획이 있는가?
- [ ] `main` PR 리뷰가 완료되었는가?
- [ ] `main` 병합 후 `vX.Y.Z` 태그를 생성했는가?

## 후속 결정 필요

- 별도 설치, 배포 채널, 환경별 Firebase가 필요해지면 dev/staging flavor와 식별값을 새 작업에서 정해야 합니다.
- dev API와 Swagger endpoint는 확인됐습니다. staging/prod 서버 full base URL과 API versioning 정책은 별도로 정해야 합니다.
- 최초 store build number는 Play Console/App Store Connect의 기존 업로드 이력을 확인한 뒤 정해야 합니다.
- Android Play Console과 Apple Developer/App Store Connect 계정 준비 여부를 확인해야 합니다.
- RELEASE-04 정책은 #222에서 확정했습니다. 실제 production workflow는 RELEASE-02-B/03, ENV-01-B와 내부 배포 안정성 조건이 충족된 뒤 별도 구현합니다.

## RELEASE-01 작업 이력

| 이슈 | 커밋 | 변경 범위 | 검증 |
| --- | --- | --- | --- |
| #209 | `07c2477` | Android/iOS 표시 이름과 prod application/bundle identifier 적용 | Android debug APK와 iOS simulator app 빌드, 산출물 식별값 확인 |
| #209 | `83945d7` | 기존 v1/v2 브랜드 앱 아이콘을 Android/iOS 전체 규격에 적용 | 20개 파일 크기와 알파 채널 확인, 1024px 원본 시각 검토 |
| #209 | - | 단일 prod 운영, flavor 도입 조건, Firebase `Not needed`와 보류 경계 문서화 | `git diff --check`, format, analyze, 전체 test, Android/iOS debug build |

## RELEASE-02 작업 이력

| 이슈 | 커밋 | 변경 범위 | 검증 |
| --- | --- | --- | --- |
| #211 | - | `pubspec.yaml` 단일 원본, 수동 증가, 번호 재사용 금지, CI override 금지와 store 이력 보류 경계 문서화 | 현재 플랫폼 매핑과 v2 설정 확인, Flutter/Android/Apple/GitHub 공식 문서 대조, `git diff --check` |

## RELEASE-04 작업 이력

| 이슈 | 커밋 | 변경 범위 | 검증 |
| --- | --- | --- | --- |
| #222 | `1df75c3` | production 제출/공개 승인 gate, 동일 artifact 승격, 최초 출시와 후속 rollout, halt/pause/hotfix 경계 확정 | GitHub/Google Play/Apple 공식 문서와 저장소 Environment 상태 대조, `git diff --check` |
