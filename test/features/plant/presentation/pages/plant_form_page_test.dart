import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/domain/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/plant_repository_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/pages/plant_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('식물 등록 정보 입력 화면은 Figma 기준 필드를 표시한다', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: PlantFormPage())),
    );

    expect(find.text('식물 등록 (2/2)'), findsOneWidget);
    expect(find.text('장소 선택'), findsOneWidget);
    expect(find.text('스윗 홈_거실'), findsOneWidget);
    expect(find.text('낫 스윗 회사_가든'), findsOneWidget);
    expect(find.text('마지막으로 물 준 날짜'), findsOneWidget);
    expect(find.text('날짜 선택'), findsOneWidget);
    expect(find.text('2023. 01. 30'), findsNothing);
    expect(find.text('선택하지 않을 시, 등록일을 기준으로 설정합니다'), findsOneWidget);
    expect(find.text('취소'), findsOneWidget);
    expect(find.text('등록'), findsOneWidget);
  });

  testWidgets('식물 수정 화면은 Figma 기준 입력 상태와 비활성 완료 버튼을 표시한다', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: PlantFormPage(plantId: 'plant-1')),
      ),
    );

    expect(find.text('식물 수정'), findsOneWidget);
    expect(find.text('몬테'), findsOneWidget);
    expect(find.text('2/10', findRichText: true), findsOneWidget);
    expect(find.bySemanticsLabel('식물 사진 수정'), findsOneWidget);

    final completeButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '완료'),
    );
    expect(completeButton.onPressed, isNull);
  });

  testWidgets('식물 등록 화면에서 선택한 날짜를 폼에 표시한다', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: PlantFormPage())),
    );

    await tester.tap(find.text('날짜 선택'));
    await tester.pumpAndSettle();

    final calendar = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    calendar.onDateChanged(DateTime(2026, 8, 25));
    await tester.pump();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('2026. 08. 25'), findsOneWidget);
    expect(find.text('날짜 선택'), findsNothing);
  });

  testWidgets('식물 수정 화면은 API에서 불러온 마지막 물 준 날짜를 복원한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(
            _StaticEditInfoPlantRepository(
              const PlantEditInfo(name: '필로덴드론', lastWateredDate: '2026-05-25'),
            ),
          ),
        ],
        child: const MaterialApp(
          home: PlantFormPage(plantId: 'plant-1', placeId: 'place-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2026. 05. 25'), findsOneWidget);
    expect(find.text('필로덴드론'), findsOneWidget);
  });

  testWidgets('식물 수정 화면은 원격 제출 중 완료 버튼을 잠근다', (tester) async {
    final repository = _PendingPlantRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: PlantFormPage(plantId: 'plant-1', placeId: 'place-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '몬테라');
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, '완료'));
    await tester.pump();

    expect(repository.updateCalls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final completeButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '완료'),
    );

    expect(completeButton.onPressed, isNull);
  });

  testWidgets('식물 수정 실패는 공통 제출 오류 메시지를 표시하고 재시도 가능하다', (tester) async {
    final repository = _FailingPlantUpdateRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: PlantFormPage(plantId: 'plant-1', placeId: 'place-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '몬테라');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '완료'));
    await tester.pumpAndSettle();

    expect(repository.updateCalls, 1);
    expect(find.text('식물 수정에 실패했어요'), findsOneWidget);
    expect(find.textContaining('raw failure'), findsNothing);

    final completeButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '완료'),
    );
    expect(completeButton.onPressed, isNotNull);
  });

  testWidgets('remote loading 상태는 식물 수정 폼 대신 로딩 안내를 표시한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(
            _PendingEditInfoPlantRepository(),
          ),
        ],
        child: const MaterialApp(home: PlantFormPage(plantId: 'plant-remote')),
      ),
    );
    await tester.pump();

    expect(find.text('식물 수정 정보를 불러오고 있어요'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('remote empty 상태는 식물 수정 정보 없음 안내를 표시한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(
            _StaticEditInfoPlantRepository(const PlantEditInfo(name: '')),
          ),
        ],
        child: const MaterialApp(home: PlantFormPage(plantId: 'plant-empty')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('식물 수정 정보를 찾을 수 없어요'), findsOneWidget);
    expect(find.text('다시 식물 상세에서 수정해 주세요'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('remote error 상태는 재시도 후 식물 수정 폼을 표시한다', (tester) async {
    final repository = _RetryEditInfoPlantRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: PlantFormPage(plantId: 'plant-retry')),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('식물 수정 정보를 불러오지 못했어요'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(repository.editInfoFetchCalls, 2);
    expect(find.text('필로덴드론'), findsOneWidget);
    expect(find.text('식물 수정 정보를 불러오지 못했어요'), findsNothing);
  });
}

class _PendingPlantRepository extends Fake implements PlantRepository {
  final Completer<void> _completer = Completer<void>();
  int updateCalls = 0;

  @override
  Future<void> updatePlant({
    required String plantId,
    required String placeCode,
    String? imageKey,
    String? nickname,
    String? lastWateredDate,
  }) {
    updateCalls++;
    return _completer.future;
  }

  @override
  Future<PlantEditInfo> fetchPlantEditInfo({required String plantId}) async {
    return const PlantEditInfo(name: '몬테');
  }
}

class _FailingPlantUpdateRepository extends Fake implements PlantRepository {
  int updateCalls = 0;

  @override
  Future<void> updatePlant({
    required String plantId,
    required String placeCode,
    String? imageKey,
    String? nickname,
    String? lastWateredDate,
  }) async {
    updateCalls++;
    throw StateError('raw failure');
  }

  @override
  Future<PlantEditInfo> fetchPlantEditInfo({required String plantId}) async {
    return const PlantEditInfo(name: '몬테');
  }
}

class _PendingEditInfoPlantRepository extends Fake implements PlantRepository {
  final Completer<PlantEditInfo> _completer = Completer<PlantEditInfo>();

  @override
  Future<PlantEditInfo> fetchPlantEditInfo({required String plantId}) {
    return _completer.future;
  }
}

class _StaticEditInfoPlantRepository extends Fake implements PlantRepository {
  _StaticEditInfoPlantRepository(this.editInfo);

  final PlantEditInfo editInfo;

  @override
  Future<PlantEditInfo> fetchPlantEditInfo({required String plantId}) async {
    return editInfo;
  }
}

class _RetryEditInfoPlantRepository extends Fake implements PlantRepository {
  int editInfoFetchCalls = 0;

  @override
  Future<PlantEditInfo> fetchPlantEditInfo({required String plantId}) async {
    editInfoFetchCalls++;

    if (editInfoFetchCalls == 1) {
      throw Exception('network');
    }

    return const PlantEditInfo(name: '필로덴드론');
  }
}
