import 'package:commonplant_frontend/features/place/domain/entities/place_detail.dart';
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
