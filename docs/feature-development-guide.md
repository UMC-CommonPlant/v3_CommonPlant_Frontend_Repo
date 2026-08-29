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
    config/
    network/
    theme/
  shared/
    forms/
    widgets/
  features/
    friend/
      data/
      domain/
    home/
      presentation/
    image/
      data/
    login/
      data/
      domain/
      presentation/
    memo/
      presentation/
    onboarding/
      presentation/
    place/
      data/
      domain/
      presentation/
    plant/
      data/
      domain/
      presentation/
    terms/
      presentation/
    user/
      data/
      domain/
      presentation/
```

화면은 feature별 `presentation/pages`에 배치합니다. 두 개 이상의 feature에서 같은 의미와 상호작용으로 재사용되는 UI는 `shared/widgets`에 두고, 특정 도메인이나 화면 조합에 가까운 위젯은 해당 feature의 `presentation/widgets`에 둡니다. 소유권이 불분명한 코드를 모으기 위한 `features/common`은 만들지 않습니다.

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
    mappers/
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
lib/features/onboarding/
  presentation/
    pages/
    widgets/
```

## 계층별 책임

| 계층 | 책임 |
| --- | --- |
| `data/dtos` | API request/response 모델과 JSON 변환 |
| `data/datasources` | HTTP 호출, 로컬 저장소 접근 |
| `data/mappers` | 응답 필드 검증과 순수 domain 모델 변환 |
| `data/repositories` | datasource와 mapper를 조합하고 feature 계약을 구현 |
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
- HTTP 클라이언트는 이미 도입된 공통 `dio` client를 사용합니다.
- 현재 request/response 경계는 수기 DTO와 순수 mapper로 구현되어 있으며 관련 테스트로 검증합니다.
- `freezed`, `json_serializable`, `build_runner`는 아직 도입하지 않았습니다. 기존 문서의 codegen 방향은 미적용 제안으로 구분하고, 도입 필요성과 마이그레이션·생성 규칙은 별도 이슈에서 결정합니다.
- request와 response는 역할이 다르면 클래스를 분리합니다.
- nullable 필드는 서버 명세와 화면 요구사항을 기준으로 명확히 둡니다.
- 날짜 문자열은 DTO에서 보존하되, 화면에 표시하기 전 변환 위치를 정합니다.
- enum 성격 값은 문자열 그대로 흘리지 않고 enum 또는 value object로 감쌉니다.
- mock 데이터와 실제 datasource는 같은 구현체 안에 섞지 않습니다.

## 네트워크 계층 기준

현재 `core/network`에 공통 Dio client, 사용자 데이터 세션, 인증 token 저장소·저장 순서 관리, interceptor와 응답 파서가 있습니다.

```text
lib/core/network/
  api_client.dart
  api_exception.dart
  api_response_parser.dart
  auth_interceptor.dart
  auth_token_store.dart
  auth_token_writer.dart
  user_data_session.dart
```

| 파일 | 역할 |
| --- | --- |
| `api_client.dart` | base URL, timeout, 데이터 세션별 Dio 구성·이전 client 종료 |
| `api_exception.dart` | 서버 오류, 네트워크 오류, 인증 오류를 앱 공통 타입으로 변환 |
| `api_response_parser.dart` | 확인된 wrapper·필드 추출과 응답 형식 검증 |
| `auth_interceptor.dart` | 활성 세션의 access token만 주입하고 세션이 바뀐 요청·응답은 취소 처리. 자동 refresh나 서버 logout은 미구현 |
| `auth_token_store.dart` | `flutter_secure_storage` 기반 access/refresh token 읽기·저장·제거 |
| `auth_token_writer.dart` | 인증 시도 유효성 검사와 token 저장·삭제 직렬화. 세션이 바뀌어도 같은 큐 유지 |
| `user_data_session.dart` | 토큰을 담지 않는 세대·활성 상태, 사용자 조회의 세션 의존성과 늦은 후처리 검사 |

