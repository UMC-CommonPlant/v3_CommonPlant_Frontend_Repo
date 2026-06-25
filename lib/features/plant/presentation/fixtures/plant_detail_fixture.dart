import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_detail_widgets.dart';

class PlantDetailFixtureData {
  const PlantDetailFixtureData({
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

  PlantDetailFixtureData applyRemote(PlantDetail detail) {
    return PlantDetailFixtureData(
      placeCode: detail.placeId ?? placeCode,
      placeName: detail.placeName ?? placeName,
      name: detail.name,
      species: detail.species ?? species,
      daysTogether: daysTogether,
      dDayLabel: dDayLabel,
      startDate: startDate,
      lastWateredDate: detail.lastWateredDate ?? lastWateredDate,
      wateringCycleLabel: wateringCycleLabel,
      memos: memos,
    );
  }
}

PlantDetailFixtureData plantDetailFixture({String? placeCode}) {
  return PlantDetailFixtureData(
    placeCode: placeCode,
    placeName: '스윗홈_거실',
    name: '몬테',
    species: 'Monstera deliciosa',
    daysTogether: 1,
    dDayLabel: 'D-3',
    startDate: '2022.11.24',
    lastWateredDate: '2022.11.24',
    wateringCycleLabel: '10 Day',
    memos: const [
      PlantDetailMemoItem(
        author: '커먼플랜트',
        content: '장마여서 물주는 날짜를 조금 늦춤 하지만 해는 맑구나 몬테랑 함께...',
        dateLabel: '2022.11.20',
        avatarAsset: AppImageAssets.placeDetailAvatarMe,
        thumbnailAsset: AppImageAssets.placeDetailMonstera,
      ),
      PlantDetailMemoItem(
        author: '커먼맘',
        content: '오늘은 잎이 조금 시들하구나 커먼아 해결책은?',
        dateLabel: '2022.11.20',
        avatarAsset: AppImageAssets.placeDetailAvatarCommonMom,
      ),
      PlantDetailMemoItem(
        author: '커먼맘',
        content: '오늘은 잎의 상태가 매우 좋다 커먼아 앱에서 알려준 물주기의 주기...',
        dateLabel: '2022.11.20',
        avatarAsset: AppImageAssets.placeDetailAvatarCommonMom,
        thumbnailAsset: AppImageAssets.plantEditMonstera,
      ),
      PlantDetailMemoItem(
        author: '커먼 파파',
        content: '오늘도 맑음',
        dateLabel: '2022.11.20',
      ),
    ],
  );
}
