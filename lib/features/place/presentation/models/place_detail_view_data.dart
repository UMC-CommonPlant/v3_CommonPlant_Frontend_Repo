import 'package:commonplant_frontend/features/place/presentation/models/place_detail_role.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_friend_profile.dart';

class PlaceDetailViewData {
  const PlaceDetailViewData({
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
}

class PlaceDetailFriendItem {
  const PlaceDetailFriendItem({
    required this.id,
    required this.name,
    this.imageAsset,
    this.isOwner = false,
  });

  final String id;
  final String name;
  final String? imageAsset;
  final bool isOwner;

  PlaceFriendProfile toProfile() {
    return PlaceFriendProfile(id: id, name: name, imageAsset: imageAsset);
  }
}

class PlaceDetailPlantItem {
  const PlaceDetailPlantItem({
    required this.id,
    required this.name,
    required this.species,
    required this.description,
    required this.dDayLabel,
    required this.dateLabel,
    this.canWater = false,
  });

  final String id;
  final String name;
  final String species;
  final String description;
  final String dDayLabel;
  final String dateLabel;
  final bool canWater;
}
