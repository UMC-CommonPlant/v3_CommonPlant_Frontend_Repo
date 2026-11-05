import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/core/network/auth_token_writer.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_requests.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_result.dart';
import 'package:commonplant_frontend/features/login/data/repositories/auth_repository.dart';
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
    final buildRef = ref;
    final initialSession = ref.read(userDataSessionProvider);
    final accessToken = await tokenStore.readAccessToken();
    final refreshToken = await tokenStore.readRefreshToken();
    if (!buildRef.mounted) return const AuthSessionState.unauthenticated();
    if (!isCurrentUserDataSession(buildRef, initialSession)) {
      return state.value ?? const AuthSessionState.unauthenticated();
    }
    final hasAccessToken = accessToken != null && accessToken.trim().isNotEmpty;
    final hasRefreshToken =
        refreshToken != null && refreshToken.trim().isNotEmpty;

    if (hasAccessToken && hasRefreshToken) {
      ref.read(userDataSessionProvider.notifier).start();
      return const AuthSessionState.authenticated();
    }

    if (hasRefreshToken) {
      try {
        await ref
            .read(authRepositoryProvider)
            .refresh(RefreshRequest(refreshToken: refreshToken.trim()));
      } catch (_) {
        // Repository가 현재 인증 시도의 실패만 정리한다. 새 로그인은 지우지 않는다.
        if (!buildRef.mounted) return const AuthSessionState.unauthenticated();
        if (!isCurrentUserDataSession(buildRef, initialSession)) {
          return state.value ?? const AuthSessionState.unauthenticated();
        }
        return const AuthSessionState.unauthenticated();
      }

      if (!buildRef.mounted) return const AuthSessionState.unauthenticated();
      if (!isCurrentUserDataSession(buildRef, initialSession)) {
        return state.value ?? const AuthSessionState.unauthenticated();
      }
      ref.read(userDataSessionProvider.notifier).start();
      return const AuthSessionState.authenticated();
    }

    if (hasAccessToken || hasRefreshToken) {
      await ref.read(authTokenWriterProvider).clear();
      if (!buildRef.mounted) return const AuthSessionState.unauthenticated();
      if (!isCurrentUserDataSession(buildRef, initialSession)) {
        return state.value ?? const AuthSessionState.unauthenticated();
      }
    }

    return const AuthSessionState.unauthenticated();
  }

  void applyAuthResult(AuthResult result) {
    final dataSession = ref.read(userDataSessionProvider.notifier);
    if (result is AuthenticatedResult) {
      dataSession.start();
    } else {
      dataSession.end();
    }
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
    // 저장소 삭제가 지연되더라도 이전 계정의 조회·후처리는 즉시 중단한다.
    ref.read(userDataSessionProvider.notifier).end();
    state = const AsyncData(AuthSessionState.unauthenticated());
    await ref.read(authTokenWriterProvider).clear();
  }

  Future<void> expireSession(UserDataSession expectedSession) async {
    if (!expectedSession.isActive ||
        !isCurrentUserDataSession(ref, expectedSession)) {
      return;
    }

    // 시작 시 refresh-only 복원과 별개로, 활성 요청의 자동 재전송은 하지 않는다.
    ref.read(userDataSessionProvider.notifier).end();
    state = const AsyncData(
      AuthSessionState.unauthenticated(reason: AuthSessionEndReason.expired),
    );
    await ref.read(authTokenWriterProvider).clear();
  }
}
