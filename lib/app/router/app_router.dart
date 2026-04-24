import 'package:commonplant_frontend/app/router/app_routes.dart';
import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) => createAppRouter());

GoRouter createAppRouter({String initialLocation = AppRoutePaths.home}) {
  return GoRouter(initialLocation: initialLocation, routes: buildAppRoutes());
}
