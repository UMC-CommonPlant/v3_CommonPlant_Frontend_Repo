import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/data/datasources/place_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_exit_controller.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaceExitController', () {
    test('remote 장소 나가기는 repository를 호출하고 홈 이동 결과를 반환한다', () async {
      final repository = _RecordingPlaceRepository();
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(repository),
        ],
      );

      addTearDown(container.dispose);

      final result = await container
          .read(placeExitControllerProvider.notifier)
          .exit('place-1');

      expect(result?.destination, PlaceExitDestination.home);
      expect(repository.deleteCalls, 1);
      expect(repository.latestDeleteCode, 'place-1');
      expect(
        container.read(placeExitControllerProvider),
        const FormSubmitState.idle(),
      );
    });

    test('remote 장소 나가기 실패는 사용자 메시지 상태를 남긴다', () async {
      final repository = _FailingPlaceRepository();
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(repository),
        ],
      );

      addTearDown(container.dispose);

      final result = await container
          .read(placeExitControllerProvider.notifier)
          .exit('place-1');

      expect(result, isNull);
      expect(repository.deleteCalls, 1);
      expect(
        container.read(placeExitControllerProvider),
        const FormSubmitState.failure('장소 나가기에 실패했어요'),
      );
    });

    test('local 장소 나가기는 원격 요청 없이 idle 상태를 유지한다', () async {
      final repository = _RecordingPlaceRepository();
      final container = ProviderContainer(
        overrides: [placeRepositoryProvider.overrideWithValue(repository)],
      );

      addTearDown(container.dispose);

      final result = await container
          .read(placeExitControllerProvider.notifier)
          .exit('place-1');

      expect(result, isNull);
      expect(repository.deleteCalls, 0);
      expect(
        container.read(placeExitControllerProvider),
        const FormSubmitState.idle(),
      );
    });
  });
}

class _RecordingPlaceRepository extends PlaceRepository {
  _RecordingPlaceRepository() : super(PlaceRemoteDataSource(Dio()));

  int deleteCalls = 0;
  String? latestDeleteCode;

  @override
  Future<void> deletePlace(String code) async {
    deleteCalls++;
    latestDeleteCode = code;
  }
}

class _FailingPlaceRepository extends PlaceRepository {
  _FailingPlaceRepository() : super(PlaceRemoteDataSource(Dio()));

  int deleteCalls = 0;

  @override
  Future<void> deletePlace(String code) async {
    deleteCalls++;
    throw StateError('raw failure');
  }
}
