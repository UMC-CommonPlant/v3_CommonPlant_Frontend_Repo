class PlantSummary {
  const PlantSummary({
    required this.id,
    required this.name,
    this.placeId,
    this.placeName,
    this.description,
    this.imageUrl,
    this.wateringCycleDays,
  });

  final String id;
  final String name;
  final String? placeId;
  final String? placeName;
  final String? description;
  final String? imageUrl;
  final int? wateringCycleDays;

  PlantSummary copyWith({
    String? id,
    String? name,
    String? placeId,
    String? placeName,
    String? description,
    String? imageUrl,
    int? wateringCycleDays,
  }) {
    return PlantSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      wateringCycleDays: wateringCycleDays ?? this.wateringCycleDays,
    );
  }
}
