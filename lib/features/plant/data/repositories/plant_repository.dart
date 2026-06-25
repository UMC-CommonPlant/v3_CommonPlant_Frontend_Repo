import 'package:commonplant_frontend/core/network/api_client.dart';
import 'package:commonplant_frontend/core/network/api_response_parser.dart';
import 'package:commonplant_frontend/features/plant/data/datasources/plant_remote_data_source.dart';
import 'package:commonplant_frontend/features/plant/data/dtos/plant_requests.dart';
import 'package:commonplant_frontend/features/plant/data/mappers/plant_mapper.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_summary.dart';
import 'package:dio/dio.dart';
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

  Future<void> createPlant(CreatePlantRequest request, {MultipartFile? image}) {
    return _remoteDataSource.createPlant(request, image: image);
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
    MultipartFile? image,
  }) {
    return _remoteDataSource.updatePlant(
      plantId: plantId,
      placeCode: placeCode,
      request: request,
      image: image,
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
