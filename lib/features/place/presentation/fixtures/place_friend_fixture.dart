import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_friend_profile.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';

const List<PlaceFriendProfile> placeFriendFixture = <PlaceFriendProfile>[
  PlaceFriendProfile(
    id: 'friend-1',
    name: '커먼맘',
    imageAsset: AppImageAssets.placeFriendAddCommonMom,
  ),
  PlaceFriendProfile(
    id: 'friend-2',
    name: '커먼인척',
    imageAsset: AppImageAssets.placeFriendAddCommonFake,
  ),
  PlaceFriendProfile(
    id: 'friend-3',
    name: '커먼일뻔',
    imageAsset: AppImageAssets.placeFriendAddCommonAlmost,
  ),
  PlaceFriendProfile(
    id: 'friend-4',
    name: '커먼일지도',
    imageAsset: AppImageAssets.placeFriendAddCommonMaybe,
  ),
  PlaceFriendProfile(id: 'friend-5', name: '커먼 파파'),
];

List<PlaceFriendProfile> placeFriendsFromUsers(List<UserProfile> users) {
  return [
    for (final user in users) PlaceFriendProfile(id: user.id, name: user.name),
  ];
}
