import 'package:commonplant_frontend/core/network/api_response_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('jsonListFromResponse', () {
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
