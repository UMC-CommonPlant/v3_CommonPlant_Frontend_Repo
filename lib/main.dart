import 'package:commonplant_frontend/app/common_plant_app.dart';
import 'package:commonplant_frontend/core/network/auth_session_expiration.dart';
import 'package:commonplant_frontend/features/image/data/gateways/image_selection_gateway.dart';
import 'package:commonplant_frontend/features/login/data/gateways/social_auth_credential_gateway.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeSocialAuthSdks();
  await discardOrphanedImageSelection();
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
