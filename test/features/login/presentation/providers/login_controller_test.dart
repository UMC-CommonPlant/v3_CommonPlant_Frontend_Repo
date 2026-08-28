import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_requests.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_result.dart';
import 'package:commonplant_frontend/features/login/data/gateways/social_auth_credential_gateway.dart';
import 'package:commonplant_frontend/features/login/data/repositories/auth_repository.dart';
import 'package:commonplant_frontend/features/login/domain/models/social_auth.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_controller.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_state.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/login_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('API 비사용 모드는 repository 없이 기존 회원가입 화면 흐름을 유지한다', () async {
    final container = ProviderContainer(
      overrides: [useRemoteApiProvider.overrideWithValue(false)],
    );
    addTearDown(container.dispose);

    final outcome = await container
        .read(loginControllerProvider.notifier)
        .login(SocialAuthProvider.kakao);

    expect(outcome, LoginOutcome.signupRequired);
    expect(
      container.read(loginControllerProvider).submitStatus,
      LoginSubmitStatus.success,
    );
  });

  test('기존 사용자는 social token으로 로그인하고 인증 상태가 된다', () async {
    final repository = _FakeAuthRepository(
      const AuthenticatedResult(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      ),
    );
    final container = _remoteContainer(
      repository: repository,
      gateway: const _StaticSocialAuthCredentialGateway(
        SocialAuthCredential(
          provider: SocialAuthProvider.google,
          token: 'social-token',
        ),
      ),
    );
    addTearDown(container.dispose);

    final outcome = await container
        .read(loginControllerProvider.notifier)
        .login(SocialAuthProvider.google);

    expect(outcome, LoginOutcome.authenticated);
    expect(repository.latestRequest?.provider, 'GOOGLE');
    expect(repository.latestRequest?.token, 'social-token');
    expect(
      container.read(authSessionControllerProvider).requireValue.status,
      AuthSessionStatus.authenticated,
    );
  });

  test('신규 사용자는 signup token과 추천 프로필을 세션에 보존한다', () async {
    final repository = _FakeAuthRepository(
      const SignupRequiredResult(
        signupToken: 'signup-token',
        suggestedName: '초록',
      ),
    );
    final container = _remoteContainer(
      repository: repository,
      gateway: const _StaticSocialAuthCredentialGateway(
        SocialAuthCredential(
          provider: SocialAuthProvider.kakao,
          token: 'social-token',
        ),
      ),
    );
    addTearDown(container.dispose);

    final outcome = await container
        .read(loginControllerProvider.notifier)
        .login(SocialAuthProvider.kakao);

    expect(outcome, LoginOutcome.signupRequired);
    final session = container.read(authSessionControllerProvider).requireValue;
    expect(session.status, AuthSessionStatus.signupRequired);
    expect(session.signupToken, 'signup-token');
    expect(session.suggestedName, '초록');
  });

  test('SDK adapter가 없으면 사용자용 설정 안내를 제공한다', () async {
    final container = _remoteContainer(
      repository: _FakeAuthRepository(
        const AuthenticatedResult(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
        ),
      ),
      gateway: const UnconfiguredSocialAuthCredentialGateway(),
    );
    addTearDown(container.dispose);

    final outcome = await container
        .read(loginControllerProvider.notifier)
        .login(SocialAuthProvider.apple);

    expect(outcome, isNull);
    final state = container.read(loginControllerProvider);
    expect(state.submitStatus, LoginSubmitStatus.failure);
    expect(state.errorMessage, socialLoginNotConfiguredMessage);
  });

  test('이전 세션의 늦은 SDK 결과로 로그인 요청을 시작하지 않는다', () async {
    final gateway = _DelayedSocialAuthCredentialGateway();
    final repository = _FakeAuthRepository(
      const AuthenticatedResult(accessToken: 'A', refreshToken: 'A'),
    );
    final container = _remoteContainer(
      repository: repository,
      gateway: gateway,
    );
    addTearDown(container.dispose);
    container.listen(loginControllerProvider, (_, _) {});
    await container.read(authSessionControllerProvider.future);
    final pending = container
        .read(loginControllerProvider.notifier)
        .login(SocialAuthProvider.kakao);
    await gateway.started.future;

    container
        .read(authSessionControllerProvider.notifier)
        .applyAuthResult(const SignupRequiredResult(signupToken: 'signup-B'));
    gateway.credential.complete(
      const SocialAuthCredential(
        provider: SocialAuthProvider.kakao,
        token: 'social-A',
      ),
    );

    expect(await pending, isNull);
    expect(repository.latestRequest, isNull);
    expect(
      container.read(authSessionControllerProvider).requireValue.signupToken,
      'signup-B',
    );
  });

  test('이전 로그인 응답이 새 회원가입 세션을 인증 상태로 덮지 않는다', () async {
    final result = Completer<AuthResult>();
    final repository = _FakeAuthRepository(
      const AuthenticatedResult(accessToken: 'A', refreshToken: 'A'),
      pendingResult: result,
    );
    final container = _remoteContainer(
      repository: repository,
      gateway: const _StaticSocialAuthCredentialGateway(
        SocialAuthCredential(
          provider: SocialAuthProvider.kakao,
          token: 'social-A',
        ),
      ),
    );
    addTearDown(container.dispose);
    container.listen(loginControllerProvider, (_, _) {});
    await container.read(authSessionControllerProvider.future);
    final pending = container
        .read(loginControllerProvider.notifier)
        .login(SocialAuthProvider.kakao);
    await repository.started.future;

    container
        .read(authSessionControllerProvider.notifier)
        .applyAuthResult(const SignupRequiredResult(signupToken: 'signup-B'));
    result.complete(repository.result);

    expect(await pending, isNull);
    expect(
      container.read(authSessionControllerProvider).requireValue.signupToken,
      'signup-B',
    );
    expect(container.read(loginControllerProvider).errorMessage, isNull);
  });
}

ProviderContainer _remoteContainer({
  required AuthRepository repository,
  required SocialAuthCredentialGateway gateway,
}) {
  return ProviderContainer(
    overrides: [
      useRemoteApiProvider.overrideWithValue(true),
      authTokenStoreProvider.overrideWithValue(_EmptyAuthTokenStore()),
      authRepositoryProvider.overrideWithValue(repository),
      socialAuthCredentialGatewayProvider.overrideWithValue(gateway),
    ],
  );
}

class _StaticSocialAuthCredentialGateway
    implements SocialAuthCredentialGateway {
  const _StaticSocialAuthCredentialGateway(this.credential);

  final SocialAuthCredential credential;

  @override
  Future<SocialAuthCredential> authorize(SocialAuthProvider provider) async {
    return credential;
  }
}

class _FakeAuthRepository extends Fake implements AuthRepository {
  _FakeAuthRepository(this.result, {this.pendingResult});

  final AuthResult result;
  final Completer<AuthResult>? pendingResult;
  final started = Completer<void>();
  LoginRequest? latestRequest;

  @override
  Future<AuthResult> login(LoginRequest request) async {
    latestRequest = request;
    if (!started.isCompleted) started.complete();
    return pendingResult?.future ?? result;
  }
}

class _DelayedSocialAuthCredentialGateway
    implements SocialAuthCredentialGateway {
  final started = Completer<void>();
  final credential = Completer<SocialAuthCredential>();

  @override
  Future<SocialAuthCredential> authorize(SocialAuthProvider provider) {
    started.complete();
    return credential.future;
  }
}

class _EmptyAuthTokenStore implements AuthTokenStore {
  @override
  Future<void> clear() async {}

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}
}
