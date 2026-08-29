import 'dart:async';

import 'package:commonplant_frontend/app/router/app_router.dart';
import 'package:commonplant_frontend/app/router/app_routes.dart';
import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/place/data/datasources/place_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/dtos/place_requests.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/fixtures/address_search_fixture.dart';
import 'package:commonplant_frontend/features/place/presentation/models/address_search_result.dart';
import 'package:commonplant_frontend/features/place/presentation/pages/place_form_page.dart';
import 'package:commonplant_frontend/features/place/presentation/pages/place_friend_add_page.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/address_search_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_viewport.dart';
import '../../helpers/user_data_session.dart';

void main() {
  for (final isEdit in [false, true]) {
    testWidgets('로컬 ${isEdit ? '수정' : '등록'}은 선택 주소를 반영하고 취소하면 보존한다', (
      tester,
    ) async {
      configureTestViewport(tester, TestViewports.reference);
      final router = createAppRouter(
        initialLocation: isEdit
            ? AppRoutePaths.placeEditLocation('place-1')
            : AppRoutePaths.placeCreate,
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '테스트 장소');
      await tester.tap(find.text('주소'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('선택').first);
      await tester.pumpAndSettle();

      expect(find.text(addressSearchFixture.first.address), findsOneWidget);
      await tester.tap(find.text('주소'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '없는 주소');
      await tester.pump();
      expect(find.text('검색 결과가 없어요'), findsOneWidget);
      // 시스템/라우터 뒤로 가기 역시 null 결과로 기존 값을 보존한다.
      router.pop();
      await tester.pumpAndSettle();

      expect(find.text(addressSearchFixture.first.address), findsOneWidget);
      expect(find.text('테스트 장소'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final viewport in [
      TestViewports.reference,
      TestViewports.compactWidth,
      TestViewports.shortHeight,
    ]) {
      testWidgets(
        'API ${isEdit ? '수정' : '등록'}은 선택 주소를 검증하고 요청 DTO에 전달한다 ($viewport)',
        (tester) async {
          configureTestViewport(tester, viewport);
          final source = _AddressPlaceDataSource();
          final (router, container) = await _pumpAddressRoutes(
            tester,
            source,
            isEdit: isEdit,
            searchResults: const [_serviceAddress],
          );
          await tester.pumpAndSettle();
          await tester.enterText(find.byType(TextField), '테스트 장소');
          await tester.pump();
          final button = find.widgetWithText(
            FilledButton,
            isEdit ? '완료' : '다음',
          );
          if (isEdit) {
            await tester.tap(find.bySemanticsLabel('선택값 삭제'));
            await tester.pump();
          }
          await tester.tap(button);
          await tester.pumpAndSettle();
          expect(source.requests, isEmpty);
          expect(find.text(placeFormAddressRequiredMessage), findsOneWidget);
          await tester.pump(
            tester.widget<SnackBar>(find.byType(SnackBar)).duration,
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('주소'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('선택'));
          await tester.pumpAndSettle();
          final form = placeFormControllerProvider(isEdit ? 'place-1' : null);
          expect(
            container.read(form).currentAddress,
            _serviceAddress.address.trim(),
          );
          expect(container.read(form).submitErrorMessage, isNull);
          expect(container.read(form).canSubmit, isTrue);
          expect(find.text(_serviceAddress.address.trim()), findsOneWidget);

          // 검색 화면의 뒤로 버튼은 반환값 없이 현재 주소를 유지한다.
          await tester.tap(find.text('주소'));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
          await tester.pumpAndSettle();
          expect(find.text(_serviceAddress.address.trim()), findsOneWidget);
          await tester.tap(button);
          await tester.pumpAndSettle();

          expect(source.requests, hasLength(1));
          expect(source.requests.single.code, isEdit ? 'place-1' : null);
          expect(source.requests.single.payload, {
            'name': '테스트 장소',
            'address': _serviceAddress.address.trim(),
          });
          expect(
            router.state.uri.path,
            isEdit ? AppRoutePaths.home : AppRoutePaths.placeFriendAdd,
          );
          if (!isEdit) {
            expect(
              router.state.uri.queryParameters['placeCode'],
              'created-place',
            );
          }
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('API ${isEdit ? '수정' : '등록'}의 기본 검색은 샘플 없이 복귀하고 기존 주소를 보존한다', (
      tester,
    ) async {
      configureTestViewport(tester, TestViewports.reference);
      final source = _AddressPlaceDataSource();
      final (_, container) = await _pumpAddressRoutes(
        tester,
        source,
        isEdit: isEdit,
      );
      await tester.pumpAndSettle();
      final form = placeFormControllerProvider(isEdit ? 'place-1' : null);
      final before = container.read(form);
      await tester.tap(find.text('주소'));
      await tester.pumpAndSettle();
      expect(find.textContaining('아직 연결되지 않았어요'), findsOneWidget);
      expect(find.text('선택'), findsNothing);
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(container.read(form), same(before));
      expect(source.requests, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('잘못 주입된 fixture route 결과도 API 폼에는 반영하지 않는다', (tester) async {
    configureTestViewport(tester, TestViewports.reference);
    final source = _AddressPlaceDataSource();
    final (_, container) = await _pumpAddressRoutes(
      tester,
      source,
      searchResults: [addressSearchFixture.first],
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '테스트 장소');
    await tester.tap(find.text('주소'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('선택'));
    await tester.pumpAndSettle();
    expect(
      container.read(placeFormControllerProvider(null)).currentAddress,
      isNull,
    );
    await tester.tap(find.widgetWithText(FilledButton, '다음'));
    await tester.pumpAndSettle();
    expect(source.requests, isEmpty);
    expect(find.text(placeFormAddressRequiredMessage), findsOneWidget);
  });

  testWidgets('검색 중 계정 세션이 교체되면 늦은 선택으로 새 폼을 덮지 않는다', (tester) async {
    configureTestViewport(tester, TestViewports.reference);
    final (_, container) = await _pumpAddressRoutes(
      tester,
      _AddressPlaceDataSource(),
      searchResults: const [_serviceAddress],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('주소'));
    await tester.pumpAndSettle();
    container.read(userDataSessionProvider.notifier).end();
    container.read(userDataSessionProvider.notifier).start();
    await tester.pump();
    final form = placeFormControllerProvider(null);
    container.read(form.notifier).updateAddress('새 계정 주소');
    await tester.tap(find.text('선택'));
    await tester.pumpAndSettle();

    expect(find.text('새 계정 주소'), findsOneWidget);
    expect(container.read(form).currentAddress, '새 계정 주소');
    expect(tester.takeException(), isNull);
  });

  testWidgets('검색을 연 화면이 폐기되면 살아 있는 폼 Provider에도 결과를 반영하지 않는다', (tester) async {
    configureTestViewport(tester, TestViewports.reference);
    final showForm = ValueNotifier(true);
    addTearDown(showForm.dispose);
    final container = ProviderContainer(
      overrides: [
        authenticatedUserDataSession,
        useRemoteApiProvider.overrideWithValue(true),
        addressSearchControllerProvider.overrideWith(
          () => _ContractAddressSearch(const [_serviceAddress]),
        ),
      ],
    );
    addTearDown(container.dispose);
    final form = placeFormControllerProvider(null);
    container.listen(form, (_, _) {});
    container.read(form.notifier).updateAddress('보존할 주소');
    final router = GoRouter(
      initialLocation: AppRoutePaths.placeCreate,
      routes: [
        GoRoute(
          path: AppRoutePaths.placeCreate,
          builder: (_, _) => ValueListenableBuilder<bool>(
            valueListenable: showForm,
            builder: (_, visible, _) =>
                visible ? const PlaceFormPage() : const SizedBox.shrink(),
          ),
        ),
        ...buildAppRoutes().whereType<GoRoute>().where(
          (route) => route.name == AppRouteNames.addressSearch,
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('주소'));
    await tester.pumpAndSettle();
    showForm.value = false;
    await tester.pumpAndSettle();
    expect(find.byType(PlaceFormPage, skipOffstage: false), findsNothing);

    await tester.tap(find.text('선택'));
    await tester.pumpAndSettle();

    expect(container.read(form).currentAddress, '보존할 주소');
    expect(tester.takeException(), isNull);
  });

  for (final fails in [false, true]) {
    testWidgets(
      '제출 중 주소 재선택은 잠금을 유지하고 ${fails ? '실패 후 새 주소로 재시도한다' : '처음 주소만 저장한다'}',
      (tester) async {
        configureTestViewport(tester, TestViewports.reference);
        final source = _AddressPlaceDataSource()..barrier = Completer<void>();
        final (router, container) = await _pumpAddressRoutes(
          tester,
          source,
          searchResults: const [_serviceAddress, _nextServiceAddress],
        );
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), '테스트 장소');
        await tester.tap(find.text('주소'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('선택').first);
        await tester.pumpAndSettle();
        final button = find.widgetWithText(FilledButton, '다음');
        final staleSubmit = tester.widget<FilledButton>(button).onPressed!;
        await tester.tap(button);
        await tester.pump();
        await tester.tap(find.text('주소'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text('선택').last);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        staleSubmit();
        await tester.pump();

        final form = placeFormControllerProvider(null);
        expect(
          container.read(form).currentAddress,
          _nextServiceAddress.address,
        );
        expect(tester.widget<FilledButton>(button).onPressed, isNull);
        expect(container.read(form).isSubmitting, isTrue);
        expect(source.requests, hasLength(1));
        expect(
          source.requests.first.payload['address'],
          _serviceAddress.address.trim(),
        );
        if (fails) {
          source.barrier!.completeError(StateError('쓰기 실패'));
          await tester.pumpAndSettle();
          expect(find.text('장소 생성에 실패했어요'), findsOneWidget);
          expect(find.text(_nextServiceAddress.address), findsOneWidget);
          await tester.pump(
            tester.widget<SnackBar>(find.byType(SnackBar)).duration,
          );
          await tester.pumpAndSettle();
          source.barrier = null;
          await tester.tap(button);
          await tester.pumpAndSettle();
          expect(source.requests, hasLength(2));
          expect(
            source.requests.last.payload['address'],
            _nextServiceAddress.address,
          );
        } else {
          source.barrier!.complete();
          await tester.pumpAndSettle();
          expect(source.requests, hasLength(1));
        }
        expect(router.state.uri.path, AppRoutePaths.placeFriendAdd);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('home에서 장소 등록 화면으로 이동한다', (WidgetTester tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('장소 추가하기'));
    await tester.pumpAndSettle();

    expect(find.text('장소 등록'), findsOneWidget);
    expect(find.text('장소의 이름을 입력해 주세요'), findsOneWidget);
  });

  testWidgets('장소 등록 다음 단계 후 홈에 장소가 추가되고 식물 추가가 활성화된다', (
    WidgetTester tester,
  ) async {
    final router = createAppRouter(initialLocation: AppRoutePaths.placeCreate);
    addTearDown(router.dispose);

    await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '옥상 정원');
    await tester.pump();
    await tester.ensureVisible(find.text('다음'));
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('친구 추가'), findsOneWidget);
    expect(
      tester
          .widget<PlaceFriendAddPage>(find.byType(PlaceFriendAddPage))
          .placeCode,
      'place-1',
    );

    await tester.ensureVisible(find.text('완료'));
    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();

    expect(find.text('My place'), findsOneWidget);
    expect(find.text('옥상 정원'), findsOneWidget);
    expect(find.text('장소 추가하기'), findsNothing);
    expect(find.bySemanticsLabel('장소 추가'), findsOneWidget);
    expect(tester.getSize(find.bySemanticsLabel('장소 추가')), const Size(24, 24));

    await tester.ensureVisible(find.text('식물 추가하기'));
    await tester.tap(find.text('식물 추가하기'));
    await tester.pumpAndSettle();

    expect(find.text('식물 등록  (1/2)'), findsOneWidget);
  });

  testWidgets('식물 등록 후 홈에서 식물 추가 카드 대신 헤더 +를 표시한다', (
    WidgetTester tester,
  ) async {
    final router = createAppRouter(initialLocation: AppRoutePaths.placeCreate);
    addTearDown(router.dispose);

    await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '옥상 정원');
    await tester.pump();
    await tester.ensureVisible(find.text('다음'));
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('완료'));
    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('식물 추가하기'));
    await tester.tap(find.text('식물 추가하기'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '몬스테라');
    await tester.pumpAndSettle();
    await tester.tap(find.text('몬스테라 델리오사'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('등록'));
    await tester.tap(find.text('등록'));
    await tester.pumpAndSettle();

    expect(find.text('My plant'), findsOneWidget);
    expect(find.text('식물 추가하기'), findsNothing);
    expect(find.bySemanticsLabel('식물 추가'), findsOneWidget);
    expect(tester.getSize(find.bySemanticsLabel('식물 추가')), const Size(24, 24));
    expect(find.bySemanticsLabel('몬스테라 델리오사'), findsOneWidget);
  });

  testWidgets('place form에서 주소 검색과 친구 추가 화면으로 이동한다', (
    WidgetTester tester,
  ) async {
    final router = createAppRouter(initialLocation: AppRoutePaths.placeCreate);
    addTearDown(router.dispose);

    await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('주소'));
    await tester.pumpAndSettle();

    expect(find.text('주소 검색'), findsOneWidget);
    expect(find.text('신도림역'), findsOneWidget);
    expect(find.text('신도림역 1호선', findRichText: true), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '옥상 정원');
    await tester.pump();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('친구 추가'), findsOneWidget);
    expect(
      tester
          .widget<PlaceFriendAddPage>(find.byType(PlaceFriendAddPage))
          .placeCode,
      'place-1',
    );
    expect(find.text('닉네임 검색'), findsOneWidget);
    expect(find.text('커먼 파파'), findsNothing);

    await tester.enterText(find.byType(TextField), '커먼');
    await tester.pumpAndSettle();

    expect(find.text('커먼 파파'), findsWidgets);
  });

  testWidgets('place detail에서 수정, 친구관리, 식물상세로 이동한다', (
    WidgetTester tester,
  ) async {
    final router = createAppRouter(
      initialLocation: AppRoutePaths.placeDetailLocation('place-1'),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('장소 상세 메뉴'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('장소 수정하기'));
    await tester.pumpAndSettle();

    expect(find.text('장소 수정'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('친구 관리'));
    await tester.pumpAndSettle();

    expect(find.text('친구 관리'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('몬테').first);
    await tester.tap(find.text('몬테').first);
    await tester.pumpAndSettle();

    expect(find.text('My plant'), findsOneWidget);
  });
}

// 실제 검색 서비스 연결이 아닌, route 반환·요청 DTO 계약용 테스트 결과.
const _serviceAddress = AddressSearchResult(
  titlePrefix: '테스트',
  titleSuffix: '장소 1',
  address: '  서울시 종로구 테스트 주소 1  ',
  source: AddressSearchResultSource.searchService,
);
const _nextServiceAddress = AddressSearchResult(
  titlePrefix: '테스트',
  titleSuffix: '장소 2',
  address: '서울시 종로구 테스트 주소 2',
  source: AddressSearchResultSource.searchService,
);

Future<(GoRouter, ProviderContainer)> _pumpAddressRoutes(
  WidgetTester tester,
  _AddressPlaceDataSource source, {
  bool isEdit = false,
  List<AddressSearchResult>? searchResults,
}) async {
  final container = ProviderContainer(
    overrides: [
      authenticatedUserDataSession,
      useRemoteApiProvider.overrideWithValue(true),
      placeRepositoryProvider.overrideWithValue(PlaceRepositoryImpl(source)),
      if (searchResults != null)
        addressSearchControllerProvider.overrideWith(
          () => _ContractAddressSearch(searchResults),
        ),
    ],
  );
  addTearDown(container.dispose);
  final router = GoRouter(
    initialLocation: isEdit
        ? AppRoutePaths.placeEditLocation('place-1')
        : AppRoutePaths.placeCreate,
    routes: [
      // 선택·등록·수정은 production route builder를 그대로 사용한다.
      ...buildAppRoutes().whereType<GoRoute>().where(
        (route) => [
          AppRouteNames.placeCreate,
          AppRouteNames.placeEdit,
          AppRouteNames.addressSearch,
        ].contains(route.name),
      ),
      GoRoute(
        path: AppRoutePaths.home,
        builder: (_, _) => const Scaffold(body: Text('테스트 홈')),
      ),
      GoRoute(
        path: AppRoutePaths.placeFriendAdd,
        builder: (_, _) => const Scaffold(body: Text('친구 추가 완료 목적지')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  return (router, container);
}

class _ContractAddressSearch extends AddressSearchController {
  _ContractAddressSearch(this.results);
  final List<AddressSearchResult> results;

  @override
  AddressSearchState build() => AddressSearchState(query: '', results: results);
}

class _AddressPlaceDataSource extends Fake implements PlaceRemoteDataSource {
  Completer<void>? barrier;
  final requests = <({String? code, Map<String, Object?> payload})>[];

  @override
  Future<Object?> getPlace(String code) async => {
    'result': {'code': code, 'name': '기존 장소', 'address': '기존 주소'},
  };

  @override
  Future<Object?> createPlace(
    CreatePlaceRequest request, {
    MultipartFile? image,
  }) async {
    requests.add((code: null, payload: request.toJson()));
    await barrier?.future;
    return {'result': 'created-place'};
  }

  @override
  Future<Object?> updatePlace({
    required String code,
    required UpdatePlaceRequest request,
    MultipartFile? image,
  }) async {
    requests.add((code: code, payload: request.toJson()));
    await barrier?.future;
    return {
      'result': {'code': code, ...request.toJson()},
    };
  }
}
