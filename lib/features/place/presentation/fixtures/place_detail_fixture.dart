import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_detail_role.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_detail_widgets.dart';

class PlaceDetailFixtureData {
  const PlaceDetailFixtureData({
    required this.role,
    required this.name,
    required this.address,
    required this.sunlightLabel,
    required this.humidityLabel,
    required this.friends,
    required this.plants,
  });

  final PlaceDetailRole role;
  final String name;
  final String address;
  final String sunlightLabel;
  final String humidityLabel;
  final List<PlaceDetailFriendItem> friends;
  final List<PlaceDetailPlantItem> plants;

  PlaceDetailFixtureData applySummary(PlaceSummary summary) {
    return PlaceDetailFixtureData(
      role: role,
      name: summary.name,
      address: summary.address ?? address,
      sunlightLabel: sunlightLabel,
      humidityLabel: humidityLabel,
      friends: friends,
      plants: plants,
    );
  }
}

PlaceDetailFixtureData placeDetailFixture(
  String placeId, {
  PlaceDetailRole? role,
}) {
  final effectiveRole = role ?? _roleFromPlaceId(placeId);

  return PlaceDetailFixtureData(
    role: effectiveRole,
    name: '스윗 홈_거실',
    address: '서울시 노원구 광운로 20',
    sunlightLabel: '9.3 / 5',
    humidityLabel: '69%',
    friends: const [
      PlaceDetailFriendItem(
        id: 'me',
        name: '나',
        imageAsset: AppImageAssets.placeDetailAvatarMe,
        isOwner: true,
      ),
      PlaceDetailFriendItem(
        id: 'common-mom',
        name: '커먼맘',
        imageAsset: AppImageAssets.placeDetailAvatarCommonMom,
      ),
      PlaceDetailFriendItem(id: 'common-papa', name: '커먼 파파'),
    ],
    plants: const [
      PlaceDetailPlantItem(
        id: 'plant-1',
        name: '몬테',
        species: '몬스테라',
        description: '일주일에 x번 물주는 거 잊지 않기',
        dDayLabel: 'D-3',
        dateLabel: '2022.11.20',
        canWater: true,
      ),
      PlaceDetailPlantItem(
        id: 'plant-2',
        name: '몬테',
        species: '몬스테라',
        description: '일주일에 x번 물주는 거 잊지 않기',
        dDayLabel: 'D-5',
        dateLabel: '2022.11.20',
      ),
      PlaceDetailPlantItem(
        id: 'plant-3',
        name: '몬테',
        species: '몬스테라',
        description: '일주일에 x번 물주는 거 잊지 않기',
        dDayLabel: 'D-5',
        dateLabel: '2022.11.20',
      ),
      PlaceDetailPlantItem(
        id: 'plant-4',
        name: '몬테',
        species: '몬스테라',
        description: '일주일에 x번 물주는 거 잊지 않기',
        dDayLabel: 'D-5',
        dateLabel: '2022.11.20',
      ),
    ],
  );
}

PlaceDetailRole _roleFromPlaceId(String placeId) {
  final normalized = placeId.toLowerCase();

  if (normalized.contains('member') || normalized.contains('team')) {
    return PlaceDetailRole.member;
  }

  return PlaceDetailRole.leader;
}
