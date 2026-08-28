import 'dart:async';

import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_requests.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_result.dart';
import 'package:commonplant_frontend/features/login/data/repositories/auth_repository.dart';
import 'package:commonplant_frontend/features/login/presentation/pages/profile_setup_page.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_controller.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_state.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/profile_setup_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/test_viewport.dart';

void main() {
  for (final viewport in [
    TestViewports.reference,
    TestViewports.compactWidth,
    TestViewports.shortHeight,
  ]) {
    testWidgets('가입 프로필 입력 중 재탭을 막고 실패 후 새 이름으로 재시도한다 ($viewport)', (
      tester,
    ) async {
      configureTestViewport(tester, viewport);
      final repository = _RetryAuthRepository();
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          authRepositoryProvider.overrideWithValue(repository),
          authSessionControllerProvider.overrideWith(
            _SignupAuthSessionController.new,
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authSessionControllerProvider.future);
      final router = GoRouter(
        initialLocation: AppRoutePaths.profileSetup,
        routes: [
          GoRoute(
            path: AppRoutePaths.profileSetup,
            builder: (context, state) => const ProfileSetupPage(),
          ),
          GoRoute(
            path: AppRoutePaths.home,
            builder: (context, state) => const Text('가입 후 홈'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      container
          .read(profileSetupControllerProvider.notifier)
          .setPrivacyTermsAccepted(true);
      await tester.enterText(find.byType(TextField), '첫 제출');
      await tester.pump();

      final button = find.widgetWithText(OutlinedButton, '완료');
      final repeatSubmit = tester.widget<OutlinedButton>(button).onPressed!;
      await tester.tap(button);
      await tester.pump();
      await tester.enterText(find.byType(TextField), '다음 제출');
      await tester.pump();
      repeatSubmit();
      await tester.pump();

      expect(repository.names, ['첫 제출']);
      expect(tester.widget<OutlinedButton>(button).onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('다음 제출'), findsOneWidget);
      expect(find.text('가입 후 홈'), findsNothing);

      repository.firstResponse.completeError(StateError('첫 요청 실패'));
      await tester.pumpAndSettle();
      expect(find.text(profileSetupSubmitFailureMessage), findsOneWidget);
      expect(find.text('다음 제출'), findsOneWidget);
      expect(tester.widget<OutlinedButton>(button).onPressed, isNotNull);

      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(repository.names, ['첫 제출', '다음 제출']);
      expect(find.text('가입 후 홈'), findsOneWidget);
      expect(find.byType(ProfileSetupPage), findsNothing);
      expect(
        container
            .read(authSessionControllerProvider)
            .requireValue
            .isAuthenticated,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    });
  }
}

class _SignupAuthSessionController extends AuthSessionController {
  @override
  Future<AuthSessionState> build() async {
    return const AuthSessionState.signupRequired(signupToken: 'signup-token');
  }
}

class _RetryAuthRepository extends Fake implements AuthRepository {
  final firstResponse = Completer<AuthResult>();
  final names = <String>[];

  @override
  Future<AuthResult> register(
    RegisterRequest request, {
    MultipartFile? image,
  }) async {
    names.add(request.name);
    if (names.length == 1) return firstResponse.future;
    return const AuthenticatedResult(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );
  }
}
