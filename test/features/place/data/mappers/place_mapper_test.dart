import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/features/place/data/mappers/place_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('placeMembersFromResponse', () {
    test('result 배열의 가입 순서와 중복 이름을 보존한다', () {
      final members = placeMembersFromResponse({
        'result': [
          {'name': '같은 이름', 'image': 'https://example.com/member.png'},
          {'name': '같은 이름', 'image': null},
        ],
      });

      expect(members.map((member) => member.name), ['같은 이름', '같은 이름']);
      expect(members.first.imageUrl, 'https://example.com/member.png');
      expect(members.last.imageUrl, isNull);
    });

    test('빈 result 배열은 빈 멤버 목록이다', () {
      expect(placeMembersFromResponse({'result': <Object?>[]}), isEmpty);
    });

    test('result가 목록이 아니면 오류로 처리한다', () {
      expect(
        () => placeMembersFromResponse({'result': null}),
        throwsA(isA<ApiException>()),
      );
    });

    test('잘못된 항목을 조용히 누락하지 않는다', () {
      expect(
        () => placeMembersFromResponse({
          'result': ['invalid'],
        }),
        throwsA(isA<ApiException>()),
      );
      expect(
        () => placeMembersFromResponse({
          'result': [<String, Object?>{}],
        }),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('placeSummariesFromResponse', () {
    test('myGarden wrapper의 placeList를 장소 요약 목록으로 만든다', () {
      final summaries = placeSummariesFromResponse({
        'result': {
          'name': '커먼이',
          'placeList': [
            {
              'image': 'https://example.com/garden.png',
              'code': 'place-nano-id',
              'name': '거실 정원',
              'member': '2',
              'plant': '3',
            },
          ],
        },
      });

      expect(summaries, hasLength(1));
      expect(summaries.single.id, 'place-nano-id');
      expect(summaries.single.name, '거실 정원');
      expect(summaries.single.imageUrl, 'https://example.com/garden.png');
      expect(summaries.single.memberCount, 2);
      expect(summaries.single.plantCount, 3);
    });

    test('소속 장소의 result 배열도 장소 요약 목록으로 만든다', () {
      final summaries = placeSummariesFromResponse({
        'result': [
          {
            'code': 'place-2',
            'name': '작업실',
            'imgUrl': 'https://example.com/studio.png',
          },
        ],
      });

      expect(summaries.single.id, 'place-2');
      expect(summaries.single.name, '작업실');
      expect(summaries.single.imageUrl, 'https://example.com/studio.png');
    });
  });

  group('placeSummaryFromResponse', () {
    test('wrapper 응답에서 fallbackId를 보존해 장소 요약을 만든다', () {
      final summary = placeSummaryFromResponse({
        'result': {'name': '루프탑'},
      }, fallbackId: 'fallback-place');

      expect(summary.id, 'fallback-place');
      expect(summary.name, '루프탑');
    });
  });

  group('place form responses', () {
    test('장소 생성 wrapper의 result 문자열을 place code로 만든다', () {
      final code = placeCodeFromCreateResponse({'result': '  Abc123  '});

      expect(code, 'Abc123');
    });

    test('장소 생성 result가 비어 있으면 ApiException을 던진다', () {
      expect(
        () => placeCodeFromCreateResponse({'result': ''}),
        throwsA(isA<ApiException>()),
      );
    });

    test('장소 수정 wrapper를 수정된 장소 요약으로 만든다', () {
      final place = updatedPlaceFromResponse({
        'result': {
          'code': 'Abc123',
          'name': '루프탑',
          'address': '서울시 성북구',
          'imgUrl': 'https://example.com/place.png',
        },
      }, fallbackCode: 'fallback');

      expect(place.id, 'Abc123');
      expect(place.name, '루프탑');
      expect(place.address, '서울시 성북구');
      expect(place.imageUrl, 'https://example.com/place.png');
    });
  });

  group('placeSummaryFromJson', () {
    test('Swagger 장소 필드를 화면용 요약 모델로 매핑한다', () {
      final summary = placeSummaryFromJson(const <String, Object?>{
        'placeCode': 'place-nano-id',
        'placeName': '거실 정원',
        'placeAddress': '서울시 성북구',
      });

      expect(summary.id, 'place-nano-id');
      expect(summary.name, '거실 정원');
      expect(summary.address, '서울시 성북구');
    });

    test('id 필드가 없으면 fallbackId를 사용한다', () {
      final summary = placeSummaryFromJson(const <String, Object?>{
        'name': '루프탑',
      }, fallbackId: 'fallback-place');

      expect(summary.id, 'fallback-place');
      expect(summary.name, '루프탑');
    });
  });

  group('placeDetailFromResponse', () {
    test('백엔드 Place 상세 계약을 멤버와 식물까지 매핑한다', () {
      final detail = placeDetailFromResponse({
        'result': {
          'name': '거실 정원',
          'code': 'ABCabc',
          'address': '서울시 노원구',
          'imgUrl': 'https://example.com/garden.png',
          'owner': true,
          'userList': [
            {'name': '커먼맘', 'image': 'https://example.com/user.png'},
          ],
          'plantList': [
            {
              'plantId': 1,
              'scientificNameKo': '몬스테라',
              'scientificNameEn': 'Monstera deliciosa',
              'registeredAt': '2026-06-30T16:55:51.387461',
              'lastWateredDate': '2026-06-29',
              'imageUrl': 'https://example.com/plant.png',
              'memo': '새 잎이 올라옴',
              'placeName': '거실 정원',
              'plantInfo': '창가에서 키우는 식물',
            },
          ],
        },
      }, fallbackCode: 'fallback');

      expect(detail.code, 'ABCabc');
      expect(detail.name, '거실 정원');
      expect(detail.address, '서울시 노원구');
      expect(detail.isOwner, isTrue);
      expect(detail.members.single.name, '커먼맘');
      expect(detail.members.single.imageUrl, 'https://example.com/user.png');
      expect(detail.plants.single.id, '1');
      expect(detail.plants.single.scientificNameKo, '몬스테라');
      expect(detail.plants.single.lastWateredDate, '2026-06-29');
      expect(detail.plants.single.description, '창가에서 키우는 식물');
    });

    test('목록이 없는 상세 응답은 빈 멤버와 식물 목록을 사용한다', () {
      final detail = placeDetailFromResponse({
        'result': {'name': '옥상', 'address': '서울시'},
      }, fallbackCode: 'fallback');

      expect(detail.code, 'fallback');
      expect(detail.isOwner, isFalse);
      expect(detail.members, isEmpty);
      expect(detail.plants, isEmpty);
    });
  });
}
