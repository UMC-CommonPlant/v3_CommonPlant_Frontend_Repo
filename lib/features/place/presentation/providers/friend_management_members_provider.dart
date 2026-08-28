import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/fixtures/friend_management_fixture.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_friend_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final remoteFriendManagementMembersProvider = FutureProvider.autoDispose
    .family<List<PlaceFriendProfile>, String>((ref, placeCode) async {
      requireUserDataSession(ref);
      final members = await ref
          .watch(placeRepositoryProvider)
          .fetchPlaceMembers(placeCode);

      return List.unmodifiable([
        for (final (index, member) in members.indexed)
          PlaceFriendProfile(
            // The API has no member ID; this key is only for this read-only list.
            id: 'member-$index',
            name: member.name,
            imageUrl: member.imageUrl,
          ),
      ]);
    }, retry: (retryCount, error) => null);

final friendManagementMembersProvider = Provider.autoDispose
    .family<AsyncValue<List<PlaceFriendProfile>>, String>((ref, placeCode) {
      if (ref.watch(useRemoteApiProvider)) {
        return ref
            .watch(remoteFriendManagementMembersProvider(placeCode))
            .unwrapPrevious();
      }

      return const AsyncData(friendManagementFixture);
    });
