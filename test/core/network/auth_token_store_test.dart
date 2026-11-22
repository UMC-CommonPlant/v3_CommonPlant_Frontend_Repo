import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/features/login/data/repositories/auth_repository.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _legacyAccess = 'commonplant.accessToken';
const _legacyRefresh = 'commonplant.refreshToken';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({
      _legacyAccess: 'old-access',
      _legacyRefresh: 'old-refresh',
    });
  });

  test('기존 토큰을 읽고 로그아웃 시 두 레거시 키를 삭제한다', () async {
    const storage = FlutterSecureStorage();
    const store = SecureAuthTokenStore(storage);
    expect(await store.readAccessToken(), 'old-access');
    expect(await store.readRefreshToken(), 'old-refresh');

    await store.clear();

    expect(await storage.read(key: _legacyAccess), isNull);
    expect(await storage.read(key: _legacyRefresh), isNull);
    expect(await store.readRefreshToken(), isNull);
  });

  test('레거시 refresh 삭제가 실패해도 재시작에서 갱신하지 않는다', () async {
    const store = SecureAuthTokenStore(_FailingRefreshDeletion());
    await expectLater(store.clear(), throwsStateError);
    const restartedStorage = FlutterSecureStorage();
    const restartedStore = SecureAuthTokenStore(restartedStorage);
    expect(await restartedStorage.read(key: _legacyRefresh), 'old-refresh');
    final container = ProviderContainer(
      overrides: [
        useRemoteApiProvider.overrideWithValue(true),
        authTokenStoreProvider.overrideWithValue(restartedStore),
        authRepositoryProvider.overrideWith(
          (_) => fail('로그아웃한 토큰으로 refresh를 시작하면 안 됩니다.'),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      (await container.read(
        authSessionControllerProvider.future,
      )).isUnauthenticated,
      isTrue,
    );

    await restartedStore.saveTokens(
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
    );
    expect(await restartedStore.readAccessToken(), 'new-access');
    expect(await restartedStore.readRefreshToken(), 'new-refresh');
  });

  test('Android에서 이전 보안 저장소 쓰기만 남아도 새 로그인으로 복원하지 않는다', () async {
    final preferences = _RestorePreferences();
    final initialStore = SecureAuthTokenStore(
      const FlutterSecureStorage(),
      restorePreferences: preferences,
    );
    await initialStore.saveTokens(accessToken: 'A', refreshToken: 'A-refresh');
    expect(await initialStore.readAccessToken(), 'A');

    final interruptedStore = SecureAuthTokenStore(
      const _UnflushedWrites(),
      restorePreferences: preferences,
    );
    await interruptedStore.clear();
    expect(await initialStore.readAccessToken(), isNull);

    await interruptedStore.saveTokens(
      accessToken: 'B',
      refreshToken: 'B-refresh',
    );
    expect(await initialStore.readRefreshToken(), isNull);

    await initialStore.saveTokens(accessToken: 'B', refreshToken: 'B-refresh');
    expect(await initialStore.readRefreshToken(), 'B-refresh');
  });
}

class _RestorePreferences extends Fake implements SharedPreferencesAsync {
  final _values = <String, String>{};

  @override
  Future<String?> getString(String key) async => _values[key];

  @override
  Future<void> setString(String key, String value) async =>
      _values[key] = value;
}

class _UnflushedWrites extends FlutterSecureStorage {
  const _UnflushedWrites();

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {}
}

class _FailingRefreshDeletion extends FlutterSecureStorage {
  const _FailingRefreshDeletion();

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (key == _legacyRefresh) throw StateError('storage error');
    await super.delete(key: key);
  }
}
