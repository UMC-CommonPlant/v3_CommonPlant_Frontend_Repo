import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_detail.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_feature_provider.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_friend_profile.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/friend_management_members_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_remote_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_owner_controller.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/user_data_session.dart';

const _code = 'place-code';
final _controller = placeOwnerControllerProvider(_code);

void main() {
  test('현재 멤버의 nanoId로 팀짱을 변경하고 관련 원격 조회만 갱신한다', () async {
    final repository = _Repository();
    final container = _container(repository);
    await _prime(container);
    container.listen(placeDetailProvider('other-place'), (_, _) {});
    await container.read(placeDetailProvider('other-place').future);
    container.read(placeListProvider.notifier).addPlace(name: '로컬 장소');

    final succeeded = await container
        .read(_controller.notifier)
        .transferTo(' member-id ');
    await _settleReads(container);

    expect(succeeded, isTrue);
    expect(repository.requests, [(code: _code, targetNanoId: 'member-id')]);
    expect(repository.reads, {
      'detail:$_code': 2,
      'summary:$_code': 2,
      'members': 2,
      'garden': 2,
      'userPlaces': 2,
      'detail:other-place': 1,
    });
    expect(container.read(_controller), const FormSubmitState.idle());
    expect(
      container.read(placeDetailProvider(_code)).requireValue.isOwner,
      isFalse,
    );
    expect(container.read(placeListProvider).single.name, '로컬 장소');
  });

  test('실패는 조회·로컬 상태를 유지하고 같은 대상 재시도를 허용한다', () async {
    final repository = _Repository()
      ..failure = const ApiException(
        message: 'raw server message',
        kind: ApiFailureKind.forbidden,
      );
    final container = _container(repository);
    await _prime(container);
    final beforeReads = Map.of(repository.reads);
    final controller = container.read(_controller.notifier);

    expect(await controller.transferTo('member-id'), isFalse);
    await container.pump();
    expect(repository.reads, beforeReads);
    expect(container.read(_controller).errorMessage, '이 작업을 수행할 권한이 없어요.');
    expect(container.read(_controller).isSubmitting, isFalse);

    repository.failure = null;
    expect(await controller.transferTo('member-id'), isTrue);
    expect(repository.requests, hasLength(2));
  });

  test('전송 중 중복 제출은 차단하고 최초 요청에만 성공을 반환한다', () async {
    final repository = _Repository()..barrier = Completer<void>();
    final container = _container(repository);
    await _prime(container);
    final controller = container.read(_controller.notifier);

    final pending = controller.transferTo('member-id');
    expect(container.read(_controller).isSubmitting, isTrue);
    expect(await controller.transferTo('another-id'), isFalse);
    expect(repository.requests, [(code: _code, targetNanoId: 'member-id')]);

    repository.barrier!.complete();
    expect(await pending, isTrue);
    expect(container.read(_controller), const FormSubmitState.idle());
  });

  test('최신 상세에서 팀짱이 아니면 이전 화면의 콜백도 전송하지 않는다', () async {
    final repository = _Repository();
    final container = _container(repository);
    await _prime(container);
    final controller = container.read(_controller.notifier);
    repository.isOwner = false;
    container.invalidate(placeDetailProvider(_code));
    await container.read(placeDetailProvider(_code).future);

    expect(await controller.transferTo('member-id'), isFalse);
    expect(repository.requests, isEmpty);
    expect(container.read(_controller).errorMessage, '팀짱 권한을 확인한 뒤 다시 시도해 주세요');
  });

  test('상세 재조회 중 남아 있는 이전 팀짱 권한으로 요청하지 않는다', () async {
    final repository = _Repository();
    final container = _container(repository);
    await _prime(container);
    repository.detailBarrier = Completer<void>();
    container.invalidate(placeDetailProvider(_code));

    expect(
      await container.read(_controller.notifier).transferTo('member-id'),
      isFalse,
    );
    expect(repository.requests, isEmpty);
    repository.detailBarrier!.complete();
    await container.read(placeDetailProvider(_code).future);
  });

  for (final target in ['', 'unknown-id', 'owner-id', 'unconfirmed-id']) {
    test('빈 값·조회에 없는 ID·팀짱·역할 미확인 대상 $target 은 전송하지 않는다', () async {
      final repository = _Repository();
      final container = _container(repository);
      await _prime(container);

      expect(
        await container.read(_controller.notifier).transferTo(target),
        isFalse,
      );
      expect(repository.requests, isEmpty);
      expect(
        container.read(_controller).errorMessage,
        '팀짱으로 변경할 현재 멤버를 다시 선택해 주세요',
      );
    });
  }

  test('최신 멤버 조회에서 사라진 대상은 이전 선택으로 전송하지 않는다', () async {
    final repository = _Repository();
    final container = _container(repository);
    await _prime(container);
    final controller = container.read(_controller.notifier);
    repository.members = const [];
    container.invalidate(remoteFriendManagementMembersProvider(_code));
    await container.read(remoteFriendManagementMembersProvider(_code).future);

    expect(await controller.transferTo('member-id'), isFalse);
    expect(repository.requests, isEmpty);
  });

  test('멤버 재조회 중 이전 목록의 대상으로 전송하지 않는다', () async {
    final repository = _Repository();
    final container = _container(repository);
    await _prime(container);
    repository.membersBarrier = Completer<void>();
    container.invalidate(remoteFriendManagementMembersProvider(_code));

    expect(
      await container.read(_controller.notifier).transferTo('member-id'),
      isFalse,
    );
    expect(repository.requests, isEmpty);
    repository.membersBarrier!.complete();
    await container.read(remoteFriendManagementMembersProvider(_code).future);
  });

  test('API 비사용 모드는 fixture를 변경하거나 원격 조회·쓰기를 하지 않는다', () async {
    final repository = _Repository();
    final container = _container(repository, useRemote: false);
    final beforeMembers = container.read(
      friendManagementMembersProvider(_code),
    );

    expect(
      await container.read(_controller.notifier).transferTo('member-id'),
      isFalse,
    );
    expect(repository.requests, isEmpty);
    expect(repository.reads, isEmpty);
    expect(
      container.read(friendManagementMembersProvider(_code)),
      beforeMembers,
    );
    expect(container.read(_controller).hasError, isTrue);
  });

  test('비활성 세션은 권한 조회나 원격 쓰기 전에 차단한다', () async {
    final repository = _Repository();
    final container = _container(repository, activeSession: false);

    expect(
      await container.read(_controller.notifier).transferTo('member-id'),
      isFalse,
    );
    expect(repository.requests, isEmpty);
    expect(repository.reads, isEmpty);
    expect(container.read(_controller).errorMessage, '로그인 후 다시 시도해 주세요');
  });

  test('빈 장소 코드는 권한 조회나 원격 쓰기 전에 차단한다', () async {
    final repository = _Repository();
    final container = _container(repository);
    final provider = placeOwnerControllerProvider('  ');
    container.listen(provider, (_, _) {});

    expect(
      await container.read(provider.notifier).transferTo('member-id'),
      isFalse,
    );
    expect(repository.requests, isEmpty);
    expect(repository.reads, isEmpty);
    expect(container.read(provider).errorMessage, '장소 정보를 확인한 뒤 다시 시도해 주세요');
  });

  for (final fails in [false, true]) {
    test('계정 전환 뒤 늦은 ${fails ? '실패' : '성공'}은 새 세션의 상태·캐시를 바꾸지 않는다', () async {
      final repository = _Repository()..barrier = Completer<void>();
      final container = _container(repository);
      await _prime(container);
      final pending = container
          .read(_controller.notifier)
          .transferTo('member-id');
      container.read(userDataSessionProvider.notifier).start();
      await _settleReads(container);
      final beforeReads = Map.of(repository.reads);
      if (fails) {
        repository.barrier!.completeError(StateError('이전 세션 실패'));
      } else {
        repository.barrier!.complete();
      }

      expect(await pending, isFalse);
      await container.pump();
      expect(repository.reads, beforeReads);
      expect(container.read(_controller), const FormSubmitState.idle());
    });

    test('화면 폐기 뒤 늦은 ${fails ? '실패' : '성공'}은 캐시 갱신과 성공을 반환하지 않는다', () async {
      final repository = _Repository()..barrier = Completer<void>();
      final container = _container(repository, keepController: false);
      await _prime(container);
      final subscription = container.listen(_controller, (_, _) {});
      final pending = container
          .read(_controller.notifier)
          .transferTo('member-id');
      subscription.close();
      await container.pump();
      final beforeReads = Map.of(repository.reads);
      if (fails) {
        repository.barrier!.completeError(StateError('폐기 후 실패'));
      } else {
        repository.barrier!.complete();
      }

      expect(await pending, isFalse);
      await container.pump();
      expect(repository.reads, beforeReads);
      expect(container.read(_controller), const FormSubmitState.idle());
    });
  }

  test('쓰기 성공 뒤 조회 실패는 성공한 변경을 실패나 재전송으로 바꾸지 않는다', () async {
    final repository = _Repository()..failReadsAfterTransfer = true;
    final container = _container(repository);
    await _prime(container);

    expect(
      await container.read(_controller.notifier).transferTo('member-id'),
      isTrue,
    );
    await _settleReads(container);
    expect(container.read(placeDetailProvider(_code)).hasError, isTrue);
    expect(container.read(_controller), const FormSubmitState.idle());
    expect(repository.requests, hasLength(1));
  });
}

