import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/pages/place_form_page.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_controller.dart';
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
    testWidgets('장소 수정 중 이름 변경·재탭은 요청을 늘리지 않는다 ($viewport)', (tester) async {
      configureTestViewport(tester, viewport);
      final response = Completer<PlaceSummary>();
      final repository = _EditablePlaceRepository(
        const PlaceSummary(id: 'place-1', name: '루프탑', address: '서울시 성북구'),
      )..updateResponse = response;
      await tester.pumpWidget(_remotePlaceEditApp(repository));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '첫 제출');
      await tester.pump();
      final button = find.widgetWithText(FilledButton, '완료');
      final repeatSubmit = tester.widget<FilledButton>(button).onPressed!;
      await tester.tap(button);
      await tester.pump();
      await tester.enterText(find.byType(TextField), '다음 제출');
      await tester.pump();
      // 비활성 프레임 전에 전달된 콜백도 Controller에서 차단해야 한다.
      repeatSubmit();
      await tester.pump();

      expect(repository.updateCalls, 1);
      expect(repository.latestUpdateName, '첫 제출');
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('다음 제출'), findsOneWidget);
      expect(find.text('홈'), findsNothing);

      response.complete(
        const PlaceSummary(id: 'place-1', name: '첫 제출', address: '서울시 성북구'),
      );
      await tester.pumpAndSettle();

      expect(repository.updateCalls, 1);
      expect(find.text('홈'), findsOneWidget);
      expect(find.byType(PlaceFormPage), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('사진이 있는 장소 수정은 안내를 표시하고 화면과 입력을 유지한다', (tester) async {
    final repository = _EditablePlaceRepository(
      const PlaceSummary(
        id: 'place-1',
        name: '루프탑',
        address: '서울시 성북구',
        imageUrl: 'https://example.com/place.png',
      ),
    );
    await tester.pumpWidget(_remotePlaceEditApp(repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '루프탑 정원');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '완료'));
    await tester.pumpAndSettle();

    expect(repository.updateCalls, 0);
    expect(find.text(placeFormImagePreservationMessage), findsOneWidget);
    expect(find.text('루프탑 정원'), findsOneWidget);
    expect(find.text('홈'), findsNothing);
    expect(find.byType(PlaceFormPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('장소 수정 화면은 기존 장소 정보와 비활성 완료 버튼을 표시한다', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: PlaceFormPage(placeId: 'place-1')),
      ),
    );

    expect(find.text('장소 수정'), findsOneWidget);
    expect(find.text('스윗 홈_ 거실'), findsOneWidget);
    expect(find.text('주소'), findsOneWidget);
    expect(find.bySemanticsLabel('장소 대표 이미지'), findsOneWidget);
    expect(find.bySemanticsLabel('텍스트 삭제'), findsOneWidget);

    final completeButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '완료'),
    );

    expect(completeButton.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('장소 수정 화면은 이름이 변경되면 완료 버튼을 활성화한다', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: PlaceFormPage(placeId: 'place-1')),
      ),
    );

    await tester.enterText(find.byType(TextField), '스윗 홈_ 방');
    await tester.pump();

    final completeButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '완료'),
    );

    expect(completeButton.onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('장소 등록 화면은 원격 주소가 없으면 안내하고 요청하지 않는다', (tester) async {
    final repository = _PendingPlaceRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: PlaceFormPage()),
      ),
    );

    await tester.enterText(find.byType(TextField), '거실');
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, '다음'));
    await tester.pump();

    expect(repository.createCalls, 0);
    expect(find.text('장소 주소를 입력해 주세요.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('remote 장소 수정 화면은 조회값으로 초기화하고 수정 API를 호출한다', (tester) async {
    final repository = _EditablePlaceRepository(
      const PlaceSummary(id: 'place-1', name: '루프탑', address: '서울시 성북구'),
    );

    await tester.pumpWidget(_remotePlaceEditApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('루프탑'), findsOneWidget);
    expect(find.text('서울시 성북구'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '루프탑 정원');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '완료'));
    await tester.pumpAndSettle();

    expect(repository.updateCalls, 1);
    expect(repository.latestUpdateCode, 'place-1');
    expect(repository.latestUpdateName, '루프탑 정원');
    expect(repository.latestUpdateAddress, '서울시 성북구');
    expect(find.text('홈'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('remote 장소 검증 오류를 폼 필드에 표시하고 원격 상세 메시지는 숨긴다', (tester) async {
    final repository =
        _EditablePlaceRepository(
            const PlaceSummary(id: 'place-1', name: '루프탑', address: '서울시 성북구'),
          )
          ..updateError = const ApiException(
            message: 'raw backend validation detail',
            statusCode: 400,
            code: 'C001',
            kind: ApiFailureKind.validation,
            fieldErrors: [
              ApiFieldError(field: 'request.name', reason: '이름 필드 오류'),
              ApiFieldError(field: 'address', reason: '주소 필드 오류'),
            ],
          );
    await tester.pumpWidget(_remotePlaceEditApp(repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '루프탑 정원');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '완료'));
    await tester.pumpAndSettle();

    expect(find.text('입력 내용을 확인해 주세요.'), findsOneWidget);
    expect(find.text('이름 필드 오류'), findsOneWidget);
    expect(find.text('주소 필드 오류'), findsOneWidget);
    expect(find.textContaining('raw backend'), findsNothing);

    await tester.enterText(find.byType(TextField), '새 이름');
    await tester.pump();
    expect(find.text('이름 필드 오류'), findsNothing);
    expect(find.text('주소 필드 오류'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Widget _remotePlaceEditApp(PlaceRepository repository) {
  final router = GoRouter(
    initialLocation: '/places/place-1/edit',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const Text('홈')),
      GoRoute(
        path: '/places/:placeId/edit',
        builder: (context, state) =>
            PlaceFormPage(placeId: state.pathParameters['placeId']),
      ),
    ],
  );
  addTearDown(router.dispose);

  return ProviderScope(
    overrides: [
      authenticatedUserDataSession,
      useRemoteApiProvider.overrideWithValue(true),
      placeRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

class _PendingPlaceRepository extends Fake implements PlaceRepository {
  final Completer<String> _completer = Completer<String>();
  int createCalls = 0;

  @override
  Future<String> createPlace({required String name, required String address}) {
    createCalls++;
    return _completer.future;
  }
}

class _EditablePlaceRepository extends Fake implements PlaceRepository {
  _EditablePlaceRepository(this.summary);

  final PlaceSummary summary;
  Completer<PlaceSummary>? updateResponse;
  Object? updateError;
  int updateCalls = 0;
  String? latestUpdateCode;
  String? latestUpdateName;
  String? latestUpdateAddress;

  @override
  Future<PlaceSummary> fetchPlace(String code) async {
    return summary;
  }

  @override
  Future<PlaceSummary> updatePlace({
    required String code,
    required String name,
    required String address,
    String? imageKey,
  }) async {
    updateCalls++;
    latestUpdateCode = code;
    latestUpdateName = name;
    latestUpdateAddress = address;

    if (updateError != null) throw updateError!;

    return updateResponse?.future ??
        PlaceSummary(id: code, name: name, address: address);
  }
}
