import 'package:commonplant_frontend/features/plant/data/datasources/plant_remote_data_source.dart';
import 'package:commonplant_frontend/features/plant/data/dtos/plant_requests.dart';
import 'package:commonplant_frontend/features/plant/data/repositories/plant_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlantRepository', () {
    test('이름 수정의 기존 image key는 DTO와 datasource에 유지된다', () async {
      final dataSource = _ImagePlantRemoteDataSource();
      final repository = PlantRepositoryImpl(dataSource);

      await repository.updatePlant(
        plantId: 'plant-1',
        placeCode: 'place-1',
        nickname: '몬테라',
        imageKey: 'images/existing.png',
      );

      expect(dataSource.latestUpdateRequest?.toJson(), {
        'imageKey': 'images/existing.png',
        'nickname': '몬테라',
      });
      expect(dataSource.latestUpdateImage, isNull);
    });

    test('식물 생성은 선택된 이미지 파일을 datasource에 전달한다', () async {
      final dataSource = _ImagePlantRemoteDataSource();
      final repository = PlantRepositoryImpl(dataSource);
      final image = MultipartFile.fromString(
        'image-bytes',
        filename: 'plant.png',
      );

      await repository.createPlant(
        placeCode: 'place-1',
        nickname: '몬스테라',
        image: image,
      );

      expect(dataSource.latestCreateImage, same(image));
      expect(dataSource.latestCreateRequest?.toJson(), {
        'placeCode': 'place-1',
        'nickname': '몬스테라',
      });
    });

    test('식물 수정은 선택된 이미지 파일을 datasource에 전달한다', () async {
      final dataSource = _ImagePlantRemoteDataSource();
      final repository = PlantRepositoryImpl(dataSource);
      final image = MultipartFile.fromString(
        'image-bytes',
        filename: 'plant.png',
      );

      await repository.updatePlant(
        plantId: 'plant-1',
        placeCode: 'place-1',
        nickname: '몬스테라',
        image: image,
      );

      expect(dataSource.latestUpdateImage, same(image));
      expect(dataSource.latestUpdateRequest?.toJson(), {'nickname': '몬스테라'});
    });
  });
}

class _ImagePlantRemoteDataSource extends Fake
    implements PlantRemoteDataSource {
  CreatePlantRequest? latestCreateRequest;
  UpdatePlantRequest? latestUpdateRequest;
  MultipartFile? latestCreateImage;
  MultipartFile? latestUpdateImage;

  @override
  Future<void> createPlant(
    CreatePlantRequest request, {
    MultipartFile? image,
  }) async {
    latestCreateRequest = request;
    latestCreateImage = image;
  }

  @override
  Future<void> updatePlant({
    required String plantId,
    required String placeCode,
    required UpdatePlantRequest request,
    MultipartFile? image,
  }) async {
    latestUpdateRequest = request;
    latestUpdateImage = image;
  }
}
