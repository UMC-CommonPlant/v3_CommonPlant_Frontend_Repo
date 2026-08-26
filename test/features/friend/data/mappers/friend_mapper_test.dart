import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/features/friend/data/mappers/friend_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('friendInvitationsFromResponse', () {
    test('백엔드 requests wrapper를 친구 요청 목록으로 만든다', () {
      final invitations = friendInvitationsFromResponse({
        'result': {
          'requests': [
            {
              'friendId': 41,
              'senderName': '커먼맘',
              'senderImgUrl': 'https://example.com/profile.png',
              'placeCode': 'place-code',
              'placeName': '거실 정원',
              'placeAddress': '서울시 노원구',
              'status': 'PENDING',
            },
          ],
        },
      });

      expect(invitations, hasLength(1));
      expect(invitations.single.id, 41);
      expect(invitations.single.senderName, '커먼맘');
      expect(
        invitations.single.senderImageUrl,
        'https://example.com/profile.png',
      );
      expect(invitations.single.placeCode, 'place-code');
      expect(invitations.single.placeName, '거실 정원');
      expect(invitations.single.placeAddress, '서울시 노원구');
      expect(invitations.single.status, 'PENDING');
    });

    test('requests가 비어 있으면 빈 목록을 반환한다', () {
      final invitations = friendInvitationsFromResponse({
        'result': {'requests': <Object?>[]},
      });

      expect(invitations, isEmpty);
    });

    test('요청 항목에 요청 PK가 없으면 ApiException을 던진다', () {
      expect(
        () => friendInvitationsFromResponse({
          'result': {
            'requests': [
              {
                'senderName': '커먼맘',
                'placeCode': 'place-code',
                'placeName': '거실 정원',
                'placeAddress': '서울시 노원구',
                'status': 'PENDING',
              },
            ],
          },
        }),
        throwsA(isA<ApiException>()),
      );
    });

    test('requests가 목록이 아니면 ApiException을 던진다', () {
      expect(
        () => friendInvitationsFromResponse({
          'result': {'requests': 'invalid'},
        }),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
