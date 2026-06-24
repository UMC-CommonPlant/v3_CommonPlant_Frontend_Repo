# lib 구조 리팩토링 개선 방향

## 목적

현재 `lib` 폴더의 구조, Riverpod 활용, 라우팅 연결, 화면 파일 책임, feature 경계를 점검하고 MVP 이후 리팩토링을 어떤 순서로 진행할지 정리합니다.

이 문서는 즉시 전체 구조를 갈아엎기 위한 설계서가 아니라, 기존 테스트와 화면 동작을 유지하면서 작은 PR 단위로 개선하기 위한 기준입니다.

## 참고 문서

- `README.md` 프로젝트 문서 섹션
- `docs/feature-development-guide.md`
- `docs/state-management-guide.md`
- `docs/routing-guide.md`
- `docs/testing-guide.md`
- `docs/git-workflow.md`

## 현재 상태 요약

- `lib`에는 Dart 파일 90개, 약 13,441줄이 있습니다.
- `features` 바로 아래에는 `common`, `friend`, `home`, `image`, `login`, `memo`, `onboarding`, `place`, `plant`, `terms`, `user` 11개 영역이 있습니다.
- `shared/widgets`에는 공용 위젯 21개, 약 2,817줄이 있습니다.
- `test`에는 Dart 테스트 파일 35개가 있고, route, page, repository, datasource, DTO, shared widget 테스트가 이미 존재합니다.
- 라우트는 `app/router`에 모여 있고, phase 0 기준 route-level screen 18개가 실제 page에 연결되어 있습니다.
- API 연동을 위한 `core/network`, feature별 `data/datasources`, `data/repositories`, 일부 `domain/entities`가 이미 생겨 있습니다.

큰 화면 파일은 아래에 집중되어 있습니다.

| 파일 | 줄 수 | 주요 책임 |
| --- | ---: | --- |
| `lib/features/plant/presentation/pages/plant_detail_page.dart` | 865 | 식물 상세 조회, mock 병합, 삭제, dialog, 메모 preview, 상세 UI |
| `lib/features/place/presentation/pages/place_detail_page.dart` | 857 | 장소 상세 조회, mock 병합, 장소 나가기, 상태 UI, 친구/식물 리스트 |
| `lib/features/login/presentation/pages/profile_setup_page.dart` | 852 | 닉네임 입력, 약관 상태, 이미지 sheet/dialog, Figma 위치 기반 layout |
| `lib/features/plant/presentation/pages/plant_form_page.dart` | 732 | 식물 생성/수정 분기, 장소 선택, API 호출, local state 갱신 |
| `lib/features/home/presentation/home_screen.dart` | 602 | 홈 hero, place/plant 목록 상태, navigation, bottom tab UI |
| `lib/features/place/presentation/pages/place_form_page.dart` | 527 | 장소 생성/수정 분기, API 호출, local state 갱신, route 이동 |

## 핵심 진단

### 1. Riverpod이 상태 경계보다 조건 분기에 가깝게 쓰이고 있음

현재 Provider는 의존성 주입과 일부 목록 상태에는 사용되고 있지만, 화면별 사용자 액션과 비동기 전이는 page 내부에 많이 남아 있습니다.

대표 사례:

- `PlaceFormPage`, `PlantFormPage`, `PlaceDetailPage`, `PlantDetailPage`가 `useRemoteApiProvider`를 직접 읽고 remote/local 동작을 분기합니다.
- 생성/수정/삭제 성공 후 `ref.invalidate(...)`, local notifier 갱신, route 이동, snackbar 표시가 page 메서드에 섞여 있습니다.
- `PlaceListNotifier`, `PlantListNotifier`, `MemoListNotifier`는 API 전환 전 local/mock 상태 역할을 하지만 실제 서버 상태 Provider와 같은 화면에서 함께 소비됩니다.
- `place_list_provider.dart`, `plant_list_provider.dart`는 목록, 상세, 등록용 장소, 수정 정보 Provider가 한 파일에 섞여 있습니다.

개선 방향:

- page는 route argument를 받고 Provider 상태를 렌더링하는 역할로 축소합니다.
- 사용자 액션은 `AsyncNotifierProvider` 또는 `NotifierProvider` 기반 controller로 분리합니다.
- local/mock 구현과 remote 구현은 화면의 `if (useRemoteApi)`가 아니라 repository/provider override 경계에서 갈라지게 합니다.
- list, detail, form controller Provider 파일을 분리해 watch 범위와 테스트 범위를 작게 만듭니다.

### 2. 라우트 연결은 되어 있지만 parameter 경계가 약함

