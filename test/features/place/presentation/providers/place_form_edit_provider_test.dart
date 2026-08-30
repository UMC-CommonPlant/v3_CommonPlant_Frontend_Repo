import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_remote_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_edit_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/user_data_session.dart';

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
      expect(info?.imageUrl, isNull);
    });

    test('remote mode는 장소 상세 summary를 수정 정보로 변환한다', () async {
      final container = ProviderContainer(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          placeSummaryProvider('remote-place').overrideWith(
            (ref) async => const PlaceSummary(
              id: 'remote-place',
              name: '루프탑',
              address: '서울시 성북구',
              imageUrl: 'https://example.com/place.png',
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(placeSummaryProvider('remote-place').future);

      final info = container
          .read(placeFormEditInfoProvider('remote-place'))
          .requireValue;

      expect(info?.id, 'remote-place');
      expect(info?.name, '루프탑');
      expect(info?.address, '서울시 성북구');
      expect(info?.imageUrl, 'https://example.com/place.png');
    });

    test('remote mode에서 빈 summary는 null data로 표시한다', () async {
      final container = ProviderContainer(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          placeSummaryProvider('empty-place').overrideWith(
            (ref) async => const PlaceSummary(id: 'empty-place', name: ''),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(placeSummaryProvider('empty-place').future);

      expect(
        container.read(placeFormEditInfoProvider('empty-place')).requireValue,
        isNull,
      );
    });
  });
}
