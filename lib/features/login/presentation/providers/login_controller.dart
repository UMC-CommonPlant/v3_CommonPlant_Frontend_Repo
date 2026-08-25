import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_requests.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_result.dart';
import 'package:commonplant_frontend/features/login/data/gateways/social_auth_credential_gateway.dart';
import 'package:commonplant_frontend/features/login/data/repositories/auth_repository.dart';
import 'package:commonplant_frontend/features/login/domain/models/social_auth.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String socialLoginNotConfiguredMessage = '소셜 로그인 설정이 아직 준비되지 않았어요';
const String socialLoginFailureMessage = '로그인에 실패했어요. 잠시 후 다시 시도해 주세요';

enum LoginSubmitStatus { idle, submitting, success, failure }

enum LoginOutcome { signupRequired, authenticated }

class LoginState {
  const LoginState({
    this.submitStatus = LoginSubmitStatus.idle,
    this.submittingProvider,
    this.errorMessage,
  });

  final LoginSubmitStatus submitStatus;
  final SocialAuthProvider? submittingProvider;
  final String? errorMessage;

  bool get isSubmitting => submitStatus == LoginSubmitStatus.submitting;

  LoginState copyWith({
    LoginSubmitStatus? submitStatus,
    SocialAuthProvider? submittingProvider,
    String? errorMessage,
    bool clearSubmittingProvider = false,
    bool clearErrorMessage = false,
  }) {
    return LoginState(
      submitStatus: submitStatus ?? this.submitStatus,
      submittingProvider: clearSubmittingProvider
          ? null
          : submittingProvider ?? this.submittingProvider,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

final loginControllerProvider =
    NotifierProvider.autoDispose<LoginController, LoginState>(
      LoginController.new,
    );

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  Future<LoginOutcome?> login(SocialAuthProvider provider) async {
    if (state.isSubmitting) {
      return null;
    }

    state = state.copyWith(
      submitStatus: LoginSubmitStatus.submitting,
      submittingProvider: provider,
      clearErrorMessage: true,
    );

    try {
      if (!ref.read(useRemoteApiProvider)) {
        state = state.copyWith(
          submitStatus: LoginSubmitStatus.success,
          clearSubmittingProvider: true,
        );
        return LoginOutcome.signupRequired;
      }

      await ref.read(authSessionControllerProvider.future);
      final credential = await ref
          .read(socialAuthCredentialGatewayProvider)
          .authorize(provider);
      final result = await ref
          .read(authRepositoryProvider)
          .login(
            LoginRequest(
              provider: credential.provider.apiValue,
              token: credential.token,
            ),
          );

      ref.read(authSessionControllerProvider.notifier).applyAuthResult(result);
      state = state.copyWith(
        submitStatus: LoginSubmitStatus.success,
        clearSubmittingProvider: true,
      );

      return switch (result) {
        SignupRequiredResult() => LoginOutcome.signupRequired,
        AuthenticatedResult() => LoginOutcome.authenticated,
      };
    } on SocialAuthNotConfiguredException {
      state = state.copyWith(
        submitStatus: LoginSubmitStatus.failure,
        errorMessage: socialLoginNotConfiguredMessage,
        clearSubmittingProvider: true,
      );
    } catch (_) {
      state = state.copyWith(
        submitStatus: LoginSubmitStatus.failure,
        errorMessage: socialLoginFailureMessage,
        clearSubmittingProvider: true,
      );
    }

    return null;
  }
}
