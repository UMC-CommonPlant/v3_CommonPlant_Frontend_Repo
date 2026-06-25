import 'package:commonplant_frontend/features/image/data/datasources/image_remote_data_source.dart';
import 'package:commonplant_frontend/features/image/data/repositories/image_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImageRepository', () {
    test('이미지 업로드는 반환값 없이 datasource에 위임한다', () async {
      final dataSource = _RecordingImageRemoteDataSource();
      final repository = ImageRepository(dataSource);
      final image = MultipartFile.fromString(
        'image-bytes',
        filename: 'plant.png',
      );

      await expectLater(repository.uploadImages([image]), completes);

      expect(dataSource.latestUploadedImages, [same(image)]);
    });

    test('이미지 수정은 반환값 없이 datasource에 위임한다', () async {
      final dataSource = _RecordingImageRemoteDataSource();
      final repository = ImageRepository(dataSource);
      final image = MultipartFile.fromString(
        'image-bytes',
        filename: 'plant.png',
      );

      await expectLater(
        repository.updateImage(
          key: 'images/user-nano-id/plant.png',
          image: image,
        ),
        completes,
      );

      expect(dataSource.latestUpdatedKey, 'images/user-nano-id/plant.png');
      expect(dataSource.latestUpdatedImage, same(image));
    });
  });
}

class _RecordingImageRemoteDataSource extends ImageRemoteDataSource {
  _RecordingImageRemoteDataSource() : super(Dio());

  List<MultipartFile>? latestUploadedImages;
  String? latestUpdatedKey;
  MultipartFile? latestUpdatedImage;

  @override
  Future<void> uploadImages(List<MultipartFile> images) async {
    latestUploadedImages = images;
  }

  @override
  Future<void> updateImage({
    required String key,
    required MultipartFile image,
  }) async {
    latestUpdatedKey = key;
    latestUpdatedImage = image;
  }
}
