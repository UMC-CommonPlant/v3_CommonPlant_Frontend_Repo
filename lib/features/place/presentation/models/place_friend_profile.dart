class PlaceFriendProfile {
  const PlaceFriendProfile({
    required this.id,
    required this.name,
    this.imageAsset,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? imageAsset;
  final String? imageUrl;
}
