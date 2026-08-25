import 'package:flutter_riverpod/flutter_riverpod.dart';

final userNotificationSettingProvider =
    NotifierProvider.autoDispose<UserNotificationSettingController, bool>(
      UserNotificationSettingController.new,
    );

class UserNotificationSettingController extends Notifier<bool> {
  @override
  bool build() => true;

  void setEnabled(bool isEnabled) {
    state = isEnabled;
  }
}
