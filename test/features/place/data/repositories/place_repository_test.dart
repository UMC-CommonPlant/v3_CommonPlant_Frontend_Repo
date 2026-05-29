import 'package:commonplant_frontend/features/place/data/datasources/place_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/dtos/place_requests.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaceRepository', () {
    test('장소 생성은 선택된 이미지 파일을 datasource에 전달한다', () async {
      final dataSource = _ImagePlaceRemoteDataSource();
      final repository = PlaceRepository(dataSource);
      final image = MultipartFile.fromString(
        'image-bytes',
        filename: 'place.png',
      );

      await repository.createPlace(
        const CreatePlaceRequest(name: '거실', address: '서울시 성북구'),
        image: image,
      );

      expect(dataSource.latestCreateImage, same(image));
    });

    test('장소 수정은 선택된 이미지 파일을 datasource에 전달한다', () async {
      final dataSource = _ImagePlaceRemoteDataSource();
      final repository = PlaceRepository(dataSource);
      final image = MultipartFile.fromString(
        'image-bytes',
        filename: 'place.png',
      );

      await repository.updatePlace(
        code: 'place-1',
        request: const UpdatePlaceRequest(name: '거실', address: '서울시 성북구'),
        image: image,
      );

      expect(dataSource.latestUpdateImage, same(image));
    });
  });
}

class _ImagePlaceRemoteDataSource extends PlaceRemoteDataSource {
  _ImagePlaceRemoteDataSource() : super(Dio());

  MultipartFile? latestCreateImage;
  MultipartFile? latestUpdateImage;

  @override
  Future<void> createPlace(
    CreatePlaceRequest request, {
    MultipartFile? image,
  }) async {
    latestCreateImage = image;
  }

  @override
  Future<void> updatePlace({
    required String code,
    required UpdatePlaceRequest request,
    MultipartFile? image,
  }) async {
    latestUpdateImage = image;
  }
}
