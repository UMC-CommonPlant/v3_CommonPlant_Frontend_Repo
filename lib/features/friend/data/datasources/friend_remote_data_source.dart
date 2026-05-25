import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/features/friend/data/dtos/friend_requests.dart';
import 'package:dio/dio.dart';

class FriendRemoteDataSource {
  const FriendRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Object?> getRequests() async {
    try {
      final response = await _dio.get<Object?>('/friends/requests');

      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> sendRequest(SendFriendRequest request) async {
    try {
      await _dio.post<Object?>('/friends/request', data: request.toJson());
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> acceptRequest(FriendDecisionRequest request) async {
    try {
      await _dio.post<Object?>('/friends/accept', data: request.toJson());
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> declineRequest(FriendDecisionRequest request) async {
    try {
      await _dio.post<Object?>('/friends/decline', data: request.toJson());
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
