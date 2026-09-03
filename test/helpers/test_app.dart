import 'package:commonplant_frontend/app/common_plant_app.dart';
import 'package:commonplant_frontend/app/router/app_router.dart';
import 'package:commonplant_frontend/features/onboarding/data/onboarding_local_store.dart';
import 'package:commonplant_frontend/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Widget buildPageTestApp(Widget home, {OnboardingLocalStore? onboardingStore}) {
  return ProviderScope(
    overrides: [
      onboardingLocalStoreProvider.overrideWithValue(
        onboardingStore ?? TestOnboardingLocalStore(),
      ),
    ],
    child: MaterialApp(home: home),
  );
}

Widget buildCommonPlantRouterTestApp(
  GoRouter router, {
  OnboardingLocalStore? onboardingStore,
}) {
  return ProviderScope(
    overrides: [
      appRouterProvider.overrideWithValue(router),
      onboardingLocalStoreProvider.overrideWithValue(
        onboardingStore ?? TestOnboardingLocalStore(),
      ),
    ],
    child: const CommonPlantApp(),
  );
}

class TestOnboardingLocalStore implements OnboardingLocalStore {
  TestOnboardingLocalStore({this.completed = false, this.writeFailures = 0});

  bool completed;
  int writeFailures;
  int writeCount = 0;

  @override
  Future<bool> readCompleted() async => completed;

  @override
  Future<void> writeCompleted() async {
    writeCount += 1;
    if (writeFailures > 0) {
      writeFailures -= 1;
      throw StateError('온보딩 저장 실패');
    }
    completed = true;
  }
}
