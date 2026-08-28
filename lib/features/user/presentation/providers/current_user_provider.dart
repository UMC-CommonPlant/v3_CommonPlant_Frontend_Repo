import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/user/data/repositories/user_repository.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _localUserProfile = UserProfile(
  id: 'local-user',
  name: '커먼플랜트',
  email: 'alwaysweave@gmail.com',
);

final currentUserProvider =
    AsyncNotifierProvider.autoDispose<CurrentUserController, UserProfile>(
      CurrentUserController.new,
      retry: (retryCount, error) => null,
    );

class CurrentUserController extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    if (!ref.watch(useRemoteApiProvider)) {
      return _localUserProfile;
    }

    requireUserDataSession(ref);
    return ref.watch(userRepositoryProvider).fetchMe();
  }

  void replace(UserProfile user) {
    state = AsyncData(user);
  }
}
