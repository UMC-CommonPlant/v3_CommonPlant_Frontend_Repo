import 'dart:typed_data';

import 'package:commonplant_frontend/features/image/data/datasources/image_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImageRemoteDataSource', () {
    test('이미지 다운로드 URL은 key query로 조회한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = ImageRemoteDataSource(_dioWith(adapter));

      await dataSource.getDownloadUrl('images/user-nano-id/monstera.png');

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
        MultipartFile.fromString('image-bytes', filename: 'plant.png'),
      ]);

      expect(adapter.latestOptions.method, 'POST');
      expect(adapter.latestOptions.path, '/s3/images');
      expect(
        adapter.latestOptions.contentType,
        startsWith('multipart/form-data'),
      );
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

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
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
