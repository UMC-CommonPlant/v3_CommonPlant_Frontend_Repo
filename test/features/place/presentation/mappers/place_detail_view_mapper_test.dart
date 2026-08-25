import 'package:commonplant_frontend/features/place/domain/entities/place_detail.dart';
import 'package:commonplant_frontend/features/place/presentation/mappers/place_detail_view_mapper.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_detail_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('remote 상세를 fixture 없이 ViewData로 변환한다', () {
    final detail = mapPlaceDetailToViewData(
      const PlaceDetail(
        code: 'remote-place',
        name: '옥상 정원',
        address: '서울시 성북구',
        isOwner: true,
        members: [
          PlaceMember(name: '커먼맘', imageUrl: 'https://example.com/user.png'),
        ],
        plants: [
          PlacePlant(
            id: '1',
            scientificNameKo: '몬스테라',
            scientificNameEn: 'Monstera deliciosa',
            registeredAt: '2026-06-30T16:55:51',
            lastWateredDate: '2026-06-29',
            imageUrl: 'https://example.com/plant.png',
            memo: '새 잎',
          ),
        ],
      ),
    );

    expect(detail?.name, '옥상 정원');
    expect(detail?.address, '서울시 성북구');
    expect(detail?.role, PlaceDetailRole.leader);
    expect(detail?.sunlightLabel, isNull);
    expect(detail?.humidityLabel, isNull);
    expect(detail?.friends.single.name, '커먼맘');
    expect(detail?.friends.single.imageUrl, 'https://example.com/user.png');
    expect(detail?.plants.single.name, '몬스테라');
    expect(detail?.plants.single.species, 'Monstera deliciosa');
    expect(detail?.plants.single.description, '새 잎');
    expect(detail?.plants.single.dDayLabel, '마지막 물주기');
    expect(detail?.plants.single.dateLabel, '2026.06.29');
    expect(detail?.plants.single.imageUrl, 'https://example.com/plant.png');
  });
}
