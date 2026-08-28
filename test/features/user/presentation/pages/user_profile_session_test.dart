import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/user/data/repositories/user_repository.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:commonplant_frontend/features/user/presentation/pages/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_viewport.dart';
import '../../../../helpers/user_data_session.dart';

void main() {
  testWidgets('B의 조회 로딩·실패·재시도 동안 A의 회원 정보를 표시하지 않는다', (tester) async {
    configureTestViewport(tester, TestViewports.reference);
    final repository = _ProfileRepository();
    final container = ProviderContainer(
      overrides: [
        authenticatedUserDataSession,
        useRemoteApiProvider.overrideWithValue(true),
        userRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: UserProfilePage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('계정 A'), findsOneWidget);
    expect(find.text('a@example.test'), findsOneWidget);

    final responseB = Completer<UserProfile>();
    repository.next = responseB;
    container.read(userDataSessionProvider.notifier).start();
    await tester.pump();

    expect(find.text('계정 A'), findsNothing);
    expect(find.text('a@example.test'), findsNothing);
    expect(find.text('회원 정보를 불러오고 있어요'), findsOneWidget);
    responseB.completeError(StateError('B 조회 실패'));
    await tester.pumpAndSettle();
    expect(find.text('회원 정보를 불러오지 못했어요'), findsOneWidget);
    expect(find.text('계정 A'), findsNothing);

    repository
      ..next = null
      ..user = const UserProfile(
        id: 'B',
        name: '계정 B',
        email: 'b@example.test',
      );
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();
    expect(find.text('계정 B'), findsOneWidget);
    expect(find.text('b@example.test'), findsOneWidget);
    expect(find.text('계정 A'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _ProfileRepository extends Fake implements UserRepository {
  UserProfile user = const UserProfile(
    id: 'A',
    name: '계정 A',
    email: 'a@example.test',
  );
  Completer<UserProfile>? next;

  @override
  Future<UserProfile> fetchMe() async => next?.future ?? user;
}
