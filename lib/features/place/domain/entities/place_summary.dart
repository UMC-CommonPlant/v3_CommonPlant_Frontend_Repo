class PlaceSummary {
  const PlaceSummary({
    required this.id,
    required this.name,
    this.address,
    this.imageUrl,
    this.memberCount,
    this.plantCount,
  });

  final String id;
  final String name;
  final String? address;
  final String? imageUrl;
  final int? memberCount;
  final int? plantCount;

  PlaceSummary copyWith({
    String? id,
    String? name,
    String? address,
    String? imageUrl,
    int? memberCount,
    int? plantCount,
  }) {
    return PlaceSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      memberCount: memberCount ?? this.memberCount,
      plantCount: plantCount ?? this.plantCount,
    );
  }
}
