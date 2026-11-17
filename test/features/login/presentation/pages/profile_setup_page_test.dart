import 'package:commonplant_frontend/features/image/data/gateways/image_selection_gateway.dart';
import 'package:commonplant_frontend/features/login/presentation/pages/profile_setup_page.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/profile_setup_controller.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/image_selection.dart';

void main() {
  testWidgets('프로필 설정 기본 화면은 Figma 기준 빈 입력 상태를 표시한다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_profileSetupApp());

    expect(find.text('9:41'), findsNothing);
    expect(find.text('프로필 설정'), findsNothing);
    expect(find.bySemanticsLabel('프로필 추가'), findsOneWidget);
    expect(find.text('닉네임을 입력해 주세요'), findsOneWidget);
    expect(find.textContaining('0/10', findRichText: true), findsOneWidget);
    expect(find.text('만 14세 이상입니다.'), findsOneWidget);
    expect(find.bySemanticsLabel('만 14세 이상입니다.'), findsOneWidget);
    expect(find.text('개인정보 이용 약관 동의'), findsOneWidget);
    expect(find.bySemanticsLabel('개인정보 이용약관 동의 필요'), findsOneWidget);
    expect(find.text('보기'), findsOneWidget);
    final ageRow = find.byKey(const ValueKey('profileAgeRow'));
    final termsRow = find.byKey(const ValueKey('profileTermsRow'));
    expect(tester.getBottomLeft(ageRow).dy, tester.getTopLeft(termsRow).dy);
    expect(
      find.descendant(of: ageRow, matching: find.text('보기')),
      findsNothing,
    );
    expect(find.text('완료'), findsOneWidget);

    expect(
      tester.getTopLeft(find.bySemanticsLabel('사진 선택')).dy,
      closeTo(147, 0.01),
    );
    expect(
      tester.getSize(find.bySemanticsLabel('사진 선택')),
      closeToSize(const Size(100, 100), 0.01),
    );
    final sizeHint = find.text('사진은 최대 10MB까지 업로드할 수 있어요.');
    expect(sizeHint.hitTestable(), findsOneWidget);
    expect(
      tester.getTopLeft(sizeHint).dy,
      greaterThan(tester.getBottomRight(find.bySemanticsLabel('사진 선택')).dy),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('profileNicknameField'))).dy,
      greaterThan(tester.getBottomRight(sizeHint).dy),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('profileTermsRow'))).dy,
      closeTo(626, 0.01),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('profileCompleteButton'))).dy,
      closeTo(698, 0.01),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('profileCompleteButton'))),
      closeToSize(const Size(335, 48), 0.01),
    );
  });

  testWidgets('실제 선택 초안을 미리보고 교체·취소한다', (tester) async {
    final image = testSelectedImage();
    final gateway = FakeImageSelectionGateway(() async => image);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [imageSelectionGatewayProvider.overrideWithValue(gateway)],
        child: const MaterialApp(home: ProfileSetupPage()),
      ),
    );
    await tester.tap(find.bySemanticsLabel('사진 선택'));
    await tester.pumpAndSettle();
    expect(gateway.calls, 1);
    expect(find.byType(Image), findsOneWidget);
    expect(tester.widget<Image>(find.byType(Image)).image, isA<MemoryImage>());
    await tester.tap(find.bySemanticsLabel('사진 교체'));
    await tester.pumpAndSettle();
    expect(gateway.calls, 2);
    await tester.tap(find.text('선택 취소'));
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('닉네임이 유효하고 두 체크박스를 선택해야 완료 버튼을 활성화한다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_profileSetupApp());

    await tester.enterText(find.byType(TextField), '커먼');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('커먼'), findsOneWidget);
    expect(find.textContaining('0/10', findRichText: true), findsNothing);
    expect(find.text('사용 가능한 닉네임입니다'), findsNothing);
    final button = find.byKey(const ValueKey('profileCompleteButton'));
    final ageCheck = find.text('만 14세 이상입니다.');
    expect(tester.widget<CommonButton>(button).onPressed, isNull);

    await tester.tap(ageCheck);
    await tester.pump();
    expect(tester.widget<CommonButton>(button).onPressed, isNull);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProfileSetupPage)),
      listen: false,
    );
    container
        .read(profileSetupControllerProvider.notifier)
        .setPrivacyTermsAccepted(true);
    await tester.pump();
    expect(tester.widget<CommonButton>(button).onPressed, isNotNull);
    expect(tester.getSize(button), closeToSize(const Size(335, 48), 0.01));

    await tester.tap(ageCheck);
    await tester.pump();
    expect(tester.widget<CommonButton>(button).onPressed, isNull);

    await tester.tap(ageCheck);
    await tester.pump();
    expect(tester.widget<CommonButton>(button).onPressed, isNotNull);
    await tester.tap(find.text('개인정보 이용 약관 동의'));
    await tester.pump();
    expect(tester.widget<CommonButton>(button).onPressed, isNull);
  });

  testWidgets('닉네임에서 포커스가 벗어나면 오류를 표시하고 수정 시 바로 갱신한다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_profileSetupApp());

    final field = find.byType(TextField);
    final button = find.byKey(const ValueKey('profileCompleteButton'));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProfileSetupPage)),
      listen: false,
    );
    container
        .read(profileSetupControllerProvider.notifier)
        .setPrivacyTermsAccepted(true);
    await tester.tap(find.text('만 14세 이상입니다.'));
    await tester.pump();
    final characterError = find.text('닉네임은 한글, 영문, 공백만 사용할 수 있어요');
    final lengthError = find.text('2~10자의 닉네임으로 입력해 주세요');

    await tester.enterText(field, '초록1');
    await tester.pump();
    expect(characterError, findsNothing);
    expect(tester.widget<CommonButton>(button).onPressed, isNull);

    await tester.tapAt(const Offset(24, 24));
    await tester.pumpAndSettle();
    expect(characterError.hitTestable(), findsOneWidget);
    expect(tester.widget<CommonButton>(button).onPressed, isNull);

    await tester.enterText(field, '커');
    await tester.pump();
    expect(lengthError, findsOneWidget);
    expect(characterError, findsNothing);
    expect(tester.widget<CommonButton>(button).onPressed, isNull);

    await tester.enterText(field, '초록 Green');
    await tester.pump();
    expect(lengthError, findsNothing);
    expect(characterError, findsNothing);
    expect(tester.widget<CommonButton>(button).onPressed, isNotNull);
  });

  testWidgets('프로필 설정 화면은 낮은 높이에서 주요 요소를 세로 축소 배치한다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_profileSetupApp());

    expect(tester.getTopLeft(find.bySemanticsLabel('사진 선택')).dy, lessThan(147));
    expect(find.text('만 14세 이상입니다.').hitTestable(), findsOneWidget);
    expect(find.text('닉네임을 입력해 주세요'), findsOneWidget);
    expect(find.text('완료'), findsOneWidget);
  });

  testWidgets('작은 화면에서 사진 선택 후 키보드를 열어도 입력과 완료 버튼에 접근한다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          imageSelectionGatewayProvider.overrideWithValue(
            FakeImageSelectionGateway(() async => testSelectedImage()),
          ),
        ],
        child: const MaterialApp(home: ProfileSetupPage()),
      ),
    );
    await tester.tap(find.bySemanticsLabel('사진 선택'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    expect(
      tester
          .getBottomRight(find.byKey(const ValueKey('profileCompleteButton')))
          .dy,
      lessThanOrEqualTo(340),
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('profileNicknameField')),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .getBottomRight(find.byKey(const ValueKey('profileNicknameField')))
          .dy,
      lessThanOrEqualTo(
        tester.getTopLeft(find.byKey(const ValueKey('profileAgeRow'))).dy,
      ),
    );
    expect(find.text('만 14세 이상입니다.').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('프로필 설정 화면은 약관 동의 상태를 체크 아이콘에 반영한다', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProfileSetupPage()),
      ),
    );

    container
        .read(profileSetupControllerProvider.notifier)
        .setPrivacyTermsAccepted(true);
    await tester.pump();

    expect(find.bySemanticsLabel('개인정보 이용약관 동의됨'), findsOneWidget);
  });
}

Widget _profileSetupApp() {
  return const ProviderScope(child: MaterialApp(home: ProfileSetupPage()));
}

Matcher closeToSize(Size expected, double delta) {
  return predicate<Size>(
    (actual) =>
        (actual.width - expected.width).abs() <= delta &&
        (actual.height - expected.height).abs() <= delta,
    'is within $delta of $expected',
  );
}
