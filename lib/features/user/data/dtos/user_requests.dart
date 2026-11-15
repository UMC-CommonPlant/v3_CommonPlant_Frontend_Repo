class UpdateUserRequest {
  const UpdateUserRequest({this.name, this.introduction});

  final String? name;
  final String? introduction;

  Map<String, Object?> toJson() {
    return {
      if (name != null) 'name': name,
      if (introduction != null) 'introduction': introduction,
    };
  }
}
