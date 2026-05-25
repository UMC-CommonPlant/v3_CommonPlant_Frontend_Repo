class PlantDetail {
  const PlantDetail({
    required this.id,
    required this.name,
    this.placeId,
    this.placeName,
    this.species,
    this.description,
    this.lastWateredDate,
    this.imageKey,
    this.imageUrl,
    this.memo,
    this.registeredAt,
  });

  final String id;
  final String name;
  final String? placeId;
  final String? placeName;
  final String? species;
  final String? description;
  final String? lastWateredDate;
  final String? imageKey;
  final String? imageUrl;
  final String? memo;
  final String? registeredAt;
}

class PlantEditInfo {
  const PlantEditInfo({
    required this.name,
    this.lastWateredDate,
    this.imageKey,
    this.imageUrl,
  });

  final String name;
  final String? lastWateredDate;
  final String? imageKey;
  final String? imageUrl;
}
