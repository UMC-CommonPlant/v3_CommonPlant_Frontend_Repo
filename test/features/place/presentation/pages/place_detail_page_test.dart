import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_detail.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_detail_role.dart';
import 'package:commonplant_frontend/features/place/presentation/pages/place_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/test_app.dart';
import '../../../../helpers/test_viewport.dart';
import '../../../../helpers/user_data_session.dart';

void main() {
  testWidgets('리더는 FAB에서 장소 수정 액션을 확인할 수 있다', (tester) async {
    await tester.pumpWidget(
      buildPageTestApp(
        const PlaceDetailPage(placeId: 'place-1', role: PlaceDetailRole.leader),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('장소 상세 메뉴'));
    await tester.pumpAndSettle();

    expect(find.text('식물 추가하기'), findsOneWidget);
    expect(find.text('장소 수정하기'), findsOneWidget);
    expect(find.text('장소 나가기'), findsOneWidget);
  });

  testWidgets('팀원은 FAB에서 장소 수정 액션을 보지 않는다', (tester) async {
    await tester.pumpWidget(
      buildPageTestApp(
        const PlaceDetailPage(placeId: 'place-1', role: PlaceDetailRole.member),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('장소 상세 메뉴'));
    await tester.pumpAndSettle();

    expect(find.text('식물 추가하기'), findsOneWidget);
    expect(find.text('장소 수정하기'), findsNothing);
    expect(find.text('장소 나가기'), findsOneWidget);
  });

  testWidgets('장소 식물 카드 이미지는 viewport 사이에서 최소·최대 범위로 변한다', (tester) async {
    final thumbnailSizes = <Size>[];
    final viewports = <Size>[
      TestViewports.compactWidth,
      const Size(340, 800),
      TestViewports.reference,
    ];

    for (final viewport in viewports) {
      configureTestViewport(tester, viewport);
      await tester.pumpWidget(
        buildPageTestApp(const PlaceDetailPage(placeId: 'place-1')),
      );
      await tester.pumpAndSettle();

      expect(find.text('몬테'), findsWidgets);
      expect(tester.takeException(), isNull, reason: '$viewport');
      final thumbnailSize = tester.getSize(
        find.byKey(const ValueKey('place-plant-card-thumbnail')).first,
      );
      thumbnailSizes.add(thumbnailSize);
      expect(
        thumbnailSize.width,
        inInclusiveRange(
          AppSizes.placePlantCardImageMinSize,
          AppSizes.placePlantCardImageMaxWidth,
        ),
      );
      expect(
        thumbnailSize.height,
        inInclusiveRange(
          AppSizes.placePlantCardImageMinSize,
          AppSizes.placePlantCardImageMaxHeight,
        ),
      );
    }

    expect(
      thumbnailSizes.first,
      const Size(
        AppSizes.placePlantCardImageMinSize,
        AppSizes.placePlantCardImageMinSize,
      ),
    );
    expect(
      thumbnailSizes.last,
      const Size(
        AppSizes.placePlantCardImageMaxWidth,
        AppSizes.placePlantCardImageMaxHeight,
      ),
    );
    expect(thumbnailSizes[0].width, lessThan(thumbnailSizes[1].width));
    expect(thumbnailSizes[1].width, lessThan(thumbnailSizes[2].width));
    expect(
      thumbnailSizes[0].height,
      lessThanOrEqualTo(thumbnailSizes[1].height),
    );
    expect(
      thumbnailSizes[1].height,
      lessThanOrEqualTo(thumbnailSizes[2].height),
    );
  });

  testWidgets('장소 나가기는 확인 dialog를 표시한다', (tester) async {
    await tester.pumpWidget(
      buildPageTestApp(const PlaceDetailPage(placeId: 'place-1')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('장소 상세 메뉴'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('장소 나가기'));
    await tester.pumpAndSettle();

    expect(find.text('장소를 나가시겠어요?'), findsOneWidget);
    expect(find.text('나가면 더 이상 식물을 관리할 수 없어요.'), findsOneWidget);
  });

  testWidgets('remote loading 상태는 상세 정보 대신 로딩 안내를 표시한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(_PendingPlaceRepository()),
        ],
        child: const MaterialApp(
          home: PlaceDetailPage(placeId: 'remote-place'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('장소 정보를 불러오고 있어요'), findsOneWidget);
    expect(find.text('스윗 홈_거실'), findsNothing);
  });

  testWidgets('remote empty 상태는 장소 없음 안내를 표시한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(
            _StaticPlaceRepository(
              const PlaceDetail(
                code: 'empty-place',
                name: '',
                address: '',
                isOwner: false,
                members: [],
                plants: [],
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: PlaceDetailPage(placeId: 'empty-place')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('장소 정보를 찾을 수 없어요'), findsOneWidget);
    expect(find.text('다시 장소 목록에서 선택해 주세요'), findsOneWidget);
    expect(find.text('스윗 홈_거실'), findsNothing);
  });

  testWidgets('remote 상세는 API 멤버와 식물만 표시한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(
            _StaticPlaceRepository(
              const PlaceDetail(
                code: 'remote-place',
                name: 'API 정원',
                address: '서울시 성북구',
                isOwner: false,
                members: [PlaceMember(name: 'API 멤버')],
                plants: [
                  PlacePlant(
                    id: '10',
                    scientificNameKo: '고무나무',
                    scientificNameEn: 'Ficus elastica',
                    lastWateredDate: '2026-08-24',
                    memo: 'API 메모',
                  ),
                ],
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          home: PlaceDetailPage(placeId: 'remote-place'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('API 정원'), findsOneWidget);
    expect(find.text('API 멤버'), findsOneWidget);
    expect(find.text('고무나무'), findsOneWidget);
    expect(find.text('Ficus elastica'), findsOneWidget);
    expect(find.text('API 메모'), findsOneWidget);
    expect(find.text('마지막 물주기'), findsOneWidget);
    expect(find.text('2026.08.24'), findsOneWidget);
    expect(find.text('스윗 홈_거실'), findsNothing);
    expect(find.text('9.3 / 5'), findsNothing);
    expect(find.text('69%'), findsNothing);

    await tester.tap(find.bySemanticsLabel('장소 상세 메뉴'));
    await tester.pumpAndSettle();

    expect(find.text('장소 나가기'), findsNothing);
    expect(find.text('장소 삭제하기'), findsNothing);
  });

  testWidgets('remote 식물 목록이 비어 있으면 empty 안내를 표시한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(
            _StaticPlaceRepository(
              const PlaceDetail(
                code: 'remote-place',
                name: 'API 정원',
                address: '서울시 성북구',
                isOwner: true,
                members: [],
                plants: [],
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          home: PlaceDetailPage(placeId: 'remote-place'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('등록된 식물이 없어요'), findsOneWidget);
  });

  testWidgets('remote error 상태는 재시도 후 상세 정보를 표시한다', (tester) async {
    final repository = _RetryPlaceRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: PlaceDetailPage(placeId: 'retry-place')),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('장소 정보를 불러오지 못했어요'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(repository.fetchCalls, 2);
    expect(find.text('옥상 정원'), findsOneWidget);
    expect(find.text('장소 정보를 불러오지 못했어요'), findsNothing);
  });

  testWidgets('remote owner 장소 삭제는 경고 후 삭제 API를 호출한다', (tester) async {
    final repository = _DeletablePlaceRepository(
      const PlaceDetail(
        code: 'remote-place',
        name: '옥상 정원',
        address: '서울시 노원구 광운로 20',
        isOwner: true,
        members: [],
        plants: [],
      ),
    );

    await tester.pumpWidget(_remotePlaceDetailApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('장소 상세 메뉴'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('장소 삭제하기'));
    await tester.pumpAndSettle();

    expect(find.text('장소를 삭제하시겠어요?'), findsOneWidget);
    expect(find.text('삭제하면 장소의 식물과 메모도 함께 사라져요.'), findsOneWidget);

    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    expect(repository.deleteCalls, 1);
    expect(repository.latestDeleteCode, 'remote-place');
    expect(find.text('홈'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _remotePlaceDetailApp(PlaceRepository repository) {
  final router = GoRouter(
    initialLocation: '/places/remote-place',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const Text('홈')),
      GoRoute(
        path: '/places/:placeId',
        builder: (context, state) => PlaceDetailPage(
          placeId: state.pathParameters['placeId'] ?? '',
          role: PlaceDetailRole.leader,
        ),
      ),
    ],
  );

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
  final Completer<PlaceDetail> _completer = Completer<PlaceDetail>();

  @override
  Future<PlaceDetail> fetchPlaceDetail(String code) {
    return _completer.future;
  }
}

class _StaticPlaceRepository extends Fake implements PlaceRepository {
  _StaticPlaceRepository(this.detail);

  final PlaceDetail detail;

  @override
  Future<PlaceDetail> fetchPlaceDetail(String code) async {
    return detail;
  }
}

class _RetryPlaceRepository extends Fake implements PlaceRepository {
  int fetchCalls = 0;

  @override
  Future<PlaceDetail> fetchPlaceDetail(String code) async {
    fetchCalls++;

    if (fetchCalls == 1) {
      throw Exception('network');
    }

    return const PlaceDetail(
      code: 'retry-place',
      name: '옥상 정원',
      address: '서울시 노원구 광운로 20',
      isOwner: true,
      members: [],
      plants: [],
    );
  }
}

class _DeletablePlaceRepository extends Fake implements PlaceRepository {
  _DeletablePlaceRepository(this.detail);

  final PlaceDetail detail;
  int deleteCalls = 0;
  String? latestDeleteCode;

  @override
  Future<PlaceDetail> fetchPlaceDetail(String code) async {
    return detail;
  }

  @override
  Future<void> deletePlace(String code) async {
    deleteCalls++;
    latestDeleteCode = code;
  }
}
