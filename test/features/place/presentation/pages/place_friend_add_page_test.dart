import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/presentation/pages/place_friend_add_page.dart';
import 'package:commonplant_frontend/features/user/data/datasources/user_remote_data_source.dart';
import 'package:commonplant_frontend/features/user/data/repositories/user_repository.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('친구 추가 기본 화면은 검색 전 결과 없이 액션을 표시한다', (WidgetTester tester) async {
    await tester.pumpWidget(_friendAddApp());

    expect(find.text('친구 추가'), findsOneWidget);
    expect(find.text('건너뛰기'), findsOneWidget);
    expect(find.text('닉네임 검색'), findsOneWidget);
    expect(find.text('취소'), findsOneWidget);
    expect(find.text('완료'), findsOneWidget);
    expect(find.text('커먼맘'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('친구 닉네임 검색 후 결과를 선택할 수 있다', (WidgetTester tester) async {
    await tester.pumpWidget(_friendAddApp());

    await tester.enterText(find.byType(TextField), '커먼');
    await tester.pumpAndSettle();

    expect(find.text('커먼맘'), findsOneWidget);
    expect(find.text('커먼인척'), findsOneWidget);
    expect(find.text('커먼일뻔'), findsOneWidget);
    expect(find.text('커먼일지도'), findsOneWidget);
    expect(find.text('커먼 파파'), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(5));

    await tester.tap(find.text('커먼맘'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('selected-friend-friend-1')),
      findsOneWidget,
    );
    expect(find.text('커먼맘'), findsNWidgets(2));
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('선택된 친구 마크 삭제 버튼으로 선택을 해제한다', (WidgetTester tester) async {
    await tester.pumpWidget(_friendAddApp());

    await tester.enterText(find.byType(TextField), '커먼');
    await tester.pumpAndSettle();

    await tester.tap(find.text('커먼일뻔'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('selected-friend-friend-3')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('selected-friend-remove-friend-3')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('selected-friend-friend-3')),
      findsNothing,
    );
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('remote 검색 중에는 로딩 안내를 표시한다', (WidgetTester tester) async {
    await tester.pumpWidget(_friendAddRemoteApp(_PendingUserRepository()));

    await tester.enterText(find.byType(TextField), '커먼');
    await tester.pump();

    expect(find.text('사용자를 검색하고 있어요'), findsOneWidget);
    expect(find.text('커먼맘'), findsNothing);
  });

  testWidgets('remote 검색 결과가 없으면 empty 안내를 표시한다', (WidgetTester tester) async {
    await tester.pumpWidget(
      _friendAddRemoteApp(_StaticUserRepository(const [])),
    );

    await tester.enterText(find.byType(TextField), '없는친구');
    await tester.pumpAndSettle();

    expect(find.text('검색 결과가 없어요'), findsOneWidget);
    expect(find.text('다른 닉네임으로 검색해 주세요'), findsOneWidget);
  });

  testWidgets('remote 검색 실패는 재시도 후 결과를 표시한다', (WidgetTester tester) async {
    final repository = _RetryUserRepository();

    await tester.pumpWidget(_friendAddRemoteApp(repository));

    await tester.enterText(find.byType(TextField), '커먼');
    await tester.pump();
    await tester.pump();

    expect(find.text('사용자 검색에 실패했어요'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(repository.searchCalls, 2);
    expect(find.text('커먼맘'), findsOneWidget);
    expect(find.text('사용자 검색에 실패했어요'), findsNothing);
  });

  testWidgets('remote 검색 결과를 선택할 수 있다', (WidgetTester tester) async {
    await tester.pumpWidget(
      _friendAddRemoteApp(
        _StaticUserRepository(const [UserProfile(id: 'user-1', name: '커먼맘')]),
      ),
    );

    await tester.enterText(find.byType(TextField), '커먼');
    await tester.pumpAndSettle();
    await tester.tap(find.text('커먼맘'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('selected-friend-user-1')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}

Widget _friendAddApp() {
  return const ProviderScope(child: MaterialApp(home: PlaceFriendAddPage()));
}

Widget _friendAddRemoteApp(UserRepository repository) {
  return ProviderScope(
    overrides: [
      useRemoteApiProvider.overrideWithValue(true),
      userRepositoryProvider.overrideWithValue(repository),
    ],
    child: const MaterialApp(home: PlaceFriendAddPage()),
  );
}

class _PendingUserRepository extends UserRepository {
  _PendingUserRepository() : super(UserRemoteDataSource(Dio()));

  final Completer<List<UserProfile>> _completer =
      Completer<List<UserProfile>>();

  @override
  Future<List<UserProfile>> searchUsers(String keyword) {
    return _completer.future;
  }
}

class _StaticUserRepository extends UserRepository {
  _StaticUserRepository(this.users) : super(UserRemoteDataSource(Dio()));

  final List<UserProfile> users;

  @override
  Future<List<UserProfile>> searchUsers(String keyword) async {
    return users;
  }
}

class _RetryUserRepository extends UserRepository {
  _RetryUserRepository() : super(UserRemoteDataSource(Dio()));

  int searchCalls = 0;

  @override
  Future<List<UserProfile>> searchUsers(String keyword) async {
    searchCalls++;

    if (searchCalls == 1) {
      throw StateError('network');
    }

    return const [UserProfile(id: 'user-1', name: '커먼맘')];
  }
}
