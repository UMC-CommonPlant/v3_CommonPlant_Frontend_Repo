import 'dart:typed_data';

import 'package:commonplant_frontend/features/user/data/datasources/user_remote_data_source.dart';
import 'package:commonplant_frontend/features/user/data/dtos/user_requests.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserRemoteDataSource', () {
    test('내 정보 조회는 GET /users로 요청한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = UserRemoteDataSource(_dioWith(adapter));

      await dataSource.getMe();

      expect(adapter.latestOptions.method, 'GET');
      expect(adapter.latestOptions.path, '/users');
    });

    test('사용자 검색은 keyword path를 인코딩해 요청한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = UserRemoteDataSource(_dioWith(adapter));

      await dataSource.searchUsers('커먼 식집사');

      expect(adapter.latestOptions.method, 'GET');
      expect(
        adapter.latestOptions.path,
        '/users/%EC%BB%A4%EB%A8%BC%20%EC%8B%9D%EC%A7%91%EC%82%AC',
      );
    });

    test('내 정보 수정은 multipart PUT /users로 요청한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = UserRemoteDataSource(_dioWith(adapter));

      await dataSource.updateMe(const UpdateUserRequest(name: '커먼'));

      expect(adapter.latestOptions.method, 'PUT');
      expect(adapter.latestOptions.path, '/users');
      expect(
        adapter.latestOptions.contentType,
        startsWith('multipart/form-data'),
      );
    });

    test('회원 탈퇴는 DELETE /users로 요청한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = UserRemoteDataSource(_dioWith(adapter));

      await dataSource.deleteMe();

      expect(adapter.latestOptions.method, 'DELETE');
      expect(adapter.latestOptions.path, '/users');
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
