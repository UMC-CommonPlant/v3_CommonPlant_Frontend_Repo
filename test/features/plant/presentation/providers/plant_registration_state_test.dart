import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_feature_provider.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/plant/domain/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/plant_repository_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/fixtures/plant_registration_place_fixture.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_controller.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_state.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_registration_place_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/user_data_session.dart';

const _places = [
  PlaceSummary(id: 'API-A', name: '실제 온실'),
  PlaceSummary(id: 'API-B', name: '실제 정원'),
];
final _form = plantFormControllerProvider(
  const PlantFormArgs(initialPlantName: '선택한 식물'),
);

void main() {
  test('API 장소 loading은 샘플·선택·등록 요청을 만들지 않는다', () async {
    final places = _ControlledPlaceRepository();
    final plants = _RecordingPlantRepository();
    final container = _container(places, plants);

    final state = container.read(_form);
    expect(state.loadStatus, PlantFormLoadStatus.loading);
    expect(state.places, isEmpty);
    expect(state.selectedPlaceId, isNull);
    expect(state.canSubmit, isFalse);
    expect(await container.read(_form.notifier).submit(), isNull);
    expect(plants.codes, isEmpty);
    expect(places.requests, hasLength(1));
  });

  test('API 장소 empty는 샘플 대신 빈 상태를 유지하고 등록을 막는다', () async {
    final places = _ControlledPlaceRepository();
    final plants = _RecordingPlantRepository();
    final container = _container(places, plants);
    places.requests.single.complete([]);
    await _settlePlaces(container);

    final state = container.read(_form);
    expect(state.loadStatus, PlantFormLoadStatus.empty);
    expect(state.places, isEmpty);
    expect(state.selectedPlace, isNull);
    expect(state.canSubmit, isFalse);
    expect(await container.read(_form.notifier).submit(), isNull);
    expect(plants.codes, isEmpty);
  });

  test('실패 재시도는 실제 장소 repository를 다시 호출한다', () async {
    final places = _ControlledPlaceRepository();
    final plants = _RecordingPlantRepository();
    final container = _container(places, plants);
    places.requests.single.completeError(StateError('raw failure'));
    await _settlePlaces(container);

    final failed = container.read(_form);
    expect(failed.loadStatus, PlantFormLoadStatus.failure);
    expect(failed.places, isEmpty);
    expect(failed.canSubmit, isFalse);
    expect(failed.loadErrorMessage, '등록할 장소를 불러오지 못했어요');
    expect(await container.read(_form.notifier).submit(), isNull);

    container.read(_form.notifier).retryLoad();
    await container.pump();
    expect(places.requests, hasLength(2));
    expect(container.read(_form).loadStatus, PlantFormLoadStatus.loading);
    places.requests.last.complete(_places);
    await _settlePlaces(container);

    final loaded = container.read(_form);
    expect(loaded.loadStatus, PlantFormLoadStatus.ready);
    expect(loaded.loadErrorMessage, isNull);
    expect(loaded.currentName, '선택한 식물');
    expect(loaded.places.map((place) => place.id), ['API-A', 'API-B']);
    expect(loaded.canSubmit, isTrue);
    expect(plants.codes, isEmpty);
  });

  test('서버 목록의 선택 code만 전송하고 목록 밖 샘플 선택은 무시한다', () async {
    final places = _ControlledPlaceRepository();
    final plants = _RecordingPlantRepository();
    final container = _container(places, plants);
    places.requests.single.complete(_places);
    await _settlePlaces(container);
    final controller = container.read(_form.notifier);
    controller.selectPlace(container.read(_form).places.last);
    controller.selectPlace(plantRegistrationPlaceFallbacks.first);
    controller.updateLastWateredDate(DateTime(2026, 8, 20));

    expect(container.read(_form).selectedPlaceId, 'API-B');
    expect(
      (await controller.submit())?.destination,
      PlantFormSubmitDestination.home,
    );
    expect(plants.codes, ['API-B']);
    expect(plants.names, ['선택한 식물']);
    expect(plants.dates, ['2026-08-20']);
  });

  test('장소 source 무효화 직후 프레임을 기다리지 않은 submit도 차단한다', () async {
    final places = _ControlledPlaceRepository();
    final plants = _RecordingPlantRepository();
    final container = _container(places, plants);
    places.requests.single.complete(_places);
    await _settlePlaces(container);
    final controller = container.read(_form.notifier);

    container.invalidate(userPlaceSummariesProvider);
    expect(await controller.submit(), isNull);
    expect(plants.codes, isEmpty);
    expect(container.read(_form).loadStatus, PlantFormLoadStatus.loading);
  });

  for (final outcome in ['empty', 'failure', 'replacement']) {
    test('목록 재조회 $outcome에서 이전 장소를 숨기고 초안을 보존한다', () async {
      final places = _ControlledPlaceRepository();
      final plants = _RecordingPlantRepository();
      final container = _container(places, plants);
      places.requests.single.complete(_places);
      await _settlePlaces(container);
      final controller = container.read(_form.notifier);
      final oldPlace = container.read(_form).places.last;
      controller.selectPlace(oldPlace);
      controller.updateName('수정한 이름');
      controller.updateLastWateredDate(DateTime(2026, 8, 21));

      container.invalidate(userPlaceSummariesProvider);
      await container.pump();
      final loading = container.read(_form);
      expect(loading.loadStatus, PlantFormLoadStatus.loading);
      expect(loading.places, isEmpty);
      expect(loading.canSubmit, isFalse);
      controller.selectPlace(oldPlace);
      expect(await controller.submit(), isNull);
      if (outcome == 'failure') {
        places.requests.last.completeError(StateError('raw failure'));
      } else {
        places.requests.last.complete(
          outcome == 'empty'
              ? []
              : [const PlaceSummary(id: 'API-C', name: '새 장소')],
        );
      }
      await container.pump();

      await _settlePlaces(container);
      final updated = container.read(_form);
      expect(updated.currentName, '수정한 이름');
      expect(updated.currentLastWateredDate, '2026-08-21');
      expect(
        updated.loadStatus.name,
        outcome == 'replacement' ? 'ready' : outcome,
      );
      expect(updated.places.any((place) => place.id == oldPlace.id), isFalse);
      controller.selectPlace(oldPlace);
      if (outcome == 'replacement') {
        expect(container.read(_form).selectedPlaceId, 'API-C');
        expect(await controller.submit(), isNotNull);
        expect(plants.codes, ['API-C']);
      } else {
        expect(updated.selectedPlaceId, isNull);
        expect(await controller.submit(), isNull);
        expect(plants.codes, isEmpty);
      }
    });
  }

  test('계정 전환 후 늦은 A 장소 응답은 B의 폼에 섞이지 않는다', () async {
    final places = _ControlledPlaceRepository();
    final plants = _RecordingPlantRepository();
    final container = _container(places, plants);
    final requestA = places.requests.single;

    container.read(userDataSessionProvider.notifier).start();
    await container.pump();
    expect(container.read(_form).places, isEmpty);
    expect(container.read(_form).canSubmit, isFalse);
    expect(places.requests, hasLength(2));
    places.requests.last.complete([
      const PlaceSummary(id: 'B-ONLY', name: 'B 장소'),
    ]);
    await _settlePlaces(container);
    requestA.complete(_places);
    await container.pump();

    expect(container.read(_form).places.map((place) => place.id), ['B-ONLY']);
    expect(container.read(_form).selectedPlaceId, 'B-ONLY');
    expect(plants.codes, isEmpty);
  });

  test('등록 중 장소 재조회는 제출 잠금과 최초 요청 값을 유지한다', () async {
    final places = _ControlledPlaceRepository();
    final barrier = Completer<void>();
    final plants = _RecordingPlantRepository()..writeBarrier = barrier;
    final container = _container(places, plants);
    places.requests.single.complete(_places);
    await _settlePlaces(container);
    final controller = container.read(_form.notifier);
    controller.selectPlace(container.read(_form).places.last);
    final first = controller.submit();

    container.invalidate(userPlaceSummariesProvider);
    await container.pump();
    expect(container.read(_form).isSubmitting, isTrue);
    expect(await controller.submit(), isNull);
    places.requests.last.complete([
      const PlaceSummary(id: 'API-C', name: '새 장소'),
    ]);
    await _settlePlaces(container);
    expect(container.read(_form).isSubmitting, isTrue);
    expect(container.read(_form).canSubmit, isFalse);
    expect(await controller.submit(), isNull);
    expect(plants.codes, ['API-B']);

    barrier.completeError(StateError('등록 실패'));
    expect(await first, isNull);
    expect(container.read(_form).canSubmit, isTrue);
    plants.writeBarrier = null;
    expect(await controller.submit(), isNotNull);
    expect(plants.codes, ['API-B', 'API-C']);
  });

  test('API 비사용 모드는 초기·빈 목록의 fixture 등록을 유지한다', () async {
    final places = _ControlledPlaceRepository();
    final plants = _RecordingPlantRepository();
    final container = _container(places, plants, useRemote: false);

    expect(container.read(_form).places, plantRegistrationPlaceFallbacks);
    await container.pump();
    expect(container.read(_form).places, plantRegistrationPlaceFallbacks);
    expect(container.read(_form).canSubmit, isTrue);
    expect(await container.read(_form.notifier).submit(), isNotNull);
    expect(places.requests, isEmpty);
    expect(plants.codes, isEmpty);
  });
}

