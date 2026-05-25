import 'package:commonplant_frontend/features/friend/data/dtos/friend_requests.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SendFriendRequest', () {
    test('receiverName 배열과 placeCode를 JSON으로 직렬화한다', () {
      final request = SendFriendRequest(
        receiverNames: const ['커먼2', '커먼3'],
        placeCode: 'aBcDeF',
      );

      expect(request.toJson(), {
        'receiverName': ['커먼2', '커먼3'],
        'placeCode': 'aBcDeF',
      });
    });
  });

  group('FriendDecisionRequest', () {
    test('friendId를 JSON으로 직렬화한다', () {
      const request = FriendDecisionRequest(friendId: 1);

      expect(request.toJson(), {'friendId': 1});
    });
  });
}
