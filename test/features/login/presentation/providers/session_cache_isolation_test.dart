import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/friend/data/repositories/friend_repository.dart';
import 'package:commonplant_frontend/features/friend/domain/entities/friend_invitation.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_result.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_controller.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_detail.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_feature_provider.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/friend_management_members_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_remote_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_edit_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_invitation_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/domain/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/plant_repository_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_detail_remote_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_edit_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_registration_place_provider.dart';
import 'package:commonplant_frontend/features/user/data/repositories/user_repository.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/current_user_provider.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_search_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('비인증 상태에서는 사용자 데이터 요청을 시작하지 않는다', () async {
    final repository = _DelayedPlaceRepository();
    final container = _container(repository, _MemoryTokenStore());
    addTearDown(container.dispose);

    await expectLater(
      container.read(remotePlaceListProvider.future),
      throwsStateError,
    );
    expect(repository.requests, isEmpty);
  });

  test('같은 ProviderScope에서 A에서 B로 로그인하면 장소 캐시를 재사용하지 않는다', () async {
    final repository = _DelayedPlaceRepository();
    final tokenStore = _MemoryTokenStore();
    final container = _container(repository, tokenStore);
    addTearDown(container.dispose);
    addTearDown(repository.completeRemaining);
    await container.read(authSessionControllerProvider.future);
    container.listen(placeSummariesProvider, (_, _) {});

    final first = container.read(remotePlaceListProvider.future);
    repository.requests.single.complete(_places('A'));
    await first;
    expect(
      container.read(placeSummariesProvider).requireValue.single.name,
      'A',
    );

    await _loginAsB(container, tokenStore);
    await container.pump();

    expect(repository.requests, hasLength(2));
    expect(container.read(placeSummariesProvider).isLoading, isTrue);
    expect(container.read(placeSummariesProvider).value, isNull);
    repository.requests.last.complete(_places('B'));
    await container.read(remotePlaceListProvider.future);
    expect(
      container.read(placeSummariesProvider).requireValue.single.name,
      'B',
    );
  });

  test('로그아웃 뒤 B를 조회하는 동안 도착한 A의 응답은 새 세션에 반영하지 않는다', () async {
    final repository = _DelayedPlaceRepository();
    final tokenStore = _MemoryTokenStore();
    final container = _container(repository, tokenStore);
    addTearDown(container.dispose);
    addTearDown(repository.completeRemaining);
    await container.read(authSessionControllerProvider.future);
    container.listen(placeSummariesProvider, (_, _) {});
    container.read(remotePlaceListProvider.future).ignore();
    final oldRequest = repository.requests.single;

    await container.read(authSessionControllerProvider.notifier).clearSession();
    await _loginAsB(container, tokenStore);
    await container.pump();

    expect(repository.requests, hasLength(2));
    repository.requests.last.complete(_places('B'));
    await container.read(remotePlaceListProvider.future);
    oldRequest.complete(_places('A'));
    await container.pump();

    expect(
      container.read(placeSummariesProvider).requireValue.single.name,
      'B',
    );
  });

  test('모든 사용자 조회 캐시는 같은 식별자여도 계정별로 다시 조회한다', () async {
    final repository = _AccountRepositories();
    final tokenStore = _MemoryTokenStore();
    final container = ProviderContainer(
      overrides: [
        useRemoteApiProvider.overrideWithValue(true),
        authTokenStoreProvider.overrideWithValue(tokenStore),
        placeRepositoryProvider.overrideWithValue(repository),
        plantRepositoryProvider.overrideWithValue(repository),
        userRepositoryProvider.overrideWithValue(repository),
        friendRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authSessionControllerProvider.future);

    final providers = <ProviderListenable<AsyncValue<Object?>>>[
      remotePlaceListProvider,
      userPlaceSummariesProvider,
      placeSummaryProvider('same-code'),
      placeDetailProvider('same-code'),
      remoteFriendManagementMembersProvider('same-code'),
      remotePlantListProvider,
      remotePlantDetailProvider('same-plant'),
      remotePlantEditInfoProvider('same-plant'),
      currentUserProvider,
      userSearchProvider('same-query'),
      remotePlaceInvitationsProvider,
      remotePlaceFormEditInfoProvider('same-code'),
      remotePlantFormEditInfoProvider('same-plant'),
      plantRegistrationPlaceProvider,
    ];
    for (final provider in providers) {
      container.listen(provider, (_, _) {});
    }

    Future<List<String>> readNames() async => [
      (await container.read(remotePlaceListProvider.future)).single.name,
      (await container.read(userPlaceSummariesProvider.future)).single.name,
      (await container.read(placeSummaryProvider('same-code').future)).name,
      (await container.read(placeDetailProvider('same-code').future)).name,
      (await container.read(
        remoteFriendManagementMembersProvider('same-code').future,
      )).single.name,
      (await container.read(remotePlantListProvider.future)).single.name,
      (await container.read(
        remotePlantDetailProvider('same-plant').future,
      )).name,
      (await container.read(
        remotePlantEditInfoProvider('same-plant').future,
      )).name,
      (await container.read(currentUserProvider.future)).name,
      (await container.read(
        userSearchProvider('same-query').future,
      )).single.name,
      (await container.read(
        remotePlaceInvitationsProvider.future,
      )).single.inviterName,
      (await container.read(
        remotePlaceFormEditInfoProvider('same-code').future,
      ))!.name,
      (await container.read(
        remotePlantFormEditInfoProvider('same-plant').future,
      ))!.name,
      (await container.read(plantRegistrationPlaceProvider.future)).single.name,
    ];

    expect(await readNames(), everyElement('A'));
    expect(repository.calls, hasLength(11));
    expect(repository.calls.values, everyElement(1));

    repository.account = 'B';
    await _loginAsB(container, tokenStore);
    expect(await readNames(), everyElement('B'));
    expect(repository.calls.values, everyElement(2));

    await container.read(authSessionControllerProvider.notifier).clearSession();
    await container.pump();
    for (final provider in providers) {
      expect(container.read(provider).unwrapPrevious().value, isNull);
    }
    expect(repository.calls.values, everyElement(2));
    expect(container.read(userDataSessionProvider).isActive, isFalse);
  });
}