ProviderContainer _container(
  _Repository repository, {
  bool useRemote = true,
  bool activeSession = true,
  bool keepController = true,
}) {
  final container = ProviderContainer(
    overrides: [
      if (activeSession) authenticatedUserDataSession,
      useRemoteApiProvider.overrideWithValue(useRemote),
      placeRepositoryProvider.overrideWithValue(repository),
      remoteFriendManagementMembersProvider(_code).overrideWith((ref) async {
        requireUserDataSession(ref);
        repository.recordRead('members');
        await repository.membersBarrier?.future;
        return repository.members;
      }),
    ],
  );
  addTearDown(container.dispose);
  if (keepController) container.listen(_controller, (_, _) {});
  return container;
}

Future<void> _prime(ProviderContainer container) async {
  container.listen(placeDetailProvider(_code), (_, _) {});
  container.listen(placeSummaryProvider(_code), (_, _) {});
  container.listen(friendManagementMembersProvider(_code), (_, _) {});
  container.listen(remotePlaceListProvider, (_, _) {});
  container.listen(userPlaceSummariesProvider, (_, _) {});
  await _settleReads(container);
}

Future<void> _settleReads(ProviderContainer container) async {
  await Future.wait<void>(
    [
      container.read(placeDetailProvider(_code).future),
      container.read(placeSummaryProvider(_code).future),
      container.read(remoteFriendManagementMembersProvider(_code).future),
      container.read(remotePlaceListProvider.future),
      container.read(userPlaceSummariesProvider.future),
    ].map(
      (future) => future.then<void>(
        (_) {},
        onError: (Object error, StackTrace stack) {},
      ),
    ),
  );
  await container.pump();
}

