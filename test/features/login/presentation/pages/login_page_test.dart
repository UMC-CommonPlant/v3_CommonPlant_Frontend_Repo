import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/features/login/data/gateways/social_auth_credential_gateway.dart';
import 'package:commonplant_frontend/features/login/presentation/pages/login_page.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('로그인 화면은 Figma 기준 로고와 소셜 로그인 버튼을 표시한다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_loginPageApp());

    expect(find.text('9:41'), findsNothing);
    expect(find.bySemanticsLabel('Common'), findsOneWidget);
    expect(find.bySemanticsLabel('Plant'), findsOneWidget);
    expect(find.bySemanticsLabel('로그인 일러스트'), findsOneWidget);
    expect(find.text('카카오로 로그인'), findsOneWidget);
    expect(find.text('구글로 로그인'), findsOneWidget);
    expect(find.text('Apple로 로그인'), findsOneWidget);

    expect(
      tester.getTopLeft(find.byKey(const ValueKey('loginWordmark'))).dy,
      closeTo(140, 0.01),
    );
    expect(
      tester.getSize(find.bySemanticsLabel('로그인 일러스트')),
      closeToSize(const Size(186, 186), 0.01),
    );
    expect(
      tester.getTopLeft(find.bySemanticsLabel('로그인 일러스트')).dy,
      closeTo(204.377, 0.01),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('loginKakaoButton'))),
      closeToSize(const Size(335, 44), 0.01),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('loginKakaoButton'))).dy,
      closeTo(582, 0.01),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('loginGoogleButton'))).dy,
      closeTo(638, 0.01),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('loginAppleButton'))).dy,
      closeTo(694, 0.01),
    );
  });

  testWidgets('로그인 화면은 낮은 높이에서 주요 요소를 세로 축소 배치한다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_loginPageApp());

    final illustrationSize = tester.getSize(find.bySemanticsLabel('로그인 일러스트'));
    expect(illustrationSize.width, lessThan(186));
    expect(illustrationSize.height, lessThan(186));
    expect(find.text('카카오로 로그인'), findsOneWidget);
    expect(find.text('구글로 로그인'), findsOneWidget);
    expect(find.text('Apple로 로그인'), findsOneWidget);
  });

  testWidgets('API 모드에서 SDK adapter가 없으면 설정 안내를 표시한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          authTokenStoreProvider.overrideWithValue(_EmptyAuthTokenStore()),
          socialAuthCredentialGatewayProvider.overrideWithValue(
            const UnconfiguredSocialAuthCredentialGateway(),
          ),
        ],
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    await tester.tap(find.text('카카오로 로그인'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('loginErrorMessage')), findsOneWidget);
    expect(find.text(socialLoginNotConfiguredMessage), findsOneWidget);
  });
}

Widget _loginPageApp() {
  return const ProviderScope(child: MaterialApp(home: LoginPage()));
}

class _EmptyAuthTokenStore implements AuthTokenStore {
  @override
  Future<void> clear() async {}

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}
}

Matcher closeToSize(Size expected, double delta) {
  return predicate<Size>(
    (actual) =>
        (actual.width - expected.width).abs() <= delta &&
        (actual.height - expected.height).abs() <= delta,
    'is within $delta of $expected',
  );
}
