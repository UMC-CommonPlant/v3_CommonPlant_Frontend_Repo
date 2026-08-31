import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/friend/data/datasources/friend_remote_data_source.dart';
import 'package:commonplant_frontend/features/friend/data/dtos/friend_requests.dart';
import 'package:commonplant_frontend/features/friend/data/repositories/friend_repository.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_invitation.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_invitation_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/user_data_session.dart';

void main() {
  test('요청 수는 요청 목록의 loading 상태를 보존한다', () {
    final container = ProviderContainer(
      overrides: [
        placeInvitationsProvider.overrideWithValue(
          const AsyncLoading<List<PlaceInvitation>>(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final count = container.read(placeInvitationRequestCountProvider);

    expect(count.isLoading, isTrue);
    expect(count.value, isNull);
  });

  test('요청 수는 요청 목록의 error 상태를 정상 0건으로 바꾸지 않는다', () {
    final error = StateError('요청 조회 실패');
    final container = ProviderContainer(
      overrides: [
        placeInvitationsProvider.overrideWithValue(
          AsyncError<List<PlaceInvitation>>(error, StackTrace.empty),
        ),
      ],
    );
    addTearDown(container.dispose);

    final count = container.read(placeInvitationRequestCountProvider);

    expect(count.hasError, isTrue);
    expect(count.error, same(error));
    expect(count.value, isNull);
  });

  test('fixture 초대를 수락하면 결과와 미처리 요청 수를 갱신한다', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(placeInvitationControllerProvider.notifier)
        .accept('invite-1');

    expect(
      container.read(placeInvitationControllerProvider).resultFor('invite-1'),
      PlaceInvitationResult.accepted,
    );
    expect(container.read(placeInvitationRequestCountProvider).value, 2);
  });

  test('fixture 초대를 삭제하면 deleted 결과를 저장한다', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(placeInvitationControllerProvider.notifier)
        .delete('invite-2');

    expect(
      container.read(placeInvitationControllerProvider).resultFor('invite-2'),
      PlaceInvitationResult.deleted,
    );
  });

  test('원격 요청을 수락하면 요청 PK를 전달하고 목록을 다시 조회한다', () async {
    final dataSource = _FakeFriendRemoteDataSource();
    final container = _remoteContainer(dataSource);
    addTearDown(container.dispose);

    await container.read(remotePlaceInvitationsProvider.future);
    final invitation = container
        .read(placeInvitationsProvider)
        .requireValue
        .single;

    await container
        .read(placeInvitationControllerProvider.notifier)
        .accept(invitation.id, friendId: invitation.friendId);
    await container.read(remotePlaceInvitationsProvider.future);

    expect(dataSource.acceptedFriendId, 41);
    expect(container.read(placeInvitationsProvider).requireValue, isEmpty);
    expect(container.read(placeInvitationRequestCountProvider).value, 0);
  });

  test('원격 요청 처리 실패는 항목을 유지하고 오류 상태를 저장한다', () async {
    final dataSource = _FakeFriendRemoteDataSource(shouldFailDecision: true);
    final container = _remoteContainer(dataSource);
    addTearDown(container.dispose);

    await container.read(remotePlaceInvitationsProvider.future);
    final invitation = container
        .read(placeInvitationsProvider)
        .requireValue
        .single;

    await container
        .read(placeInvitationControllerProvider.notifier)
        .delete(invitation.id, friendId: invitation.friendId);

    final state = container.read(placeInvitationControllerProvider);
    expect(state.resultFor(invitation.id), isNull);
    expect(state.isSubmitting(invitation.id), isFalse);
    expect(state.actionErrorMessage, '친구 요청을 처리하지 못했어요');
    expect(container.read(placeInvitationRequestCountProvider).value, 1);
  });
}

ProviderContainer _remoteContainer(FriendRemoteDataSource dataSource) {
  return ProviderContainer(
    overrides: [
      authenticatedUserDataSession,
      useRemoteApiProvider.overrideWithValue(true),
      friendRemoteDataSourceProvider.overrideWithValue(dataSource),
    ],
  );
}

class _FakeFriendRemoteDataSource extends FriendRemoteDataSource {
  _FakeFriendRemoteDataSource({this.shouldFailDecision = false}) : super(Dio());

  final bool shouldFailDecision;
  int? acceptedFriendId;
  bool _resolved = false;

  @override
  Future<Object?> getRequestsRaw() async {
    return {
      'result': {
        'requests': _resolved
            ? <Object?>[]
            : <Object?>[
                {
                  'friendId': 41,
                  'senderName': '커먼맘',
                  'senderImgUrl': 'https://example.com/profile.png',
                  'placeCode': 'place-code',
                  'placeName': '거실 정원',
                  'placeAddress': '서울시 노원구',
                  'status': 'PENDING',
                },
              ],
      },
    };
  }

  @override
  Future<void> acceptRequest(FriendDecisionRequest request) async {
    if (shouldFailDecision) {
      throw StateError('decision failed');
    }

    acceptedFriendId = request.friendId;
    _resolved = true;
  }

  @override
  Future<void> declineRequest(FriendDecisionRequest request) async {
    if (shouldFailDecision) {
      throw StateError('decision failed');
    }

    _resolved = true;
  }
}
