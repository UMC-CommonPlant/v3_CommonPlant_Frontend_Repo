import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_result.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_controller.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_detail.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_remote_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_place_code_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/user_data_session.dart';

void main() {
  test('장소 이름이 아니라 정확한 plant ID가 있는 장소 code를 반환한다', () async {
    final repository = _StaticPlaceRepository(
      places: const [
        PlaceSummary(id: 'place-a', name: '같은 장소명'),
        PlaceSummary(id: 'place-b', name: '같은 장소명'),
      ],
      details: {
        'place-a': _placeDetail(code: 'place-a', plantIds: ['other-plant']),
        'place-b': _placeDetail(
          code: 'canonical-place-b',
          plantIds: ['target-plant'],
        ),
      },
    );
    final container = _container(repository);
    addTearDown(container.dispose);

    final code = await container.read(
      remotePlantPlaceCodeProvider('target-plant').future,
    );

    expect(code, 'canonical-place-b');
    expect(repository.detailCodes, ['place-a', 'place-b']);
  });

  test('어느 장소에도 plant ID가 없으면 code를 추정하지 않는다', () async {
    final repository = _StaticPlaceRepository(
      places: const [PlaceSummary(id: 'place-a', name: '첫 장소')],
      details: {
        'place-a': _placeDetail(code: 'place-a', plantIds: ['other-plant']),
      },
    );
    final container = _container(repository);
    addTearDown(container.dispose);

    final code = await container.read(
      remotePlantPlaceCodeProvider('target-plant').future,
    );

    expect(code, isNull);
  });

  test('장소 상세 오류를 전달하고 원본 Provider 무효화 후 재시도한다', () async {
    final repository = _RetryPlaceRepository();
    final container = _container(repository);
    addTearDown(container.dispose);

    await expectLater(
      container.read(remotePlantPlaceCodeProvider('target-plant').future),
      throwsStateError,
    );

    container.invalidate(placeDetailProvider('place-a'));
    container.invalidate(remotePlaceListProvider);
    container.invalidate(remotePlantPlaceCodeProvider('target-plant'));

    expect(
      await container.read(remotePlantPlaceCodeProvider('target-plant').future),
      'place-a',
    );
    expect(repository.detailCalls, 2);
  });

  test('계정 전환 뒤 늦은 이전 계정 resolver 결과를 사용하지 않는다', () async {
    final repository = _DelayedAccountPlaceRepository();
    final tokenStore = _MemoryTokenStore();
    final container = ProviderContainer(
      overrides: [
        useRemoteApiProvider.overrideWithValue(true),
        authTokenStoreProvider.overrideWithValue(tokenStore),
        placeRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(repository.completeRemaining);
    await container.read(authSessionControllerProvider.future);
    container.listen(remotePlantPlaceCodeProvider('target-plant'), (_, _) {});

    container
        .read(remotePlantPlaceCodeProvider('target-plant').future)
        .ignore();
    await _waitForRequest(container, repository, 'A-place');
    expect(repository.requests.keys, contains('A-place'));

    repository.account = 'B';
    await _loginAsB(container, tokenStore);
    await _waitForRequest(container, repository, 'B-place');
    expect(repository.requests.keys, contains('B-place'));

    repository.requests['B-place']!.complete(
      _placeDetail(code: 'B-place', plantIds: ['target-plant']),
    );
    expect(
      await container.read(remotePlantPlaceCodeProvider('target-plant').future),
      'B-place',
    );

    repository.requests['A-place']!.complete(
      _placeDetail(code: 'A-place', plantIds: ['target-plant']),
    );
    await container.pump();

    expect(
      container.read(remotePlantPlaceCodeProvider('target-plant')).requireValue,
      'B-place',
    );
  });
}

Future<void> _waitForRequest(
  ProviderContainer container,
  _DelayedAccountPlaceRepository repository,
  String code,
) async {
  for (var attempt = 0; attempt < 10; attempt++) {
    await container.pump();
    if (repository.requests.containsKey(code)) {
      return;
    }
  }

  fail('$code 장소 상세 요청이 시작되지 않았습니다.');
}

ProviderContainer _container(PlaceRepository repository) {
  return ProviderContainer(
    overrides: [
      authenticatedUserDataSession,
      useRemoteApiProvider.overrideWithValue(true),
      placeRepositoryProvider.overrideWithValue(repository),
    ],
  );
}

PlaceDetail _placeDetail({
  required String code,
  required List<String> plantIds,
}) {
  return PlaceDetail(
    code: code,
    name: '같은 장소명',
    address: '주소',
    isOwner: true,
    members: const [],
    plants: [
      for (final id in plantIds) PlacePlant(id: id, scientificNameKo: '같은 식물명'),
    ],
  );
}

class _StaticPlaceRepository extends Fake implements PlaceRepository {
  _StaticPlaceRepository({required this.places, required this.details});

  final List<PlaceSummary> places;
  final Map<String, PlaceDetail> details;
  final List<String> detailCodes = [];

  @override
  Future<List<PlaceSummary>> fetchMyGardenPlaces() async => places;

  @override
  Future<PlaceDetail> fetchPlaceDetail(String code) async {
    detailCodes.add(code);
    return details[code]!;
  }
}

class _RetryPlaceRepository extends Fake implements PlaceRepository {
  int detailCalls = 0;

  @override
  Future<List<PlaceSummary>> fetchMyGardenPlaces() async {
    return const [PlaceSummary(id: 'place-a', name: '장소')];
  }

  @override
  Future<PlaceDetail> fetchPlaceDetail(String code) async {
    detailCalls++;
    if (detailCalls == 1) {
      throw StateError('장소 상세 실패');
    }
    return _placeDetail(code: code, plantIds: ['target-plant']);
  }
}

class _DelayedAccountPlaceRepository extends Fake implements PlaceRepository {
  String account = 'A';
  final Map<String, Completer<PlaceDetail>> requests = {};

  @override
  Future<List<PlaceSummary>> fetchMyGardenPlaces() async {
    return [PlaceSummary(id: '$account-place', name: account)];
  }

  @override
  Future<PlaceDetail> fetchPlaceDetail(String code) {
    final request = Completer<PlaceDetail>();
    requests[code] = request;
    return request.future;
  }

  void completeRemaining() {
    for (final entry in requests.entries) {
      if (!entry.value.isCompleted) {
        entry.value.complete(_placeDetail(code: entry.key, plantIds: const []));
      }
    }
  }
}

class _MemoryTokenStore implements AuthTokenStore {
  String? accessToken = 'access-A';
  String? refreshToken = 'refresh-A';

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
  }
}

Future<void> _loginAsB(
  ProviderContainer container,
  AuthTokenStore tokenStore,
) async {
  const result = AuthenticatedResult(
    accessToken: 'access-B',
    refreshToken: 'refresh-B',
  );
  await tokenStore.saveTokens(
    accessToken: result.accessToken,
    refreshToken: result.refreshToken,
  );
  container
      .read(authSessionControllerProvider.notifier)
      .applyAuthResult(result);
}
