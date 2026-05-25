import 'package:commonplant_frontend/core/network/api_client.dart';
import 'package:commonplant_frontend/core/network/api_response_parser.dart';
import 'package:commonplant_frontend/features/plant/data/datasources/plant_remote_data_source.dart';
import 'package:commonplant_frontend/features/plant/data/dtos/plant_requests.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final plantRemoteDataSourceProvider = Provider<PlantRemoteDataSource>((ref) {
  return PlantRemoteDataSource(ref.watch(dioProvider));
});

final plantRepositoryProvider = Provider<PlantRepository>((ref) {
  return PlantRepository(ref.watch(plantRemoteDataSourceProvider));
});

class PlantRepository {
  const PlantRepository(this._remoteDataSource);

  final PlantRemoteDataSource _remoteDataSource;

  Future<List<PlantSummary>> fetchPlants({int page = 0, int size = 20}) async {
    final data = await _remoteDataSource.getPlants(page: page, size: size);
    final items = jsonListFromResponse(data, context: '식물 목록 조회');

    return [for (final item in items) plantSummaryFromJson(item)];
  }

  Future<void> createPlant(CreatePlantRequest request) {
    return _remoteDataSource.createPlant(request);
  }

  Future<PlantDetail> fetchPlant({required String plantId}) async {
    final data = await _remoteDataSource.getPlant(plantId: plantId);
    final object = unwrapJsonObject(data, context: '식물 상세 조회');

    return plantDetailFromJson(object, fallbackId: plantId);
  }

  Future<PlantEditInfo> fetchPlantEditInfo({required String plantId}) async {
    final data = await _remoteDataSource.getPlantEditInfo(plantId: plantId);
    final object = unwrapJsonObject(data, context: '식물 수정 정보 조회');

    return plantEditInfoFromJson(object);
  }

  Future<void> updatePlant({
    required String plantId,
    required String placeCode,
    required UpdatePlantRequest request,
  }) {
    return _remoteDataSource.updatePlant(
      plantId: plantId,
      placeCode: placeCode,
      request: request,
    );
  }

  Future<void> deletePlant({
    required String plantId,
    required String placeCode,
  }) {
    return _remoteDataSource.deletePlant(
      plantId: plantId,
      placeCode: placeCode,
    );
  }
}

PlantSummary plantSummaryFromJson(JsonMap json) {
  return PlantSummary(
    id: readRequiredString(json, const ['id', 'plantId'], '식물 ID'),
    name: readRequiredString(json, const ['nickname', 'name'], '식물 이름'),
    placeId: readOptionalString(json, const ['placeId', 'placeCode']),
    placeName: readOptionalString(json, const ['placeName']),
    description: readOptionalString(json, const ['description']),
    imageUrl: readOptionalString(json, const [
      'representativeImageUrl',
      'imageUrl',
    ]),
  );
}

PlantDetail plantDetailFromJson(
  JsonMap json, {
  required String fallbackId,
  String? fallbackPlaceId,
}) {
  return PlantDetail(
    id: readOptionalString(json, const ['id', 'plantId']) ?? fallbackId,
    name: readRequiredString(json, const [
      'nickname',
      'name',
      'scientificNameKo',
      'scientificNameEn',
    ], '식물 이름'),
    placeId:
        readOptionalString(json, const ['placeId', 'placeCode']) ??
        fallbackPlaceId,
    placeName: readOptionalString(json, const ['placeName']),
    species: readOptionalString(json, const [
      'scientificNameEn',
      'scientificNameKo',
      'species',
    ]),
    description: readOptionalString(json, const ['plantInfo', 'description']),
    lastWateredDate: readOptionalString(json, const ['lastWateredDate']),
    imageKey: readOptionalString(json, const ['imageKey']),
    imageUrl: readOptionalString(json, const ['imageUrl']),
    memo: readOptionalString(json, const ['memo']),
    registeredAt: readOptionalString(json, const ['registeredAt']),
  );
}

PlantEditInfo plantEditInfoFromJson(JsonMap json) {
  return PlantEditInfo(
    name: readRequiredString(json, const ['nickname', 'name'], '식물 애칭'),
    lastWateredDate: readOptionalString(json, const ['lastWateredDate']),
    imageKey: readOptionalString(json, const ['imageKey']),
    imageUrl: readOptionalString(json, const ['imageUrl']),
  );
}
