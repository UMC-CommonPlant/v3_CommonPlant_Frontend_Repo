class PlaceFriendProfile {
  const PlaceFriendProfile({
    required this.id,
    required this.name,
    this.imageAsset,
    this.imageUrl,
    this.isOwner,
  });

  final String id;
  final String name;
  final String? imageAsset;
  final String? imageUrl;
  final bool? isOwner;
}
