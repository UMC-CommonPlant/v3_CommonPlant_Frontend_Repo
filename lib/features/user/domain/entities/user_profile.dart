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

  UserProfile copyWith({
    String? id,
    String? name,
    Object? email = _unset,
    Object? provider = _unset,
    Object? imgUrl = _unset,
    Object? introduction = _unset,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: identical(email, _unset) ? this.email : email as String?,
      provider: identical(provider, _unset)
          ? this.provider
          : provider as String?,
      imgUrl: identical(imgUrl, _unset) ? this.imgUrl : imgUrl as String?,
      introduction: identical(introduction, _unset)
          ? this.introduction
          : introduction as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfile &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.provider == provider &&
        other.imgUrl == imgUrl &&
        other.introduction == introduction;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, email, provider, imgUrl, introduction);
  }
}

const Object _unset = Object();
