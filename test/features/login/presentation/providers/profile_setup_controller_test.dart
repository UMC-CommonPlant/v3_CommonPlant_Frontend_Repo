import 'dart:async';

import 'package:commonplant_frontend/features/login/presentation/providers/profile_setup_controller.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/profile_setup_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('닉네임 입력에 따라 제출 가능 상태를 계산한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(profileSetupControllerProvider.notifier);

    expect(container.read(profileSetupControllerProvider).canSubmit, isFalse);

    controller.updateNickname('커');
    expect(container.read(profileSetupControllerProvider).canSubmit, isFalse);

    controller.updateNickname('커먼');
    expect(container.read(profileSetupControllerProvider).nickname, '커먼');
    expect(container.read(profileSetupControllerProvider).canSubmit, isTrue);
  });

  test('프로필 이미지 선택과 초기화 상태를 관리한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(profileSetupControllerProvider.notifier);

    controller.selectProfileImage();
    expect(container.read(profileSetupControllerProvider).hasImage, isTrue);

    controller.resetProfileImage();
    expect(container.read(profileSetupControllerProvider).hasImage, isFalse);
  });

  test('개인정보 약관 동의 상태를 설정하고 전환한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(profileSetupControllerProvider.notifier);

    controller.setPrivacyTermsAccepted(true);
    expect(
      container.read(profileSetupControllerProvider).isPrivacyTermsAccepted,
      isTrue,
    );

    controller.togglePrivacyTermsAccepted();
    expect(
      container.read(profileSetupControllerProvider).isPrivacyTermsAccepted,
      isFalse,
    );
  });

  test('제출은 중복 실행을 막고 submitting과 success 상태를 거친다', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final statuses = <ProfileSetupSubmitStatus>[];
    final subscription = container.listen(
      profileSetupControllerProvider,
      (previous, next) => statuses.add(next.submitStatus),
    );
    addTearDown(subscription.close);
    final controller = container.read(profileSetupControllerProvider.notifier);
    final completer = Completer<void>();

    controller.updateNickname('커먼');
    final submitFuture = controller.submit(action: () => completer.future);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(profileSetupControllerProvider).isSubmitting, isTrue);
    expect(await controller.submit(), isFalse);

    completer.complete();
    expect(await submitFuture, isTrue);
    expect(
      statuses,
      containsAllInOrder([
        ProfileSetupSubmitStatus.submitting,
        ProfileSetupSubmitStatus.success,
      ]),
    );
  });

  test('제출 실패는 사용자 메시지를 제공하고 재시도할 수 있다', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(profileSetupControllerProvider.notifier);

    controller.updateNickname('커먼');
    final didSubmit = await controller.submit(
      action: () async => throw StateError('raw failure'),
    );

    expect(didSubmit, isFalse);
    expect(
      container.read(profileSetupControllerProvider).submitStatus,
      ProfileSetupSubmitStatus.failure,
    );
    expect(
      container.read(profileSetupControllerProvider).errorMessage,
      profileSetupSubmitFailureMessage,
    );
    expect(container.read(profileSetupControllerProvider).canSubmit, isTrue);
  });
}