feature의 datasource는 공통 Dio client를 주입받아 사용하고, 화면이나 Controller에서 직접 Dio를 생성하지 않습니다.

사용자별 조회 Provider는 API 모드에서 `requireUserDataSession(ref)`로 세션을 구독합니다. 화면용 `AsyncValue`는 `unwrapPrevious()`로 이전 계정 데이터를 숨기고, 변경 Controller는 await 전후의 세션과 Ref를 확인합니다. 인증 저장·삭제는 `AuthTokenWriter`를 거치며 feature가 저장소에 직접 쓰지 않습니다. [상태관리의 세션 격리 기준](state-management-guide.md#사용자-데이터-세션-격리)을 따릅니다.

실제 API 호출은 기본 개발/테스트 흐름을 깨지 않도록 `COMMONPLANT_USE_API` 환경값으로 켭니다.
확인된 dev API base URL은 `https://commonplant-dev.okbear.dev/api/v1`이며 `COMMONPLANT_API_BASE_URL`로 명시적으로 주입합니다.
현재 `lib/core/config/app_environment.dart`의 기본값은 이전 `https://commonplant.site/api/v1`이므로 별도 코드 변경 전에는 기본값에 의존하지 않습니다.
현재는 단일 prod 앱이며 별도 dev/staging flavor는 없습니다. API mode와 base URL은 `dart-define` 또는 CI/CD 주입값으로 관리합니다.

```bash
fvm flutter run \
  --dart-define=COMMONPLANT_USE_API=true \
  --dart-define=COMMONPLANT_API_BASE_URL=https://commonplant-dev.okbear.dev/api/v1
fvm flutter run --dart-define-from-file=env/local.api.json
```

운영 배포에서는 CI/CD가 production 값을 주입해야 하며, 실제 환경값 파일과 secret은 저장소에 커밋하지 않습니다.
필요하면 `.example` 파일만 문서용으로 추가합니다.

Swagger에 성공 response body schema가 없는 API는 mapper에서 확인 가능한 필드만 사용하고, 필수 필드가 없으면 공통 API 오류로 처리합니다. 응답 구조가 확정되기 전까지 화면에서 임의 필드를 직접 읽지 않습니다.

감사에서 확인한 이미지 key 누락은 #248에서 Plant key 보존과 Place 사진 수정의 안전 차단으로, 계정별 캐시는 #249에서 세션 격리로 보완했습니다. #250은 입력 변경 중 제출 잠금을, #251은 원격 식물 등록 장소의 상태·선택·제출과 실제 조회 재시도를 보완합니다. API 비사용 fixture를 원격 조회의 loading/error/empty 대체값으로 사용하지 않습니다. #252는 장소 code 없는 원격 수정의 거짓 성공을 막고 성공 후 관련 조회를 갱신합니다. 현재 Plant 응답에 없는 code를 장소명으로 추측하지 않습니다. #253은 주소 결과의 출처·세션·화면 수명을 검증해 폼에 연결하며 API 모드 fixture를 차단합니다. 실제 주소 검색은 별도 미결정 범위이고, 응답 파서 문제 등 #254~#256은 [개발 감사 체크리스트](development-audit-checklist.md)에서 계속 추적합니다. 위 기준을 이미 모든 경로가 충족한 것으로 해석하지 않습니다.

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

- dev API와 Swagger URL은 #213에서 확인했습니다. staging/prod full base URL과 API versioning 정책은 배포 환경 준비 시 별도로 확정해야 합니다.
- MVP 앱명 `커먼플랜트`와 Android/iOS 식별자 `com.plant.common`은 확정됐습니다. 별도 설치·배포 채널이 필요해지면 dev/staging flavor를 `docs/release-workflow.md` 기준으로 검토합니다.
- 백엔드 에러 코드가 확정되면 `api_exception.dart`의 mapping table을 갱신해야 합니다.
