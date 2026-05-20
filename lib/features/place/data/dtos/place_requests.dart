class CreatePlaceRequest {
  const CreatePlaceRequest({required this.name, this.address});

  final String name;
  final String? address;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      if (address != null && address!.isNotEmpty) 'address': address,
    };
  }
}
