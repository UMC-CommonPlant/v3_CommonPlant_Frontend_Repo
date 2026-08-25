import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_detail.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_detail_role.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_view_provider.dart';
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

    test('remote mode는 API 상세만 ViewData로 변환한다', () async {
      final repository = _StaticPlaceRepository(
        const PlaceDetail(
          code: 'remote-place',
          name: '옥상 정원',
          address: '서울시 노원구 광운로 20',
          isOwner: false,
          members: [PlaceMember(name: '커먼맘')],
          plants: [],
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
      await container.read(placeRemoteDetailViewProvider(request).future);

      final detail = container
          .read(placeDetailViewProvider(request))
          .requireValue;

      expect(detail?.name, '옥상 정원');
      expect(detail?.address, '서울시 노원구 광운로 20');
      expect(detail?.role, PlaceDetailRole.member);
      expect(detail?.friends.single.name, '커먼맘');
      expect(detail?.plants, isEmpty);
      expect(detail?.sunlightLabel, isNull);
      expect(detail?.humidityLabel, isNull);
      expect(repository.fetchCalls, 1);
    });

    test('remote mode에서 빈 summary는 null data로 표시한다', () async {
      final repository = _StaticPlaceRepository(
        const PlaceDetail(
          code: 'empty-place',
          name: '',
          address: '',
          isOwner: false,
          members: [],
          plants: [],
        ),
      );
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final request = (placeId: 'empty-place', role: null);
      await container.read(placeRemoteDetailViewProvider(request).future);

      expect(
        container.read(placeDetailViewProvider(request)).requireValue,
        isNull,
      );
    });
  });
}

class _StaticPlaceRepository extends Fake implements PlaceRepository {
  _StaticPlaceRepository(this.detail);

  final PlaceDetail detail;
  int fetchCalls = 0;

  @override
  Future<PlaceDetail> fetchPlaceDetail(String code) async {
    fetchCalls++;
    return detail;
  }
}
