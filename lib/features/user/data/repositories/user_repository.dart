import 'package:commonplant_frontend/core/network/api_client.dart';
import 'package:commonplant_frontend/core/network/api_response_parser.dart';
import 'package:commonplant_frontend/features/user/data/datasources/user_remote_data_source.dart';
import 'package:commonplant_frontend/features/user/data/dtos/user_requests.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSource(ref.watch(dioProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(userRemoteDataSourceProvider));
});

class UserRepository {
  const UserRepository(this._remoteDataSource);

  final UserRemoteDataSource _remoteDataSource;

  Future<UserProfile> fetchMe() async {
    final data = await _remoteDataSource.getMe();
    final object = unwrapJsonObject(data, context: '내 정보 조회');

    return userProfileFromJson(object);
  }

  Future<List<UserProfile>> searchUsers(String keyword) async {
    final data = await _remoteDataSource.searchUsers(keyword);
    final items = jsonListFromResponse(data, context: '사용자 검색');

    return [for (final item in items) userProfileFromJson(item)];
  }

  Future<UserProfile> updateMe(UpdateUserRequest request) async {
    final data = await _remoteDataSource.updateMe(request);
    final object = unwrapJsonObject(data, context: '내 정보 수정');

    return userProfileFromJson(object);
  }

  Future<void> deleteMe() async {
    await _remoteDataSource.deleteMe();
  }
}

UserProfile userProfileFromJson(JsonMap json) {
  return UserProfile(
    id: readRequiredString(json, const ['id', 'userId', 'nanoId'], '사용자 ID'),
    name: readRequiredString(json, const ['name'], '사용자 이름'),
    email: readOptionalString(json, const ['email']),
    provider: readOptionalString(json, const ['provider']),
    imgUrl: readOptionalString(json, const ['imgUrl', 'imageUrl']),
    introduction: readOptionalString(json, const ['introduction']),
  );
}
