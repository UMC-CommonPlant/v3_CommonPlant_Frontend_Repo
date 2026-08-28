import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authTokenWriterProvider = Provider<AuthTokenWriter>((ref) {
  final writer = AuthTokenWriter(ref.watch(authTokenStoreProvider));
  ref.listen(userDataSessionProvider, (previous, next) {
    writer.invalidateAttempts();
  });
  ref.onDispose(writer.invalidateAttempts);
  return writer;
});

/// 토큰 저장·삭제를 순서대로 실행하고 오래된 인증 시도의 저장을 차단한다.
class AuthTokenWriter {
  AuthTokenWriter(this._store);

  final AuthTokenStore _store;
  Future<void> _pending = Future<void>.value();
  int _revision = 0;

  int beginAttempt() => ++_revision;

  void invalidateAttempts() => _revision++;

  void checkCurrentAttempt(int attempt) {
    if (attempt != _revision) {
      throw StateError('이미 종료된 인증 요청입니다.');
    }
  }

  Future<void> saveTokens({
    required int attempt,
    required String accessToken,
    required String refreshToken,
  }) {
    return _enqueue(() async {
      checkCurrentAttempt(attempt);
      await _store.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      checkCurrentAttempt(attempt);
    });
  }

  Future<void> clear() {
    invalidateAttempts();
    // 이미 시작한 저장은 취소할 수 없으므로 그 뒤에서 삭제한다.
    return _enqueue(_store.clear);
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    final result = _pending.then((_) => operation());
    // 오류는 호출자에게 전달하되 다음 저장·삭제까지 막지는 않는다.
    _pending = result.then<void>((_) {}, onError: (Object error) {});
    return result;
  }
}
