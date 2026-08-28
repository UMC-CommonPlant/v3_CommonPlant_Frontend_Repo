import 'dart:async';

import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/core/network/auth_token_writer.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('새 인증 시도 후 이전 시도는 저장소에 기록하지 않는다', () async {
    final store = _TokenStore();
    final writer = AuthTokenWriter(store);
    final attemptA = writer.beginAttempt();
    final attemptB = writer.beginAttempt();

    await expectLater(
      writer.saveTokens(attempt: attemptA, accessToken: 'A', refreshToken: 'A'),
      throwsStateError,
    );
    expect(store.savedAccessTokens, isEmpty);
    await writer.saveTokens(
      attempt: attemptB,
      accessToken: 'B',
      refreshToken: 'B',
    );
    expect(store.savedAccessTokens, ['B']);
  });

  test('느린 로그아웃 삭제 뒤에 새 계정 토큰을 저장한다', () async {
    final store = _TokenStore()..clearBarrier = Completer<void>();
    final writer = AuthTokenWriter(store);
    final clearing = writer.clear();
    await store.clearStarted.future;
    final saving = writer.saveTokens(
      attempt: writer.beginAttempt(),
      accessToken: 'B',
      refreshToken: 'B',
    );
    await Future<void>.delayed(Duration.zero);
    expect(store.savedAccessTokens, isEmpty);

    store.clearBarrier!.complete();
    await clearing;
    await saving;
    expect(store.accessToken, 'B');
    expect(store.refreshToken, 'B');
  });

  test('저장 실패를 전달한 뒤에도 삭제와 다음 저장은 실행한다', () async {
    final store = _TokenStore()..saveError = StateError('storage failure');
    final writer = AuthTokenWriter(store);

    await expectLater(
      writer.saveTokens(
        attempt: writer.beginAttempt(),
        accessToken: 'A',
        refreshToken: 'A',
      ),
      throwsStateError,
    );
    await writer.clear();
    store.saveError = null;
    await writer.saveTokens(
      attempt: writer.beginAttempt(),
      accessToken: 'B',
      refreshToken: 'B',
    );
    expect(store.accessToken, 'B');
  });

  test('세션 전환은 이전 인증을 무효화하되 저장·삭제 큐는 재생성하지 않는다', () async {
    final store = _TokenStore();
    final container = ProviderContainer(
      overrides: [authTokenStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    final writer = container.read(authTokenWriterProvider);
    final attemptA = writer.beginAttempt();

    container.read(userDataSessionProvider.notifier).start();
    expect(container.read(authTokenWriterProvider), same(writer));
    await expectLater(
      writer.saveTokens(attempt: attemptA, accessToken: 'A', refreshToken: 'A'),
      throwsStateError,
    );
    await writer.saveTokens(
      attempt: writer.beginAttempt(),
      accessToken: 'B',
      refreshToken: 'B',
    );
    expect(store.savedAccessTokens, ['B']);
  });
}

class _TokenStore implements AuthTokenStore {
  String? accessToken;
  String? refreshToken;
  Object? saveError;
  Completer<void>? clearBarrier;
  final clearStarted = Completer<void>();
  final List<String> savedAccessTokens = [];

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (saveError case final error?) throw error;
    savedAccessTokens.add(accessToken);
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> clear() async {
    if (!clearStarted.isCompleted) clearStarted.complete();
    await clearBarrier?.future;
    accessToken = null;
    refreshToken = null;
  }
}
