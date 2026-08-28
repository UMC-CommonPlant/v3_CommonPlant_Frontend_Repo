import 'package:commonplant_frontend/core/network/user_data_session.dart';

/// 인증 자체를 검증하지 않는 화면/Provider 테스트의 로그인된 데이터 세션.
final authenticatedUserDataSession = userDataSessionProvider.overrideWithBuild(
  (ref, notifier) => const UserDataSession(generation: 1, isActive: true),
);
