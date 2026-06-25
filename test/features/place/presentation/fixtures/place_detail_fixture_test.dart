import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/presentation/fixtures/place_detail_fixture.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_detail_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('placeDetailFixture', () {
    test('placeId와 명시 role로 local 상세 데이터를 만든다', () {
      final leaderDetail = placeDetailFixture(
        'place-1',
        role: PlaceDetailRole.leader,
      );
      final memberDetail = placeDetailFixture('team-place');

      expect(leaderDetail.role, PlaceDetailRole.leader);
      expect(leaderDetail.name, '스윗 홈_거실');
      expect(leaderDetail.address, '서울시 노원구 광운로 20');
      expect(leaderDetail.friends.map((friend) => friend.name), [
        '나',
        '커먼맘',
        '커먼 파파',
      ]);
      expect(leaderDetail.plants, hasLength(4));
      expect(leaderDetail.plants.first.canWater, isTrue);
      expect(memberDetail.role, PlaceDetailRole.member);
    });

    test('remote summary를 적용해도 fixture 보조 정보는 유지한다', () {
      final detail = placeDetailFixture('place-1').applySummary(
        const PlaceSummary(
          id: 'remote-place',
          name: '옥상 정원',
          address: '서울시 성북구',
        ),
      );

      expect(detail.name, '옥상 정원');
      expect(detail.address, '서울시 성북구');
      expect(detail.sunlightLabel, '9.3 / 5');
      expect(detail.humidityLabel, '69%');
      expect(detail.friends, hasLength(3));
      expect(detail.plants, hasLength(4));
    });
  });
}
