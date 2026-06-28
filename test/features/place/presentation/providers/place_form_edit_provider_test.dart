import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/data/datasources/place_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_edit_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('placeFormEditInfoProvider', () {
    test('local mode는 기본 수정 정보를 즉시 반환한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(placeFormEditInfoProvider('place-1'));

      final info = state.requireValue;
      expect(info?.id, 'place-1');
      expect(info?.name, '스윗 홈_ 거실');
      expect(info?.address, isNull);
    });

    test('remote mode는 장소 상세 summary를 수정 정보로 변환한다', () async {
      final repository = _StaticPlaceRepository(
        const PlaceSummary(id: 'remote-place', name: '루프탑', address: '서울시 성북구'),
      );
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(
        remotePlaceFormEditInfoProvider('remote-place').future,
      );

      final info = container
          .read(placeFormEditInfoProvider('remote-place'))
          .requireValue;

      expect(info?.id, 'remote-place');
      expect(info?.name, '루프탑');
      expect(info?.address, '서울시 성북구');
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

      await container.read(
        remotePlaceFormEditInfoProvider('empty-place').future,
      );

      expect(
        container.read(placeFormEditInfoProvider('empty-place')).requireValue,
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
