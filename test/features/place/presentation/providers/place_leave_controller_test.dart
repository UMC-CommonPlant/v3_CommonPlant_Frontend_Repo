import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_detail.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_feature_provider.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/friend_management_members_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_remote_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_exit_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/domain/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/plant_repository_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_detail_remote_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_edit_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_place_code_provider.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/user_data_session.dart';

const _code = 'leaving-place';
const _plantId = 'affected-plant';

void main() {
  test('나가기는 정규화한 code로 leave만 호출하고 확인용 조회를 추가하지 않는다', () async {
    final repository = _Repository();
    final container = _container(repository);

    final result = await container
        .read(placeExitControllerProvider.notifier)
        .leave(' $_code ');

    expect(result, isTrue);
    expect(repository.writes, [(action: 'leave', code: _code)]);
    expect(repository.reads, isEmpty);
    expect(
      container.read(placeExitControllerProvider),
      const FormSubmitState.idle(),
    );
  });

  test('나가기 성공은 장소·멤버·식물 캐시를 갱신하고 다른 장소·식물과 로컬 값은 유지한다', () async {
    final repository = _Repository();
    final container = _container(repository);
    await _prime(container);
    container.listen(placeDetailProvider('other-place'), (_, _) {});
    container.listen(remotePlantDetailProvider('other-plant'), (_, _) {});
    container.listen(remotePlantEditInfoProvider('other-plant'), (_, _) {});
    await container.read(placeDetailProvider('other-place').future);
    await container.read(remotePlantDetailProvider('other-plant').future);
    await container.read(remotePlantEditInfoProvider('other-plant').future);
    container.read(placeListProvider.notifier).addPlace(name: '기존 로컬 장소');
    container.read(plantListProvider.notifier).addPlant(name: '기존 로컬 식물');

    expect(
      await container.read(placeExitControllerProvider.notifier).leave(_code),
      isTrue,
    );
    await _settleReads(container);

    expect(repository.reads, {
      'detail:$_code': 2,
      'summary:$_code': 2,
      'members:$_code': 2,
      'garden': 2,
      'userPlaces': 2,
      'plants': 2,
      'plant:$_plantId': 2,
      'edit:$_plantId': 2,
      'detail:other-place': 1,
      'plant:other-plant': 1,
      'edit:other-plant': 1,
    });
    expect(container.read(placeDetailProvider(_code)).hasError, isTrue);
    expect(container.read(placeSummaryProvider(_code)).hasError, isTrue);
    expect(
      container.read(friendManagementMembersProvider(_code)).hasError,
      isTrue,
    );
    expect(container.read(remotePlaceListProvider).requireValue, isEmpty);
    expect(container.read(userPlaceSummariesProvider).requireValue, isEmpty);
    expect(container.read(remotePlantListProvider).requireValue, isEmpty);
    expect(
      container.read(remotePlantDetailProvider(_plantId)).hasError,
      isTrue,
    );
    expect(
      container.read(remotePlantEditInfoProvider(_plantId)).hasError,
      isTrue,
    );
    expect(
      container.read(remotePlantPlaceCodeProvider(_plantId)).requireValue,
      isNull,
    );
    expect(container.read(placeListProvider).single.name, '기존 로컬 장소');
    expect(container.read(plantListProvider).single.name, '기존 로컬 식물');
    expect(
      container.read(placeExitControllerProvider),
      const FormSubmitState.idle(),
    );
  });

  test('상세 재조회 중 나가도 이전 상세의 식물 상세·편집 캐시를 제거한다', () async {
    final repository = _Repository();
    final container = _container(repository);
    await _prime(container);
    repository.detailBarrier = Completer<void>();
    container.invalidate(placeDetailProvider(_code));
    final refreshingDetail = container.read(placeDetailProvider(_code));
    expect(refreshingDetail.isLoading, isTrue);
    expect(refreshingDetail.value?.plants.single.id, _plantId);

    expect(
      await container.read(placeExitControllerProvider.notifier).leave(_code),
      isTrue,
    );
    await _settleReads(container);
    expect(repository.reads['plant:$_plantId'], 2);
    expect(repository.reads['edit:$_plantId'], 2);
    expect(
      container.read(remotePlantDetailProvider(_plantId)).hasError,
      isTrue,
    );
    expect(
      container.read(remotePlantEditInfoProvider(_plantId)).hasError,
      isTrue,
    );

    repository.detailBarrier!.complete();
    await container.pump();
    expect(container.read(placeDetailProvider(_code)).hasError, isTrue);
    expect(
      container.read(remotePlantDetailProvider(_plantId)).hasError,
      isTrue,
    );
    expect(
      container.read(remotePlantEditInfoProvider(_plantId)).hasError,
      isTrue,
    );
  });

  for (final failure in [
    (error: StateError('raw failure'), message: '장소 나가기에 실패했어요'),
    (
      error: const ApiException(
        message: 'raw forbidden',
        statusCode: 403,
        kind: ApiFailureKind.forbidden,
      ),
      message: '이 작업을 수행할 권한이 없어요.',
    ),
    (
      error: const ApiException(
        message: 'raw not found',
        statusCode: 404,
        kind: ApiFailureKind.notFound,
      ),
      message: '요청한 정보를 찾을 수 없어요.',
    ),
  ]) {
    test('나가기 실패 ${failure.message}는 캐시를 유지하며 재시도할 수 있다', () async {
      final repository = _Repository()..failure = failure.error;
      final container = _container(repository);
      await _prime(container);
      final controller = container.read(placeExitControllerProvider.notifier);
      final beforeReads = Map.of(repository.reads);

      expect(await controller.leave(_code), isFalse);
      await container.pump();
      expect(repository.reads, beforeReads);
      expect(
        container.read(placeExitControllerProvider).errorMessage,
        failure.message,
      );
      expect(container.read(placeExitControllerProvider).isSubmitting, isFalse);
      expect(
        container.read(remotePlaceListProvider).requireValue,
        hasLength(1),
      );

      repository.failure = null;
      expect(await controller.leave(_code), isTrue);
      expect(repository.writes, [
        (action: 'leave', code: _code),
        (action: 'leave', code: _code),
      ]);
      await _settleReads(container);
    });
  }

  for (final firstIsLeave in [false, true]) {
    test(
      '${firstIsLeave ? '나가기' : '삭제'} 전송 중에는 나가기·삭제의 중복 제출을 함께 차단한다',
      () async {
        final repository = _Repository()..barrier = Completer<void>();
        final container = _container(repository);
        final controller = container.read(placeExitControllerProvider.notifier);
        final first = firstIsLeave
            ? controller.leave(_code)
            : controller.exit(_code);

        expect(await controller.leave(_code), isFalse);
        expect(await controller.exit(_code), isFalse);
        expect(repository.writes, [
          (action: firstIsLeave ? 'leave' : 'delete', code: _code),
        ]);
        expect(
          container.read(placeExitControllerProvider).isSubmitting,
          isTrue,
        );
        repository.barrier!.complete();
        expect(await first, isTrue);
        expect(
          container.read(placeExitControllerProvider),
          const FormSubmitState.idle(),
        );
      },
    );
  }

  test('API 비사용 나가기는 fixture·원격 요청을 변경하지 않는다', () async {
    final repository = _Repository();
    final container = _container(repository, useRemote: false);
    final beforeMembers = container.read(
      friendManagementMembersProvider(_code),
    );

    expect(
      await container.read(placeExitControllerProvider.notifier).leave(_code),
      isFalse,
    );
    expect(repository.writes, isEmpty);
    expect(repository.reads, isEmpty);
    expect(
      container.read(friendManagementMembersProvider(_code)),
      beforeMembers,
    );
    expect(
      container.read(placeExitControllerProvider),
      const FormSubmitState.idle(),
    );
  });

  test('비활성 세션과 빈 code는 조회·쓰기 전에 차단한다', () async {
    final repository = _Repository();
    final container = _container(repository, activeSession: false);
    final controller = container.read(placeExitControllerProvider.notifier);

    expect(await controller.leave(_code), isFalse);
    container.read(userDataSessionProvider.notifier).start();
    expect(await controller.leave(' \t '), isFalse);
    expect(await controller.exit(''), isFalse);
    expect(repository.writes, isEmpty);
    expect(repository.reads, isEmpty);
    expect(
      container.read(placeExitControllerProvider).errorMessage,
      '장소 정보를 확인할 수 없어요.',
    );
  });

  for (final fails in [false, true]) {
    test(
      '계정 전환 뒤 늦은 나가기 ${fails ? '실패' : '성공'}은 새 세션 상태·캐시에 반영하지 않는다',
      () async {
        final repository = _Repository()..barrier = Completer<void>();
        final container = _container(repository);
        await _prime(container);
        final pending = container
            .read(placeExitControllerProvider.notifier)
            .leave(_code);
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
        expect(
          container.read(placeExitControllerProvider),
          const FormSubmitState.idle(),
        );
      },
    );

    test(
      'Controller 폐기 뒤 늦은 나가기 ${fails ? '실패' : '성공'}은 상태·캐시에 반영하지 않는다',
      () async {
        final repository = _Repository()..barrier = Completer<void>();
        final container = _container(repository);
        await _prime(container);
        final pending = container
            .read(placeExitControllerProvider.notifier)
            .leave(_code);
        container.invalidate(placeExitControllerProvider);
        expect(
          container.read(placeExitControllerProvider),
          const FormSubmitState.idle(),
        );
        final beforeReads = Map.of(repository.reads);
        if (fails) {
          repository.barrier!.completeError(StateError('폐기 후 실패'));
        } else {
          repository.barrier!.complete();
        }

        expect(await pending, isFalse);
        await container.pump();
        expect(repository.reads, beforeReads);
        expect(
          container.read(placeExitControllerProvider),
          const FormSubmitState.idle(),
        );
      },
    );
  }
}

