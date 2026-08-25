import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_result.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authSessionControllerProvider =
    AsyncNotifierProvider<AuthSessionController, AuthSessionState>(
      AuthSessionController.new,
    );

class AuthSessionController extends AsyncNotifier<AuthSessionState> {
  @override
  Future<AuthSessionState> build() async {
    if (!ref.watch(useRemoteApiProvider)) {
      return const AuthSessionState.authenticated();
    }

    final tokenStore = ref.watch(authTokenStoreProvider);
    final accessToken = await tokenStore.readAccessToken();
    final refreshToken = await tokenStore.readRefreshToken();
    final hasAccessToken = accessToken != null && accessToken.isNotEmpty;
    final hasRefreshToken = refreshToken != null && refreshToken.isNotEmpty;

    if (hasAccessToken && hasRefreshToken) {
      return const AuthSessionState.authenticated();
    }

    if (hasAccessToken || hasRefreshToken) {
      await tokenStore.clear();
    }

    return const AuthSessionState.unauthenticated();
  }

  void applyAuthResult(AuthResult result) {
    state = AsyncData(switch (result) {
      SignupRequiredResult(
        :final signupToken,
        :final suggestedName,
        :final suggestedImgUrl,
      ) =>
        AuthSessionState.signupRequired(
          signupToken: signupToken,
          suggestedName: suggestedName,
          suggestedImgUrl: suggestedImgUrl,
        ),
      AuthenticatedResult() => const AuthSessionState.authenticated(),
    });
  }

  Future<void> clearSession() async {
    await ref.read(authTokenStoreProvider).clear();
    state = const AsyncData(AuthSessionState.unauthenticated());
  }
}
