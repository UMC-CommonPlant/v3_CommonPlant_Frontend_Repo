import 'dart:convert';
import 'dart:typed_data';

import 'package:commonplant_frontend/features/plant/data/datasources/plant_remote_data_source.dart';
import 'package:commonplant_frontend/features/plant/data/dtos/plant_requests.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlantRemoteDataSource', () {
    test('사진 유지 요청은 multipart JSON에 기존 key를 보존한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = DioPlantRemoteDataSource(_dioWith(adapter));

      await dataSource.updatePlant(
        plantId: '1',
        placeCode: 'Abc123',
        request: const UpdatePlantRequest(
          nickname: '몬테라',
          imageKey: 'images/existing.png',
        ),
      );

      expect(adapter.latestBody, contains('"imageKey":"images/existing.png"'));
      expect(adapter.latestBody, contains('"nickname":"몬테라"'));
      expect(adapter.latestBody, isNot(contains('name="image"')));
    });

    test('명시적 null key는 삭제 계약대로 key와 파일을 생략한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = DioPlantRemoteDataSource(_dioWith(adapter));

      await dataSource.updatePlant(
        plantId: '1',
        placeCode: 'Abc123',
        request: const UpdatePlantRequest(nickname: '몬테라', imageKey: null),
      );

      expect(adapter.latestBody, isNot(contains('"imageKey"')));
      expect(adapter.latestBody, isNot(contains('name="image"')));
    });

    test('식물 상세 조회는 place query 없이 plantId path만 보낸다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = DioPlantRemoteDataSource(_dioWith(adapter));

      await dataSource.getPlant(plantId: '1');

      expect(adapter.latestOptions.path, '/plants/1');
      expect(adapter.latestOptions.queryParameters, isEmpty);
    });

    test('식물 수정 정보 조회는 place query 없이 plantId path만 보낸다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = DioPlantRemoteDataSource(_dioWith(adapter));

      await dataSource.getPlantEditInfo(plantId: '1');

      expect(adapter.latestOptions.path, '/plants/1/edit');
      expect(adapter.latestOptions.queryParameters, isEmpty);
    });

    test('식물 수정은 placeCode query를 보낸다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = DioPlantRemoteDataSource(_dioWith(adapter));

      await dataSource.updatePlant(
        plantId: '1',
        placeCode: 'Abc123',
        request: const UpdatePlantRequest(nickname: '거실 몬스테라'),
      );

      expect(adapter.latestOptions.path, '/plants/1');
      expect(adapter.latestOptions.queryParameters, {'placeCode': 'Abc123'});
    });

    test('식물 생성은 optional image part를 multipart에 포함한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = DioPlantRemoteDataSource(_dioWith(adapter));

      await dataSource.createPlant(
        const CreatePlantRequest(placeCode: 'Abc123', nickname: '몬스테라'),
        image: MultipartFile.fromString('image-bytes', filename: 'plant.png'),
      );

      final formData = adapter.latestOptions.data as FormData;

      expect(adapter.latestOptions.method, 'POST');
      expect(adapter.latestOptions.path, '/plants');
      expect(formData.files.map((file) => file.key), contains('image'));
    });

    test('식물 수정은 optional image part를 multipart에 포함한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = DioPlantRemoteDataSource(_dioWith(adapter));

      await dataSource.updatePlant(
        plantId: '1',
        placeCode: 'Abc123',
        request: const UpdatePlantRequest(nickname: '거실 몬스테라'),
        image: MultipartFile.fromString('image-bytes', filename: 'plant.png'),
      );

      final formData = adapter.latestOptions.data as FormData;

      expect(adapter.latestOptions.method, 'PUT');
      expect(adapter.latestOptions.path, '/plants/1');
      expect(formData.files.map((file) => file.key), contains('image'));
      expect(adapter.latestBody, contains('image-bytes'));
      expect(adapter.latestBody, contains('filename="plant.png"'));
    });

    test('식물 삭제는 placeCode query를 보낸다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = DioPlantRemoteDataSource(_dioWith(adapter));

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
  late String latestBody;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    latestOptions = options;
    latestBody = requestStream == null
        ? ''
        : await utf8.decoder.bind(requestStream).join();

    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