ProviderContainer _container(
  _Repository repository, {
  bool useRemote = true,
  bool activeSession = true,
}) {
  final container = ProviderContainer(
    overrides: [
      if (activeSession) authenticatedUserDataSession,
      useRemoteApiProvider.overrideWithValue(useRemote),
      placeRepositoryProvider.overrideWithValue(repository),
      plantRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> _prime(ProviderContainer container) async {
  container.listen(placeDetailProvider(_code), (_, _) {});
  container.listen(placeSummaryProvider(_code), (_, _) {});
  container.listen(friendManagementMembersProvider(_code), (_, _) {});
  container.listen(remotePlaceListProvider, (_, _) {});
  container.listen(userPlaceSummariesProvider, (_, _) {});
  container.listen(remotePlantListProvider, (_, _) {});
  container.listen(remotePlantDetailProvider(_plantId), (_, _) {});
  container.listen(remotePlantEditInfoProvider(_plantId), (_, _) {});
  container.listen(remotePlantPlaceCodeProvider(_plantId), (_, _) {});
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
      container.read(remotePlantListProvider.future),
      container.read(remotePlantDetailProvider(_plantId).future),
      container.read(remotePlantEditInfoProvider(_plantId).future),
      container.read(remotePlantPlaceCodeProvider(_plantId).future),
    ].map(
      (future) => future.then<void>(
        (_) {},
        onError: (Object error, StackTrace stack) {},
      ),
    ),
  );
  await container.pump();
}

class _Repository extends Fake implements PlaceRepository, PlantRepository {
  final writes = <({String action, String code})>[];
  final reads = <String, int>{};
  Object? failure;
  Completer<void>? barrier;
  Completer<void>? detailBarrier;
  bool _left = false;

  void _read(String key, {bool inaccessibleAfterLeave = false}) {
    reads.update(key, (count) => count + 1, ifAbsent: () => 1);
    if (_left && inaccessibleAfterLeave) {
      throw const ApiException(
        message: '해당 장소의 멤버가 아닙니다.',
        statusCode: 403,
        kind: ApiFailureKind.forbidden,
      );
    }
  }

  Future<void> _write(String action, String code) async {
    writes.add((action: action, code: code));
    await barrier?.future;
    if (failure case final error?) throw error;
    _left = true;
  }

  @override
  Future<void> leavePlace(String code) => _write('leave', code);

  @override
  Future<void> deletePlace(String code) => _write('delete', code);

  @override
  Future<PlaceDetail> fetchPlaceDetail(String code) async {
    _read('detail:$code', inaccessibleAfterLeave: code == _code);
    await detailBarrier?.future;
    return PlaceDetail(
      code: code,
      name: '장소',
      address: '주소',
      isOwner: false,
      members: const [],
      plants: [
        PlacePlant(
          id: code == _code ? _plantId : 'other-plant',
          scientificNameKo: '몬스테라',
        ),
      ],
    );
  }

  @override
  Future<PlaceSummary> fetchPlace(String code) async {
    _read('summary:$code', inaccessibleAfterLeave: code == _code);
    return PlaceSummary(id: code, name: '장소');
  }

  @override
  Future<List<PlaceMember>> fetchPlaceMembers(String code) async {
    _read('members:$code', inaccessibleAfterLeave: code == _code);
    return const [PlaceMember(name: '멤버', nanoId: 'member-id', isOwner: false)];
  }

  @override
  Future<List<PlaceSummary>> fetchMyGardenPlaces() async {
    _read('garden');
    return _left ? const [] : const [PlaceSummary(id: _code, name: '장소')];
  }

  @override
  Future<List<PlaceSummary>> fetchUserPlaces() async {
    _read('userPlaces');
    return _left ? const [] : const [PlaceSummary(id: _code, name: '장소')];
  }

  @override
  Future<List<PlantSummary>> fetchPlants({int page = 0, int size = 20}) async {
    _read('plants');
    return _left
        ? const []
        : const [PlantSummary(id: _plantId, name: '몬스테라', placeId: _code)];
  }

  @override
  Future<PlantDetail> fetchPlant({required String plantId}) async {
    _read('plant:$plantId', inaccessibleAfterLeave: plantId == _plantId);
    return PlantDetail(id: plantId, name: '몬스테라');
  }

  @override
  Future<PlantEditInfo> fetchPlantEditInfo({required String plantId}) async {
    _read('edit:$plantId', inaccessibleAfterLeave: plantId == _plantId);
    return const PlantEditInfo(name: '몬스테라');
  }
}
