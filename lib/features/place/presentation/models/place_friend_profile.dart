class PlaceFriendProfile {
  const PlaceFriendProfile({
    required this.id,
    required this.name,
    this.imageAsset,
  });

  final String id;
  final String name;
  final String? imageAsset;
}