ProviderContainer _container(
  PlaceRepository places,
  PlantRepository plants, {
  bool useRemote = true,
}) {
  final container = ProviderContainer(
    overrides: [
      authenticatedUserDataSession,
      useRemoteApiProvider.overrideWithValue(useRemote),
      placeRepositoryProvider.overrideWithValue(places),
      plantRepositoryProvider.overrideWithValue(plants),
    ],
  );
  addTearDown(container.dispose);
  container.listen(_form, (_, _) {});
  return container;
}

Future<void> _settlePlaces(ProviderContainer container) async {
  // 루트 조회뿐 아니라 폼이 구독하는 파생 Future의 전파까지 기다린다.
  await container
      .read(plantRegistrationPlaceProvider.future)
      .then<void>((_) {}, onError: (Object error, StackTrace stackTrace) {});
  await container.pump();
}

class _ControlledPlaceRepository extends Fake implements PlaceRepository {
  final requests = <Completer<List<PlaceSummary>>>[];

  @override
  Future<List<PlaceSummary>> fetchUserPlaces() {
    final request = Completer<List<PlaceSummary>>();
    requests.add(request);
    return request.future;
  }
}

class _RecordingPlantRepository extends Fake implements PlantRepository {
  final codes = <String>[];
  final names = <String>[];
  final dates = <String?>[];
  Completer<void>? writeBarrier;

  @override
  Future<void> createPlant({
    required String placeCode,
    required String nickname,
    String? scientificNameKo,
    String? scientificNameEn,
    String? lastWateredDate,
    String? description,
  }) async {
    codes.add(placeCode);
    names.add(nickname);
    dates.add(lastWateredDate);
    await writeBarrier?.future;
  }
}
