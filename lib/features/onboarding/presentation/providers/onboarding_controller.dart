import 'package:commonplant_frontend/features/onboarding/data/onboarding_local_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String onboardingSaveFailureMessage = '시작 정보를 저장하지 못했어요. 다시 시도해 주세요';

final onboardingLocalStoreProvider = Provider<OnboardingLocalStore>((ref) {
  return SharedPreferencesOnboardingLocalStore();
});

final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, bool>(OnboardingController.new);

class OnboardingController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() {
    return ref.watch(onboardingLocalStoreProvider).readCompleted();
  }

  Future<bool> complete() async {
    if (state.value == true) {
      return true;
    }
    if (state.isLoading) {
      return false;
    }

    state = const AsyncLoading();
    try {
      await ref.read(onboardingLocalStoreProvider).writeCompleted();
      state = const AsyncData(true);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}
