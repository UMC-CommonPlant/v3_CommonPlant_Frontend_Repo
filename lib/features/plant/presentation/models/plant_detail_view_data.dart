class PlantDetailViewData {
  const PlantDetailViewData({
    required this.placeCode,
    required this.placeName,
    required this.name,
    required this.species,
    required this.daysTogether,
    required this.dDayLabel,
    required this.startDate,
    required this.lastWateredDate,
    required this.wateringCycleLabel,
    required this.memos,
  });

  final String? placeCode;
  final String placeName;
  final String name;
  final String species;
  final int daysTogether;
  final String dDayLabel;
  final String startDate;
  final String lastWateredDate;
  final String wateringCycleLabel;
  final List<PlantDetailMemoItem> memos;
}

class PlantDetailMemoItem {
  const PlantDetailMemoItem({
    required this.author,
    required this.content,
    required this.dateLabel,
    this.avatarAsset,
    this.thumbnailAsset,
  });

  final String author;
  final String content;
  final String dateLabel;
  final String? avatarAsset;
  final String? thumbnailAsset;
}
