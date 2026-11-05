import 'dart:typed_data';

import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/core/network/auth_interceptor.dart';
import 'package:commonplant_frontend/features/login/data/datasources/auth_remote_data_source.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_requests.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthRemoteDataSource.refresh', () {
    test('refresh JSON과 access token 제외 설정을 기존 Dio에 전달한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = AuthRemoteDataSource(_dioWith(adapter));

      final result = await dataSource.refresh(
        const RefreshRequest(refreshToken: 'existing-refresh'),
      );

      expect(adapter.latestOptions.method, 'POST');
      expect(adapter.latestOptions.path, '/auth/refresh');
      expect(adapter.latestOptions.data, {'refreshToken': 'existing-refresh'});
      expect(adapter.latestOptions.contentType, Headers.jsonContentType);
      expect(adapter.latestOptions.extra[skipAccessTokenExtraKey], isTrue);
      expect(result, isA<Map<String, Object?>>());
    });

    test('갱신 HTTP 오류를 ApiException으로 전달한다', () async {
      final adapter = _CapturingAdapter(statusCode: 401);
      final dataSource = AuthRemoteDataSource(_dioWith(adapter));

      await expectLater(
        dataSource.refresh(
          const RefreshRequest(refreshToken: 'expired-refresh'),
        ),
        throwsA(
          isA<ApiException>().having(
            (error) => error.statusCode,
            'status',
            401,
          ),
        ),
      );
    });
  });

  group('AuthRemoteDataSource.register', () {
    test('register JSON part를 application/json multipart로 전송한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = AuthRemoteDataSource(_dioWith(adapter));

      await dataSource.register(
        const RegisterRequest(signupToken: 'signup-token', name: '커먼'),
      );

      final formData = adapter.latestOptions.data as FormData;
      final registerPart = formData.files.singleWhere(
        (file) => file.key == 'register',
      );

      expect(adapter.latestOptions.method, 'POST');
      expect(adapter.latestOptions.path, '/auth/register');
      expect(
        adapter.latestOptions.contentType,
        startsWith('multipart/form-data'),
      );
      expect(registerPart.value.contentType?.mimeType, 'application/json');
      expect(formData.files.map((file) => file.key), isNot(contains('image')));
    });

    test('선택한 image를 별도 multipart part로 전달한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = AuthRemoteDataSource(_dioWith(adapter));
      final image = MultipartFile.fromString(
        'image-bytes',
        filename: 'profile.png',
      );

      await dataSource.register(
        const RegisterRequest(signupToken: 'signup-token', name: '커먼'),
        image: image,
      );

      final formData = adapter.latestOptions.data as FormData;
      final imagePart = formData.files.singleWhere(
        (file) => file.key == 'image',
      );

      expect(imagePart.value, same(image));
    });
  });
}

Dio _dioWith(HttpClientAdapter adapter) {
  return Dio(BaseOptions(baseUrl: 'https://example.com'))
    ..httpClientAdapter = adapter;
}

class _CapturingAdapter implements HttpClientAdapter {
  _CapturingAdapter({this.statusCode = 200});

  final int statusCode;
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
      '{"result":{"accessToken":"access-token",'
      '"refreshToken":"refresh-token","newUser":false}}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
