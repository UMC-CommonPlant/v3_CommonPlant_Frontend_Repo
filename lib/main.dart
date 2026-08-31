import 'package:commonplant_frontend/app/common_plant_app.dart';
import 'package:commonplant_frontend/core/network/auth_session_expiration.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        authSessionExpirationHandlerProvider.overrideWith(
          (ref) =>
              (session) => ref
                  .read(authSessionControllerProvider.notifier)
                  .expireSession(session),
        ),
      ],
      child: const CommonPlantApp(),
    ),
  );
}
