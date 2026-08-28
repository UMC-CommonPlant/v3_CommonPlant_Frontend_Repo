import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/friend/data/datasources/friend_remote_data_source.dart';
import 'package:commonplant_frontend/features/friend/data/dtos/friend_requests.dart';
import 'package:commonplant_frontend/features/friend/data/repositories/friend_repository.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_friend_profile.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_friend_request_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/user_data_session.dart';

void main() {
  const friends = [
    PlaceFriendProfile(id: 'user-1', name: ' 커먼맘 '),
    PlaceFriendProfile(id: 'user-2', name: '커먼파파'),
  ];

  test('선택한 이름과 장소 코드로 원격 친구 요청을 전송한다', () async {
    final repository = _FakeFriendRepository();
    final container = _remoteContainer(repository);
    addTearDown(container.dispose);

    final succeeded = await container
        .read(placeFriendRequestControllerProvider.notifier)
        .submit(placeCode: ' place-code ', friends: friends);

    expect(succeeded, isTrue);
    expect(repository.sendCalls, 1);
    expect(repository.latestRequest?.receiverNames, ['커먼맘', '커먼파파']);
    expect(repository.latestRequest?.placeCode, 'place-code');
    expect(
      container.read(placeFriendRequestControllerProvider).isSubmitting,
      isFalse,
    );
  });

  test('선택한 친구가 없으면 원격 요청 없이 완료한다', () async {
    final repository = _FakeFriendRepository();
    final container = _remoteContainer(repository);
    addTearDown(container.dispose);

    final succeeded = await container
        .read(placeFriendRequestControllerProvider.notifier)
        .submit(placeCode: 'place-code', friends: const []);

    expect(succeeded, isTrue);
    expect(repository.sendCalls, 0);
  });

  test('원격 전송에 필요한 장소 코드가 없으면 오류를 저장한다', () async {
    final repository = _FakeFriendRepository();
    final container = _remoteContainer(repository);
    addTearDown(container.dispose);

    final succeeded = await container
        .read(placeFriendRequestControllerProvider.notifier)
        .submit(placeCode: null, friends: friends);

    expect(succeeded, isFalse);
    expect(repository.sendCalls, 0);
    expect(
      container.read(placeFriendRequestControllerProvider).errorMessage,
      '장소 정보를 확인할 수 없어요',
    );
  });

  test('원격 전송 실패는 재시도 가능한 오류 상태로 전환한다', () async {
    final repository = _FakeFriendRepository(shouldFail: true);
    final container = _remoteContainer(repository);
    addTearDown(container.dispose);

    final succeeded = await container
        .read(placeFriendRequestControllerProvider.notifier)
        .submit(placeCode: 'place-code', friends: friends);

    expect(succeeded, isFalse);
    expect(repository.sendCalls, 1);
    expect(
      container.read(placeFriendRequestControllerProvider).errorMessage,
      '친구 요청을 보내지 못했어요',
    );
  });

  test('전송 중 중복 요청을 차단한다', () async {
    final pending = Completer<void>();
    final repository = _FakeFriendRepository(pending: pending);
    final container = _remoteContainer(repository);
    addTearDown(container.dispose);
    container.listen(placeFriendRequestControllerProvider, (_, _) {});
    final controller = container.read(
      placeFriendRequestControllerProvider.notifier,
    );

    final firstResult = controller.submit(
      placeCode: 'place-code',
      friends: friends,
    );
    await Future<void>.delayed(Duration.zero);
    final secondResult = await controller.submit(
      placeCode: 'place-code',
      friends: friends,
    );

    expect(secondResult, isFalse);
    expect(repository.sendCalls, 1);
    expect(
      container.read(placeFriendRequestControllerProvider).isSubmitting,
      isTrue,
    );

    pending.complete();
    expect(await firstResult, isTrue);
  });
}

ProviderContainer _remoteContainer(FriendRepository repository) {
  return ProviderContainer(
    overrides: [
      authenticatedUserDataSession,
      useRemoteApiProvider.overrideWithValue(true),
      friendRepositoryProvider.overrideWithValue(repository),
    ],
  );
}

class _FakeFriendRepository extends FriendRepository {
  _FakeFriendRepository({this.shouldFail = false, this.pending})
    : super(FriendRemoteDataSource(Dio()));

  final bool shouldFail;
  final Completer<void>? pending;
  int sendCalls = 0;
  SendFriendRequest? latestRequest;

  @override
  Future<void> sendRequest(SendFriendRequest request) async {
    sendCalls++;
    latestRequest = request;

    if (shouldFail) {
      throw StateError('request failed');
    }

    await pending?.future;
  }
}
