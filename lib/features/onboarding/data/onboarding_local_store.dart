import 'package:shared_preferences/shared_preferences.dart';

const String onboardingCompletedKey = 'commonplant.onboarding.completed';

abstract interface class OnboardingLocalStore {
  Future<bool> readCompleted();

  Future<void> writeCompleted();
}

class SharedPreferencesOnboardingLocalStore implements OnboardingLocalStore {
  SharedPreferencesOnboardingLocalStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<bool> readCompleted() async {
    return await _preferences.getBool(onboardingCompletedKey) ?? false;
  }

  @override
  Future<void> writeCompleted() {
    return _preferences.setBool(onboardingCompletedKey, true);
  }
}
