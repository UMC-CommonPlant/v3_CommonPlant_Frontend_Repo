# Feature 작업 가이드

커먼플랜트는 feature 중심 구조를 기본으로 합니다. 공통 정책은 `core`, 재사용 UI는 `shared`, 도메인별 화면과 상태는 `features`에 둡니다.

## 현재 구조

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
    common/
      presentation/
        widgets/
    home/
      presentation/
    login/
      presentation/
        pages/
    memo/
      presentation/
        pages/
    onboarding/
      presentation/
        pages/
    place/
      presentation/
        pages/
    plant/
      presentation/
        pages/
    terms/
      presentation/
        pages/
```

현재 `phase 0` 화면 퍼블리싱은 feature별 `presentation/pages`에 배치되어 있습니다. API 연동 전까지 화면 상태는 page 내부의 임시 상태로만 유지하고, 여러 feature에서 공유되는 퍼블리싱 보조 위젯은 `features/common/presentation/widgets`에 둡니다.

## 기본 원칙

- feature는 도메인 단위로 나눕니다.
- 화면은 `presentation`에 두고, API 응답 파싱이나 비즈니스 규칙을 직접 처리하지 않습니다.
- API 모델과 저장소 구현은 `data`에 둡니다.
- 화면에서 쓰는 순수 모델과 핵심 규칙은 필요할 때 `domain`에 둡니다.
- MVP에서는 모든 feature에 `data/domain/presentation`을 기계적으로 만들지 않습니다.
- 실제 코드가 생기는 순간 필요한 계층만 추가합니다.

## 권장 폴더 구조

도메인 로직과 API 연동이 있는 feature는 아래 구조를 기준으로 합니다.

```text
lib/features/place/
  data/
    datasources/
    dtos/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    pages/
    widgets/
    providers/
```

간단한 퍼블리싱 화면만 있는 경우에는 먼저 `presentation`만 만들어도 됩니다.

```text
lib/features/login/
  presentation/
    pages/
    widgets/
```

## 계층별 책임

| 계층 | 책임 |
| --- | --- |
| `data/dtos` | API request/response 모델과 JSON 변환 |
| `data/datasources` | HTTP 호출, 로컬 저장소 접근 |
| `data/repositories` | datasource 결과를 domain 또는 presentation 모델로 변환 |
| `domain/entities` | 화면과 API에 종속되지 않는 핵심 모델 |
| `domain/repositories` | repository interface |
| `domain/usecases` | 여러 repository 호출 또는 비즈니스 규칙 조합 |
| `presentation/pages` | route 단위 화면 |
| `presentation/widgets` | feature 내부에서만 쓰는 위젯 |
| `presentation/providers` | Riverpod Provider, Controller, ViewModel |

## 계층을 추가하는 기준

| 상황 | 권장 |
| --- | --- |
| Figma 화면만 구현 | `presentation/pages`, `presentation/widgets` |
| 화면 상태가 복잡함 | `presentation/providers` 추가 |
| API 응답 모델이 필요함 | `data/dtos` 추가 |
| API 호출이 필요함 | `data/datasources`, `data/repositories` 추가 |
| 동일 규칙이 여러 화면에서 공유됨 | `domain/usecases` 또는 `domain/entities` 추가 |
| 다른 feature에서도 재사용됨 | `core` 또는 `shared` 이동 검토 |

빈 폴더를 미리 만들기보다, 실제 코드가 들어갈 때 함께 추가합니다.

## 네이밍 기준

| 대상 | 예시 |
| --- | --- |
| Page | `PlaceListPage`, `PlantDetailPage` |
| Feature widget | `PlaceMemberList`, `PlantWateringSummary` |
| DTO | `PlaceResponse`, `CreatePlaceRequest` |
| Entity | `Place`, `Plant`, `Memo` |
| Repository interface | `PlaceRepository` |
| Repository implementation | `PlaceRepositoryImpl` |
| Datasource | `PlaceRemoteDataSource` |
| Provider | `placeListProvider`, `placeDetailProvider` |
| Controller | `PlaceCreateController` |

파일명은 snake_case를 사용합니다.

```text
place_list_page.dart
place_repository.dart
place_repository_impl.dart
place_remote_data_source.dart
```

## 공통으로 올릴지 판단하는 기준

`shared/widgets`로 올려도 되는 경우:

- 두 개 이상의 feature에서 동일한 형태와 상호작용으로 사용됩니다.
- 도메인 이름 없이도 의미가 통합니다.
- 상태 변화는 콜백이나 값 주입으로 처리할 수 있습니다.

feature 내부에 남기는 경우:

- 특정 도메인 용어와 정책을 알아야 합니다.
- 한 화면에서만 쓰입니다.
- API 모델이나 feature Provider에 직접 의존합니다.

## API 모델 기준

- 화면 코드에서 `Map<String, dynamic>`을 직접 다루지 않습니다.
- API 연동 시 HTTP 클라이언트는 `dio`를 기준으로 사용합니다.
- API request/response 모델은 `freezed`와 `json_serializable` 기반 생성을 기본 방향으로 합니다.
- 현재 코드베이스에는 아직 codegen 설정이 없으므로, 첫 API 연동 PR에서 `freezed`, `json_serializable`, `build_runner` 도입과 생성 명령을 함께 정리합니다.
- request와 response는 역할이 다르면 클래스를 분리합니다.
- nullable 필드는 서버 명세와 화면 요구사항을 기준으로 명확히 둡니다.
- 날짜 문자열은 DTO에서 보존하되, 화면에 표시하기 전 변환 위치를 정합니다.
- enum 성격 값은 문자열 그대로 흘리지 않고 enum 또는 value object로 감쌉니다.
- mock 데이터와 실제 datasource는 같은 구현체 안에 섞지 않습니다.

## 네트워크 계층 기준

API 연동이 시작되면 `core/network`에 공통 Dio client와 interceptor를 둡니다.

```text
lib/core/network/
  api_client.dart
  api_exception.dart
  auth_interceptor.dart
