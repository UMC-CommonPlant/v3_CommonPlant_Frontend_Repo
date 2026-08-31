import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_detail.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/domain/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/plant_repository_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/pages/plant_detail_page.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_detail_view_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_place_code_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/test_app.dart';
import '../../../../helpers/test_viewport.dart';
import '../../../../helpers/user_data_session.dart';

void main() {
  testWidgets('식물 상세는 Figma 주요 정보와 더보기 메뉴를 표시한다', (tester) async {
    await tester.pumpWidget(
      buildPageTestApp(const PlantDetailPage(plantId: 'plant-1')),
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
      buildPageTestApp(const PlantDetailPage(plantId: 'plant-1')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('식물 상세 메뉴'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제하기'));
    await tester.pumpAndSettle();

    expect(find.text('식물을 삭제할까요?'), findsOneWidget);
    expect(find.text('삭제하면 기록된 메모도 함께 사라져요.'), findsOneWidget);
  });

  testWidgets('날짜 요약 간격은 viewport 사이에서 최소·최대 범위로 변한다', (tester) async {
    const maxGap = 34.0;
    final gaps = <double>[];
    final viewports = <Size>[
      TestViewports.compactWidth,
      const Size(333, 800),
      TestViewports.reference,
    ];

    for (final viewport in viewports) {
      configureTestViewport(tester, viewport);
      await tester.pumpWidget(
        buildPageTestApp(const PlantDetailPage(plantId: 'plant-1')),
      );
      await tester.pumpAndSettle();

      expect(find.text('마지막으로 물 준 날짜'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: '$viewport');
      final gap = tester
          .getSize(find.byKey(const ValueKey('plant-date-summary-gap')))
          .width;
      gaps.add(gap);
      expect(gap, inInclusiveRange(AppSpacing.x8, maxGap));
    }

    expect(gaps.first, AppSpacing.x8);
    expect(gaps.last, maxGap);
    expect(gaps[0], lessThan(gaps[1]));
    expect(gaps[1], lessThan(gaps[2]));
  });

  testWidgets('remote loading 상태는 식물 상세 대신 로딩 안내를 표시한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authenticatedUserDataSession,
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
          authenticatedUserDataSession,
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
          authenticatedUserDataSession,
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

  testWidgets('소속 장소 조회 오류는 상세 오류로 표시하고 재시도 후 복구한다', (tester) async {
    final placeRepository = _RetryPlaceResolverRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(
            _StaticPlantRepository(
              detail: const PlantDetail(
                id: 'plant-place-retry',
                name: '필로덴드론',
                placeName: '거실 정원',
              ),
            ),
          ),
          placeRepositoryProvider.overrideWithValue(placeRepository),
        ],
        child: const MaterialApp(
          home: PlantDetailPage(plantId: 'plant-place-retry'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('식물 정보를 불러오지 못했어요'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(placeRepository.detailCalls, 2);
    expect(find.text('필로덴드론'), findsOneWidget);
    expect(find.text('식물 정보를 불러오지 못했어요'), findsNothing);
  });

  testWidgets('remote 상세는 Swagger 값과 미제공 상태만 표시한다', (tester) async {
    final repository = _StaticPlantRepository(
      detail: const PlantDetail(
        id: 'plant-remote',
        name: '필로덴드론',
        placeName: '거실 정원',
        species: 'Philodendron erubescens',
        description: '반양지에서 관리해 주세요.',
        lastWateredDate: '2026-05-25',
        memo: '새 잎이 올라오고 있어요.',
        registeredAt: '2026-05-12T19:30:00',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
          remotePlantPlaceCodeProvider(
            'plant-remote',
          ).overrideWith((ref) async => 'resolved-place'),
          plantDetailNowProvider.overrideWithValue(() => DateTime(2026, 5, 25)),
        ],
        child: const MaterialApp(
          home: PlantDetailPage(plantId: 'plant-remote'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('거실 정원'), findsOneWidget);
    expect(find.text('Philodendron erubescens'), findsOneWidget);
    expect(find.textContaining('14일', findRichText: true), findsOneWidget);
    expect(find.text('2026.05.12'), findsOneWidget);
    expect(find.text('2026.05.25'), findsOneWidget);
    expect(find.text('물주기 예정 정보 없음'), findsOneWidget);
    expect(find.text('물주기 주기 정보 없음'), findsOneWidget);
    expect(find.text('새 잎이 올라오고 있어요.'), findsOneWidget);
    expect(find.text('반양지에서 관리해 주세요.'), findsOneWidget);
    expect(find.text('D-3'), findsNothing);
    expect(find.text('10 Day'), findsNothing);
    expect(find.text('커먼플랜트'), findsNothing);
    expect(find.text('작성하기'), findsNothing);
    expect(find.bySemanticsLabel('메모 전체보기'), findsNothing);
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
      authenticatedUserDataSession,
      useRemoteApiProvider.overrideWithValue(true),
      plantRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

class _PendingPlantRepository extends Fake implements PlantRepository {
  final Completer<PlantDetail> _detailCompleter = Completer<PlantDetail>();

  @override
  Future<PlantDetail> fetchPlant({required String plantId}) {
    return _detailCompleter.future;
  }
}

class _StaticPlantRepository extends Fake implements PlantRepository {
  _StaticPlantRepository({required this.detail});

  final PlantDetail detail;

  @override
  Future<PlantDetail> fetchPlant({required String plantId}) async {
    return detail;
  }
}

class _RetryPlantRepository extends Fake implements PlantRepository {
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
      placeId: 'place-retry',
      placeName: '스윗홈_거실',
      species: 'Philodendron',
      lastWateredDate: '2026.05.25',
    );
  }
}

class _RetryPlaceResolverRepository extends Fake implements PlaceRepository {
  int detailCalls = 0;

  @override
  Future<List<PlaceSummary>> fetchMyGardenPlaces() async {
    return const [PlaceSummary(id: 'place-retry', name: '거실 정원')];
  }

  @override
  Future<PlaceDetail> fetchPlaceDetail(String code) async {
    detailCalls++;
    if (detailCalls == 1) {
      throw StateError('장소 상세 실패');
    }

    return PlaceDetail(
      code: code,
      name: '거실 정원',
      address: '주소',
      isOwner: true,
      members: const [],
      plants: const [
        PlacePlant(id: 'plant-place-retry', scientificNameKo: '필로덴드론'),
      ],
    );
  }
}

class _DeletablePlantRepository extends Fake implements PlantRepository {
  _DeletablePlantRepository(this.detail);

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
