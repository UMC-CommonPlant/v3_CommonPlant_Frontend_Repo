import 'package:commonplant_frontend/features/user/data/datasources/user_remote_data_source.dart';
import 'package:commonplant_frontend/features/user/data/repositories/user_repository.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_search_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('빈 검색어는 repository를 호출하지 않고 빈 목록을 반환한다', () async {
    final repository = _UserSearchRepository();
    final container = ProviderContainer(
      overrides: [userRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final users = await container.read(userSearchProvider('  ').future);

    expect(users, isEmpty);
    expect(repository.searchCalls, 0);
  });

  test('검색어가 있으면 UserRepository.searchUsers 결과를 반환한다', () async {
    final repository = _UserSearchRepository(
      users: const [
        UserProfile(id: 'user-1', name: '커먼맘'),
        UserProfile(id: 'user-2', name: '커먼 파파'),
      ],
    );
    final container = ProviderContainer(
      overrides: [userRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final users = await container.read(userSearchProvider(' 커먼 ').future);

    expect(repository.searchCalls, 1);
    expect(repository.lastKeyword, '커먼');
    expect(users.map((user) => user.name), ['커먼맘', '커먼 파파']);
  });
}

class _UserSearchRepository extends UserRepository {
  _UserSearchRepository({this.users = const []})
    : super(UserRemoteDataSource(Dio()));

  final List<UserProfile> users;
  int searchCalls = 0;
  String? lastKeyword;

  @override
  Future<List<UserProfile>> searchUsers(String keyword) async {
    searchCalls++;
    lastKeyword = keyword;

    return users;
  }
}
