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
import 'package:commonplant_frontend/features/login/data/gateways/social_auth_credential_gateway.dart';
import 'package:commonplant_frontend/features/login/domain/models/social_auth.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_controller.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/login_controller.dart';
import 'package:commonplant_frontend/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
      await tester.ensureVisible(find.text('완료'));
      await tester.tap(find.text('완료'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('동의합니다'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('확인'));
      await tester.tap(find.text('확인'));
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

Future<void> _pumpApp(WidgetTester tester, ProviderContainer container) async {
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
  await tester.pumpAndSettle();
}

ProviderContainer _container(
  _TokenStore store,
  _AuthAdapter server, {
  SocialAuthTokenLoader? tokenLoader,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://test.invalid'))
    ..httpClientAdapter = server;
  return ProviderContainer(
    overrides: [
      useRemoteApiProvider.overrideWithValue(true),
      dioProvider.overrideWithValue(dio),
      authTokenStoreProvider.overrideWithValue(store),
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

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await requestStream?.drain<void>();
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
