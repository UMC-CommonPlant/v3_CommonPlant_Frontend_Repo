import 'package:commonplant_frontend/core/network/api_client.dart';
import 'package:commonplant_frontend/features/friend/data/datasources/friend_remote_data_source.dart';
import 'package:commonplant_frontend/features/friend/data/dtos/friend_requests.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendRemoteDataSourceProvider = Provider<FriendRemoteDataSource>((ref) {
  return FriendRemoteDataSource(ref.watch(dioProvider));
});

final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  return FriendRepository(ref.watch(friendRemoteDataSourceProvider));
});

class FriendRepository {
  const FriendRepository(this._remoteDataSource);

  final FriendRemoteDataSource _remoteDataSource;

  Future<Object?> fetchRequestsRaw() {
    return _remoteDataSource.getRequests();
  }

  Future<void> sendRequest(SendFriendRequest request) {
    return _remoteDataSource.sendRequest(request);
  }

  Future<void> acceptRequest(FriendDecisionRequest request) {
    return _remoteDataSource.acceptRequest(request);
  }

  Future<void> declineRequest(FriendDecisionRequest request) {
    return _remoteDataSource.declineRequest(request);
  }
}
