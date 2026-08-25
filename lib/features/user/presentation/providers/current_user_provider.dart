import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/user/data/repositories/user_repository.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _localUserProfile = UserProfile(id: 'local-user', name: '커먼(유저 네임');

final currentUserProvider = FutureProvider<UserProfile>((ref) async {
  if (!ref.watch(useRemoteApiProvider)) {
    return _localUserProfile;
  }

  return ref.watch(userRepositoryProvider).fetchMe();
}, retry: (retryCount, error) => null);
