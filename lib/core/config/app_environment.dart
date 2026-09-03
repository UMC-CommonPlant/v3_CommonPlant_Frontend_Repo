import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class AppEnvironment {
  const AppEnvironment._();

  static const bool useRemoteApi = bool.fromEnvironment('COMMONPLANT_USE_API');

  static const String apiBaseUrl = String.fromEnvironment(
    'COMMONPLANT_API_BASE_URL',
    defaultValue: 'https://commonplant.site/api/v1',
  );

  static const String kakaoNativeAppKey = String.fromEnvironment(
    'COMMONPLANT_KAKAO_NATIVE_APP_KEY',
  );

  static const String googleServerClientId = String.fromEnvironment(
    'COMMONPLANT_GOOGLE_SERVER_CLIENT_ID',
  );

  static const String googleIosClientId = String.fromEnvironment(
    'COMMONPLANT_GOOGLE_IOS_CLIENT_ID',
  );
}

final useRemoteApiProvider = Provider<bool>((ref) {
  return AppEnvironment.useRemoteApi;
});

final apiBaseUrlProvider = Provider<String>((ref) {
  return AppEnvironment.apiBaseUrl;
});
