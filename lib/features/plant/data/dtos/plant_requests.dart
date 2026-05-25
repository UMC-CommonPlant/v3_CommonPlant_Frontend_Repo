class CreatePlantRequest {
  const CreatePlantRequest({
    required this.placeCode,
    required this.nickname,
    this.scientificNameKo,
    this.scientificNameEn,
    this.lastWateredDate,
    this.description,
  });

  final String placeCode;
  final String nickname;
  final String? scientificNameKo;
  final String? scientificNameEn;
  final String? lastWateredDate;
  final String? description;

  Map<String, Object?> toJson() {
    return {
      'placeCode': placeCode,
      'nickname': nickname,
      if (scientificNameKo != null) 'scientificNameKo': scientificNameKo,
      if (scientificNameEn != null) 'scientificNameEn': scientificNameEn,
      if (lastWateredDate != null) 'lastWateredDate': lastWateredDate,
      if (description != null) 'description': description,
    };
  }
}

class UpdatePlantRequest {
  const UpdatePlantRequest({
    this.imageKey,
    this.nickname,
    this.lastWateredDate,
  });

  final String? imageKey;
  final String? nickname;
  final String? lastWateredDate;

  Map<String, Object?> toJson() {
    return {
      if (imageKey != null) 'imageKey': imageKey,
      if (nickname != null) 'nickname': nickname,
      if (lastWateredDate != null) 'lastWateredDate': lastWateredDate,
    };
  }
}
