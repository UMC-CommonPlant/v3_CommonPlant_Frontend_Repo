import 'package:commonplant_frontend/features/plant/data/datasources/plant_remote_data_source.dart';
import 'package:commonplant_frontend/features/plant/data/dtos/plant_requests.dart';
import 'package:commonplant_frontend/features/plant/data/mappers/plant_mapper.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_summary.dart';
import 'package:commonplant_frontend/features/plant/domain/repositories/plant_repository.dart';
import 'package:dio/dio.dart';

class PlantRepositoryImpl implements PlantRepository {
  const PlantRepositoryImpl(this._remoteDataSource);

  final PlantRemoteDataSource _remoteDataSource;

  @override
  Future<List<PlantSummary>> fetchPlants({int page = 0, int size = 20}) async {
    final data = await _remoteDataSource.getPlants(page: page, size: size);

    return plantSummariesFromResponse(data);
  }

  @override
  Future<void> createPlant({
    required String placeCode,
    required String nickname,
    String? scientificNameKo,
    String? scientificNameEn,
    String? lastWateredDate,
    String? description,
    MultipartFile? image,
  }) {
    final request = CreatePlantRequest(
      placeCode: placeCode,
      nickname: nickname,
      scientificNameKo: scientificNameKo,
      scientificNameEn: scientificNameEn,
      lastWateredDate: lastWateredDate,
      description: description,
    );

    return _remoteDataSource.createPlant(request, image: image);
  }

  @override
  Future<PlantDetail> fetchPlant({required String plantId}) async {
    final data = await _remoteDataSource.getPlant(plantId: plantId);

    return plantDetailFromResponse(data, fallbackId: plantId);
  }

  @override
  Future<PlantEditInfo> fetchPlantEditInfo({required String plantId}) async {
    final data = await _remoteDataSource.getPlantEditInfo(plantId: plantId);

    return plantEditInfoFromResponse(data);
  }

  @override
  Future<void> updatePlant({
    required String plantId,
    required String placeCode,
    String? imageKey,
    String? nickname,
    String? lastWateredDate,
    MultipartFile? image,
  }) {
    final request = UpdatePlantRequest(
      imageKey: imageKey,
      nickname: nickname,
      lastWateredDate: lastWateredDate,
    );

    return _remoteDataSource.updatePlant(
      plantId: plantId,
      placeCode: placeCode,
      request: request,
      image: image,
    );
  }

  @override
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
