import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_detail.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/friend_management_members_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/user_data_session.dart';

void main() {
  test('local 모드는 원격 조회 없이 fixture 멤버를 제공한다', () {
    final repository = _MembersRepository();
    final container = ProviderContainer(
      overrides: [
        authenticatedUserDataSession,
        placeRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final members = container
        .read(friendManagementMembersProvider('place-1'))
        .requireValue;

    expect(members.map((member) => member.name), ['커먼맘', '커먼 파파']);
    expect(repository.requestedCodes, isEmpty);
  });

  test('remote 모드는 장소 코드와 이미지·동명이인 항목을 보존한다', () async {
    final repository = _MembersRepository(
      members: const [
        PlaceMember(name: '서버 멤버', imageUrl: 'https://example.com/one.png'),
        PlaceMember(name: '서버 멤버'),
      ],
    );
    final container = _remoteContainer(repository);
    addTearDown(container.dispose);

    final members = await container.read(
      remoteFriendManagementMembersProvider('place-code').future,
    );

    expect(repository.requestedCodes, ['place-code']);
    expect(members.map((member) => member.name), ['서버 멤버', '서버 멤버']);
    expect(members.map((member) => member.id).toSet(), hasLength(2));
    expect(members.first.imageUrl, 'https://example.com/one.png');
    expect(members.last.imageUrl, isNull);
    expect(members.every((member) => member.imageAsset == null), isTrue);
  });

  test('remote 조회 실패는 fixture로 대체하지 않는다', () async {
    final container = _remoteContainer(_MembersRepository(shouldFail: true));
    addTearDown(container.dispose);

    await expectLater(
      container.read(remoteFriendManagementMembersProvider('place-1').future),
      throwsStateError,
    );
    expect(
      container.read(friendManagementMembersProvider('place-1')).hasError,
      isTrue,
    );
  });
}

ProviderContainer _remoteContainer(PlaceRepository repository) {
  return ProviderContainer(
    overrides: [
      authenticatedUserDataSession,
      useRemoteApiProvider.overrideWithValue(true),
      placeRepositoryProvider.overrideWithValue(repository),
    ],
  );
}

class _MembersRepository extends Fake implements PlaceRepository {
  _MembersRepository({this.members = const [], this.shouldFail = false});

  final List<PlaceMember> members;
  final bool shouldFail;
  final List<String> requestedCodes = [];

  @override
  Future<List<PlaceMember>> fetchPlaceMembers(String code) async {
    requestedCodes.add(code);
    if (shouldFail) {
      throw StateError('members failed');
    }
    return members;
  }
}
