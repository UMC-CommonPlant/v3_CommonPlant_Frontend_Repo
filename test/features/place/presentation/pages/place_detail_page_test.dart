import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/data/datasources/place_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/presentation/pages/place_detail_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('리더는 FAB에서 장소 수정 액션을 확인할 수 있다', (tester) async {
    await tester.pumpWidget(
      _buildPlaceDetailApp(
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
      _buildPlaceDetailApp(
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

  testWidgets('장소 나가기는 확인 dialog를 표시한다', (tester) async {
    await tester.pumpWidget(
      _buildPlaceDetailApp(const PlaceDetailPage(placeId: 'place-1')),
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
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(
            _StaticPlaceRepository(
              const PlaceSummary(id: 'empty-place', name: ''),
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

  testWidgets('remote error 상태는 재시도 후 상세 정보를 표시한다', (tester) async {
    final repository = _RetryPlaceRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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
}

Widget _buildPlaceDetailApp(Widget home) {
  return ProviderScope(child: MaterialApp(home: home));
}

class _PendingPlaceRepository extends PlaceRepository {
  _PendingPlaceRepository() : super(PlaceRemoteDataSource(Dio()));

  final Completer<PlaceSummary> _completer = Completer<PlaceSummary>();

  @override
  Future<PlaceSummary> fetchPlace(String code) {
    return _completer.future;
  }
}

class _StaticPlaceRepository extends PlaceRepository {
  _StaticPlaceRepository(this.summary) : super(PlaceRemoteDataSource(Dio()));

  final PlaceSummary summary;

  @override
  Future<PlaceSummary> fetchPlace(String code) async {
    return summary;
  }
}

class _RetryPlaceRepository extends PlaceRepository {
  _RetryPlaceRepository() : super(PlaceRemoteDataSource(Dio()));

  int fetchCalls = 0;

  @override
  Future<PlaceSummary> fetchPlace(String code) async {
    fetchCalls++;

    if (fetchCalls == 1) {
      throw Exception('network');
    }

    return const PlaceSummary(
      id: 'retry-place',
      name: '옥상 정원',
      address: '서울시 노원구 광운로 20',
    );
  }
}
