import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/presentation/fixtures/place_friend_fixture.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_friend_selection_controller.dart';
import 'package:commonplant_frontend/features/user/data/datasources/user_remote_data_source.dart';
import 'package:commonplant_frontend/features/user/data/repositories/user_repository.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_search_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/user_data_session.dart';

void main() {
  test('local 검색어에 맞는 Place friend 목록을 보여준다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(placeFriendSelectionControllerProvider.notifier)
        .updateQuery('커먼맘');

    final searchState = container.read(placeFriendSearchProvider);
    expect(searchState.result.requireValue, hasLength(1));
    expect(searchState.result.requireValue.single.name, '커먼맘');
    expect(searchState.showEmptyState, isFalse);
  });

  test('친구 profile을 선택하고 다시 누르면 해제한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(
      placeFriendSelectionControllerProvider.notifier,
    );
    final friend = placeFriendFixture.first;

    controller.toggle(friend);
    expect(
      container.read(placeFriendSelectionControllerProvider).selectedIds,
      contains(friend.id),
    );

    controller.toggle(friend);
    expect(
      container.read(placeFriendSelectionControllerProvider).selectedIds,
      isEmpty,
    );
  });

  test('remote User 결과를 Place friend profile로 변환한다', () async {
    final repository = _StaticUserRepository(const [
      UserProfile(id: 'user-1', name: '커먼맘'),
    ]);
    final container = ProviderContainer(
      overrides: [
        authenticatedUserDataSession,
        useRemoteApiProvider.overrideWithValue(true),
        userRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(placeFriendSearchProvider, (_, _) {});
    addTearDown(subscription.close);

    container
        .read(placeFriendSelectionControllerProvider.notifier)
        .updateQuery('커먼');
    await container.read(userSearchProvider('커먼').future);

    final searchState = container.read(placeFriendSearchProvider);
    expect(searchState.showEmptyState, isTrue);
    expect(searchState.result.requireValue.single.id, 'user-1');
    expect(searchState.result.requireValue.single.name, '커먼맘');
  });
}

class _StaticUserRepository extends UserRepository {
  _StaticUserRepository(this.users) : super(UserRemoteDataSource(Dio()));

  final List<UserProfile> users;

  @override
  Future<List<UserProfile>> searchUsers(String keyword) async {
    return users;
  }
}
