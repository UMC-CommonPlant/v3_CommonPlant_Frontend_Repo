import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class AppEnvironment {
  const AppEnvironment._();

  static const bool useRemoteApi = bool.fromEnvironment('COMMONPLANT_USE_API');

  static const String apiBaseUrl = String.fromEnvironment(
    'COMMONPLANT_API_BASE_URL',
    defaultValue: 'https://commonplant.site/api/v1',
  );
}

final useRemoteApiProvider = Provider<bool>((ref) {
  return AppEnvironment.useRemoteApi;
});

final apiBaseUrlProvider = Provider<String>((ref) {
  return AppEnvironment.apiBaseUrl;
});
