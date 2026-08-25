import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/features/friend/data/datasources/friend_remote_data_source.dart';
import 'package:commonplant_frontend/features/friend/data/dtos/friend_requests.dart';
import 'package:commonplant_frontend/features/friend/data/repositories/friend_repository.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_invitation.dart';
import 'package:commonplant_frontend/features/place/presentation/pages/place_invitations_page.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_invitation_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_viewport.dart';

void main() {
  testWidgets('장소 친구 요청 기본 화면을 Figma 항목과 버튼으로 표시한다', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester);

    expect(find.text('장소 친구 요청'), findsOneWidget);
    expect(find.text('초대받은 장소'), findsNothing);
    expect(find.text('커먼맘'), findsNWidgets(2));
    expect(find.text('도라에몽'), findsOneWidget);
    expect(find.text('스윗홈_욕실'), findsOneWidget);
    expect(find.text('스윗홈_베란다'), findsOneWidget);
    expect(find.text('낫 스윗 회사_중앙'), findsOneWidget);
    expect(find.text('서울시 노원구 광운로 20'), findsNWidgets(2));
    expect(find.text('서울시 강남구 커먼로 55'), findsOneWidget);
    expect(find.text('확인'), findsNWidgets(3));
    expect(find.text('삭제'), findsNWidgets(3));
    expect(
      tester.getSize(find.bySemanticsLabel('스윗홈_욕실 확인')),
      const Size(
        AppSizes.placeInvitationActionButtonMaxWidth,
        AppSizes.placeInvitationActionButtonHeight,
      ),
    );
  });

  testWidgets('확인과 삭제 버튼을 누르면 fixture 항목별 결과 상태로 분기한다', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester);

    await tester.tap(find.bySemanticsLabel('스윗홈_욕실 삭제'));
    await tester.pump();

    expect(find.text('요청 삭제됨'), findsOneWidget);
    expect(find.text('스윗홈_욕실'), findsNothing);
    expect(find.text('확인'), findsNWidgets(2));
    expect(find.text('삭제'), findsNWidgets(2));

    await tester.tap(find.bySemanticsLabel('스윗홈_베란다 확인'));
    await tester.pump();

    expect(find.text('스윗홈_베란다에서 함께 해보세요:)'), findsOneWidget);
    expect(find.text('스윗홈_베란다'), findsNothing);
    expect(find.text('낫 스윗 회사_중앙'), findsOneWidget);
    expect(find.text('확인'), findsOneWidget);
    expect(find.text('삭제'), findsOneWidget);
  });

  testWidgets('compact 폭에서도 초대 action button을 overflow 없이 표시한다', (
    WidgetTester tester,
  ) async {
    final buttonWidths = <double>[];

    for (final viewport in [TestViewports.compactWidth, const Size(360, 800)]) {
      await _pumpPage(tester, viewport: viewport);

      expect(tester.takeException(), isNull, reason: '$viewport viewport');
      final buttonWidth = tester
          .getSize(find.bySemanticsLabel('스윗홈_욕실 확인'))
          .width;
      buttonWidths.add(buttonWidth);
      expect(
        buttonWidth,
        inInclusiveRange(
          AppSizes.placeInvitationActionButtonMinWidth,
          AppSizes.placeInvitationActionButtonMaxWidth,
        ),
      );
    }

    expect(buttonWidths.first, lessThan(buttonWidths.last));
  });

  testWidgets('원격 목록을 조회하는 동안 loading 상태를 표시한다', (WidgetTester tester) async {
    final loading = Completer<List<PlaceInvitation>>();

    await _pumpPage(
      tester,
      settle: false,
      scopeBuilder: (child) => ProviderScope(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          remotePlaceInvitationsProvider.overrideWith((ref) => loading.future),
        ],
        child: child,
      ),
    );
    await tester.pump();

    expect(find.text('친구 요청을 불러오고 있어요'), findsOneWidget);
  });

  testWidgets('원격 요청이 없으면 empty 상태를 표시한다', (WidgetTester tester) async {
    await _pumpPage(
      tester,
      scopeBuilder: (child) => ProviderScope(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          remotePlaceInvitationsProvider.overrideWith((ref) async => const []),
        ],
        child: child,
      ),
    );

    expect(find.text('받은 장소 요청이 없어요'), findsOneWidget);
  });

  testWidgets('원격 목록 조회 실패는 재시도 가능한 error 상태를 표시한다', (
    WidgetTester tester,
  ) async {
    await _pumpPage(
      tester,
      scopeBuilder: (child) => ProviderScope(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          remotePlaceInvitationsProvider.overrideWith(
            (ref) => Future.error(StateError('load failed')),
          ),
        ],
        child: child,
      ),
    );

    expect(find.text('친구 요청을 불러오지 못했어요'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });

  testWidgets('원격 요청을 수락하는 동안 중복 action을 막고 성공 후 제거한다', (
    WidgetTester tester,
  ) async {
    final dataSource = _InvitationDataSource(waitForDecision: true);

    await _pumpPage(
      tester,
      scopeBuilder: (child) => ProviderScope(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          friendRemoteDataSourceProvider.overrideWithValue(dataSource),
        ],
        child: child,
      ),
    );

    await tester.tap(find.bySemanticsLabel('거실 정원 확인'));
    await tester.pump();

    expect(find.bySemanticsLabel('거실 정원 요청 처리 중'), findsOneWidget);
    expect(find.bySemanticsLabel('거실 정원 확인'), findsNothing);

    dataSource.completeDecision();
    await tester.pumpAndSettle();

    expect(dataSource.acceptedFriendId, 41);
    expect(find.text('거실 정원'), findsNothing);
    expect(find.text('받은 장소 요청이 없어요'), findsOneWidget);
  });

  testWidgets('원격 요청 처리 실패는 요청과 사용자용 오류를 유지한다', (WidgetTester tester) async {
    final dataSource = _InvitationDataSource(shouldFailDecision: true);

    await _pumpPage(
      tester,
      scopeBuilder: (child) => ProviderScope(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          friendRemoteDataSourceProvider.overrideWithValue(dataSource),
        ],
        child: child,
      ),
    );

    await tester.tap(find.bySemanticsLabel('거실 정원 삭제'));
    await tester.pumpAndSettle();

    expect(find.text('친구 요청을 처리하지 못했어요'), findsOneWidget);
    expect(find.text('거실 정원'), findsOneWidget);
    expect(find.bySemanticsLabel('거실 정원 삭제'), findsOneWidget);
  });
}

