import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/fixtures/address_search_fixture.dart';
import 'package:commonplant_frontend/features/place/presentation/models/address_search_result.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_remote_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_state.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/user_data_session.dart';

void main() {
  group('PlaceFormController', () {
    for (final isEdit in [false, true]) {
      for (final fails in [false, true]) {
        test(
          '장소 ${isEdit ? '수정' : '생성'} 중 입력해도 한 번만 제출하고 ${fails ? '실패 후 재시도한다' : '이동 결과를 한 번 반환한다'}',
          () async {
            final barrier = Completer<void>();
            final repository = _RecordingPlaceRepository()
              ..writeBarrier = barrier;
            final container = ProviderContainer(
              overrides: [
                authenticatedUserDataSession,
                useRemoteApiProvider.overrideWithValue(true),
                placeRepositoryProvider.overrideWithValue(repository),
              ],
            );
            addTearDown(container.dispose);
            final provider = placeFormControllerProvider(
              isEdit ? 'place-1' : null,
            );
            container.listen(provider, (_, _) {});
            if (isEdit) {
              await container.read(placeSummaryProvider('place-1').future);
              await container.pump();
            }
            final controller = container.read(provider.notifier);
            controller.updateName('첫 제출');
            controller.updateAddress('서울시 성북구');
            final first = controller.submit();
            final duplicates = <Future<PlaceFormSubmitResult?>>[];
            final pendingStates = <PlaceFormState>[];

            for (final edit in <void Function()>[
              () => controller.updateName('다음 제출'),
              () => controller.updateAddress('서울시 강남구'),
              controller.clearAddress,
            ]) {
              edit();
              pendingStates.add(container.read(provider));
              duplicates.add(controller.submit());
            }
            await controller.applyAddressSelection(
              Future.value(_serviceAddress),
            );
            pendingStates.add(container.read(provider));
            duplicates.add(controller.submit());
            if (fails) {
              barrier.completeError(StateError('첫 요청 실패'));
            } else {
              barrier.complete();
            }
            final results = await Future.wait([first, ...duplicates]);

            expect(pendingStates.every((state) => state.isSubmitting), isTrue);
            expect(pendingStates.every((state) => !state.canSubmit), isTrue);
            expect(pendingStates.last.currentName, '다음 제출');
            expect(pendingStates.last.currentAddress, '서울시 종로구');
            expect(isEdit ? repository.updateCalls : repository.createCalls, 1);
            expect(
              isEdit
                  ? repository.latestUpdateName
                  : repository.latestCreateName,
              '첫 제출',
            );
            expect(
              isEdit
                  ? repository.latestUpdateAddress
                  : repository.latestCreateAddress,
              '서울시 성북구',
            );
            expect(results.skip(1), everyElement(isNull));
            if (!fails) {
              expect(
                results.first?.destination,
                isEdit
                    ? PlaceFormSubmitDestination.home
                    : PlaceFormSubmitDestination.friendAdd,
              );
              return;
            }

            expect(results.first, isNull);
            expect(
              container.read(provider).submitState.errorMessage,
              isNotNull,
            );
            expect(container.read(provider).canSubmit, isTrue);
            repository.writeBarrier = null;
            expect(await controller.submit(), isNotNull);
            expect(isEdit ? repository.updateCalls : repository.createCalls, 2);
            expect(
              isEdit
                  ? repository.latestUpdateName
                  : repository.latestCreateName,
              '다음 제출',
            );
            expect(
              isEdit
                  ? repository.latestUpdateAddress
                  : repository.latestCreateAddress,
              '서울시 종로구',
            );
          },
        );
      }
    }

    for (final isRemote in [false, true]) {
      test('샘플 주소는 ${isRemote ? 'API 폼에 반영하지 않는다' : '로컬 폼에 반영한다'}', () async {
        final container = ProviderContainer(
          overrides: [
            authenticatedUserDataSession,
            useRemoteApiProvider.overrideWithValue(isRemote),
          ],
        );
        addTearDown(container.dispose);
        final provider = placeFormControllerProvider(null);
        container.listen(provider, (_, _) {});
        final controller = container.read(provider.notifier);
        controller.updateAddress('기존 주소');

        await controller.applyAddressSelection(
          Future.value(addressSearchFixture.first),
        );

        expect(
          container.read(provider).currentAddress,
          isRemote ? '기존 주소' : addressSearchFixture.first.address,
        );
      });
    }

    for (final result in <AddressSearchResult?>[
      null,
      const AddressSearchResult(
        titlePrefix: '',
        titleSuffix: '',
        address: '   ',
        source: AddressSearchResultSource.searchService,
      ),
    ]) {
      test('${result == null ? '취소' : '빈 주소'}는 폼 상태를 그대로 유지한다', () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final provider = placeFormControllerProvider(null);
        container.listen(provider, (_, _) {});
        final controller = container.read(provider.notifier);
        controller.updateName('거실');
        controller.updateAddress('기존 주소');
        final before = container.read(provider);

        await controller.applyAddressSelection(Future.value(result));

        expect(container.read(provider), same(before));
      });
    }

    test('폐기된 폼에서 기다리던 주소 결과는 새 폼에 반영하지 않는다', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final provider = placeFormControllerProvider(null);
      final subscription = container.listen(provider, (_, _) {});
      final selection = Completer<AddressSearchResult?>();
      final pending = container
          .read(provider.notifier)
          .applyAddressSelection(selection.future);
      subscription.close();
      await container.pump();
      container.listen(provider, (_, _) {});
      container.read(provider.notifier).updateAddress('새 폼 주소');

      selection.complete(_serviceAddress);
      await pending;

      expect(container.read(provider).currentAddress, '새 폼 주소');
    });

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

    test('remote 검증 오류는 이름과 주소 필드에 연결하고 입력 시 초기화한다', () async {
      final repository = _RecordingPlaceRepository()
        ..writeError = const ApiException(
          message: '요청 값이 유효하지 않습니다.',
          statusCode: 400,
          code: 'C001',
          kind: ApiFailureKind.validation,
          fieldErrors: [
            ApiFieldError(field: 'request.name', reason: '이름 오류'),
            ApiFieldError(field: 'address', reason: '주소 오류'),
          ],
        );
      final container = ProviderContainer(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final provider = placeFormControllerProvider(null);
      container.listen(provider, (_, _) {});
      final controller = container.read(provider.notifier);
      controller.updateName('거실');
      controller.updateAddress('서울시 성북구');

      expect(await controller.submit(), isNull);

      final failed = container.read(provider);
      expect(failed.submitState.errorMessage, '입력 내용을 확인해 주세요.');
      expect(failed.nameErrorMessage, '이름 오류');
      expect(failed.addressErrorMessage, '주소 오류');

      controller.updateName('새 이름');
      final edited = container.read(provider);
      expect(edited.submitState.errorMessage, isNull);
      expect(edited.nameErrorMessage, isNull);
      expect(edited.addressErrorMessage, isNull);
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

      await container.read(placeSummaryProvider('place-1').future);
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

    test('remote 장소 수정 정보 실패는 원본 summary를 다시 조회한다', () async {
      final repository = _RetryPlaceRepository();
      final container = ProviderContainer(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final provider = placeFormControllerProvider('retry-place');
      final subscription = container.listen(provider, (previous, next) {});
      addTearDown(subscription.close);

      await expectLater(
        container.read(placeSummaryProvider('retry-place').future),
        throwsStateError,
      );
      await container.pump();

      expect(container.read(provider).loadStatus, PlaceFormLoadStatus.failure);

      container.read(provider.notifier).retryLoad();
      await container.read(placeSummaryProvider('retry-place').future);
      await container.pump();

      final state = container.read(provider);
      expect(repository.fetchCalls, 2);
      expect(state.loadStatus, PlaceFormLoadStatus.ready);
      expect(state.currentName, '루프탑');
      expect(state.currentAddress, '서울시 성북구');
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
      await container.read(placeSummaryProvider('place-1').future);
      await container.pump();
      final controller = container.read(provider.notifier);

      controller.updateName('루프탑');
      expect(await controller.submit(), isNull);
      await controller.applyAddressSelection(Future.value(_serviceAddress));
      expect(await controller.submit(), isNull);

      expect(repository.updateCalls, 0);
      final state = container.read(provider);
      expect(state.submitState.errorMessage, contains('기존 사진'));
      expect(state.currentName, '루프탑');
      expect(state.currentAddress, _serviceAddress.address);
      expect(state.isSubmitting, isFalse);
    });
  });
}

class _RecordingPlaceRepository extends Fake implements PlaceRepository {
  _RecordingPlaceRepository({this.imageUrl});

  final String? imageUrl;
  Completer<void>? writeBarrier;
  Object? writeError;
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

    await writeBarrier?.future;
    if (writeError != null) throw writeError!;

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

    await writeBarrier?.future;
    if (writeError != null) throw writeError!;

    return PlaceSummary(id: code, name: name, address: address);
  }
}

class _RetryPlaceRepository extends Fake implements PlaceRepository {
  int fetchCalls = 0;

  @override
  Future<PlaceSummary> fetchPlace(String code) async {
    fetchCalls++;
    if (fetchCalls == 1) {
      throw StateError('첫 조회 실패');
    }

    return PlaceSummary(id: code, name: '루프탑', address: '서울시 성북구');
  }
}

// 외부 검색 연동 없이 반환 계약만 검증하는 테스트 전용 결과.
const _serviceAddress = AddressSearchResult(
  titlePrefix: '테스트',
  titleSuffix: '주소',
  address: '서울시 종로구',
  source: AddressSearchResultSource.searchService,
);
