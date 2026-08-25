import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_controller.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_state.dart';
import 'package:commonplant_frontend/features/user/data/repositories/user_repository.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_account_controller.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_settings_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('로그아웃은 서버 호출 없이 로컬 token과 인증 세션을 제거한다', () async {
    final tokenStore = _MemoryAuthTokenStore();
    final repository = _RecordingUserRepository();
    final container = _container(tokenStore, repository);
    addTearDown(container.dispose);
    final subscription = container.listen(
      userAccountControllerProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
    await container.read(authSessionControllerProvider.future);

    final succeeded = await container
        .read(userAccountControllerProvider.notifier)
        .logout();

    expect(succeeded, isTrue);
    expect(repository.deleteCalls, 0);
    expect(tokenStore.clearCalls, 1);
    expect(
      container.read(authSessionControllerProvider).requireValue.status,
      AuthSessionStatus.unauthenticated,
    );
  });

  test('회원 탈퇴는 DELETE 요청 성공 후 로컬 세션을 제거한다', () async {
    final tokenStore = _MemoryAuthTokenStore();
    final repository = _RecordingUserRepository();
    final container = _container(tokenStore, repository);
    addTearDown(container.dispose);
    final subscription = container.listen(
      userAccountControllerProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
    await container.read(authSessionControllerProvider.future);

    final succeeded = await container
        .read(userAccountControllerProvider.notifier)
        .deleteAccount();

    expect(succeeded, isTrue);
    expect(repository.deleteCalls, 1);
    expect(tokenStore.clearCalls, 1);
  });

  test('회원 탈퇴 오류는 세션을 유지하고 사용자용 오류를 제공한다', () async {
    final tokenStore = _MemoryAuthTokenStore();
    final repository = _RecordingUserRepository(
      deleteError: StateError('탈퇴 실패'),
    );
    final container = _container(tokenStore, repository);
    addTearDown(container.dispose);
    final subscription = container.listen(
      userAccountControllerProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
    await container.read(authSessionControllerProvider.future);

    final succeeded = await container
        .read(userAccountControllerProvider.notifier)
        .deleteAccount();

    expect(succeeded, isFalse);
    expect(tokenStore.clearCalls, 0);
    expect(
      container.read(userAccountControllerProvider).errorMessage,
      '회원 탈퇴를 완료하지 못했어요',
    );
    expect(
      container.read(authSessionControllerProvider).requireValue.status,
      AuthSessionStatus.authenticated,
    );
  });

  test('알림 설정은 화면 세션의 로컬 상태로 전환한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(
      userNotificationSettingProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);

    expect(container.read(userNotificationSettingProvider), isTrue);
    container.read(userNotificationSettingProvider.notifier).setEnabled(false);
    expect(container.read(userNotificationSettingProvider), isFalse);
  });
}

ProviderContainer _container(
  AuthTokenStore tokenStore,
  UserRepository repository,
) {
  return ProviderContainer(
    overrides: [
      useRemoteApiProvider.overrideWithValue(true),
      authTokenStoreProvider.overrideWithValue(tokenStore),
      userRepositoryProvider.overrideWithValue(repository),
    ],
  );
}

class _RecordingUserRepository extends Fake implements UserRepository {
  _RecordingUserRepository({this.deleteError});

  final Object? deleteError;
  int deleteCalls = 0;

  @override
  Future<void> deleteMe() async {
    deleteCalls++;
    if (deleteError != null) {
      return Future<void>.error(deleteError!);
    }
  }
}

class _MemoryAuthTokenStore implements AuthTokenStore {
  String? accessToken = 'access-token';
  String? refreshToken = 'refresh-token';
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