Future<void> _pumpPage(
  WidgetTester tester, {
  Size viewport = TestViewports.reference,
  Widget Function(Widget child)? scopeBuilder,
  bool settle = true,
}) async {
  configureTestViewport(tester, viewport);

  const page = MaterialApp(home: PlaceInvitationsPage());
  final scopedPage =
      scopeBuilder?.call(page) ?? const ProviderScope(child: page);

  await tester.pumpWidget(scopedPage);
  if (settle) {
    await tester.pumpAndSettle();
  }
}

class _InvitationDataSource extends FriendRemoteDataSource {
  _InvitationDataSource({
    this.waitForDecision = false,
    this.shouldFailDecision = false,
  }) : super(Dio());

  final bool waitForDecision;
  final bool shouldFailDecision;
  final Completer<void> _decisionCompleter = Completer<void>();
  int? acceptedFriendId;
  bool _resolved = false;

  @override
  Future<Object?> getRequestsRaw() async {
    return {
      'result': {
        'requests': _resolved
            ? <Object?>[]
            : <Object?>[
                {
                  'friendId': 41,
                  'senderName': '커먼맘',
                  'senderImgUrl': null,
                  'placeCode': 'place-code',
                  'placeName': '거실 정원',
                  'placeAddress': '서울시 노원구',
                  'status': 'PENDING',
                },
              ],
      },
    };
  }

  @override
  Future<void> acceptRequest(FriendDecisionRequest request) async {
    acceptedFriendId = request.friendId;
    await _resolve();
  }

  @override
  Future<void> declineRequest(FriendDecisionRequest request) {
    return _resolve();
  }

  Future<void> _resolve() async {
    if (shouldFailDecision) {
      throw StateError('decision failed');
    }
    if (waitForDecision) {
      await _decisionCompleter.future;
    }
    _resolved = true;
  }

  void completeDecision() {
    if (!_decisionCompleter.isCompleted) {
      _decisionCompleter.complete();
    }
  }
}
