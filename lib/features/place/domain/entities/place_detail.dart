class PlaceDetail {
  const PlaceDetail({
    required this.code,
    required this.name,
    required this.address,
    required this.isOwner,
    required this.members,
    required this.plants,
    this.imageUrl,
  });

  final String code;
  final String name;
  final String address;
  final String? imageUrl;
  final bool isOwner;
  final List<PlaceMember> members;
  final List<PlacePlant> plants;
}

class PlaceMember {
  const PlaceMember({required this.name, this.imageUrl});

  final String name;
  final String? imageUrl;
}

class PlacePlant {
  const PlacePlant({
    required this.id,
    required this.scientificNameKo,
    this.scientificNameEn,
    this.registeredAt,
    this.lastWateredDate,
    this.imageUrl,
    this.memo,
    this.placeName,
    this.description,
  });

  final String id;
  final String scientificNameKo;
  final String? scientificNameEn;
  final String? registeredAt;
  final String? lastWateredDate;
  final String? imageUrl;
  final String? memo;
  final String? placeName;
  final String? description;
}
