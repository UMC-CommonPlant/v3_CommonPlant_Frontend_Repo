import 'package:commonplant_frontend/app/common_plant_app.dart';
import 'package:commonplant_frontend/app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Widget buildPageTestApp(Widget home) {
  return ProviderScope(child: MaterialApp(home: home));
}

Widget buildCommonPlantRouterTestApp(GoRouter router) {
  return ProviderScope(
    overrides: [appRouterProvider.overrideWithValue(router)],
    child: const CommonPlantApp(),
  );
}
