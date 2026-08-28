import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_edit_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_state.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/user_data_session.dart';

void main() {
  group('PlaceFormController', () {
    test('local 장소 생성은 draft를 목록에 추가하고 친구 추가 결과를 반환한다', () async {
      final container = ProviderContainer();
      final subscription = container.listen(
        placeFormControllerProvider(null),
        (previous, next) {},
      );

      addTearDown(subscription.close);
      addTearDown(container.dispose);

      final controller = container.read(
        placeFormControllerProvider(null).notifier,
      );
      controller.updateName('  거실  ');
      controller.updateAddress('  서울시 성북구  ');

      final result = await controller.submit();
      final places = container.read(placeListProvider);

      expect(result?.destination, PlaceFormSubmitDestination.friendAdd);
      expect(result?.placeCode, 'place-1');
      expect(
        container.read(placeFormControllerProvider(null)).submitState,
        const FormSubmitState.idle(),
      );
      expect(places, hasLength(1));
      expect(places.single.name, '거실');
      expect(places.single.address, '서울시 성북구');
    });

    test('local 장소 수정은 초기값을 노출하고 변경한 draft를 저장한다', () async {
      final container = ProviderContainer();

      addTearDown(container.dispose);

      final place = container
          .read(placeListProvider.notifier)
          .addPlace(name: '거실', address: '서울시 성북구');
      final subscription = container.listen(
        placeFormControllerProvider(place.id),
        (previous, next) {},
      );
      addTearDown(subscription.close);

      final initialState = container.read(
        placeFormControllerProvider(place.id),
      );
      final controller = container.read(
        placeFormControllerProvider(place.id).notifier,
      );

      expect(initialState.loadStatus, PlaceFormLoadStatus.ready);
      expect(initialState.currentName, '스윗 홈_ 거실');

      controller.updateName('루프탑');
      controller.updateAddress('서울시 강남구');
      final result = await controller.submit();
      final places = container.read(placeListProvider);

      expect(result?.destination, PlaceFormSubmitDestination.home);
      expect(result?.placeCode, place.id);
      expect(places.single.name, '루프탑');
      expect(places.single.address, '서울시 강남구');
    });

    test('remote 장소 생성은 주소가 없으면 요청하지 않고 검증 메시지를 남긴다', () async {
      final repository = _RecordingPlaceRepository();
      final container = ProviderContainer(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(repository),
        ],
      );
      final subscription = container.listen(
        placeFormControllerProvider(null),
        (previous, next) {},
      );

      addTearDown(subscription.close);
      addTearDown(container.dispose);

      final controller = container.read(
        placeFormControllerProvider(null).notifier,
      );
      controller.updateName('거실');

      final result = await controller.submit();

      expect(result, isNull);
      expect(repository.createCalls, 0);
      expect(
        container.read(placeFormControllerProvider(null)).submitState,
        const FormSubmitState.failure('장소 주소를 입력해 주세요.'),
      );
    });

    test('remote 장소 생성은 응답 place code를 친구 추가 결과에 보존한다', () async {
      final repository = _RecordingPlaceRepository();
      final container = ProviderContainer(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(repository),
        ],
      );
      final subscription = container.listen(
        placeFormControllerProvider(null),
        (previous, next) {},
      );

      addTearDown(subscription.close);
      addTearDown(container.dispose);

      final controller = container.read(
        placeFormControllerProvider(null).notifier,
      );
      controller.updateName('거실');
      controller.updateAddress('서울시 성북구');

      final result = await controller.submit();

      expect(result?.destination, PlaceFormSubmitDestination.friendAdd);
      expect(result?.placeCode, 'created-place');
      expect(repository.createCalls, 1);
    });

    test('remote 장소 수정은 조회값을 draft로 사용하고 repository를 호출한다', () async {
      final repository = _RecordingPlaceRepository();
      final container = ProviderContainer(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(repository),
        ],
      );
      final subscription = container.listen(
        placeFormControllerProvider('place-1'),
        (previous, next) {},
      );

      addTearDown(subscription.close);
      addTearDown(container.dispose);

      await container.read(remotePlaceFormEditInfoProvider('place-1').future);
      await Future<void>.delayed(Duration.zero);
      final initialState = container.read(
        placeFormControllerProvider('place-1'),
      );
      final controller = container.read(
        placeFormControllerProvider('place-1').notifier,
      );

      expect(initialState.currentName, '거실');
      expect(initialState.currentAddress, '서울시 성북구');

      controller.updateName('루프탑');
      final result = await controller.submit();

      expect(result?.destination, PlaceFormSubmitDestination.home);
      expect(result?.placeCode, 'place-1');
      expect(repository.updateCalls, 1);
      expect(repository.latestUpdateCode, 'place-1');
      expect(repository.latestUpdateName, '루프탑');
      expect(repository.latestUpdateAddress, '서울시 성북구');
      expect(repository.latestUpdateImageKey, isNull);
    });

    test('사진이 있는 장소의 이름·주소 수정은 기존 사진 유실을 막는다', () async {
      final repository = _RecordingPlaceRepository(
        imageUrl: 'https://example.com/place.png?signature=old',
      );
      final container = ProviderContainer(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final provider = placeFormControllerProvider('place-1');
      final subscription = container.listen(provider, (previous, next) {});
      addTearDown(subscription.close);
      await container.read(remotePlaceFormEditInfoProvider('place-1').future);
      await container.pump();
      final controller = container.read(provider.notifier);

      controller.updateName('루프탑');
      expect(await controller.submit(), isNull);
      controller.updateAddress('서울시 강남구');
      expect(await controller.submit(), isNull);

      expect(repository.updateCalls, 0);
      final state = container.read(provider);
      expect(state.submitErrorMessage, contains('기존 사진'));
      expect(state.currentName, '루프탑');
      expect(state.currentAddress, '서울시 강남구');
      expect(state.isSubmitting, isFalse);
    });
  });
}

class _RecordingPlaceRepository extends Fake implements PlaceRepository {
  _RecordingPlaceRepository({this.imageUrl});

  final String? imageUrl;
  int createCalls = 0;
  int updateCalls = 0;
  String? latestUpdateCode;
  String? latestCreateName;
  String? latestCreateAddress;
  String? latestUpdateName;
  String? latestUpdateAddress;
  String? latestUpdateImageKey;

  @override
  Future<PlaceSummary> fetchPlace(String code) async {
    return PlaceSummary(
      id: code,
      name: '거실',
      address: '서울시 성북구',
      imageUrl: imageUrl,
    );
  }

  @override
  Future<String> createPlace({
    required String name,
    required String address,
  }) async {
    createCalls++;
    latestCreateName = name;
    latestCreateAddress = address;

    return 'created-place';
  }

  @override
  Future<PlaceSummary> updatePlace({
    required String code,
    required String name,
    required String address,
    String? imageKey,
  }) async {
    updateCalls++;
    latestUpdateCode = code;
    latestUpdateName = name;
    latestUpdateAddress = address;
    latestUpdateImageKey = imageKey;

    return PlaceSummary(id: code, name: name, address: address);
  }
}
