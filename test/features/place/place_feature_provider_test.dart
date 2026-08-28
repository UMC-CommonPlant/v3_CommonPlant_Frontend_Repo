import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_feature_provider.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/user_data_session.dart';

void main() {
  group('userPlaceSummariesProvider', () {
    test('remote mode는 소속 장소 조회를 repository에 위임한다', () async {
      final repository = _StaticPlaceRepository([
        const PlaceSummary(id: 'place-1', name: '거실'),
        const PlaceSummary(id: 'place-2', name: '작업실'),
      ]);
      final container = ProviderContainer(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final places = await container.read(userPlaceSummariesProvider.future);

      expect([for (final place in places) place.name], ['거실', '작업실']);
      expect(repository.fetchUserPlacesCalls, 1);
    });
  });
}

class _StaticPlaceRepository extends Fake implements PlaceRepository {
  _StaticPlaceRepository(this.places);

  final List<PlaceSummary> places;
  int fetchUserPlacesCalls = 0;

  @override
  Future<List<PlaceSummary>> fetchUserPlaces() async {
    fetchUserPlacesCalls++;
    return places;
  }
}
