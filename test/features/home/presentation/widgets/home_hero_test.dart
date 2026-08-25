import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/home/presentation/widgets/home_hero.dart';
import 'package:commonplant_frontend/features/user/data/repositories/user_repository.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home hero에 현재 사용자 이름을 표시한다', (tester) async {
    final repository = _StaticUserRepository(
      const UserProfile(id: 'user-232', name: '새싹집사'),
    );

    await tester.pumpWidget(_buildHero(repository));
    await tester.pumpAndSettle();

    expect(find.text('새싹집사'), findsOneWidget);
    expect(repository.fetchMeCalls, 1);
  });

  testWidgets('현재 사용자 조회 중 loading 상태를 표시한다', (tester) async {
    final repository = _PendingUserRepository();

    await tester.pumpWidget(_buildHero(repository));
    await tester.pump();

    expect(find.bySemanticsLabel('사용자 정보 불러오는 중'), findsOneWidget);
    repository.complete(const UserProfile(id: 'user-232', name: '새싹집사'));
    await tester.pumpAndSettle();
  });

  testWidgets('현재 사용자 조회 오류에서 재시도하여 복구한다', (tester) async {
    final repository = _RetryUserRepository();

    await tester.pumpWidget(_buildHero(repository, width: 320));
    await tester.pumpAndSettle();

    expect(find.text('사용자 정보를 불러오지 못했어요'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(find.text('재시도 사용자'), findsOneWidget);
    expect(repository.fetchMeCalls, 2);
  });
}

Widget _buildHero(UserRepository repository, {double width = 375}) {
  return ProviderScope(
    overrides: [
      useRemoteApiProvider.overrideWithValue(true),
      userRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          height: 220,
          child: const HomeHero(topInset: 0, contentHeight: 200),
        ),
      ),
    ),
  );
}

class _StaticUserRepository extends Fake implements UserRepository {
  _StaticUserRepository(this.user);

  final UserProfile user;
  int fetchMeCalls = 0;

  @override
  Future<UserProfile> fetchMe() async {
    fetchMeCalls++;
    return user;
  }
}

class _PendingUserRepository extends Fake implements UserRepository {
  final Completer<UserProfile> _completer = Completer<UserProfile>();

  void complete(UserProfile user) => _completer.complete(user);

  @override
  Future<UserProfile> fetchMe() => _completer.future;
}

class _RetryUserRepository extends Fake implements UserRepository {
  int fetchMeCalls = 0;

  @override
  Future<UserProfile> fetchMe() async {
    fetchMeCalls++;
    if (fetchMeCalls == 1) {
      throw StateError('첫 조회 실패');
    }

    return const UserProfile(id: 'user-232', name: '재시도 사용자');
  }
}