ProviderContainer _container(
  PlaceRepository repository,
  AuthTokenStore tokenStore,
) {
  return ProviderContainer(
    overrides: [
      useRemoteApiProvider.overrideWithValue(true),
      authTokenStoreProvider.overrideWithValue(tokenStore),
      placeRepositoryProvider.overrideWithValue(repository),
    ],
  );
}

Future<void> _loginAsB(
  ProviderContainer container,
  AuthTokenStore tokenStore,
) async {
  const result = AuthenticatedResult(
    accessToken: 'access-B',
    refreshToken: 'refresh-B',
  );
  await tokenStore.saveTokens(
    accessToken: result.accessToken,
    refreshToken: result.refreshToken,
  );
  container
      .read(authSessionControllerProvider.notifier)
      .applyAuthResult(result);
}

List<PlaceSummary> _places(String account) => [
  PlaceSummary(id: 'same-place-code', name: account),
];

class _DelayedPlaceRepository extends Fake implements PlaceRepository {
  final requests = <Completer<List<PlaceSummary>>>[];

  @override
  Future<List<PlaceSummary>> fetchMyGardenPlaces() {
    final request = Completer<List<PlaceSummary>>();
    requests.add(request);
    return request.future;
  }

  void completeRemaining() {
    for (final request in requests) {
      if (!request.isCompleted) request.complete(const []);
    }
  }
}

class _MemoryTokenStore implements AuthTokenStore {
  String? accessToken = 'access-A';
  String? refreshToken = 'refresh-A';

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
  }
}

class _AccountRepositories extends Fake
    implements
        PlaceRepository,
        PlantRepository,
        UserRepository,
        FriendRepository {
  String account = 'A';
  final calls = <String, int>{};

  void _record(String method) =>
      calls.update(method, (n) => n + 1, ifAbsent: () => 1);

  @override
  Future<List<PlaceSummary>> fetchMyGardenPlaces() async {
    _record('garden');
    return _places(account);
  }

  @override
  Future<List<PlaceSummary>> fetchUserPlaces() async {
    _record('places');
    return _places(account);
  }

  @override
  Future<PlaceSummary> fetchPlace(String code) async {
    _record('place');
    return PlaceSummary(id: code, name: account, address: '주소');
  }

  @override
  Future<PlaceDetail> fetchPlaceDetail(String code) async {
    _record('place-detail');
    return PlaceDetail(
      code: code,
      name: account,
      address: '주소',
      isOwner: true,
      members: const [],
      plants: const [],
    );
  }

  @override
  Future<List<PlaceMember>> fetchPlaceMembers(String code) async {
    _record('members');
    return [PlaceMember(name: account)];
  }

  @override
  Future<List<PlantSummary>> fetchPlants({int page = 0, int size = 20}) async {
    _record('plants');
    return [PlantSummary(id: 'same-plant', name: account)];
  }

  @override
  Future<PlantDetail> fetchPlant({required String plantId}) async {
    _record('plant-detail');
    return PlantDetail(id: plantId, name: account);
  }

  @override
  Future<PlantEditInfo> fetchPlantEditInfo({required String plantId}) async {
    _record('plant-edit');
    return PlantEditInfo(name: account);
  }

  @override
  Future<UserProfile> fetchMe() async {
    _record('me');
    return UserProfile(id: account, name: account);
  }

  @override
  Future<List<UserProfile>> searchUsers(String keyword) async {
    _record('search');
    return [UserProfile(id: account, name: account)];
  }

  @override
  Future<List<FriendInvitation>> fetchRequests() async {
    _record('requests');
    return [
      FriendInvitation(
        id: 1,
        senderName: account,
        placeCode: 'same-code',
        placeName: account,
        placeAddress: '주소',
        status: 'PENDING',
      ),
    ];
  }
}
