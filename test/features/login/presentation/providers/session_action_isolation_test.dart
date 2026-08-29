import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/friend/data/dtos/friend_requests.dart';
import 'package:commonplant_frontend/features/friend/data/repositories/friend_repository.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_result.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_controller.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/models/address_search_result.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_friend_profile.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_exit_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_friend_request_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_invitation_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/features/plant/domain/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/plant_repository_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/models/plant_registration_place.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_delete_controller.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_controller.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_state.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_registration_place_provider.dart';
import 'package:commonplant_frontend/features/user/data/dtos/user_requests.dart';
import 'package:commonplant_frontend/features/user/data/repositories/user_repository.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/current_user_provider.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_account_controller.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_profile_edit_controller.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_profile_edit_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final fails in [false, true]) {
    test('A의 프로필 수정 ${fails ? '실패' : '성공'} 결과는 B의 프로필과 폼을 덮지 않는다', () async {
      final repository = _PendingRepositories();
      final container = await _container(repository);
      container.listen(currentUserProvider, (_, _) {});
      final userA = await container.read(currentUserProvider.future);
      final form = userProfileEditControllerProvider(
        UserProfileEditArgs(user: userA),
      );
      container.listen(form, (_, _) {});
      final controller = container.read(form.notifier);
      controller.updateName('수정한 A');
      final pending = controller.submit();

      await _switchToB(container, repository);
      await container.read(currentUserProvider.future);
      if (fails) {
        repository.updateMeResult.completeError(StateError('A 수정 실패'));
      } else {
        repository.updateMeResult.complete(
          const UserProfile(id: 'A', name: '수정한 A'),
        );
      }

      expect(await pending, isFalse);
      expect(container.read(currentUserProvider).requireValue.id, 'B');
      expect(container.read(form).currentName, isEmpty);
      expect(container.read(form).submitErrorMessage, isNull);
      controller.updateName('과거 폼');
      expect(await controller.submit(), isFalse);
      expect(repository.updateMeCalls, 1);
    });

    test('A의 친구 요청 처리 ${fails ? '실패' : '성공'} 결과는 B의 처리 상태를 바꾸지 않는다', () async {
      final repository = _PendingRepositories();
      final container = await _container(repository);
      container.listen(placeInvitationControllerProvider, (_, _) {});
      final pending = container
          .read(placeInvitationControllerProvider.notifier)
          .accept('same-id', friendId: 1);

      await _switchToB(container, repository);
      if (fails) {
        repository.friendDecision.completeError(StateError('A 요청 실패'));
      } else {
        repository.friendDecision.complete();
      }
      await pending;

      final state = container.read(placeInvitationControllerProvider);
      expect(state.results, isEmpty);
      expect(state.submittingIds, isEmpty);
      expect(state.actionErrorMessage, isNull);
    });
  }

  test('A의 주소 선택 결과는 인증 전환 후 B의 폼에 반영하지 않는다', () async {
    final repository = _PendingRepositories();
    final container = await _container(repository);
    final provider = placeFormControllerProvider(null);
    container.listen(provider, (_, _) {});
    final selection = Completer<AddressSearchResult?>();
    final pending = container
        .read(provider.notifier)
        .applyAddressSelection(selection.future);

    await _switchToB(container, repository);
    container.read(provider.notifier).updateName('B 장소');
    container.read(provider.notifier).updateAddress('B 주소');
    selection.complete(
      const AddressSearchResult(
        titlePrefix: 'A',
        titleSuffix: '장소',
        address: 'A 주소',
        source: AddressSearchResultSource.searchService,
      ),
    );
    await pending;

    expect(container.read(provider).currentAddress, 'B 주소');
    expect(container.read(provider).currentName, 'B 장소');
    expect(container.read(provider).submitErrorMessage, isNull);
  });

  test('A의 장소 생성 완료는 B의 입력·캐시를 변경하거나 이동 결과를 반환하지 않는다', () async {
    final repository = _PendingRepositories();
    final container = await _container(repository);
    final form = placeFormControllerProvider(null);
    container.listen(form, (_, _) {});
    container.listen(remotePlaceListProvider, (_, _) {});
    await container.read(remotePlaceListProvider.future);
    final controller = container.read(form.notifier);
    controller.updateName('장소 A');
    controller.updateAddress('A 주소');
    final pending = controller.submit();

    await _switchToB(container, repository);
    await container.read(remotePlaceListProvider.future);
    controller.updateName('장소 B');
    final callsBefore = repository.placeListCalls;
    repository.createPlaceResult.complete('place-A');

    expect(await pending, isNull);
    expect(container.read(form).currentName, '장소 B');
    expect(
      (await container.read(remotePlaceListProvider.future)).single.name,
      '계정 B',
    );
    expect(repository.placeListCalls, callsBefore);
  });

  test('A의 식물 생성 완료는 B의 로컬 목록과 이동 결과에 섞이지 않는다', () async {
    final repository = _PendingRepositories();
    final container = await _container(repository);
    const args = PlantFormArgs();
    final form = plantFormControllerProvider(args);
    container.listen(form, (_, _) {});
    container.listen(remotePlantListProvider, (_, _) {});
    await container.read(plantRegistrationPlaceProvider.future);
    await container.read(remotePlantListProvider.future);
    final pending = container.read(form.notifier).submit();

    await _switchToB(container, repository);
    await container.read(remotePlantListProvider.future);
    final callsBefore = repository.plantListCalls;
    repository.createPlantResult.complete();

    expect(await pending, isNull);
    expect(container.read(plantListProvider), isEmpty);
    await container.read(remotePlantListProvider.future);
    expect(repository.plantListCalls, callsBefore);
  });

  test('A의 장소 삭제 완료는 B의 캐시를 갱신하거나 이동시키지 않는다', () async {
    final repository = _PendingRepositories();
    final container = await _container(repository);
    container.listen(placeExitControllerProvider, (_, _) {});
    container.listen(remotePlaceListProvider, (_, _) {});
    await container.read(remotePlaceListProvider.future);
    final pending = container
        .read(placeExitControllerProvider.notifier)
        .exit('place-A');

    await _switchToB(container, repository);
    await container.read(remotePlaceListProvider.future);
    final callsBefore = repository.placeListCalls;
    repository.deletePlaceResult.complete();

    expect(await pending, isNull);
    await container.read(remotePlaceListProvider.future);
    expect(repository.placeListCalls, callsBefore);
    expect(container.read(placeExitControllerProvider).errorMessage, isNull);
  });

  test('A의 식물 삭제 완료는 B의 상태나 이동 결과에 반영하지 않는다', () async {
    final repository = _PendingRepositories();
    final container = await _container(repository);
    container.listen(plantDeleteControllerProvider, (_, _) {});
    final pending = container
        .read(plantDeleteControllerProvider.notifier)
        .delete(plantId: 'plant-A', placeCode: 'place-A');

    await _switchToB(container, repository);
    repository.deletePlantResult.complete();

    expect(await pending, isNull);
    expect(container.read(plantDeleteControllerProvider).isSubmitting, isFalse);
    expect(container.read(plantDeleteControllerProvider).errorMessage, isNull);
  });

  test('A의 발신 요청 완료는 B의 화면에 완료 이동을 반환하지 않는다', () async {
    final repository = _PendingRepositories();
    final container = await _container(repository);
    container.listen(placeFriendRequestControllerProvider, (_, _) {});
    final pending = container
        .read(placeFriendRequestControllerProvider.notifier)
        .submit(
          placeCode: 'place-A',
          friends: const [PlaceFriendProfile(id: 'friend-A', name: '친구 A')],
        );

    await _switchToB(container, repository);
    repository.sendFriendResult.complete();

    expect(await pending, isFalse);
    expect(
      container.read(placeFriendRequestControllerProvider).isSubmitting,
      isFalse,
    );
  });

  test('A의 늦은 탈퇴 응답으로 B를 로그아웃시키지 않는다', () async {
    final repository = _PendingRepositories();
    final container = await _container(repository);
    container.listen(userAccountControllerProvider, (_, _) {});
    final pending = container
        .read(userAccountControllerProvider.notifier)
        .deleteAccount();

    await _switchToB(container, repository);
    repository.deleteMeResult.complete();

    expect(await pending, isFalse);
    expect(
      container
          .read(authSessionControllerProvider)
          .requireValue
          .isAuthenticated,
      isTrue,
    );
    expect(container.read(userDataSessionProvider).isActive, isTrue);
    expect(
      (container.read(authTokenStoreProvider) as _MemoryTokenStore).clearCalls,
      0,
    );
    expect(
      await container.read(authTokenStoreProvider).readAccessToken(),
      'access-B',
    );
  });
}

