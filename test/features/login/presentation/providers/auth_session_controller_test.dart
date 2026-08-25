import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_result.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_controller.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('API 비사용 모드는 기존 화면 흐름을 위해 인증 상태로 시작한다', () async {
    final container = ProviderContainer(
      overrides: [useRemoteApiProvider.overrideWithValue(false)],
    );
    addTearDown(container.dispose);

    final session = await container.read(authSessionControllerProvider.future);

    expect(session.status, AuthSessionStatus.authenticated);
  });

  test('API 모드는 저장된 access와 refresh token이 모두 있으면 세션을 복원한다', () async {
    final tokenStore = _MemoryAuthTokenStore(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );
    final container = _remoteContainer(tokenStore);
    addTearDown(container.dispose);

    final session = await container.read(authSessionControllerProvider.future);

    expect(session.status, AuthSessionStatus.authenticated);
    expect(tokenStore.clearCalls, 0);
  });

  test('API 모드는 token이 없으면 비인증 상태로 시작한다', () async {
    final container = _remoteContainer(_MemoryAuthTokenStore());
    addTearDown(container.dispose);

    final session = await container.read(authSessionControllerProvider.future);

    expect(session.status, AuthSessionStatus.unauthenticated);
  });

  test('불완전한 token 쌍은 삭제하고 비인증 상태로 복구한다', () async {
    final tokenStore = _MemoryAuthTokenStore(accessToken: 'access-token');
    final container = _remoteContainer(tokenStore);
    addTearDown(container.dispose);

    final session = await container.read(authSessionControllerProvider.future);

    expect(session.status, AuthSessionStatus.unauthenticated);
    expect(tokenStore.clearCalls, 1);
    expect(tokenStore.accessToken, isNull);
  });

  test('신규 사용자 로그인 결과에서 회원가입 진행 정보를 보존한다', () async {
    final container = _remoteContainer(_MemoryAuthTokenStore());
    addTearDown(container.dispose);
    await container.read(authSessionControllerProvider.future);

    container
        .read(authSessionControllerProvider.notifier)
        .applyAuthResult(
          const SignupRequiredResult(
            signupToken: 'signup-token',
            suggestedName: '커먼',
            suggestedImgUrl: 'https://example.com/profile.png',
          ),
        );

    final session = container.read(authSessionControllerProvider).requireValue;
    expect(session.status, AuthSessionStatus.signupRequired);
    expect(session.signupToken, 'signup-token');
    expect(session.suggestedName, '커먼');
    expect(session.suggestedImgUrl, 'https://example.com/profile.png');
  });
}

ProviderContainer _remoteContainer(AuthTokenStore tokenStore) {
  return ProviderContainer(
    overrides: [
      useRemoteApiProvider.overrideWithValue(true),
      authTokenStoreProvider.overrideWithValue(tokenStore),
    ],
  );
}

class _MemoryAuthTokenStore implements AuthTokenStore {
  _MemoryAuthTokenStore({this.accessToken, this.refreshToken});

  String? accessToken;
  String? refreshToken;
  int clearCalls = 0;

  @override
  Future<void> clear() async {
    clearCalls++;
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
