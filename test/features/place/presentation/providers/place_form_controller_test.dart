import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/data/datasources/place_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/dtos/place_requests.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaceFormController', () {
    test('local 장소 생성은 목록에 추가하고 친구 추가 이동 결과를 반환한다', () async {
      final container = ProviderContainer();

      addTearDown(container.dispose);

      final result = await container
          .read(placeFormControllerProvider.notifier)
          .submit(
            const PlaceFormSubmitInput.create(
              name: '  거실  ',
              address: '  서울시 성북구  ',
            ),
          );
      final places = container.read(placeListProvider);

      expect(result?.destination, PlaceFormSubmitDestination.friendAdd);
      expect(
        container.read(placeFormControllerProvider),
        const FormSubmitState.idle(),
      );
      expect(places, hasLength(1));
      expect(places.single.name, '거실');
      expect(places.single.address, '서울시 성북구');
    });

    test('local 장소 수정은 목록 값을 갱신하고 홈 이동 결과를 반환한다', () async {
      final container = ProviderContainer();

      addTearDown(container.dispose);

      final place = container
          .read(placeListProvider.notifier)
          .addPlace(name: '거실', address: '서울시 성북구');

      final result = await container
          .read(placeFormControllerProvider.notifier)
          .submit(
            PlaceFormSubmitInput.update(
              placeId: place.id,
              name: '루프탑',
              address: '서울시 강남구',
            ),
          );
      final places = container.read(placeListProvider);

      expect(result?.destination, PlaceFormSubmitDestination.home);
      expect(places.single.name, '루프탑');
      expect(places.single.address, '서울시 강남구');
    });

    test('remote 장소 생성은 주소가 없으면 요청하지 않고 검증 메시지를 남긴다', () async {
      final repository = _RecordingPlaceRepository();
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(repository),
        ],
      );

      addTearDown(container.dispose);

      final result = await container
          .read(placeFormControllerProvider.notifier)
          .submit(const PlaceFormSubmitInput.create(name: '거실'));

      expect(result, isNull);
      expect(repository.createCalls, 0);
      expect(
        container.read(placeFormControllerProvider),
        const FormSubmitState.failure('장소 주소를 입력해 주세요.'),
      );
    });

    test('remote 장소 수정은 repository를 호출하고 홈 이동 결과를 반환한다', () async {
      final repository = _RecordingPlaceRepository();
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(repository),
        ],
      );

      addTearDown(container.dispose);

      final result = await container
          .read(placeFormControllerProvider.notifier)
          .submit(
            const PlaceFormSubmitInput.update(
              placeId: 'place-1',
              name: '루프탑',
              address: '서울시 성북구',
            ),
          );

      expect(result?.destination, PlaceFormSubmitDestination.home);
      expect(repository.updateCalls, 1);
      expect(repository.latestUpdateCode, 'place-1');
      expect(repository.latestUpdateRequest?.toJson(), {
        'name': '루프탑',
        'address': '서울시 성북구',
      });
      expect(
        container.read(placeFormControllerProvider),
        const FormSubmitState.idle(),
      );
    });
  });
}

class _RecordingPlaceRepository extends PlaceRepository {
  _RecordingPlaceRepository() : super(PlaceRemoteDataSource(Dio()));

  int createCalls = 0;
  int updateCalls = 0;
  String? latestUpdateCode;
  CreatePlaceRequest? latestCreateRequest;
  UpdatePlaceRequest? latestUpdateRequest;

  @override
  Future<void> createPlace(
    CreatePlaceRequest request, {
    MultipartFile? image,
  }) async {
    createCalls++;
    latestCreateRequest = request;
  }

  @override
  Future<void> updatePlace({
    required String code,
    required UpdatePlaceRequest request,
    MultipartFile? image,
  }) async {
    updateCalls++;
    latestUpdateCode = code;
    latestUpdateRequest = request;
  }
}