Future<ProviderContainer> _container(_PendingRepositories repository) async {
  final container = ProviderContainer(
    overrides: [
      useRemoteApiProvider.overrideWithValue(true),
      authTokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
      placeRepositoryProvider.overrideWithValue(repository),
      plantRepositoryProvider.overrideWithValue(repository),
      userRepositoryProvider.overrideWithValue(repository),
      friendRepositoryProvider.overrideWithValue(repository),
      plantRegistrationPlaceProvider.overrideWith(
        (ref) => const [
          PlantRegistrationPlace(
            id: 'place-A',
            name: '장소',
            imageAsset: 'fixture.png',
          ),
        ],
      ),
    ],
  );
  addTearDown(container.dispose);
  await container.read(authSessionControllerProvider.future);
  return container;
}

Future<void> _switchToB(
  ProviderContainer container,
  _PendingRepositories repository,
) async {
  repository.user = const UserProfile(id: 'B', name: '계정 B');
  const result = AuthenticatedResult(
    accessToken: 'access-B',
    refreshToken: 'refresh-B',
  );
  await container
      .read(authTokenStoreProvider)
      .saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
  container
      .read(authSessionControllerProvider.notifier)
      .applyAuthResult(result);
  await container.pump();
}

class _PendingRepositories extends Fake
    implements
        PlaceRepository,
        PlantRepository,
        UserRepository,
        FriendRepository {
  UserProfile user = const UserProfile(id: 'A', name: '계정 A');
  final updateMeResult = Completer<UserProfile>();
  final createPlaceResult = Completer<String>();
  final createPlantResult = Completer<void>();
  final deletePlaceResult = Completer<void>();
  final deletePlantResult = Completer<void>();
  final deleteMeResult = Completer<void>();
  final friendDecision = Completer<void>();
  final sendFriendResult = Completer<void>();
  int updateMeCalls = 0;
  int placeListCalls = 0;
  int plantListCalls = 0;

  @override
  Future<UserProfile> fetchMe() async => user;

  @override
  Future<UserProfile> updateMe(
    UpdateUserRequest request, {
    MultipartFile? image,
  }) {
    updateMeCalls++;
    return updateMeResult.future;
  }

  @override
  Future<List<PlaceSummary>> fetchMyGardenPlaces() async {
    placeListCalls++;
    return [PlaceSummary(id: 'same-code', name: user.name)];
  }

  @override
  Future<List<PlantSummary>> fetchPlants({int page = 0, int size = 20}) async {
    plantListCalls++;
    return const [];
  }

  @override
  Future<String> createPlace({required String name, required String address}) =>
      createPlaceResult.future;

  @override
  Future<void> createPlant({
    required String placeCode,
    required String nickname,
    String? scientificNameKo,
    String? scientificNameEn,
    String? lastWateredDate,
    String? description,
  }) => createPlantResult.future;

  @override
  Future<void> deletePlace(String code) => deletePlaceResult.future;

  @override
  Future<void> deletePlant({
    required String plantId,
    required String placeCode,
  }) => deletePlantResult.future;

  @override
  Future<void> deleteMe() => deleteMeResult.future;

  @override
  Future<void> acceptRequest(FriendDecisionRequest request) =>
      friendDecision.future;

  @override
  Future<void> sendRequest(SendFriendRequest request) =>
      sendFriendResult.future;
}

class _MemoryTokenStore implements AuthTokenStore {
  String? accessToken = 'access-A';
  String? refreshToken = 'refresh-A';
  int clearCalls = 0;

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
    clearCalls++;
    accessToken = null;
    refreshToken = null;
  }
}
