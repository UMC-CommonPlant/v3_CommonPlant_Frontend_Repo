import 'dart:async';

import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/user/data/dtos/user_requests.dart';
import 'package:commonplant_frontend/features/user/data/repositories/user_repository.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:commonplant_frontend/features/user/presentation/pages/user_profile_edit_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/test_viewport.dart';
import '../../../../helpers/user_data_session.dart';

void main() {
  for (final viewport in [
    TestViewports.reference,
    TestViewports.compactWidth,
    TestViewports.shortHeight,
  ]) {
    testWidgets('회원정보 수정 중 재탭을 막고 실패 후 새 이름으로 재시도한다 ($viewport)', (
      tester,
    ) async {
      configureTestViewport(tester, viewport);
      final repository = _RetryUserRepository();
      final router = GoRouter(
        initialLocation: AppRoutePaths.userProfileEdit,
        routes: [
          GoRoute(
            path: AppRoutePaths.userProfileEdit,
            builder: (context, state) => const UserProfileEditPage(),
          ),
          GoRoute(
            path: AppRoutePaths.userProfile,
            builder: (context, state) => const Text('프로필 도착'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authenticatedUserDataSession,
            useRemoteApiProvider.overrideWithValue(true),
            userRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '첫 제출');
      await tester.pump();
      final button = find.widgetWithText(FilledButton, '수정 완료');
      final repeatSubmit = tester.widget<FilledButton>(button).onPressed!;
      await tester.tap(button);
      await tester.pump();
      await tester.enterText(find.byType(TextField), '다음 제출');
      await tester.pump();
      repeatSubmit();
      await tester.pump();

      expect(repository.names, ['첫 제출']);
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('다음 제출'), findsOneWidget);
      expect(find.text('프로필 도착'), findsNothing);

      repository.firstResponse.completeError(StateError('첫 요청 실패'));
      await tester.pumpAndSettle();
      expect(find.text('회원 정보를 수정하지 못했어요'), findsOneWidget);
      expect(find.text('다음 제출'), findsOneWidget);
      expect(tester.widget<FilledButton>(button).onPressed, isNotNull);

      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(repository.names, ['첫 제출', '다음 제출']);
      expect(find.text('프로필 도착'), findsOneWidget);
      expect(find.byType(UserProfileEditPage), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}

class _RetryUserRepository extends Fake implements UserRepository {
  static const _user = UserProfile(id: 'user-250', name: '초록집사');
  final firstResponse = Completer<UserProfile>();
  final names = <String?>[];

  @override
  Future<UserProfile> fetchMe() async => _user;

  @override
  Future<UserProfile> updateMe(
    UpdateUserRequest request, {
    MultipartFile? image,
  }) async {
    names.add(request.name);
    if (names.length == 1) return firstResponse.future;
    return _user.copyWith(name: request.name);
  }
}
