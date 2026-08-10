import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_remote_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('placeDetailProvider', () {
    test('장소 상세 조회를 repository에 위임한다', () async {
      final repository = _StaticPlaceRepository(
        const PlaceSummary(id: 'place-1', name: '거실', address: '서울시 성북구'),
      );
      final container = ProviderContainer(
        overrides: [placeRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final summary = await container.read(
        placeDetailProvider('place-1').future,
      );

      expect(summary.id, 'place-1');
      expect(summary.name, '거실');
      expect(summary.address, '서울시 성북구');
      expect(repository.lastCode, 'place-1');
    });
  });
}

class _StaticPlaceRepository extends Fake implements PlaceRepository {
  _StaticPlaceRepository(this.summary);

  final PlaceSummary summary;
  String? lastCode;

  @override
  Future<PlaceSummary> fetchPlace(String code) async {
    lastCode = code;
    return summary;
  }
}
