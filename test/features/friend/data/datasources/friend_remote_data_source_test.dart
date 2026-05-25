import 'dart:typed_data';

import 'package:commonplant_frontend/features/friend/data/datasources/friend_remote_data_source.dart';
import 'package:commonplant_frontend/features/friend/data/dtos/friend_requests.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FriendRemoteDataSource', () {
    test('친구 요청 목록은 GET /friends/requests로 요청한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = FriendRemoteDataSource(_dioWith(adapter));

      await dataSource.getRequests();

      expect(adapter.latestOptions.method, 'GET');
      expect(adapter.latestOptions.path, '/friends/requests');
    });

    test('친구 요청 전송은 POST /friends/request로 요청한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = FriendRemoteDataSource(_dioWith(adapter));

      await dataSource.sendRequest(
        SendFriendRequest(receiverNames: const ['커먼2'], placeCode: 'aBcDeF'),
      );

      expect(adapter.latestOptions.method, 'POST');
      expect(adapter.latestOptions.path, '/friends/request');
    });

    test('친구 요청 수락은 POST /friends/accept로 요청한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = FriendRemoteDataSource(_dioWith(adapter));

      await dataSource.acceptRequest(const FriendDecisionRequest(friendId: 1));

      expect(adapter.latestOptions.method, 'POST');
      expect(adapter.latestOptions.path, '/friends/accept');
    });

    test('친구 요청 거절은 POST /friends/decline으로 요청한다', () async {
      final adapter = _CapturingAdapter();
      final dataSource = FriendRemoteDataSource(_dioWith(adapter));

      await dataSource.declineRequest(const FriendDecisionRequest(friendId: 1));

      expect(adapter.latestOptions.method, 'POST');
      expect(adapter.latestOptions.path, '/friends/decline');
    });
  });
}

Dio _dioWith(HttpClientAdapter adapter) {
  return Dio(BaseOptions(baseUrl: 'https://example.com'))
    ..httpClientAdapter = adapter;
}

class _CapturingAdapter implements HttpClientAdapter {
  late RequestOptions latestOptions;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    latestOptions = options;

    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
