import 'package:commonplant_frontend/features/place/data/dtos/place_requests.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreatePlaceRequest', () {
    test('Swagger required 필드인 name과 address를 JSON으로 직렬화한다', () {
      final request = CreatePlaceRequest(name: '정원', address: '서울특별시');

      expect(request.toJson(), {'name': '정원', 'address': '서울특별시'});
    });
  });
}
