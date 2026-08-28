import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/domain/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/plant_repository_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/fixtures/plant_registration_place_fixture.dart';
import 'package:commonplant_frontend/features/plant/presentation/pages/plant_form_page.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_controller.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_registration_place_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/user_data_session.dart';

void main() {
  testWidgets('사진 key가 없는 식물 수정은 안내를 표시하고 API를 호출하지 않는다', (tester) async {
    final repository = _StaticEditInfoPlantRepository(
      const PlantEditInfo(
        name: '몬테',
        imageUrl: 'https://example.com/plant.png',
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authenticatedUserDataSession,
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

    expect(repository.updateCalls, 0);
    expect(find.text(plantFormImagePreservationMessage), findsOneWidget);
    expect(find.text('몬테라'), findsOneWidget);
    expect(find.byType(PlantFormPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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
          authenticatedUserDataSession,
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

  testWidgets('미래 API 날짜는 보존하되 날짜 선택기는 오늘 이후를 허용하지 않는다', (tester) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final futureDate = DateTime(today.year + 1, today.month, today.day);
    final apiDate = _apiDate(futureDate);
    final displayDate = _displayDate(futureDate);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(
            _StaticEditInfoPlantRepository(
              PlantEditInfo(name: '필로덴드론', lastWateredDate: apiDate),
            ),
          ),
        ],
        child: const MaterialApp(
          home: PlantFormPage(plantId: 'plant-1', placeId: 'place-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(displayDate), findsOneWidget);

    await tester.tap(find.text(displayDate));
    await tester.pumpAndSettle();

    final calendar = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    expect(calendar.initialDate, today);
    expect(calendar.lastDate, today);

    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();

    expect(find.byType(CalendarDatePicker), findsNothing);
    expect(find.text(displayDate), findsOneWidget);
  });

  testWidgets('식물 등록 화면은 원격 제출 중 등록 버튼을 잠근다', (tester) async {
    final repository = _PendingPlantCreateRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
          plantRegistrationPlaceProvider.overrideWith(
            (ref) => [plantRegistrationPlaceFallbacks.first],
          ),
        ],
        child: const MaterialApp(home: PlantFormPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '등록'));
    await tester.pump();

    expect(repository.createCalls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final submitButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '등록'),
    );
    expect(submitButton.onPressed, isNull);
  });

  testWidgets('식물 등록 실패는 사용자 오류를 표시하고 재시도할 수 있다', (tester) async {
    final repository = _FailingPlantCreateRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
          plantRegistrationPlaceProvider.overrideWith(
            (ref) => [plantRegistrationPlaceFallbacks.first],
          ),
        ],
        child: const MaterialApp(home: PlantFormPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '등록'));
    await tester.pumpAndSettle();

    expect(repository.createCalls, 1);
    expect(find.text('식물 등록에 실패했어요'), findsOneWidget);
    expect(find.textContaining('raw failure'), findsNothing);

    final submitButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '등록'),
    );
    expect(submitButton.onPressed, isNotNull);
  });

  testWidgets('식물 수정 화면은 원격 제출 중 완료 버튼을 잠근다', (tester) async {
    final repository = _PendingPlantRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authenticatedUserDataSession,
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
          authenticatedUserDataSession,
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
          authenticatedUserDataSession,
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
          authenticatedUserDataSession,
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
          authenticatedUserDataSession,
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

String _apiDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '${date.year}-$month-$day';
}

String _displayDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '${date.year}. $month. $day';
}

class _PendingPlantCreateRepository extends Fake implements PlantRepository {
  final Completer<void> _completer = Completer<void>();
  int createCalls = 0;

  @override
  Future<void> createPlant({
    required String placeCode,
    required String nickname,
    String? scientificNameKo,
    String? scientificNameEn,
    String? lastWateredDate,
    String? description,
  }) {
    createCalls++;
    return _completer.future;
  }
}

class _FailingPlantCreateRepository extends Fake implements PlantRepository {
  int createCalls = 0;

  @override
  Future<void> createPlant({
    required String placeCode,
    required String nickname,
    String? scientificNameKo,
    String? scientificNameEn,
    String? lastWateredDate,
    String? description,
  }) async {
    createCalls++;
    throw StateError('raw failure');
  }
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
  }

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
