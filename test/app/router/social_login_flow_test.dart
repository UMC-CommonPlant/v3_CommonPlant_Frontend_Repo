import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:commonplant_frontend/app/common_plant_app.dart';
import 'package:commonplant_frontend/app/router/app_router.dart';
import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/api_client.dart';
import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/features/home/presentation/home_screen.dart';
import 'package:commonplant_frontend/features/image/data/gateways/image_selection_gateway.dart';
import 'package:commonplant_frontend/features/login/data/gateways/social_auth_credential_gateway.dart';
import 'package:commonplant_frontend/features/login/domain/models/social_auth.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_controller.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/login_controller.dart';
import 'package:commonplant_frontend/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/image_selection.dart';
import '../../helpers/test_app.dart';

void main() {
  for (final provider in [
    SocialAuthProvider.kakao,
    SocialAuthProvider.google,
  ]) {
    final label = provider == SocialAuthProvider.kakao ? '카카오로 로그인' : '구글로 로그인';
    testWidgets('$provider 신규 → 가입 완료 → 재로그인 → 새 앱 세션 복원', (tester) async {
      final store = _TokenStore();
      final server = _AuthAdapter();
      final container = _container(store, server);
      addTearDown(container.dispose);
      await _pumpApp(tester, container);

      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(
        container
            .read(appRouterProvider)
            .routeInformationProvider
            .value
            .uri
            .path,
        AppRoutePaths.profileSetup,
      );
      expect(find.text('닉네임을 입력해 주세요'), findsOneWidget);
      expect(
        container.read(authSessionControllerProvider).requireValue.signupToken,
        'signup-token',
      );
      expect(store.saveCalls, 0);
      expect(store.accessToken, isNull);
      expect(store.refreshToken, isNull);
      expect(server.logins.single, {
        'provider': provider.apiValue,
        'token': '${provider.name}-sdk-token',
      });

      await tester.enterText(find.byType(TextField), '초록');
      await tester.tapAt(const Offset(24, 24));
      await tester.pumpAndSettle();
      await tester.tap(find.text('만 14세 이상입니다.'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('보기'));
      await tester.tap(find.text('보기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('동의합니다'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('확인'));
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('완료'));
      await tester.tap(find.text('완료'));
      await tester.pumpAndSettle();
      expect(server.registration, {
        'signupToken': 'signup-token',
        'name': '초록',
      });
      expect(store.saveCalls, 1);
      expect(store.accessToken, 'registered-access');
      expect(store.refreshToken, 'registered-refresh');
      expect(
        container
            .read(authSessionControllerProvider)
            .requireValue
            .isAuthenticated,
        isTrue,
      );
      expect(
        container
            .read(appRouterProvider)
            .routeInformationProvider
            .value
            .uri
            .path,
        AppRoutePaths.home,
      );
      expect(find.byType(HomeScreen), findsOneWidget);

      await container
          .read(authSessionControllerProvider.notifier)
          .clearSession();
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(server.logins.length, 2);
      expect(store.saveCalls, 2);
      expect(store.accessToken, 'existing-access');
      expect(store.refreshToken, 'existing-refresh');
      expect(
        container
            .read(appRouterProvider)
            .routeInformationProvider
            .value
            .uri
            .path,
        AppRoutePaths.home,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      final restarted = _container(store, server);
      addTearDown(restarted.dispose);
      await _pumpApp(tester, restarted);
      expect(
        restarted
            .read(authSessionControllerProvider)
            .requireValue
            .isAuthenticated,
        isTrue,
      );
      expect(
        restarted
            .read(appRouterProvider)
            .routeInformationProvider
            .value
            .uri
            .path,
        AppRoutePaths.home,
      );
      expect(server.logins.length, 2);
    });

    for (final failure in [
      'cancel',
      'sdk',
      'backend',
      'missing-signup',
      'invalid-token',
      'not-json',
    ]) {
      testWidgets('$provider $failure 실패 후 버튼·세션 복구와 재시도', (tester) async {
        final store = _TokenStore();
        final server = _AuthAdapter()..failure = failure;
        final barrier = Completer<String?>();
        var sdkCalls = 0;
        Future<String?> load() async {
          sdkCalls++;
          if (sdkCalls == 1) return barrier.future;
          return '${provider.name}-sdk-token';
        }

        final container = _container(store, server, tokenLoader: load);
        addTearDown(container.dispose);
        await _pumpApp(tester, container);
        final firstCallback = tester
            .widget<InkWell>(
              find.descendant(
                of: find.byKey(
                  ValueKey(
                    provider == SocialAuthProvider.kakao
                        ? 'loginKakaoButton'
                        : 'loginGoogleButton',
                  ),
                ),
                matching: find.byType(InkWell),
              ),
            )
            .onTap!;
        firstCallback();
        firstCallback();
        await tester.pump();
        expect(sdkCalls, 1);
        expect(container.read(loginControllerProvider).isSubmitting, isTrue);
        for (final button in ['loginKakaoButton', 'loginGoogleButton']) {
          expect(
            tester
                .widget<InkWell>(
                  find.descendant(
                    of: find.byKey(ValueKey(button)),
                    matching: find.byType(InkWell),
                  ),
                )
                .onTap,
            isNull,
          );
        }
        if (failure == 'cancel') {
          barrier.completeError(const SocialAuthCanceledException());
        } else if (failure == 'sdk') {
          barrier.completeError(StateError('private-sdk-details'));
        } else {
          barrier.complete('${provider.name}-sdk-token');
        }
        await tester.pumpAndSettle();
        expect(container.read(loginControllerProvider).isSubmitting, isFalse);
        expect(
          container
              .read(authSessionControllerProvider)
              .requireValue
              .isUnauthenticated,
          isTrue,
        );
        expect(store.saveCalls, 0);
        expect(store.accessToken, isNull);
        expect(store.refreshToken, isNull);
        expect(
          container
              .read(appRouterProvider)
              .routeInformationProvider
              .value
              .uri
              .path,
          AppRoutePaths.login,
        );
        expect(
          find.text(
            failure == 'backend'
                ? '서버에 문제가 발생했어요. 잠시 후 다시 시도해 주세요.'
                : socialLoginFailureMessage,
          ),
          failure == 'cancel' ? findsNothing : findsOneWidget,
        );
        expect(find.textContaining('private-'), findsNothing);
        expect(
          server.logins.length,
          ['cancel', 'sdk'].contains(failure) ? 0 : 1,
        );

        server.failure = null;
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(sdkCalls, 2);
        expect(
          container
              .read(authSessionControllerProvider)
              .requireValue
              .isSignupRequired,
          isTrue,
        );
        expect(find.text('닉네임을 입력해 주세요'), findsOneWidget);
      });
    }
  }

  for (final rejectsNickname in [true, false]) {
    testWidgets(
      rejectsNickname
          ? '가입 중 닉네임이 거절되면 프로필에 초안과 동의를 보존한다'
          : '가입 서버 장애는 프로필에서 안내하고 다시 제출할 수 있다',
      (tester) async {
        const nicknameError = '이 닉네임은 사용할 수 없어요.';
        final initialName = rejectsNickname ? '새싹' : '초록';
        final store = _TokenStore();
        final server = _AuthAdapter()
          ..registrationFailure = ResponseBody.fromString(
            jsonEncode(
              rejectsNickname
                  ? {
                      'errors': [
                        {'field': 'name', 'reason': nicknameError},
                      ],
                    }
                  : {'message': 'Unavailable'},
            ),
            rejectsNickname ? 400 : 503,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        final container = _container(
          store,
          server,
          imageGateway: FakeImageSelectionGateway(
            () async => testSelectedImage(),
          ),
        );
        addTearDown(container.dispose);
        await _pumpApp(tester, container);
        await tester.tap(find.text('카카오로 로그인'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), initialName);
        await tester.tap(find.bySemanticsLabel('사진 선택'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('만 14세 이상입니다.'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('보기'));
        await tester.tap(find.text('보기'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('동의합니다'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('확인'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('완료'));
        await tester.tap(find.text('완료'));
        await tester.pumpAndSettle();

        expect(store.saveCalls, 0);
        expect(server.registration, {
          'signupToken': 'signup-token',
          'name': initialName,
        });
        server.registrationFailure = null;
        if (rejectsNickname) {
          expect(find.text(nicknameError).hitTestable(), findsOneWidget);
          expect(find.text(initialName), findsOneWidget);
          expect(find.bySemanticsLabel('사진 교체'), findsOneWidget);
          expect(find.bySemanticsLabel('개인정보 이용약관 동의됨'), findsOneWidget);
          await tester.enterText(find.byType(TextField), '초록');
          await tester.tapAt(const Offset(24, 24));
          await tester.pumpAndSettle();
          expect(find.text(nicknameError), findsNothing);
          await tester.ensureVisible(find.text('완료'));
          await tester.tap(find.text('완료'));
        } else {
          expect(find.text('서버에 문제가 발생했어요. 잠시 후 다시 시도해 주세요.'), findsOneWidget);
          await tester.tap(find.text('완료'));
        }
        await tester.pumpAndSettle();

        expect(server.registration, {
          'signupToken': 'signup-token',
          'name': '초록',
        });
        expect(store.saveCalls, 1);
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );
  }

  testWidgets('회원탈퇴는 확인 후 요청하며 실패 후 재시도해 로그인으로 이동한다', (tester) async {
    final store = _TokenStore()
      ..accessToken = 'active-access'
      ..refreshToken = 'active-refresh';
    final pending = Completer<ResponseBody>();
    final server = _AuthAdapter()..accountDeletionResponse = pending.future;
    final container = _container(store, server);
    addTearDown(container.dispose);
    await _pumpApp(tester, container);
    final router = container.read(appRouterProvider);
    router.go(AppRoutePaths.userSettings);
    await tester.pumpAndSettle();
    await tester.tap(find.text('회원탈퇴'));
    await tester.pumpAndSettle();

    final deleteButton = find.widgetWithText(CommonButton, '계정 삭제하기');
    expect(tester.widget<CommonButton>(deleteButton).onPressed, isNull);
    expect(server.accountDeletionCalls, 0);

    await tester.tap(find.text('유의사항을 모두 확인하였습니다.'));
    await tester.pump();
    expect(tester.widget<CommonButton>(deleteButton).onPressed, isNotNull);
    await tester.tap(deleteButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.widget<CommonButton>(deleteButton).isLoading, isTrue);
    expect(server.accountDeletionCalls, 1);
    await tester.tap(deleteButton);
    await tester.pump();
    expect(server.accountDeletionCalls, 1);

    pending.complete(ResponseBody.fromString('{}', 503));
    await tester.pumpAndSettle();
    expect(find.text('서버에 문제가 발생했어요. 잠시 후 다시 시도해 주세요.'), findsOneWidget);
    expect(store.accessToken, 'active-access');
    expect(tester.widget<CommonButton>(deleteButton).onPressed, isNotNull);

    server.accountDeletionResponse = Future.value(
      ResponseBody.fromString('', 204),
    );
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(server.accountDeletionCalls, 2);
    expect(router.routeInformationProvider.value.uri.path, AppRoutePaths.login);
    expect(store.accessToken, isNull);
    expect(store.refreshToken, isNull);
  });

  for (final succeeds in [true, false]) {
    testWidgets(
      'refresh-only 확인 중 로그인하지 않고 결과에 따라 보호 route를 처리한다 ($succeeds)',
      (tester) async {
        final response = Completer<ResponseBody>();
        final store = _TokenStore()..refreshToken = 'saved-refresh';
        final server = _AuthAdapter()..refreshResponse = response;
        final container = _container(store, server);
        addTearDown(container.dispose);
        await _pumpApp(tester, container, settle: false);
        await tester.pump(const Duration(milliseconds: 100));
        container.read(appRouterProvider).go(AppRoutePaths.userSettings);
        await tester.pump(const Duration(milliseconds: 100));

        expect(container.read(authSessionControllerProvider).isLoading, isTrue);
        expect(find.text('카카오로 로그인'), findsNothing);
        expect(find.bySemanticsLabel('로그인 확인 중'), findsOneWidget);
        expect(find.text('데이터를 불러오지 못했어요'), findsNothing);
        expect(find.text('사용자 정보를 불러오지 못했어요'), findsNothing);
        expect(find.text('로그아웃'), findsNothing);
        expect(server.refreshCalls, 1);
        expect(store.saveCalls, 0);
        response.complete(
          ResponseBody.fromString(
            jsonEncode(
              succeeds
                  ? {
                      'result': {'accessToken': 'refreshed-access'},
                    }
                  : {'code': 'A004', 'message': 'expired'},
            ),
            succeeds ? 200 : 401,
            headers: {
              Headers.contentTypeHeader: ['application/json'],
            },
          ),
        );
        await tester.pumpAndSettle();

        final uri = container
            .read(appRouterProvider)
            .routeInformationProvider
            .value
            .uri;
        expect(
          uri.path,
          succeeds ? AppRoutePaths.userSettings : AppRoutePaths.login,
        );
        expect(server.logins, isEmpty);
        expect(find.bySemanticsLabel('로그인 확인 중'), findsNothing);
        expect(store.accessToken, succeeds ? 'refreshed-access' : isNull);
        expect(store.refreshToken, succeeds ? 'saved-refresh' : isNull);
        if (!succeeds) {
          expect(uri.queryParameters['redirect'], AppRoutePaths.userSettings);
          expect(find.text('카카오로 로그인'), findsOneWidget);
        }
      },
    );
  }

  testWidgets('기존 사용자의 로그인 전 보호 route를 성공 후 보존한다', (tester) async {
    final container = _container(
      _TokenStore(),
      _AuthAdapter()..registered = true,
    );
    addTearDown(container.dispose);
    await _pumpApp(tester, container);
    container.read(appRouterProvider).go(AppRoutePaths.userSettings);
    await tester.pumpAndSettle();
    await tester.tap(find.text('카카오로 로그인'));
    await tester.pumpAndSettle();
    expect(
      container.read(appRouterProvider).routeInformationProvider.value.uri.path,
      AppRoutePaths.userSettings,
    );
  });
}

Future<void> _pumpApp(
  WidgetTester tester,
  ProviderContainer container, {
  bool settle = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(375, 812);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const CommonPlantApp(),
    ),
  );
  if (settle) await tester.pumpAndSettle();
}

ProviderContainer _container(
  _TokenStore store,
  _AuthAdapter server, {
  SocialAuthTokenLoader? tokenLoader,
  ImageSelectionGateway? imageGateway,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://test.invalid'))
    ..httpClientAdapter = server;
  return ProviderContainer(
    overrides: [
      useRemoteApiProvider.overrideWithValue(true),
      dioProvider.overrideWithValue(dio),
      authTokenStoreProvider.overrideWithValue(store),
      if (imageGateway != null)
        imageSelectionGatewayProvider.overrideWithValue(imageGateway),
      onboardingLocalStoreProvider.overrideWithValue(
        TestOnboardingLocalStore(completed: true),
      ),
      socialAuthCredentialGatewayProvider.overrideWithValue(
        SdkSocialAuthCredentialGateway(
          kakaoNativeAppKey: 'test-key',
          googleServerClientId: 'test-client',
          googleIosClientId: '',
          targetPlatform: TargetPlatform.android,
          kakaoTokenLoader: tokenLoader ?? () async => 'kakao-sdk-token',
          googleTokenLoader: tokenLoader ?? () async => 'google-sdk-token',
        ),
      ),
    ],
  );
}

class _AuthAdapter implements HttpClientAdapter {
  bool registered = false;
  String? failure;
  final logins = <Object?>[];
  Object? registration;
  ResponseBody? registrationFailure;
  int refreshCalls = 0;
  int accountDeletionCalls = 0;
  Future<ResponseBody>? accountDeletionResponse;
  Completer<ResponseBody>? refreshResponse;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await requestStream?.drain<void>();
    if (options.path == '/users' && options.method == 'DELETE') {
      accountDeletionCalls++;
      return accountDeletionResponse!;
    }
    if (options.path == '/auth/refresh') {
      refreshCalls++;
      expect(options.data, {'refreshToken': 'saved-refresh'});
      return refreshResponse!.future;
    }
    Object? body;
    var status = 200;
    if (options.path == '/auth/login') {
      logins.add(options.data);
      body = {
        'result': registered
            ? {
                'isNewUser': false,
                'accessToken': 'existing-access',
                'refreshToken': 'existing-refresh',
              }
            : {
                'isNewUser': true,
                'signupToken': 'signup-token',
                'accessToken': 'must-not-save',
                'refreshToken': 'must-not-save',
              },
      };
      switch (failure) {
        case 'backend':
          status = 500;
          body = {'message': 'private-backend-details'};
        case 'missing-signup':
          body = {
            'result': {
              'isNewUser': true,
              'accessToken': 'must-not-save',
              'refreshToken': 'must-not-save',
            },
          };
        case 'invalid-token':
          body = {
            'result': {
              'isNewUser': false,
              'accessToken': 123,
              'refreshToken': 'refresh',
            },
          };
        case 'not-json':
          body = ['invalid'];
      }
    } else if (options.path == '/auth/register') {
      final data = options.data as FormData;
      final part = data.files
          .singleWhere((entry) => entry.key == 'register')
          .value;
      registration = jsonDecode(
        utf8.decode(
          await part.clone().finalize().expand((bytes) => bytes).toList(),
        ),
      );
      if (registrationFailure case final failure?) return failure;
      registered = true;
      body = {
        'result': {
          'isNewUser': true,
          'accessToken': 'registered-access',
          'refreshToken': 'registered-refresh',
        },
      };
    } else {
      // 인증 외 Home 조회는 실패 UI로 종료하며 실제 네트워크를 사용하지 않는다.
      status = 503;
      body = {'message': 'Unavailable in auth test'};
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _TokenStore implements AuthTokenStore {
  String? accessToken;
  String? refreshToken;
  int saveCalls = 0;

  @override
  Future<String?> readAccessToken() async => accessToken;
  @override
  Future<String?> readRefreshToken() async => refreshToken;
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    saveCalls++;
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
  }
}
