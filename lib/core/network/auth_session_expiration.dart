import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef AuthSessionExpirationHandler =
    Future<void> Function(UserDataSession session);

final authSessionExpirationHandlerProvider =
    Provider<AuthSessionExpirationHandler?>((ref) => null);
