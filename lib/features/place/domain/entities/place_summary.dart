class PlaceSummary {
  const PlaceSummary({required this.id, required this.name, this.address});

  final String id;
  final String name;
  final String? address;

  PlaceSummary copyWith({String? id, String? name, String? address}) {
    return PlaceSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
    );
  }
}
