import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/core/network/api_response_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('jsonListFromResponse', () {
    test('정상 빈 배열은 빈 목록으로 유지한다', () {
      expect(
        jsonListFromResponse({'result': <Object?>[]}, context: '목록 조회'),
        isEmpty,
      );
    });

    test('전체 항목 타입이 잘못되면 첫 번째 위치를 포함한 오류를 던진다', () {
      expect(
        () => jsonListFromResponse({
          'result': [1, 'bad'],
        }, context: '목록 조회'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            '목록 조회 응답 목록 1번째 항목이 JSON object 형식이 아닙니다.',
          ),
        ),
      );
    });

    test('정상 항목 사이의 잘못된 타입도 위치를 포함한 오류를 던진다', () {
      expect(
        () => jsonListFromResponse({
          'result': {
            'content': {
              'items': [
                {'id': 'first'},
                'bad',
                {'id': 'third'},
              ],
            },
          },
        }, context: '목록 조회'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            '목록 조회 응답 목록 2번째 항목이 JSON object 형식이 아닙니다.',
          ),
        ),
      );
    });

    test('공통 wrapper의 result.content.items 목록을 읽는다', () {
      final items = jsonListFromResponse({
        'success': true,
        'status': 200,
        'message': 'getPlants',
        'result': {
          'content': {
            'items': [
              {'plantId': 1, 'nickname': '거실 몬스테라'},
            ],
            'totalCount': 1,
            'page': 0,
            'size': 20,
          },
        },
      }, context: '식물 목록 조회');

      expect(items, hasLength(1));
      expect(items.single['plantId'], 1);
      expect(items.single['nickname'], '거실 몬스테라');
    });
  });
}
