import 'package:commonplant_frontend/features/plant/data/datasources/plant_remote_data_source.dart';
import 'package:commonplant_frontend/features/plant/data/dtos/plant_requests.dart';
import 'package:commonplant_frontend/features/plant/data/repositories/plant_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlantRepository', () {
    test('식물 생성은 선택된 이미지 파일을 datasource에 전달한다', () async {
      final dataSource = _ImagePlantRemoteDataSource();
      final repository = PlantRepository(dataSource);
      final image = MultipartFile.fromString(
        'image-bytes',
        filename: 'plant.png',
      );

      await repository.createPlant(
        const CreatePlantRequest(placeCode: 'place-1', nickname: '몬스테라'),
        image: image,
      );

      expect(dataSource.latestCreateImage, same(image));
    });

    test('식물 수정은 선택된 이미지 파일을 datasource에 전달한다', () async {
      final dataSource = _ImagePlantRemoteDataSource();
      final repository = PlantRepository(dataSource);
      final image = MultipartFile.fromString(
        'image-bytes',
        filename: 'plant.png',
      );

      await repository.updatePlant(
        plantId: 'plant-1',
        placeCode: 'place-1',
        request: const UpdatePlantRequest(nickname: '몬스테라'),
        image: image,
      );

      expect(dataSource.latestUpdateImage, same(image));
    });
  });
}

class _ImagePlantRemoteDataSource extends PlantRemoteDataSource {
  _ImagePlantRemoteDataSource() : super(Dio());

  MultipartFile? latestCreateImage;
  MultipartFile? latestUpdateImage;

  @override
  Future<void> createPlant(
    CreatePlantRequest request, {
    MultipartFile? image,
  }) async {
    latestCreateImage = image;
  }

  @override
  Future<void> updatePlant({
    required String plantId,
    required String placeCode,
    required UpdatePlantRequest request,
    MultipartFile? image,
  }) async {
    latestUpdateImage = image;
  }
}
