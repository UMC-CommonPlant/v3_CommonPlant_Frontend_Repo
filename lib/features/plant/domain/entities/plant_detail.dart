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
  });

  final String id;
  final String name;
  final String? placeId;
  final String? placeName;
  final String? species;
  final String? description;
  final String? lastWateredDate;
  final String? imageKey;
}

class PlantEditInfo {
  const PlantEditInfo({
    required this.name,
    this.lastWateredDate,
    this.imageKey,
  });

  final String name;
  final String? lastWateredDate;
  final String? imageKey;
}
