import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/data/datasources/plant_remote_data_source.dart';
import 'package:commonplant_frontend/features/plant/data/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/presentation/pages/plant_detail_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('식물 상세는 Figma 주요 정보와 더보기 메뉴를 표시한다', (tester) async {
    await tester.pumpWidget(
      _buildPlantDetailApp(const PlantDetailPage(plantId: 'plant-1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('My plant'), findsOneWidget);
    expect(find.text('스윗홈_거실'), findsOneWidget);
    expect(find.text('몬테'), findsOneWidget);
    expect(find.text('Monstera deliciosa'), findsOneWidget);
    expect(find.text('D-3'), findsOneWidget);
    expect(find.text('Memo'), findsOneWidget);
    expect(find.text('식물정보'), findsOneWidget);
    expect(find.text('10 Day'), findsOneWidget);
    expect(
      tester.getCenter(find.byTooltip('식물 상세 메뉴')).dy,
      lessThanOrEqualTo(56),
    );
    expect(
      tester
          .getTopLeft(
            find.byKey(const ValueKey('plant-detail-section-divider')).first,
          )
          .dx,
      0,
    );
    expect(
      tester
          .getSize(
            find.byKey(const ValueKey('plant-detail-section-divider')).first,
          )
          .width,
      tester.view.physicalSize.width / tester.view.devicePixelRatio,
    );

    await tester.tap(find.byTooltip('식물 상세 메뉴'));
    await tester.pumpAndSettle();

    expect(find.text('수정하기'), findsOneWidget);
    expect(find.text('삭제하기'), findsOneWidget);
  });

  testWidgets('식물 삭제 메뉴는 확인 dialog를 표시한다', (tester) async {
    await tester.pumpWidget(
      _buildPlantDetailApp(const PlantDetailPage(plantId: 'plant-1')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('식물 상세 메뉴'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제하기'));
    await tester.pumpAndSettle();

    expect(find.text('식물을 삭제할까요?'), findsOneWidget);
    expect(find.text('삭제하면 기록된 메모도 함께 사라져요.'), findsOneWidget);
  });

  testWidgets('remote loading 상태는 식물 상세 대신 로딩 안내를 표시한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(_PendingPlantRepository()),
        ],
        child: const MaterialApp(
          home: PlantDetailPage(plantId: 'plant-remote'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('식물 정보를 불러오고 있어요'), findsOneWidget);
    expect(find.text('몬테'), findsNothing);
  });

  testWidgets('remote empty 상태는 식물 없음 안내를 표시한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(
            _StaticPlantRepository(
              detail: const PlantDetail(id: 'plant-empty', name: ''),
            ),
          ),
        ],
        child: const MaterialApp(home: PlantDetailPage(plantId: 'plant-empty')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('식물 정보를 찾을 수 없어요'), findsOneWidget);
    expect(find.text('다시 식물 목록에서 선택해 주세요'), findsOneWidget);
    expect(find.text('몬테'), findsNothing);
  });

  testWidgets('remote error 상태는 재시도 후 식물 상세 정보를 표시한다', (tester) async {
    final repository = _RetryPlantRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: PlantDetailPage(plantId: 'plant-retry')),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('식물 정보를 불러오지 못했어요'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(repository.detailFetchCalls, 2);
    expect(find.text('필로덴드론'), findsOneWidget);
    expect(find.text('식물 정보를 불러오지 못했어요'), findsNothing);
  });

  testWidgets('remote 식물 삭제 확인은 삭제 API를 호출하고 홈으로 이동한다', (tester) async {
    final repository = _DeletablePlantRepository(
      const PlantDetail(
        id: 'plant-remote',
        name: '필로덴드론',
        placeId: 'place-1',
        placeName: '거실 정원',
      ),
    );

    await tester.pumpWidget(_remotePlantDetailApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('식물 상세 메뉴'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    expect(repository.deleteCalls, 1);
    expect(repository.latestDeletedPlantId, 'plant-remote');
    expect(repository.latestDeletedPlaceCode, 'place-1');
    expect(find.text('홈'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _buildPlantDetailApp(Widget home) {
  return ProviderScope(child: MaterialApp(home: home));
}

Widget _remotePlantDetailApp(PlantRepository repository) {
  final router = GoRouter(
    initialLocation: '/plants/plant-remote?placeId=place-1',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const Text('홈')),
      GoRoute(
        path: '/plants/:plantId',
        builder: (context, state) => PlantDetailPage(
          plantId: state.pathParameters['plantId'] ?? '',
          placeId: state.uri.queryParameters['placeId'],
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      useRemoteApiProvider.overrideWithValue(true),
      plantRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

class _PendingPlantRepository extends PlantRepository {
  _PendingPlantRepository() : super(PlantRemoteDataSource(Dio()));

  final Completer<PlantDetail> _detailCompleter = Completer<PlantDetail>();

  @override
  Future<PlantDetail> fetchPlant({required String plantId}) {
    return _detailCompleter.future;
  }
}

class _StaticPlantRepository extends PlantRepository {
  _StaticPlantRepository({required this.detail})
    : super(PlantRemoteDataSource(Dio()));

  final PlantDetail detail;

  @override
  Future<PlantDetail> fetchPlant({required String plantId}) async {
    return detail;
  }
}

class _RetryPlantRepository extends PlantRepository {
  _RetryPlantRepository() : super(PlantRemoteDataSource(Dio()));

  int detailFetchCalls = 0;

  @override
  Future<PlantDetail> fetchPlant({required String plantId}) async {
    detailFetchCalls++;

    if (detailFetchCalls == 1) {
      throw Exception('network');
    }

    return const PlantDetail(
      id: 'plant-retry',
      name: '필로덴드론',
      placeName: '스윗홈_거실',
      species: 'Philodendron',
      lastWateredDate: '2026.05.25',
    );
  }
}

class _DeletablePlantRepository extends PlantRepository {
  _DeletablePlantRepository(this.detail) : super(PlantRemoteDataSource(Dio()));

  final PlantDetail detail;
  int deleteCalls = 0;
  String? latestDeletedPlantId;
  String? latestDeletedPlaceCode;

  @override
  Future<PlantDetail> fetchPlant({required String plantId}) async {
    return detail;
  }

  @override
  Future<void> deletePlant({
    required String plantId,
    required String placeCode,
  }) async {
    deleteCalls++;
    latestDeletedPlantId = plantId;
    latestDeletedPlaceCode = placeCode;
  }
}