```

| 파일 | 역할 |
| --- | --- |
| `api_client.dart` | base URL, timeout, Dio instance Provider 구성 |
| `api_exception.dart` | 서버 오류, 네트워크 오류, 인증 오류를 앱 공통 타입으로 변환 |
| `auth_interceptor.dart` | access token 주입, 인증 실패 처리 |

feature의 datasource는 공통 Dio client를 주입받아 사용하고, 화면이나 Controller에서 직접 Dio를 생성하지 않습니다.

실제 API 호출은 기본 개발/테스트 흐름을 깨지 않도록 `COMMONPLANT_USE_API` dart-define으로 켭니다.
base URL은 `COMMONPLANT_API_BASE_URL`로 바꿀 수 있으며 기본값은 서버 Swagger 기준 `https://commonplant.site/api/v1`입니다.

```bash
fvm flutter run --dart-define=COMMONPLANT_USE_API=true
fvm flutter run --dart-define=COMMONPLANT_USE_API=true --dart-define=COMMONPLANT_API_BASE_URL=https://commonplant.site/api/v1
```

Swagger에 성공 response body schema가 없는 API는 mapper에서 확인 가능한 필드만 사용하고, 필수 필드가 없으면 공통 API 오류로 처리합니다. 응답 구조가 확정되기 전까지 화면에서 임의 필드를 직접 읽지 않습니다.

## 작업 순서

1. 요구사항과 Figma 범위를 확인합니다.
2. 기존 `shared/widgets`와 `core/theme` 토큰으로 구현 가능한 부분을 찾습니다.
3. feature 내부에 필요한 page/widget/provider 범위를 정합니다.
4. API 연동이 있으면 DTO, datasource, repository 책임을 먼저 나눕니다.
5. loading, success, empty, error 상태를 UI와 상태 객체에 반영합니다.
6. 테스트가 필요한 단위를 정하고 widget test 또는 unit test를 추가합니다.
7. `fvm dart format`, `fvm flutter analyze`, `fvm flutter test`를 실행합니다.

## 리뷰 체크리스트

- [ ] feature 밖으로 새는 도메인 의존성이 없는가?
- [ ] 공용 위젯으로 뺄 만한 중복 UI가 생기지 않았는가?
- [ ] 화면 코드가 API 파싱이나 저장소 구현을 직접 알지 않는가?
- [ ] 비동기 상태가 loading/success/empty/error로 구분되는가?
- [ ] route parameter와 Provider 입력값이 명확한가?
- [ ] 다음 Place, Plant, Memo 화면에서 재사용할 수 있는 형태인가?

## 결정 필요

- 백엔드 base URL, API versioning, flavor 분리 방식은 API 연동 시점에 확정해야 합니다.
- 백엔드 에러 코드가 확정되면 `api_exception.dart`의 mapping table을 갱신해야 합니다.
