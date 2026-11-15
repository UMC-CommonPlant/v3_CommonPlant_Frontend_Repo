import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/features/image/data/datasources/image_remote_data_source.dart';
import 'package:commonplant_frontend/features/image/data/repositories/image_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

const _key = 'images/users/sample/plant.png';
const _url = 'https://cdn.example.com/images/users/sample/plant.png';
const _image = {'key': _key, 'contentType': 'image/png', 'sizeBytes': 256};

void main() {
  group('ImageRepository', () {
    test('이미지 조회는 Garage 공개 URL과 메타데이터를 반환한다', () async {
      final dataSource = _RecordingImageRemoteDataSource({
        'result': {..._image, 'placeId': 17, 'imageUrl': _url},
      });

      final image = await ImageRepository(dataSource).getImage(_key);

      expect(dataSource.latestKey, _key);
      expect(image.key, _key);
      expect(image.imageUrl, _url);
      expect(image.contentType, 'image/png');
      expect(image.sizeBytes, 256);
      expect(image.placeId, 17);
    });

    test('조회 응답에 공개 URL이 없거나 올바르지 않으면 실패한다', () async {
      for (final value in [null, 123, '/relative', 'file:///local.png']) {
        final repository = ImageRepository(
          _RecordingImageRemoteDataSource({
            'result': {..._image, 'imageUrl': value},
          }),
        );

        await expectLater(
          repository.getImage(_key),
          throwsA(isA<ApiException>()),
        );
      }
    });

    test('다중 업로드는 URL 없이 반환된 각 이미지 key를 순서대로 보존한다', () async {
      final repository = ImageRepository(
        _RecordingImageRemoteDataSource({
          'result': {
            'images': [
              _image,
              {..._image, 'key': 'images/users/sample/second.png'},
            ],
          },
        }),
      );
      final images = await repository.uploadImages([_file(), _file()]);

      expect(images.map((image) => image.key), [
        _key,
        'images/users/sample/second.png',
      ]);
      expect(images.first.imageUrl, isNull);
      expect(images.first.placeId, isNull);
    });

    test('업로드 결과가 불완전하거나 잘못된 항목을 포함하면 실패한다', () async {
      for (final value in [
        [_image],
        [_image, 'invalid'],
        [
          _image,
          {..._image, 'sizeBytes': '256'},
        ],
      ]) {
        final repository = ImageRepository(
          _RecordingImageRemoteDataSource({
            'result': {'images': value},
          }),
        );

        await expectLater(
          repository.uploadImages([_file(), _file()]),
          throwsA(isA<ApiException>()),
        );
      }
    });

    test('교체 대상 key와 교체 후 응답의 새 key를 구분한다', () async {
      const replacementKey = 'images/users/sample/replacement.png';
      final dataSource = _RecordingImageRemoteDataSource({
        'result': {..._image, 'key': replacementKey, 'imageUrl': null},
      });

      final image = await ImageRepository(
        dataSource,
      ).updateImage(key: _key, image: _file());

      expect(dataSource.latestKey, _key);
      expect(image.key, replacementKey);
      expect(image.imageUrl, isNull);
    });

    test('result 객체가 없는 성공 응답을 거부한다', () async {
      final repository = ImageRepository(
        _RecordingImageRemoteDataSource(_image),
      );

      await expectLater(
        repository.updateImage(key: _key, image: _file()),
        throwsA(isA<ApiException>()),
      );
    });
  });
}

MultipartFile _file() => MultipartFile.fromString(
  'image-bytes',
  filename: 'plant.png',
  contentType: DioMediaType('image', 'png'),
);

class _RecordingImageRemoteDataSource extends ImageRemoteDataSource {
  _RecordingImageRemoteDataSource(this.response) : super(Dio());

  final Object? response;
  String? latestKey;

  @override
  Future<Object?> getImage(String key) async {
    latestKey = key;
    return response;
  }

  @override
  Future<Object?> uploadImages(List<MultipartFile> images) async => response;

  @override
  Future<Object?> updateImage({
    required String key,
    required MultipartFile image,
  }) async {
    latestKey = key;
    return response;
  }
}
