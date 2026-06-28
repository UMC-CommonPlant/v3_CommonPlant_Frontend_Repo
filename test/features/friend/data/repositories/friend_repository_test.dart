import 'package:commonplant_frontend/features/friend/data/datasources/friend_remote_data_source.dart';
import 'package:commonplant_frontend/features/friend/data/dtos/friend_requests.dart';
import 'package:commonplant_frontend/features/friend/data/repositories/friend_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FriendRepository', () {
    test('친구 요청 목록 raw 응답은 datasource 값 그대로 반환한다', () async {
      final dataSource = _RecordingFriendRemoteDataSource(
        requestsRawResponse: const {
          'success': true,
          'result': [
            {'friendId': 1},
          ],
        },
      );
      final repository = FriendRepository(dataSource);

      final response = await repository.fetchRequestsRaw();

      expect(response, same(dataSource.requestsRawResponse));
    });

    test('친구 요청 전송은 datasource에 request를 위임한다', () async {
      final dataSource = _RecordingFriendRemoteDataSource();
      final repository = FriendRepository(dataSource);
      final request = SendFriendRequest(
        receiverNames: const ['커먼2'],
        placeCode: 'aBcDeF',
      );

      await expectLater(repository.sendRequest(request), completes);

      expect(dataSource.latestSendRequest, same(request));
    });

    test('친구 요청 수락과 거절은 datasource에 request를 위임한다', () async {
      final dataSource = _RecordingFriendRemoteDataSource();
      final repository = FriendRepository(dataSource);
      const request = FriendDecisionRequest(friendId: 1);

      await expectLater(repository.acceptRequest(request), completes);
      await expectLater(repository.declineRequest(request), completes);

      expect(dataSource.latestAcceptRequest, same(request));
      expect(dataSource.latestDeclineRequest, same(request));
    });
  });
}

class _RecordingFriendRemoteDataSource extends FriendRemoteDataSource {
  _RecordingFriendRemoteDataSource({this.requestsRawResponse}) : super(Dio());

  final Object? requestsRawResponse;
  SendFriendRequest? latestSendRequest;
  FriendDecisionRequest? latestAcceptRequest;
  FriendDecisionRequest? latestDeclineRequest;

  @override
  Future<Object?> getRequestsRaw() async {
    return requestsRawResponse;
  }

  @override
  Future<void> sendRequest(SendFriendRequest request) async {
    latestSendRequest = request;
  }

  @override
  Future<void> acceptRequest(FriendDecisionRequest request) async {
    latestAcceptRequest = request;
  }

  @override
  Future<void> declineRequest(FriendDecisionRequest request) async {
    latestDeclineRequest = request;
  }
}