`app_routes.dart`는 route spec과 builder switch를 통해 모든 route-level page를 연결합니다. 다만 일부 route parameter가 없을 때 빈 문자열로 page에 전달됩니다.

대표 사례:

- `state.pathParameters['placeId'] ?? ''`
- `state.pathParameters['plantId'] ?? ''`
- query parameter `placeId`, `name`, `role`을 page 생성 시 바로 문자열로 넘김

이 방식은 route가 잘못 호출돼도 빠르게 실패하지 않고, page 내부에서 빈 값 상태로 진행될 수 있습니다.

개선 방향:

- `requiredPathParam(state, 'placeId')` 같은 router helper를 추가해 필수 parameter 누락을 route 계층에서 처리합니다.
- query parameter도 `PlantEditRouteArgs`, `TermsRouteArgs`처럼 route 계층에서 의미 있는 값으로 정규화합니다.
- 인증 상태가 확정되면 `appRouterProvider`가 auth state를 watch하고 redirect를 담당하게 합니다.
- page 내부에서 인증 여부나 route raw parameter를 직접 판단하지 않게 합니다.

### 3. 화면 파일이 route, 상태, mock data, 세부 UI를 동시에 가짐

대형 page 파일에는 아래 책임이 함께 들어 있습니다.

- route page class
- `TextEditingController`, `FocusNode`, `FormSubmitController`
- API 호출과 Provider invalidate
- mock data class와 sample list
- dialog, bottom sheet, popup
- 화면 전용 section widget
- empty/loading/error 상태 UI

이 구조는 초기 퍼블리싱 속도에는 유리하지만, API 연동과 상태 테스트가 늘면 한 화면을 수정할 때 읽어야 할 범위가 지나치게 커집니다.

개선 방향:

- route page는 `pages/`에 유지합니다.
- 화면 전용 section은 `presentation/widgets/`로 이동합니다.
- 화면 상태 모델과 controller는 `presentation/providers/`로 이동합니다.
- mock/sample data는 `presentation/fixtures/` 또는 테스트 fixture로 분리합니다. 실제 API 모드와 같은 파일에서 섞지 않습니다.
- `PlantStateScaffold`처럼 이미 분리된 상태 UI는 Place/Memo에도 비슷한 패턴으로 확장합니다.

### 4. feature 계층 의존 방향이 일부 무너져 있음

문서 기준으로 화면은 API request/response 모델과 repository 구현을 직접 알지 않는 것이 좋습니다. 현재는 presentation page가 data 계층을 직접 import하는 지점이 있습니다.

대표 사례:

- `place_form_page.dart`가 `place_requests.dart`, `place_repository.dart`를 직접 import합니다.
- `plant_form_page.dart`가 `plant_requests.dart`, `plant_repository.dart`를 직접 import합니다.
- `place_detail_page.dart`, `plant_detail_page.dart`가 repository를 직접 읽어 삭제/나가기 API를 호출합니다.

개선 방향:

- page는 data DTO를 만들지 않고 form/controller input model을 넘깁니다.
- controller 또는 usecase가 DTO 변환과 repository 호출을 담당합니다.
- repository Provider 선언은 유지하되, page에서 직접 접근하는 대신 feature controller Provider가 의존하게 합니다.
- `friend`, `image`처럼 raw `Object?`를 반환하는 repository는 API 응답 타입이 확정되는 순서대로 domain/entity 또는 DTO mapper를 추가합니다.

### 5. API mapper와 repository 책임이 붙어 있음

`place_repository.dart`, `plant_repository.dart`, `user_repository.dart`는 repository 구현, Provider 선언, JSON mapper가 한 파일에 있습니다. 현재 규모에서는 동작하지만 API 응답이 늘면 mapper 테스트와 repository 테스트의 경계가 흐려집니다.

개선 방향:

- `data/mappers/` 또는 `data/dtos/` 하위에 mapper 함수를 분리합니다.
- repository는 datasource 호출과 mapper 조합만 담당합니다.
- `api_response_parser.dart`의 fallback key 정책은 임시 호환 전략으로 유지하되, Swagger 응답이 확정된 API부터 명시적 DTO로 교체합니다.
- `ApiException`은 status/code별 사용자 메시지 매핑이 필요한 시점에 공통 error model로 확장합니다.

### 6. shared와 features/common의 기준이 흐려질 수 있음

`shared/widgets`에는 공용 버튼, 입력창, 카드, dialog, scaffold 등 실제로 재사용 가치가 있는 컴포넌트가 많습니다. 동시에 일부 컴포넌트는 특정 화면의 Figma 조합에 강하게 묶일 가능성이 있습니다.

개선 방향:

- 두 개 이상의 feature에서 같은 의미와 상호작용으로 쓰이는 것만 `shared/widgets`에 둡니다.
- 도메인 용어가 들어가거나 한 화면의 조합에 가까운 위젯은 feature 내부 `presentation/widgets`로 내립니다.
- `features/common/presentation/widgets/phase0_widgets.dart`는 phase 0 보조 위젯이라는 임시 성격이 강하므로, 계속 쓸 컴포넌트와 제거할 컴포넌트를 분리합니다.
- 공용 위젯 파일이 300줄을 넘는 경우 variant, style, primitive를 분리할지 검토합니다.

### 7. 테스트는 넓게 있으나 controller 단위 테스트가 부족해질 가능성이 큼

현재 테스트는 route/page/repository/datasource/DTO/shared widget을 넓게 커버합니다. 다만 page가 많은 책임을 갖고 있어 상태 전이 테스트가 widget test에 몰릴 가능성이 있습니다.

개선 방향:

- form submit, create/update/delete, invalidate 대상, 실패 메시지는 controller unit test로 옮깁니다.
- widget test는 렌더링, 버튼 상태, loading/empty/error/success 분기에 집중합니다.
- route parameter 누락/정규화 테스트를 router test에 추가합니다.
- Provider override가 쉬운 구조를 유지해 네트워크 없는 테스트를 보장합니다.

## 권장 목표 구조

모든 feature에 계층을 기계적으로 만들 필요는 없습니다. 다만 API와 상태 전이가 있는 feature는 아래 구조를 목표로 둡니다.

```text
lib/features/place/
  data/
    datasources/
      place_remote_data_source.dart
    dtos/
      place_requests.dart
      place_responses.dart
    mappers/
      place_mapper.dart
    repositories/
      place_repository_impl.dart
  domain/
    entities/
      place_summary.dart
      place_detail.dart
    repositories/
      place_repository.dart
  presentation/
    pages/
      place_detail_page.dart
      place_form_page.dart
    providers/
      place_list_provider.dart
      place_detail_provider.dart
      place_form_controller.dart
      place_exit_controller.dart
    widgets/
      place_detail_header.dart
      place_plant_list.dart
      place_form_fields.dart
    fixtures/
      place_detail_fixture.dart
```

초기에는 `domain/repositories`와 repository interface를 꼭 만들 필요는 없습니다. remote 구현과 fake/local 구현을 동시에 운영해야 하거나 controller test에서 계약이 필요해지는 시점에 추가합니다.

## 단계별 작업 제안

### 1단계: 라우팅 안전장치 정리

목표는 route 연결을 유지한 채 잘못된 parameter가 page 내부로 흘러가지 않게 만드는 것입니다.

- `app_routes.dart`에 필수 path parameter helper를 추가합니다.
- `placeId`, `plantId` 누락 시 placeholder 또는 명시적 error page로 보냅니다.
- query parameter 정규화를 route helper로 모읍니다.
- route test에서 필수 parameter와 query parameter 동작을 검증합니다.

### 2단계: Place/Plant form controller 분리

가장 먼저 `PlaceFormPage`, `PlantFormPage`에서 API 호출과 local state 갱신을 분리합니다.

- `place_form_controller.dart`를 만들고 create/update submit 상태를 관리합니다.
- `plant_form_controller.dart`를 만들고 create/update submit 상태를 관리합니다.
- page는 controller 상태를 watch하고 입력값과 submit 이벤트만 전달합니다.
- DTO 생성과 repository 호출은 controller 또는 repository 근처로 이동합니다.

### 3단계: 상세 화면 delete/exit controller 분리

`PlaceDetailPage`, `PlantDetailPage`의 삭제/나가기 액션을 분리합니다.

- `place_exit_controller.dart`, `plant_delete_controller.dart`를 추가합니다.
- 성공 결과는 page가 받아 route 이동만 수행합니다.
- 실패 메시지는 controller state로 내려주고 snackbar 표시는 page에서 담당합니다.
- 관련 Provider invalidate 대상은 controller에 모읍니다.

### 4단계: 대형 page widget 분해

상태 분리 후 대형 파일의 전용 widget을 옮깁니다.

- `place_detail_page.dart`: header, metric strip, friend strip, plant list, FAB를 `presentation/widgets`로 이동합니다.
- `plant_detail_page.dart`: hero, care summary, memo preview, info section을 `presentation/widgets`로 이동합니다.
- `profile_setup_page.dart`: action sheet, permission dialog, avatar, nickname field, terms row를 `presentation/widgets`로 이동합니다.
- 각 이동은 동작 변경 없이 import만 정리하고 기존 widget test를 그대로 통과시키는 단위로 진행합니다.

