import 'package:commonplant_frontend/app/router/app_router.dart';
import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_viewport.dart';

void main() {
  final locations = <String>[
    AppRoutePaths.home,
    AppRoutePaths.onboarding,
    AppRoutePaths.login,
    AppRoutePaths.profileSetup,
    AppRoutePaths.terms,
    AppRoutePaths.placeInvitations,
    AppRoutePaths.placeCreate,
    AppRoutePaths.addressSearch,
    AppRoutePaths.placeFriendAdd,
    AppRoutePaths.placeEditLocation('place-1'),
    AppRoutePaths.friendManagementLocation('place-1'),
    AppRoutePaths.placeDetailLocation('place-1'),
    AppRoutePaths.plantSearch,
    AppRoutePaths.plantCreateDetails,
    AppRoutePaths.plantEditLocation('plant-1'),
    AppRoutePaths.memoWriteLocation('plant-1'),
    AppRoutePaths.memoListLocation('plant-1'),
    AppRoutePaths.plantDetailLocation('plant-1'),
    AppRoutePaths.userProfile,
    AppRoutePaths.userSettings,
    AppRoutePaths.userProfileEdit,
  ];
  for (final viewport in const [
    Size(320, 720),
    Size(600, 800),
    Size(720, 720),
    Size(884, 812),
    Size(812, 375),
    Size(560, 320),
  ]) {
    testWidgets('전체 화면이 가용 창에서 overflow 없이 열린다 ($viewport)', (tester) async {
      configureTestViewport(tester, viewport);
      final failures = <String>[];
      for (final location in locations) {
        final router = createAppRouter(initialLocation: location);
        await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
        await tester.pumpAndSettle();
        Object? error;
        while ((error = tester.takeException()) != null) {
          failures.add('$location: $error');
        }
        await tester.pumpWidget(const SizedBox.shrink());
        router.dispose();
      }
      expect(failures, isEmpty, reason: 'logical viewport $viewport');
    });
  }
}
