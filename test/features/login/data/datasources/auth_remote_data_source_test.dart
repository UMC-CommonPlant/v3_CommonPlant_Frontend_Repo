import 'dart:typed_data';

import 'package:commonplant_frontend/features/login/data/datasources/auth_remote_data_source.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_requests.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
