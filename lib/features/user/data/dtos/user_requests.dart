class UpdateUserRequest {
  const UpdateUserRequest({this.name, this.introduction, this.imgUrl});

  final String? name;
  final String? introduction;
  final String? imgUrl;

  Map<String, Object?> toJson() {
    return {
      if (name != null) 'name': name,
      if (introduction != null) 'introduction': introduction,
      if (imgUrl != null) 'imgUrl': imgUrl,
    };
  }
}
