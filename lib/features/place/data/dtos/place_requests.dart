class CreatePlaceRequest {
  const CreatePlaceRequest({required this.name, required this.address});

  final String name;
  final String address;

  Map<String, Object?> toJson() {
    return {'name': name, 'address': address};
  }
}

class UpdatePlaceRequest {
  const UpdatePlaceRequest({
    required this.name,
    required this.address,
    this.imageKey,
  });

  final String name;
  final String address;
  final String? imageKey;

  Map<String, Object?> toJson() {
    return {
      if (imageKey != null) 'imageKey': imageKey,
      'name': name,
      'address': address,
    };
  }
}
