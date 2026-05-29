import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/data/datasources/place_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/dtos/place_requests.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/presentation/pages/place_form_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
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
    expect(repository.latestUpdateRequest?.toJson(), {
      'name': '루프탑 정원',
      'address': '서울시 성북구',
    });
    expect(find.text('홈'), findsOneWidget);
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

  return ProviderScope(
    overrides: [
      useRemoteApiProvider.overrideWithValue(true),
      placeRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

class _PendingPlaceRepository extends PlaceRepository {
  _PendingPlaceRepository() : super(PlaceRemoteDataSource(Dio()));

  final Completer<void> _completer = Completer<void>();
  int createCalls = 0;

  @override
  Future<void> createPlace(CreatePlaceRequest request, {MultipartFile? image}) {
    createCalls++;
    return _completer.future;
  }
}

class _EditablePlaceRepository extends PlaceRepository {
  _EditablePlaceRepository(this.summary) : super(PlaceRemoteDataSource(Dio()));

  final PlaceSummary summary;
  int updateCalls = 0;
  String? latestUpdateCode;
  UpdatePlaceRequest? latestUpdateRequest;

  @override
  Future<PlaceSummary> fetchPlace(String code) async {
    return summary;
  }

  @override
  Future<void> updatePlace({
    required String code,
    required UpdatePlaceRequest request,
    MultipartFile? image,
  }) async {
    updateCalls++;
    latestUpdateCode = code;
    latestUpdateRequest = request;
  }
}
