import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_detail.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_remote_provider.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/domain/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/plant_repository_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_detail_remote_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_controller.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_edit_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_state.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/user_data_session.dart';

const _args = PlantFormArgs(plantId: 'plant-1', placeId: 'PLACE-A');
final _form = plantFormControllerProvider(_args);

void main() {
  for (final code in [null, '', ' \t\n ']) {
    test('원격 수정 code=$code는 안내 상태이며 조회·쓰기·로컬 변경을 하지 않는다', () async {
      final repository = _EditRepository();
      final container = _container(repository);
      container.read(plantListProvider.notifier).addPlant(name: '기존 로컬');
      final form = plantFormControllerProvider(
        PlantFormArgs(plantId: 'plant-1', placeId: code),
      );
      container.listen(form, (_, _) {});
      final controller = container.read(form.notifier);
      await container.pump();
      await Future<void>.delayed(Duration.zero);
      await container.pump();

      controller.updateName('변경 시도');
      controller.updateLastWateredDate(DateTime(2026, 8, 28));
      expect(await controller.submit(), isNull);
      expect(container.read(form).loadStatus, PlantFormLoadStatus.missingPlace);
      expect(container.read(form).canSubmit, isFalse);
      controller.retryLoad();
      expect(repository.requests, isEmpty);
      expect(repository.reads, isEmpty);
      expect(container.read(plantListProvider).single.name, '기존 로컬');
    });
  }

  test('정상 code를 정규화하고 기존 이미지 key·이름·날짜를 전달한다', () async {
    final repository = _EditRepository();
    final container = _container(repository);
    final form = plantFormControllerProvider(
      const PlantFormArgs(plantId: 'plant-1', placeId: ' PLACE-A '),
    );
    container.listen(form, (_, _) {});
    await container.read(remotePlantEditInfoProvider('plant-1').future);
    await container.pump();
    final controller = container.read(form.notifier);
    controller.updateName('수정한 이름');
    controller.updateLastWateredDate(DateTime(2026, 8, 28));

    final result = await controller.submit();
    expect(result?.destination, PlantFormSubmitDestination.plantDetail);
    expect(result?.plantId, 'plant-1');
    expect(result?.placeId, 'PLACE-A');
    expect(repository.requests.single, (
      plantId: 'plant-1',
      code: 'PLACE-A',
      name: '수정한 이름',
      imageKey: 'images/keep.png',
      date: '2026-08-28',
    ));
  });

  test('수정 성공은 해당 목록·상세·편집·장소 캐시만 갱신하고 결과를 반환한다', () async {
    final repository = _EditRepository();
    final container = _container(repository);
    await _prime(container);
    container.listen(remotePlantDetailProvider('other-plant'), (_, _) {});
    container.listen(placeDetailProvider('OTHER-PLACE'), (_, _) {});
    await container.read(remotePlantDetailProvider('other-plant').future);
    await container.read(placeDetailProvider('OTHER-PLACE').future);
    container.read(plantListProvider.notifier).addPlant(name: '기존 로컬');
    final controller = container.read(_form.notifier);
    controller.updateName('새 애칭');
    controller.updateLastWateredDate(DateTime(2026, 8, 28));

    final result = await controller.submit();
    expect(result?.destination, PlantFormSubmitDestination.plantDetail);
    await _settleReads(container);

    expect(repository.reads, {
      'list': 2,
      'plant:plant-1': 2,
      'edit:plant-1': 2,
      'place:PLACE-A': 2,
      'plant:other-plant': 1,
      'place:OTHER-PLACE': 1,
    });
    expect(
      container.read(remotePlantListProvider).requireValue.single.name,
      '새 애칭',
    );
    expect(
      container
          .read(remotePlantDetailProvider('plant-1'))
          .requireValue
          .lastWateredDate,
      '2026-08-28',
    );
    expect(
      container
          .read(placeDetailProvider('PLACE-A'))
          .requireValue
          .plants
          .single
          .lastWateredDate,
      '2026-08-28',
    );
    expect(container.read(_form).currentName, '새 애칭');
    expect(container.read(_form).canSubmit, isFalse);
    expect(container.read(plantListProvider).single.name, '새 애칭');
    expect(repository.requests, hasLength(1));
  });

  test('API 실패는 캐시·로컬 상태를 바꾸지 않고 초안 재시도를 허용한다', () async {
    final repository = _EditRepository()..barrier = Completer<void>();
    final container = _container(repository);
    await _prime(container);
    container.read(plantListProvider.notifier).addPlant(name: '기존 로컬');
    final beforeReads = Map.of(repository.reads);
    final controller = container.read(_form.notifier);
    controller.updateName('첫 요청');
    final pending = controller.submit();
    controller.updateName('다음 요청');
    expect(await controller.submit(), isNull);
    expect(container.read(_form).isSubmitting, isTrue);
    repository.barrier!.completeError(StateError('raw failure'));
    expect(await pending, isNull);
    await container.pump();

    expect(repository.reads, beforeReads);
    expect(container.read(plantListProvider).single.name, '기존 로컬');
    expect(container.read(_form).currentName, '다음 요청');
    expect(container.read(_form).submitErrorMessage, '식물 수정에 실패했어요');
    expect(container.read(_form).canSubmit, isTrue);
    repository.barrier = null;
    expect(await controller.submit(), isNotNull);
    await _settleReads(container);
    expect(repository.requests.map((request) => request.name), [
      '첫 요청',
      '다음 요청',
    ]);
    expect(
      container.read(remotePlantListProvider).requireValue.single.name,
      '다음 요청',
    );
  });

  for (final fails in [false, true]) {
    test('계정 전환 후 늦은 수정 ${fails ? '실패' : '성공'}은 B의 캐시·이동에 반영하지 않는다', () async {
      final repository = _EditRepository()..barrier = Completer<void>();
      final container = _container(repository);
      await _prime(container);
      final controller = container.read(_form.notifier);
      controller.updateName('A 수정');
      final pending = controller.submit();
      container.read(userDataSessionProvider.notifier).start();
      await _settleReads(container);
      final beforeReads = Map.of(repository.reads);
      if (fails) {
        repository.barrier!.completeError(StateError('A 실패'));
      } else {
        repository.barrier!.complete();
      }
      expect(await pending, isNull);
      await container.pump();

      expect(repository.reads, beforeReads);
      expect(container.read(plantListProvider), isEmpty);
      expect(container.read(_form).currentName, '기존 애칭');
      expect(container.read(_form).submitErrorMessage, isNull);
      expect(container.read(_form).isSubmitting, isFalse);
    });
  }

  test('성공 후 재조회 오류는 완료한 PUT을 실패나 추가 쓰기로 바꾸지 않는다', () async {
    final repository = _EditRepository()..failReadsAfterUpdate = true;
    final container = _container(repository);
    await _prime(container);
    final controller = container.read(_form.notifier);
    controller.updateName('수정 완료');
    final result = await controller.submit();

    expect(result?.destination, PlantFormSubmitDestination.plantDetail);
    await _settleReads(container);
    expect(container.read(remotePlantListProvider).hasError, isTrue);
    expect(
      container.read(remotePlantDetailProvider('plant-1')).hasError,
      isTrue,
    );
    expect(container.read(_form).loadStatus, PlantFormLoadStatus.failure);
    expect(repository.requests, hasLength(1));
  });

  test('API 비사용 수정은 code 없이도 기존 로컬 동작을 유지한다', () async {
    final repository = _EditRepository();
    final container = _container(repository, useRemote: false);
    final plant = container
        .read(plantListProvider.notifier)
        .addPlant(name: '몬테');
    final form = plantFormControllerProvider(PlantFormArgs(plantId: plant.id));
    container.listen(form, (_, _) {});
    container.read(form.notifier).updateName('로컬 수정');

    expect(await container.read(form.notifier).submit(), isNotNull);
    expect(container.read(plantListProvider).single.name, '로컬 수정');
    expect(repository.reads, isEmpty);
    expect(repository.requests, isEmpty);
  });
}

