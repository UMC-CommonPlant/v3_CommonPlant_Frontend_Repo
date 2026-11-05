import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/api_exception.dart';
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

      final profiles = <PlaceFriendProfile>[];
      final memberIds = <String>{};
      for (final member in members) {
        final nanoId = member.nanoId;
        if (nanoId == null ||
            nanoId.trim().isEmpty ||
            member.isOwner == null ||
            !memberIds.add(nanoId)) {
          throw const ApiException(message: '장소 멤버의 식별자와 역할을 확인할 수 없어요');
        }
        profiles.add(
          PlaceFriendProfile(
            id: nanoId,
            name: member.name,
            imageUrl: member.imageUrl,
            isOwner: member.isOwner,
          ),
        );
      }
      return List.unmodifiable(profiles);
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