class _Repository extends Fake implements PlaceRepository {
  final reads = <String, int>{};
  final requests = <({String code, String targetNanoId})>[];
  List<PlaceFriendProfile> members = const [
    PlaceFriendProfile(id: 'owner-id', name: '현재 팀짱', isOwner: true),
    PlaceFriendProfile(id: 'member-id', name: '같은 이름', isOwner: false),
    PlaceFriendProfile(id: 'another-id', name: '같은 이름', isOwner: false),
    PlaceFriendProfile(id: 'unconfirmed-id', name: '역할 미확인'),
  ];
  bool isOwner = true;
  Object? failure;
  Completer<void>? barrier;
  Completer<void>? detailBarrier;
  Completer<void>? membersBarrier;
  bool failReadsAfterTransfer = false;
  bool _failReads = false;

  void recordRead(String key) {
    reads.update(key, (count) => count + 1, ifAbsent: () => 1);
    if (_failReads) throw StateError('후속 조회 실패');
  }

  @override
  Future<void> changePlaceOwner({
    required String code,
    required String targetNanoId,
  }) async {
    requests.add((code: code, targetNanoId: targetNanoId));
    await barrier?.future;
    if (failure case final error?) throw error;
    isOwner = false;
    _failReads = failReadsAfterTransfer;
  }

  @override
  Future<PlaceDetail> fetchPlaceDetail(String code) async {
    recordRead('detail:$code');
    await detailBarrier?.future;
    return PlaceDetail(
      code: code,
      name: '장소',
      address: '주소',
      isOwner: isOwner,
      members: const [],
      plants: const [],
    );
  }

  @override
  Future<PlaceSummary> fetchPlace(String code) async {
    recordRead('summary:$code');
    return PlaceSummary(id: code, name: '장소');
  }

  @override
  Future<List<PlaceSummary>> fetchMyGardenPlaces() async {
    recordRead('garden');
    return const [PlaceSummary(id: _code, name: '장소')];
  }

  @override
  Future<List<PlaceSummary>> fetchUserPlaces() async {
    recordRead('userPlaces');
    return const [PlaceSummary(id: _code, name: '장소')];
  }
}
