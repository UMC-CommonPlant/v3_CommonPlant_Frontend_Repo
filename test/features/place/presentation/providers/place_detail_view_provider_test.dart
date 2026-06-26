import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/data/datasources/place_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_detail_role.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_view_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('placeDetailViewProvider', () {
    test('local mode는 fixture 상세를 즉시 반환한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(
        placeDetailViewProvider((
          placeId: 'place-1',
          role: PlaceDetailRole.member,
        )),
      );

      final detail = state.requireValue;
      expect(detail?.name, '스윗 홈_거실');
      expect(detail?.role, PlaceDetailRole.member);
    });

    test('remote mode는 summary를 fixture 상세에 병합한다', () async {
      final repository = _StaticPlaceRepository(
        const PlaceSummary(
          id: 'remote-place',
          name: '옥상 정원',
          address: '서울시 노원구 광운로 20',
        ),
      );
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final request = (placeId: 'remote-place', role: PlaceDetailRole.leader);
      await container.read(remotePlaceDetailViewProvider(request).future);

      final detail = container
          .read(placeDetailViewProvider(request))
          .requireValue;

      expect(detail?.name, '옥상 정원');
      expect(detail?.address, '서울시 노원구 광운로 20');
      expect(detail?.role, PlaceDetailRole.leader);
      expect(repository.fetchCalls, 1);
    });

    test('remote mode에서 빈 summary는 null data로 표시한다', () async {
      final repository = _StaticPlaceRepository(
        const PlaceSummary(id: 'empty-place', name: ''),
      );
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final request = (placeId: 'empty-place', role: null);
      await container.read(remotePlaceDetailViewProvider(request).future);

      expect(
        container.read(placeDetailViewProvider(request)).requireValue,
        isNull,
      );
    });
  });
}

class _StaticPlaceRepository extends PlaceRepository {
  _StaticPlaceRepository(this.summary) : super(PlaceRemoteDataSource(Dio()));

  final PlaceSummary summary;
  int fetchCalls = 0;

  @override
  Future<PlaceSummary> fetchPlace(String code) async {
    fetchCalls++;
    return summary;
  }
}
