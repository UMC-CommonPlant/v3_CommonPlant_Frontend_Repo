class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.provider,
    this.imgUrl,
    this.introduction,
  });

  final String id;
  final String name;
  final String? email;
  final String? provider;
  final String? imgUrl;
  final String? introduction;
}
