import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/features/login/data/datasources/auth_remote_data_source.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_requests.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_result.dart';
import 'package:commonplant_frontend/features/login/data/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthRepository.register', () {
    test('선택한 image를 전달하고 성공 응답 token을 저장한다', () async {
      final dataSource = _RegisterAuthRemoteDataSource();
      final tokenStore = _MemoryAuthTokenStore();
      final repository = AuthRepository(dataSource, tokenStore);
      final image = MultipartFile.fromString(
        'image-bytes',
        filename: 'profile.png',
      );

      final result = await repository.register(
        const RegisterRequest(signupToken: 'signup-token', name: '커먼'),
        image: image,
      );

      expect(dataSource.latestImage, same(image));
      expect(result, isA<AuthenticatedResult>());
      expect(tokenStore.accessToken, 'access-token');
      expect(tokenStore.refreshToken, 'refresh-token');
    });
  });
}

class _RegisterAuthRemoteDataSource extends AuthRemoteDataSource {
  _RegisterAuthRemoteDataSource() : super(Dio());

  MultipartFile? latestImage;

  @override
  Future<Object?> register(
    RegisterRequest request, {
    MultipartFile? image,
  }) async {
    latestImage = image;

    return {
      'result': {
        'accessToken': 'access-token',
        'refreshToken': 'refresh-token',
        'newUser': false,
      },
    };
  }
}

class _MemoryAuthTokenStore implements AuthTokenStore {
  String? accessToken;
  String? refreshToken;

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
  }

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }
}
