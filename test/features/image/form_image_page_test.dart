import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/image/data/gateways/image_selection_gateway.dart';
import 'package:commonplant_frontend/features/place/presentation/pages/place_form_page.dart';
import 'package:commonplant_frontend/features/plant/presentation/pages/plant_form_page.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:commonplant_frontend/features/user/presentation/pages/user_profile_edit_page.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/current_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/image_selection.dart';

void main() {
  for (final page in <Widget>[
    const PlaceFormPage(),
    const PlantFormPage(initialPlantName: '몬스테라'),
    const UserProfileEditPage(),
  ]) {
    testWidgets('${page.runtimeType}: 선택·교체·오류·초안 취소를 모바일 폼에 반영한다', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      var fail = false;
      final gateway = FakeImageSelectionGateway(() async {
        if (fail) throw const ImageSelectionException('다른 사진을 선택해 주세요.');
        return testSelectedImage();
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            useRemoteApiProvider.overrideWithValue(false),
            imageSelectionGatewayProvider.overrideWithValue(gateway),
            currentUserProvider.overrideWith(() => _CurrentUser()),
          ],
          child: MaterialApp(home: page),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('사진 선택'));
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
      expect(
        tester.widget<Image>(find.byType(Image)).image,
        isA<MemoryImage>(),
      );
      fail = true;
      await tester.tap(find.bySemanticsLabel('사진 교체'));
      await tester.pumpAndSettle();
      expect(find.text('다른 사진을 선택해 주세요.'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      fail = false;
      await tester.tap(find.bySemanticsLabel('사진 교체'));
      await tester.pumpAndSettle();
      expect(gateway.calls, 3);
      await tester.tap(find.text('선택 취소'));
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}

class _CurrentUser extends CurrentUserController {
  @override
  Future<UserProfile> build() async =>
      const UserProfile(id: 'user', name: '초록집사');
}
