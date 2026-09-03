import 'package:commonplant_frontend/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_app.dart';

void main() {
  test('저장된 값이 없으면 미완료 상태로 시작한다', () async {
    final container = ProviderContainer(
      overrides: [
        onboardingLocalStoreProvider.overrideWithValue(
          TestOnboardingLocalStore(),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(await container.read(onboardingControllerProvider.future), isFalse);
  });

  test('완료하면 로컬 값과 Provider 상태를 함께 갱신한다', () async {
    final store = TestOnboardingLocalStore();
    final container = ProviderContainer(
      overrides: [onboardingLocalStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    await container.read(onboardingControllerProvider.future);

    final didComplete = await container
        .read(onboardingControllerProvider.notifier)
        .complete();

    expect(didComplete, isTrue);
    expect(store.completed, isTrue);
    expect(store.writeCount, 1);
    expect(container.read(onboardingControllerProvider).value, isTrue);
  });

  test('새 ProviderScope에서도 저장된 완료 값을 복원한다', () async {
    final store = TestOnboardingLocalStore();
    final firstContainer = ProviderContainer(
      overrides: [onboardingLocalStoreProvider.overrideWithValue(store)],
    );
    await firstContainer.read(onboardingControllerProvider.future);
    await firstContainer.read(onboardingControllerProvider.notifier).complete();
    firstContainer.dispose();

    final secondContainer = ProviderContainer(
      overrides: [onboardingLocalStoreProvider.overrideWithValue(store)],
    );
    addTearDown(secondContainer.dispose);

    expect(
      await secondContainer.read(onboardingControllerProvider.future),
      isTrue,
    );
  });

  test('저장 실패 뒤 같은 Controller에서 다시 시도할 수 있다', () async {
    final store = TestOnboardingLocalStore(writeFailures: 1);
    final container = ProviderContainer(
      overrides: [onboardingLocalStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    await container.read(onboardingControllerProvider.future);

    final firstResult = await container
        .read(onboardingControllerProvider.notifier)
        .complete();
    final secondResult = await container
        .read(onboardingControllerProvider.notifier)
        .complete();

    expect(firstResult, isFalse);
    expect(secondResult, isTrue);
    expect(store.completed, isTrue);
    expect(store.writeCount, 2);
    expect(container.read(onboardingControllerProvider).value, isTrue);
  });
}
