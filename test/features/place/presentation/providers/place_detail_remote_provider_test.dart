import 'package:commonplant_frontend/features/place/domain/entities/place_detail.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_remote_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/user_data_session.dart';

void main() {
  group('placeDetailProvider', () {
    test('장소 상세 조회를 repository에 위임한다', () async {
      final repository = _StaticPlaceRepository(
        const PlaceDetail(
          code: 'place-1',
          name: '거실',
          address: '서울시 성북구',
          isOwner: true,
          members: [],
          plants: [],
        ),
      );
      final container = ProviderContainer(
        overrides: [
          authenticatedUserDataSession,
          placeRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final detail = await container.read(
        placeDetailProvider('place-1').future,
      );

      expect(detail.code, 'place-1');
      expect(detail.name, '거실');
      expect(detail.address, '서울시 성북구');
      expect(repository.lastCode, 'place-1');
    });
  });

  group('placeSummaryProvider', () {
    test('장소 수정용 summary 조회를 repository에 위임한다', () async {
      final repository = _StaticPlaceSummaryRepository(
        const PlaceSummary(id: 'place-2', name: '루프탑', address: '서울시 성북구'),
      );
      final container = ProviderContainer(
        overrides: [
          authenticatedUserDataSession,
          placeRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final summary = await container.read(
        placeSummaryProvider('place-2').future,
      );

      expect(summary.id, 'place-2');
      expect(summary.name, '루프탑');
      expect(summary.address, '서울시 성북구');
      expect(repository.lastCode, 'place-2');
    });
  });
}

class _StaticPlaceRepository extends Fake implements PlaceRepository {
  _StaticPlaceRepository(this.detail);

  final PlaceDetail detail;
  String? lastCode;

  @override
  Future<PlaceDetail> fetchPlaceDetail(String code) async {
    lastCode = code;
    return detail;
  }
}

class _StaticPlaceSummaryRepository extends Fake implements PlaceRepository {
  _StaticPlaceSummaryRepository(this.summary);

  final PlaceSummary summary;
  String? lastCode;

  @override
  Future<PlaceSummary> fetchPlace(String code) async {
    lastCode = code;
    return summary;
  }
}
