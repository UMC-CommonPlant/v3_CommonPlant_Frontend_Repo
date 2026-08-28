import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 사용자 데이터의 수명만 식별한다. 토큰이나 계정 정보는 보관하지 않는다.
class UserDataSession {
  const UserDataSession({required this.generation, required this.isActive});

  final int generation;
  final bool isActive;
}

final userDataSessionProvider =
    NotifierProvider<UserDataSessionController, UserDataSession>(
      UserDataSessionController.new,
    );

class UserDataSessionController extends Notifier<UserDataSession> {
  @override
  UserDataSession build() =>
      const UserDataSession(generation: 0, isActive: false);

  void start() => _replace(isActive: true);

  void end() => _replace(isActive: false);

  void _replace({required bool isActive}) {
    state = UserDataSession(
      generation: state.generation + 1,
      isActive: isActive,
    );
  }
}

UserDataSession requireUserDataSession(Ref ref) {
  final session = ref.watch(userDataSessionProvider);
  if (!session.isActive) {
    throw StateError('사용자 데이터를 조회할 로그인 세션이 없습니다.');
  }
  return session;
}

bool isCurrentUserDataSession(Ref ref, UserDataSession session) {
  return ref.mounted && identical(ref.read(userDataSessionProvider), session);
}
