import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/presentation/fixtures/place_detail_fixture.dart';
import 'package:commonplant_frontend/features/place/presentation/mappers/place_detail_view_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('remote summary를 ViewData에 적용하고 fallback 보조 정보는 유지한다', () {
    final detail = mapPlaceSummaryToDetailViewData(
      fallback: placeDetailFixture('place-1'),
      summary: const PlaceSummary(
        id: 'remote-place',
        name: '옥상 정원',
        address: '서울시 성북구',
      ),
    );

    expect(detail?.name, '옥상 정원');
    expect(detail?.address, '서울시 성북구');
    expect(detail?.sunlightLabel, '9.3 / 5');
    expect(detail?.humidityLabel, '69%');
    expect(detail?.friends, hasLength(3));
    expect(detail?.plants, hasLength(4));
  });
}
