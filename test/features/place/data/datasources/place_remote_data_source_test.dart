import 'dart:convert';
import 'dart:typed_data';

import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/features/place/data/datasources/place_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/dtos/place_requests.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaceRemoteDataSource', () {
    test('팀짱 위임은 실제 code·nanoId를 인코딩한 PUT이며 body가 없다', () async {
      final adapter = _CapturingAdapter(responseBody: '{"result":null}');
      final dataSource = DioPlaceRemoteDataSource(_dioWith(adapter));

      await dataSource.changePlaceOwner(
        code: 'place/A B',
        targetNanoId: 'nano/A B',
      );

      expect(adapter.latestOptions.method, 'PUT');
      expect(
        adapter.latestOptions.path,
        '/place/place%2FA%20B/owner/nano%2FA%20B',
      );
      expect(adapter.latestOptions.data, isNull);
      expect(adapter.latestOptions.queryParameters, isEmpty);
    });

    for (final status in [403, 404]) {
      test('팀짱 위임의 $status 응답을 API 실패로 전달한다', () async {
        final adapter = _CapturingAdapter(statusCode: status);
        final dataSource = DioPlaceRemoteDataSource(_dioWith(adapter));
        await expectLater(
          dataSource.changePlaceOwner(code: 'place', targetNanoId: 'member'),
          throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'status', status),
          ),
        );
      });
    }
    test('장소 멤버는 code를 인코딩한 GET path로 조회하고 응답을 보존한다', () async {
      final adapter = _CapturingAdapter(responseBody: '{"result":[]}');
      final dataSource = DioPlaceRemoteDataSource(_dioWith(adapter));

      final response = await dataSource.getPlaceMembers('place/A B');

      expect(adapter.latestOptions.method, 'GET');
      expect(adapter.latestOptions.path, '/place/place%2FA%20B/members');
      expect(response, {'result': <Object?>[]});
    });

    test('장소 수정은 multipart PUT /place/update/{code}로 요청한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = DioPlaceRemoteDataSource(_dioWith(adapter));

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
      expect(
        adapter.latestBody,
        contains('"imageKey":"images/user-nano-id/garden.png"'),
      );
      expect(adapter.latestBody, isNot(contains('name="image"')));
    });

    test('명시적 null key는 삭제 계약대로 key와 파일을 생략한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = DioPlaceRemoteDataSource(_dioWith(adapter));

      await dataSource.updatePlace(
        code: 'Abc123',
        request: const UpdatePlaceRequest(
          name: '정원',
          address: '서울특별시',
          imageKey: null,
        ),
      );

      expect(adapter.latestBody, isNot(contains('"imageKey"')));
      expect(adapter.latestBody, isNot(contains('name="image"')));
    });

    test('장소 생성은 optional image part를 multipart에 포함한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = DioPlaceRemoteDataSource(_dioWith(adapter));

      await dataSource.createPlace(
        const CreatePlaceRequest(name: '정원', address: '서울특별시'),
        image: MultipartFile.fromString('image-bytes', filename: 'place.png'),
      );

      final formData = adapter.latestOptions.data as FormData;

      expect(adapter.latestOptions.method, 'POST');
      expect(adapter.latestOptions.path, '/place/create');
      expect(formData.files.map((file) => file.key), contains('image'));
    });

    test('장소 수정은 optional image part를 multipart에 포함한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = DioPlaceRemoteDataSource(_dioWith(adapter));

      await dataSource.updatePlace(
        code: 'Abc123',
        request: const UpdatePlaceRequest(name: '정원', address: '서울특별시'),
        image: MultipartFile.fromString('image-bytes', filename: 'place.png'),
      );

      final formData = adapter.latestOptions.data as FormData;

      expect(adapter.latestOptions.method, 'PUT');
      expect(adapter.latestOptions.path, '/place/update/Abc123');
      expect(formData.files.map((file) => file.key), contains('image'));
      expect(adapter.latestBody, contains('image-bytes'));
      expect(adapter.latestBody, contains('filename="place.png"'));
    });
  });
}

Dio _dioWith(HttpClientAdapter adapter) {
  return Dio(BaseOptions(baseUrl: 'https://example.com'))
    ..httpClientAdapter = adapter;
}

class _CapturingAdapter implements HttpClientAdapter {
  _CapturingAdapter({this.responseBody = '{}', this.statusCode = 200});

  final String responseBody;
  final int statusCode;
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
      responseBody,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
