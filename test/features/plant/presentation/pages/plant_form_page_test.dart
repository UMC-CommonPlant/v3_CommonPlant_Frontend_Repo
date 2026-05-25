import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/data/datasources/plant_remote_data_source.dart';
import 'package:commonplant_frontend/features/plant/data/dtos/plant_requests.dart';
import 'package:commonplant_frontend/features/plant/data/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/presentation/pages/plant_form_page.dart';
import 'package:dio/dio.dart';
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
    expect(find.text('2023. 01. 30'), findsOneWidget);
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
}

class _PendingPlantRepository extends PlantRepository {
  _PendingPlantRepository() : super(PlantRemoteDataSource(Dio()));

  final Completer<void> _completer = Completer<void>();
  int updateCalls = 0;

  @override
  Future<void> updatePlant({
    required String plantId,
    required String placeCode,
    required UpdatePlantRequest request,
  }) {
    updateCalls++;
    return _completer.future;
  }
}
