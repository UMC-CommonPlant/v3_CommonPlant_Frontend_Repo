import 'dart:typed_data';

import 'package:commonplant_frontend/features/plant/data/datasources/plant_remote_data_source.dart';
import 'package:commonplant_frontend/features/plant/data/dtos/plant_requests.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlantRemoteDataSource', () {
    test('식물 상세 조회는 place query 없이 plantId path만 보낸다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = PlantRemoteDataSource(_dioWith(adapter));

      await dataSource.getPlant(plantId: '1');

      expect(adapter.latestOptions.path, '/plants/1');
      expect(adapter.latestOptions.queryParameters, isEmpty);
    });

    test('식물 수정 정보 조회는 place query 없이 plantId path만 보낸다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = PlantRemoteDataSource(_dioWith(adapter));

      await dataSource.getPlantEditInfo(plantId: '1');

      expect(adapter.latestOptions.path, '/plants/1/edit');
      expect(adapter.latestOptions.queryParameters, isEmpty);
    });

    test('식물 수정은 placeCode query를 보낸다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = PlantRemoteDataSource(_dioWith(adapter));

      await dataSource.updatePlant(
        plantId: '1',
        placeCode: 'Abc123',
        request: const UpdatePlantRequest(nickname: '거실 몬스테라'),
      );

      expect(adapter.latestOptions.path, '/plants/1');
      expect(adapter.latestOptions.queryParameters, {'placeCode': 'Abc123'});
    });

    test('식물 삭제는 placeCode query를 보낸다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = PlantRemoteDataSource(_dioWith(adapter));

      await dataSource.deletePlant(plantId: '1', placeCode: 'Abc123');

      expect(adapter.latestOptions.path, '/plants/1');
      expect(adapter.latestOptions.queryParameters, {'placeCode': 'Abc123'});
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
