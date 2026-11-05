import 'package:commonplant_frontend/app/router/app_router.dart';
import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_theme.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_controller.dart';
import 'package:commonplant_frontend/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommonPlantApp extends ConsumerWidget {
  const CommonPlantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final onboarding = ref.watch(onboardingControllerProvider);
    final isRestoringSession =
        ref.watch(useRemoteApiProvider) &&
        (onboarding.isLoading ||
            (onboarding.value == true &&
                ref.watch(authSessionControllerProvider).isLoading));

    return MaterialApp.router(
      title: 'CommonPlant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) => isRestoringSession
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: AppColors.brandPrimary,
                  semanticsLabel: '로그인 확인 중',
                ),
              ),
            )
          : child ?? const SizedBox.shrink(),
    );
  }
}