ProviderContainer _container(
  _EditRepository repository, {
  bool useRemote = true,
}) {
  final container = ProviderContainer(
    overrides: [
      authenticatedUserDataSession,
      useRemoteApiProvider.overrideWithValue(useRemote),
      plantRepositoryProvider.overrideWithValue(repository),
      placeRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> _prime(ProviderContainer container) async {
  container.listen(_form, (_, _) {});
  container.listen(remotePlantListProvider, (_, _) {});
  container.listen(remotePlantDetailProvider('plant-1'), (_, _) {});
  container.listen(placeDetailProvider('PLACE-A'), (_, _) {});
  await _settleReads(container);
}

Future<void> _settleReads(ProviderContainer container) async {
  await Future.wait<void>(
    [
      container.read(remotePlantListProvider.future),
      container.read(remotePlantDetailProvider('plant-1').future),
      container.read(remotePlantEditInfoProvider('plant-1').future),
      container.read(placeDetailProvider('PLACE-A').future),
    ].map(
      (future) => future.then<void>(
        (_) {},
        onError: (Object error, StackTrace stack) {},
      ),
    ),
  );
  await container.pump();
}

class _EditRepository extends Fake implements PlantRepository, PlaceRepository {
  final reads = <String, int>{};
  final requests =
      <
        ({
          String plantId,
          String code,
          String? name,
          String? imageKey,
          String? date,
        })
      >[];
  String savedName = '기존 애칭';
  String savedDate = '2026-08-20';
  Completer<void>? barrier;
  bool failReadsAfterUpdate = false;
  bool _failReads = false;

  void _read(String key) {
    reads.update(key, (count) => count + 1, ifAbsent: () => 1);
    if (_failReads) throw StateError('재조회 실패');
  }

  @override
  Future<List<PlantSummary>> fetchPlants({int page = 0, int size = 20}) async {
    _read('list');
    return [PlantSummary(id: 'plant-1', name: savedName)];
  }

  @override
  Future<PlantDetail> fetchPlant({required String plantId}) async {
    _read('plant:$plantId');
    return PlantDetail(id: plantId, name: '몬스테라', lastWateredDate: savedDate);
  }

  @override
  Future<PlantEditInfo> fetchPlantEditInfo({required String plantId}) async {
    _read('edit:$plantId');
    return PlantEditInfo(
      name: savedName,
      imageKey: 'images/keep.png',
      imageUrl: 'https://example.test/keep.png',
      lastWateredDate: savedDate,
    );
  }

  @override
  Future<PlaceDetail> fetchPlaceDetail(String code) async {
    _read('place:$code');
    return PlaceDetail(
      code: code,
      name: '장소',
      address: '주소',
      isOwner: true,
      members: const [],
      plants: [
        PlacePlant(
          id: 'plant-1',
          scientificNameKo: '몬스테라',
          lastWateredDate: savedDate,
        ),
      ],
    );
  }

  @override
  Future<void> updatePlant({
    required String plantId,
    required String placeCode,
    String? imageKey,
    String? nickname,
    String? lastWateredDate,
  }) async {
    requests.add((
      plantId: plantId,
      code: placeCode,
      name: nickname,
      imageKey: imageKey,
      date: lastWateredDate,
    ));
    await barrier?.future;
    savedName = nickname ?? savedName;
    savedDate = lastWateredDate ?? savedDate;
    _failReads = failReadsAfterUpdate;
  }
}
