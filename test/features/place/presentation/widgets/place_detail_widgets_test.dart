import 'package:commonplant_frontend/features/place/presentation/widgets/place_detail_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('PlaceDetailHeader는 장소 정보와 친구 관리 이동을 제공한다', (tester) async {
    await tester.pumpWidget(
      _buildRouterApp(
        PlaceDetailHeader(
          placeId: 'place-1',
          name: '옥상 정원',
          address: '서울시 노원구 광운로 20',
          sunlightLabel: '9.3 / 5',
          humidityLabel: '69%',
          friends: const [
            PlaceDetailFriendItem(id: 'me', name: '나', isOwner: true),
            PlaceDetailFriendItem(id: 'mate', name: '커먼맘'),
          ],
        ),
      ),
    );

    expect(find.text('옥상 정원'), findsOneWidget);
    expect(find.text('서울시 노원구 광운로 20'), findsOneWidget);
    expect(find.text('9.3 / 5'), findsOneWidget);
    expect(find.text('69%'), findsOneWidget);
    expect(find.text('나'), findsOneWidget);
    expect(find.text('커먼맘'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('친구 관리'));
    await tester.pumpAndSettle();

    expect(find.text('친구 관리 화면'), findsOneWidget);
  });

  testWidgets('PlacePlantList는 식물 정보를 표시하고 식물 상세로 이동한다', (tester) async {
    await tester.pumpWidget(
      _buildRouterApp(
        const PlacePlantList(
          placeId: 'place-1',
          plants: [
            PlaceDetailPlantItem(
              id: 'plant-1',
              name: '몬테',
              species: '몬스테라',
              description: '일주일에 x번 물주는 거 잊지 않기',
              dDayLabel: 'D-3',
              dateLabel: '2022.11.20',
              canWater: true,
            ),
          ],
        ),
      ),
    );

    expect(find.text('몬테'), findsOneWidget);
    expect(find.text('몬스테라'), findsOneWidget);
    expect(find.text('D-3'), findsOneWidget);
    expect(find.text('2022.11.20'), findsOneWidget);

    await tester.tap(find.text('몬테'));
    await tester.pumpAndSettle();

    expect(find.text('식물 상세 화면'), findsOneWidget);
  });

  testWidgets('PlaceDetailFab는 권한에 따라 장소 수정 액션을 표시한다', (tester) async {
    await tester.pumpWidget(
      _buildRouterApp(
        PlaceDetailFab(placeId: 'place-1', canEditPlace: false, onExit: () {}),
      ),
    );

    await tester.tap(find.bySemanticsLabel('장소 상세 메뉴'));
    await tester.pumpAndSettle();

    expect(find.text('식물 추가하기'), findsOneWidget);
    expect(find.text('장소 수정하기'), findsNothing);
    expect(find.text('장소 나가기'), findsOneWidget);
  });
}

Widget _buildRouterApp(Widget home) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(body: home),
      ),
      GoRoute(
        path: '/places/:placeId/friends',
        builder: (context, state) => const Text('친구 관리 화면'),
      ),
      GoRoute(
        path: '/plants/:plantId',
        builder: (context, state) => const Text('식물 상세 화면'),
      ),
      GoRoute(
        path: '/plants/new/search',
        builder: (context, state) => const Text('식물 검색 화면'),
      ),
      GoRoute(
        path: '/places/:placeId/edit',
        builder: (context, state) => const Text('장소 수정 화면'),
      ),
    ],
  );

  return MaterialApp.router(routerConfig: router);
}
