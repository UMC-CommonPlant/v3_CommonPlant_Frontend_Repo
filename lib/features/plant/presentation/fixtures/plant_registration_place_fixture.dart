import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/features/plant/presentation/models/plant_registration_place.dart';

const plantRegistrationPlaceFallbacks = [
  PlantRegistrationPlace(
    id: 'place-1',
    name: '스윗 홈_거실',
    imageAsset: AppImageAssets.placeEditLivingRoom,
  ),
  PlantRegistrationPlace(
    id: 'place-2',
    name: '낫 스윗 회사_가든',
    imageAsset: AppImageAssets.placeDetailMonstera,
  ),
  PlantRegistrationPlace(
    id: 'place-3',
    name: '집_작업실',
    imageAsset: AppImageAssets.placeEditLivingRoom,
  ),
  PlantRegistrationPlace(
    id: 'place-4',
    name: '본가_거실',
    imageAsset: AppImageAssets.placeDetailMonstera,
  ),
];
