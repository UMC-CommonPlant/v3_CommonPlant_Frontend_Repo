import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userNotificationSettingProvider =
    NotifierProvider.autoDispose<UserNotificationSettingController, bool>(
      UserNotificationSettingController.new,
    );

class UserNotificationSettingController extends Notifier<bool> {
  @override
  bool build() {
    if (ref.watch(useRemoteApiProvider)) ref.watch(userDataSessionProvider);
    return true;
  }

  void setEnabled(bool isEnabled) {
    state = isEnabled;
  }
}
