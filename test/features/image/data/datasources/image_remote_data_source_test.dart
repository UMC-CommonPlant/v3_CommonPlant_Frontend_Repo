import 'dart:typed_data';

import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/features/image/data/datasources/image_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImageRemoteDataSource', () {
    test('공개 이미지 URL은 key query로 조회한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = ImageRemoteDataSource(_dioWith(adapter));

      await dataSource.getImage('images/user-nano-id/monstera.png');

      expect(adapter.latestOptions.method, 'GET');
      expect(adapter.latestOptions.path, '/s3/images');
      expect(adapter.latestOptions.queryParameters, {
        'key': 'images/user-nano-id/monstera.png',
      });
    });

    test('이미지 업로드는 multipart POST /s3/images로 요청한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = ImageRemoteDataSource(_dioWith(adapter));

      await dataSource.uploadImages([
        MultipartFile.fromString('png-bytes', filename: 'plant.png'),
        MultipartFile.fromString('webp-bytes', filename: 'place.webp'),
      ]);

      final files = (adapter.latestOptions.data as FormData).files;
      expect(files.map((file) => file.key), ['images', 'images']);
      expect(files.map((file) => file.value.filename), [
        'plant.png',
        'place.webp',
      ]);
      expect(adapter.latestOptions.method, 'POST');
      expect(adapter.latestOptions.path, '/s3/images');
      expect(
        adapter.latestOptions.contentType,
        startsWith('multipart/form-data'),
      );
    });

    test('허용 개수를 벗어난 이미지 묶음은 서버에 요청하지 않는다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = ImageRemoteDataSource(_dioWith(adapter));

      for (final count in [0, 6]) {
        await expectLater(
          dataSource.uploadImages([
            for (var index = 0; index < count; index++)
              MultipartFile.fromString('image-bytes', filename: 'image.png'),
          ]),
          throwsA(isA<ApiException>()),
        );
      }

      expect(adapter.calls, 0);
    });

    test('이미지 수정은 key query와 multipart PUT /s3/images로 요청한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = ImageRemoteDataSource(_dioWith(adapter));

      await dataSource.updateImage(
        key: 'images/user-nano-id/monstera.png',
        image: MultipartFile.fromString('image-bytes', filename: 'plant.png'),
      );

      expect(adapter.latestOptions.method, 'PUT');
      expect(adapter.latestOptions.path, '/s3/images');
      expect(adapter.latestOptions.queryParameters, {
        'key': 'images/user-nano-id/monstera.png',
      });
      expect(
        adapter.latestOptions.contentType,
        startsWith('multipart/form-data'),
      );
    });

    test('이미지 삭제는 key query로 요청한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = ImageRemoteDataSource(_dioWith(adapter));

      await dataSource.deleteImage('images/user-nano-id/monstera.png');

      expect(adapter.latestOptions.method, 'DELETE');
      expect(adapter.latestOptions.path, '/s3/images');
      expect(adapter.latestOptions.queryParameters, {
        'key': 'images/user-nano-id/monstera.png',
      });
    });
  });
}

Dio _dioWith(HttpClientAdapter adapter) {
  return Dio(BaseOptions(baseUrl: 'https://example.com'))
    ..httpClientAdapter = adapter;
}

class _CapturingAdapter implements HttpClientAdapter {
  late RequestOptions latestOptions;
  int calls = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    latestOptions = options;

    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
