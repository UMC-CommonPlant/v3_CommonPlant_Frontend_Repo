import 'dart:typed_data';

import 'package:commonplant_frontend/features/place/data/datasources/place_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/dtos/place_requests.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaceRemoteDataSource', () {
    test('장소 수정은 multipart PUT /place/update/{code}로 요청한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = PlaceRemoteDataSource(_dioWith(adapter));

      await dataSource.updatePlace(
        code: 'Abc123',
        request: const UpdatePlaceRequest(
          name: '정원',
          address: '서울특별시',
          imageKey: 'images/user-nano-id/garden.png',
        ),
      );

      expect(adapter.latestOptions.method, 'PUT');
      expect(adapter.latestOptions.path, '/place/update/Abc123');
      expect(
        adapter.latestOptions.contentType,
        startsWith('multipart/form-data'),
      );
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
