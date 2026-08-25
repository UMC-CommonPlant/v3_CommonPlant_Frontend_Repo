import 'package:commonplant_frontend/app/router/app_route_spec.dart';
import 'package:commonplant_frontend/app/router/app_routes.dart';
import 'package:commonplant_frontend/app/router/route_parameter_error_page.dart';
import 'package:commonplant_frontend/app/router/route_parameters.dart';
import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Figma 기준 route-level screen 21개를 등록한다', () {
    expect(appRouteSpecs, hasLength(21));
    expect(appRouteSpecs.map((route) => route.name).toSet(), hasLength(21));
    expect(appRouteSpecs.map((route) => route.path).toSet(), hasLength(21));
  });

  test('필수 path parameter는 null, 빈 문자열, 공백 문자열을 허용하지 않는다', () {
    expect(
      requiredPathParameter(const {'placeId': 'place-1'}, 'placeId'),
      'place-1',
    );
    expect(requiredPathParameter(const {}, 'placeId'), isNull);
    expect(requiredPathParameter(const {'placeId': ''}, 'placeId'), isNull);
    expect(requiredPathParameter(const {'placeId': '   '}, 'placeId'), isNull);
  });

  test('선택 query parameter는 값이 있을 때 trim한 문자열을 반환한다', () {
    expect(optionalQueryParameter(const {}, 'placeId'), isNull);
    expect(optionalQueryParameter(const {'placeId': ''}, 'placeId'), isNull);
    expect(optionalQueryParameter(const {'placeId': '   '}, 'placeId'), isNull);
    expect(
      optionalQueryParameter(const {'placeId': ' place-1 '}, 'placeId'),
      'place-1',
    );
  });

  testWidgets('route parameter 오류 화면이 누락된 parameter와 route 정보를 표시한다', (
    WidgetTester tester,
  ) async {
    const route = AppRouteSpec(
      name: AppRouteNames.placeDetail,
      path: AppRoutePaths.placeDetail,
      title: '장소 상세',
      figmaFrames: ['#2-3 My place 리더화면'],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: RouteParameterErrorPage(route: route, parameterName: 'placeId'),
      ),
    );

    expect(find.text('라우트 정보를 확인할 수 없어요'), findsOneWidget);
    expect(find.text('필수 경로 값이 누락되었습니다: placeId'), findsOneWidget);
    expect(find.text('routeName: placeDetail'), findsOneWidget);
    expect(find.text('path: /places/:placeId'), findsOneWidget);
  });
}