### 5단계: mock/sample data 분리

page 내부의 mock data를 분리해 API 전환 시 혼선을 줄입니다.

- Place detail fixture, Plant detail fixture, Memo sample을 별도 파일로 이동합니다.
- fixture는 presentation preview 또는 local mode에서만 쓰이게 합니다.
- 실제 API 응답과 fixture를 합성하는 `applyRemote`, `applySummary` 패턴은 controller/view state mapper로 이동합니다.

### 6단계: data mapper 분리와 raw response 축소

repository 파일에서 mapper를 분리하고 raw `Object?` 반환을 줄입니다.

- `placeSummaryFromJson`, `plantSummaryFromJson`, `plantDetailFromJson`, `userProfileFromJson`을 mapper 파일로 이동합니다.
- `friendRepository.fetchRequestsRaw`, `imageRepository.getDownloadUrl` 등 raw 반환 API는 응답 타입 확정 후 DTO/entity로 감쌉니다.
- mapper unit test를 repository test와 분리합니다.

### 7단계: shared widget 소유권 감사

공용 위젯의 재사용 기준을 점검합니다.

- 진짜 공용 control: button, text field, scaffold, dialog, popup
- 공용 display 후보: place card, plant card, memo card
- feature 내부 후보: 특정 Figma section에 가까운 banner, guide, form 조합

분류 결과는 `docs/shared-widget-guide.md`에 반영합니다.

## 우선순위 제안

| 우선순위 | 작업 | 이유 |
| --- | --- | --- |
| P0 | route parameter helper 추가 | 잘못된 route 진입을 빠르게 드러내고 테스트 가능하게 만듭니다. |
| P0 | Place/Plant form controller 분리 | page가 data DTO와 repository를 직접 아는 문제를 줄입니다. |
| P1 | 상세 delete/exit controller 분리 | 사용자 액션, API 호출, invalidate 범위를 테스트 가능한 단위로 만듭니다. |
| P1 | 대형 page widget 분해 | 리뷰와 유지보수 비용을 줄이고 화면 수정 충돌을 낮춥니다. |
| P1 | mock/sample data 분리 | API 모드와 퍼블리싱 fallback의 경계를 명확히 합니다. |
| P2 | mapper 분리와 raw response 축소 | Swagger 확정 범위부터 안정적인 API 계층으로 전환합니다. |
| P2 | shared widget 소유권 감사 | 공용화 과잉과 feature 누수를 줄입니다. |
| P2 | auth redirect Provider 설계 | 인증 정책 확정 후 router와 login flow를 정리합니다. |

## 후속 이슈 후보

- `[Task] 라우트 파라미터 검증 헬퍼 추가`
- `[Task] Place 폼 Controller 분리`
- `[Task] Plant 폼 Controller 분리`
- `[Task] 장소/식물 상세 액션 Controller 분리`
- `[Task] 상세 화면 mock fixture 분리`
- `[Task] Place/Plant 대형 화면 위젯 분리`
- `[Task] API mapper 파일 분리`
- `[Task] Friend/Image 응답 타입 정리`
- `[Task] shared widget 소유권 감사`
- `[Task] 인증 redirect Provider 설계`

## 리팩토링 시 지켜야 할 기준

- 한 PR에서 폴더 이동, 상태관리 변경, UI 변경을 동시에 하지 않습니다.
- page 분해 PR은 동작 변경 없이 파일 경계만 바꿉니다.
- controller 분리 PR은 기존 widget test를 유지하고 controller unit test를 추가합니다.
- route 변경 PR은 router test를 먼저 갱신합니다.
- 빈 `data/domain/presentation` 폴더를 미리 만들지 않습니다.
- Riverpod code generation 도입 여부는 별도 결정 전까지 보류합니다.
- API 응답이 확정되지 않은 곳은 임의 DTO를 크게 만들지 않고, 현재 fallback parser에서 확인 가능한 범위만 명시합니다.

## 완료 판단 체크리스트

- [ ] page가 repository 구현과 data DTO를 직접 import하지 않습니다.
- [ ] route 필수 parameter 누락이 page 내부 빈 문자열로 전달되지 않습니다.
- [ ] create/update/delete/exit 액션이 controller 단위로 테스트됩니다.
- [ ] remote/local 분기가 page에 흩어져 있지 않습니다.
- [ ] mock/sample data가 실제 API 상태와 한 파일에서 섞이지 않습니다.
- [ ] 700줄 이상 page 파일이 route page와 전용 widgets/providers로 나뉩니다.
- [ ] shared widget은 두 개 이상 feature에서 같은 의미로 쓰이는 컴포넌트 위주로 유지됩니다.
