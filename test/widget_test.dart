import 'dart:io';

import 'package:commonplant_frontend/app/common_plant_app.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/features/home/presentation/home_screen.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('앱이 초기 홈 화면을 표시한다', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CommonPlantApp()));
    await tester.pumpAndSettle();

    expect(find.text('커먼(유저 네임'), findsOneWidget);
    expect(find.textContaining('한걸음에', findRichText: true), findsOneWidget);
    expect(find.text('My place'), findsOneWidget);
    expect(find.text('My plant'), findsOneWidget);
    expect(find.text('요청 3건'), findsOneWidget);
    expect(
      tester.getSize(find.bySemanticsLabel('장소 요청 3건')),
      const Size(96, 36),
    );
    expect(find.text('장소 추가하기'), findsOneWidget);
    expect(find.text('식물 추가하기'), findsOneWidget);
    expect(find.bySemanticsLabel('정원'), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.person_outline)).size,
      AppSizes.iconLarge,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CommonSvgIcon &&
            widget.assetPath == AppIconAssets.plantSelected,
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('유저 일러스트'), findsOneWidget);
  });

  testWidgets('메인 화면은 영역 배경을 full width로 두고 콘텐츠에만 내부 패딩을 적용한다', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ProviderScope(child: CommonPlantApp()));
    await tester.pumpAndSettle();

    final heroBackgroundRect = tester.getRect(find.bySemanticsLabel('메인 배경'));
    expect(heroBackgroundRect.left, 0);
    expect(heroBackgroundRect.width, 430);
    expect(
      tester.getSize(find.bySemanticsLabel('유저 일러스트')),
      const Size(88, 64),
    );

    const horizontalPadding = 20.0;
    expect(
      tester.getTopLeft(find.text('커먼(유저 네임')).dx,
      closeTo(horizontalPadding, 0.1),
    );
    expect(
      tester.getTopLeft(find.text('My place')).dx,
      closeTo(horizontalPadding, 1),
    );
  });

  testWidgets('메인 화면은 데이터가 있으면 추가 카드 대신 섹션 + 아이콘을 표시한다', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placeListProvider.overrideWith(_SeededPlaceListNotifier.new),
          plantListProvider.overrideWith(_SeededPlantListNotifier.new),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('장소 추가하기'), findsNothing);
    expect(find.text('식물 추가하기'), findsNothing);
    expect(find.text('요청 3건'), findsOneWidget);
    expect(
      tester.getSize(find.bySemanticsLabel('장소 요청 3건')),
      const Size(96, 36),
    );
    expect(find.bySemanticsLabel('장소 추가'), findsOneWidget);
    expect(find.bySemanticsLabel('식물 추가'), findsOneWidget);
    expect(tester.getSize(find.bySemanticsLabel('장소 추가')), const Size(24, 24));
    expect(tester.getSize(find.bySemanticsLabel('식물 추가')), const Size(24, 24));
    expect(find.bySemanticsLabel('몬스테라'), findsOneWidget);
  });

  test('선택된 식물 아이콘은 잎 면을 Sea Green Dark1로 채운다', () {
    final svg = File(AppIconAssets.plantSelected).readAsStringSync();

    expect(svg, contains('#00C596'));
    expect(svg, contains('fill="#00C596"'));
    expect(svg, contains('stroke="white"'));
  });
}

class _SeededPlaceListNotifier extends PlaceListNotifier {
  @override
  List<PlaceSummary> build() {
    return const [PlaceSummary(id: 'place-1', name: '옥상 정원')];
  }
}

class _SeededPlantListNotifier extends PlantListNotifier {
  @override
  List<PlantSummary> build() {
    return const [PlantSummary(id: 'plant-1', name: '몬스테라')];
  }
}
