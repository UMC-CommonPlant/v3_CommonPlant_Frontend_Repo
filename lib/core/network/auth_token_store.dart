import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AuthTokenStore {
  Future<String?> readAccessToken();

  Future<String?> readRefreshToken();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> clear();
}

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authTokenStoreProvider = Provider<AuthTokenStore>((ref) {
  return SecureAuthTokenStore(
    ref.watch(secureStorageProvider),
    // Android secure storage writes through SharedPreferences.apply().
    // The default Android SharedPreferencesAsync backend uses DataStore.
    restorePreferences:
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? SharedPreferencesAsync()
        : null,
  );
});

class SecureAuthTokenStore implements AuthTokenStore {
  const SecureAuthTokenStore(
    this._storage, {
    SharedPreferencesAsync? restorePreferences,
  }) : _restorePreferences = restorePreferences;

  static const String _sessionKey = 'commonplant.authSession';
  static const String _restoreKey = 'commonplant.authRestoreSession';
  static const String _signedOut = 'signed-out';
  static const String _accessTokenKey = 'commonplant.accessToken';
  static const String _refreshTokenKey = 'commonplant.refreshToken';

  final FlutterSecureStorage _storage;
  final SharedPreferencesAsync? _restorePreferences;

  @override
  Future<String?> readAccessToken() =>
      _readToken('accessToken', _accessTokenKey);

  @override
  Future<String?> readRefreshToken() =>
      _readToken('refreshToken', _refreshTokenKey);

  Future<String?> _readToken(String field, String legacyKey) async {
    final restoreId = await _restorePreferences?.getString(_restoreKey);
    if (restoreId == _signedOut) return null;

    final session = await _storage.read(key: _sessionKey);
    if (session == null) {
      return restoreId == null ? _storage.read(key: legacyKey) : null;
    }
    if (session == _signedOut) return null;

    try {
      final tokens = jsonDecode(session);
      if (tokens is Map<String, dynamic> &&
          tokens['restoreId'] == restoreId &&
          tokens[field] is String) {
        return tokens[field] as String;
      }
      return null;
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final preferences = _restorePreferences;
    final random = preferences == null ? null : Random.secure();
    final restoreId = random == null
        ? null
        : base64UrlEncode(List.generate(16, (_) => random.nextInt(256)));
    await _storage.write(
      key: _sessionKey,
      value: jsonEncode({
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        if (restoreId != null) 'restoreId': restoreId,
      }),
    );
    // A persisted restore ID cannot enable a previous secure-storage record.
    if (restoreId != null) await preferences!.setString(_restoreKey, restoreId);
  }

  @override
  Future<void> clear() async {
    await _restorePreferences?.setString(_restoreKey, _signedOut);
    // 이전 버전 키가 남아 있어도 이 기록을 확인한 앱은 세션을 복원하지 않는다.
    await _storage.write(key: _sessionKey, value: _signedOut);
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }
}
