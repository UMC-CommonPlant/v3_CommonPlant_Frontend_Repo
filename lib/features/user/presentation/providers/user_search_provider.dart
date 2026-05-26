import 'package:commonplant_frontend/features/user/data/repositories/user_repository.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userSearchProvider = FutureProvider.family<List<UserProfile>, String>((
  ref,
  keyword,
) {
  final normalizedKeyword = keyword.trim();

  if (normalizedKeyword.isEmpty) {
    return const <UserProfile>[];
  }

  return ref.watch(userRepositoryProvider).searchUsers(normalizedKeyword);
}, retry: (retryCount, error) => null);
