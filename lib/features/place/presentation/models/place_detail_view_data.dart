import 'package:commonplant_frontend/features/place/presentation/models/place_detail_role.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_friend_profile.dart';

class PlaceDetailViewData {
  const PlaceDetailViewData({
    required this.role,
    required this.name,
    required this.address,
    required this.friends,
    required this.plants,
    this.sunlightLabel,
    this.humidityLabel,
  });

  final PlaceDetailRole role;
  final String name;
  final String address;
  final String? sunlightLabel;
  final String? humidityLabel;
  final List<PlaceDetailFriendItem> friends;
  final List<PlaceDetailPlantItem> plants;
}

class PlaceDetailFriendItem {
  const PlaceDetailFriendItem({
    required this.id,
    required this.name,
    this.imageAsset,
    this.imageUrl,
    this.isOwner = false,
  });

  final String id;
  final String name;
  final String? imageAsset;
  final String? imageUrl;
  final bool isOwner;

  PlaceFriendProfile toProfile() {
    return PlaceFriendProfile(
      id: id,
      name: name,
      imageAsset: imageAsset,
      imageUrl: imageUrl,
    );
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
    this.imageAsset,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String species;
  final String description;
  final String? dDayLabel;
  final String? dateLabel;
  final bool canWater;
  final String? imageAsset;
  final String? imageUrl;
}
