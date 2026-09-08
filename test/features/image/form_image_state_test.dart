import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/image/data/gateways/image_selection_gateway.dart';
import 'package:commonplant_frontend/features/image/data/models/selected_image.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/profile_setup_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_controller.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_controller.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_state.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_profile_edit_controller.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_profile_edit_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/image_selection.dart';

void main() {
  test('signup: 선택·교체·취소·오류는 기존 초안을 보존하고 중복 선택을 차단한다', () async {
    final first = testSelectedImage();
    final second = testSelectedImage();
    Future<SelectedImage?> Function() action = () async => first;
    final gateway = FakeImageSelectionGateway(() => action());
    final container = ProviderContainer(
      overrides: [
        useRemoteApiProvider.overrideWithValue(false),
        imageSelectionGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);
    final provider = profileSetupControllerProvider;
    container.listen(provider, (_, _) {});
    final controller = container.read(provider.notifier);
    await controller.selectImage();
    expect(container.read(provider).selectedImage, same(first));
    action = () async => second;
    await controller.selectImage();
    expect(container.read(provider).selectedImage, same(second));
    action = () async => null;
    await controller.selectImage();
    expect(container.read(provider).selectedImage, same(second));
    action = () => Future.error(const ImageSelectionException('사진 선택 실패'));
    expect(await controller.selectImage(), '사진 선택 실패');
    expect(container.read(provider).selectedImage, same(second));
    final pending = Completer<SelectedImage?>();
    action = () => pending.future;
    final selection = controller.selectImage();
    expect(container.read(provider).canSubmit, isFalse);
    await controller.selectImage();
    controller.clearSelectedImage();
    expect(gateway.calls, 5);
    expect(container.read(provider).selectedImage, same(second));
    pending.complete(null);
    await selection;
    expect(container.read(provider).isPickingImage, isFalse);
    controller.clearSelectedImage();
    expect(container.read(provider).selectedImage, isNull);
  });
  for (final dispose in [false, true]) {
    test('signup: 늦은 결과는 세션 변경·폼 폐기 이후 반영되지 않는다 ($dispose)', () async {
      final pending = Completer<SelectedImage?>();
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(false),
          imageSelectionGatewayProvider.overrideWithValue(
            FakeImageSelectionGateway(() => pending.future),
          ),
        ],
      );
      final provider = profileSetupControllerProvider;
      container.listen(provider, (_, _) {});
      final selection = container.read(provider.notifier).selectImage();
      if (dispose) {
        container.dispose();
      } else {
        container.read(userDataSessionProvider.notifier).start();
      }
      pending.complete(testSelectedImage());
      expect(await selection, isNull);
      if (!dispose) {
        expect(container.read(provider).selectedImage, isNull);
        container.dispose();
      }
    });
  }

  test('place: 선택·교체·취소·오류는 기존 초안을 보존하고 중복 선택을 차단한다', () async {
    final first = testSelectedImage();
    final second = testSelectedImage();
    Future<SelectedImage?> Function() action = () async => first;
    final gateway = FakeImageSelectionGateway(() => action());
    final container = ProviderContainer(
      overrides: [
        useRemoteApiProvider.overrideWithValue(false),
        imageSelectionGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);
    final provider = placeFormControllerProvider(null);
    container.listen(provider, (_, _) {});
    final controller = container.read(provider.notifier);
    await controller.selectImage();
    expect(container.read(provider).selectedImage, same(first));
    action = () async => second;
    await controller.selectImage();
    expect(container.read(provider).selectedImage, same(second));
    action = () async => null;
    await controller.selectImage();
    expect(container.read(provider).selectedImage, same(second));
    action = () => Future.error(const ImageSelectionException('사진 선택 실패'));
    expect(await controller.selectImage(), '사진 선택 실패');
    expect(container.read(provider).selectedImage, same(second));
    final pending = Completer<SelectedImage?>();
    action = () => pending.future;
    final selection = controller.selectImage();
    expect(container.read(provider).canSubmit, isFalse);
    await controller.selectImage();
    controller.clearSelectedImage();
    expect(gateway.calls, 5);
    expect(container.read(provider).selectedImage, same(second));
    pending.complete(null);
    await selection;
    expect(container.read(provider).isPickingImage, isFalse);
    controller.clearSelectedImage();
    expect(container.read(provider).selectedImage, isNull);
  });
  for (final dispose in [false, true]) {
    test('place: 늦은 결과는 세션 변경·폼 폐기 이후 반영되지 않는다 ($dispose)', () async {
      final pending = Completer<SelectedImage?>();
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(false),
          imageSelectionGatewayProvider.overrideWithValue(
            FakeImageSelectionGateway(() => pending.future),
          ),
        ],
      );
      final provider = placeFormControllerProvider(null);
      container.listen(provider, (_, _) {});
      final selection = container.read(provider.notifier).selectImage();
      if (dispose) {
        container.dispose();
      } else {
        container.read(userDataSessionProvider.notifier).start();
      }
      pending.complete(testSelectedImage());
      expect(await selection, isNull);
      if (!dispose) {
        expect(container.read(provider).selectedImage, isNull);
        container.dispose();
      }
    });
  }

  test('plant: 선택·교체·취소·오류는 기존 초안을 보존하고 중복 선택을 차단한다', () async {
    final first = testSelectedImage();
    final second = testSelectedImage();
    Future<SelectedImage?> Function() action = () async => first;
    final gateway = FakeImageSelectionGateway(() => action());
    final container = ProviderContainer(
      overrides: [
        useRemoteApiProvider.overrideWithValue(false),
        imageSelectionGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);
    final provider = plantFormControllerProvider(
      const PlantFormArgs(initialPlantName: '몬스테라'),
    );
    container.listen(provider, (_, _) {});
    final controller = container.read(provider.notifier);
    await controller.selectImage();
    expect(container.read(provider).selectedImage, same(first));
    action = () async => second;
    await controller.selectImage();
    expect(container.read(provider).selectedImage, same(second));
    action = () async => null;
    await controller.selectImage();
    expect(container.read(provider).selectedImage, same(second));
    action = () => Future.error(const ImageSelectionException('사진 선택 실패'));
    expect(await controller.selectImage(), '사진 선택 실패');
    expect(container.read(provider).selectedImage, same(second));
    final pending = Completer<SelectedImage?>();
    action = () => pending.future;
    final selection = controller.selectImage();
    expect(container.read(provider).canSubmit, isFalse);
    await controller.selectImage();
    controller.clearSelectedImage();
    expect(gateway.calls, 5);
    expect(container.read(provider).selectedImage, same(second));
    pending.complete(null);
    await selection;
    expect(container.read(provider).isPickingImage, isFalse);
    controller.clearSelectedImage();
    expect(container.read(provider).selectedImage, isNull);
  });
  for (final dispose in [false, true]) {
    test('plant: 늦은 결과는 세션 변경·폼 폐기 이후 반영되지 않는다 ($dispose)', () async {
      final pending = Completer<SelectedImage?>();
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(false),
          imageSelectionGatewayProvider.overrideWithValue(
            FakeImageSelectionGateway(() => pending.future),
          ),
        ],
      );
      final provider = plantFormControllerProvider(
        const PlantFormArgs(initialPlantName: '몬스테라'),
      );
      container.listen(provider, (_, _) {});
      final selection = container.read(provider.notifier).selectImage();
      if (dispose) {
        container.dispose();
      } else {
        container.read(userDataSessionProvider.notifier).start();
      }
      pending.complete(testSelectedImage());
      expect(await selection, isNull);
      if (!dispose) {
        expect(container.read(provider).selectedImage, isNull);
        container.dispose();
      }
    });
  }

  test('user: 선택·교체·취소·오류는 기존 초안을 보존하고 중복 선택을 차단한다', () async {
    final first = testSelectedImage();
    final second = testSelectedImage();
    Future<SelectedImage?> Function() action = () async => first;
    final gateway = FakeImageSelectionGateway(() => action());
    final container = ProviderContainer(
      overrides: [
        useRemoteApiProvider.overrideWithValue(false),
        imageSelectionGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);
    final provider = userProfileEditControllerProvider(
      const UserProfileEditArgs(
        user: UserProfile(id: 'user', name: '초록집사'),
      ),
    );
    container.listen(provider, (_, _) {});
    final controller = container.read(provider.notifier);
    await controller.selectImage();
    expect(container.read(provider).selectedImage, same(first));
    action = () async => second;
    await controller.selectImage();
    expect(container.read(provider).selectedImage, same(second));
    action = () async => null;
    await controller.selectImage();
    expect(container.read(provider).selectedImage, same(second));
    action = () => Future.error(const ImageSelectionException('사진 선택 실패'));
    expect(await controller.selectImage(), '사진 선택 실패');
    expect(container.read(provider).selectedImage, same(second));
    final pending = Completer<SelectedImage?>();
    action = () => pending.future;
    final selection = controller.selectImage();
    expect(container.read(provider).canSubmit, isFalse);
    await controller.selectImage();
    controller.clearSelectedImage();
    expect(gateway.calls, 5);
    expect(container.read(provider).selectedImage, same(second));
    pending.complete(null);
    await selection;
    expect(container.read(provider).isPickingImage, isFalse);
    controller.clearSelectedImage();
    expect(container.read(provider).selectedImage, isNull);
  });
  for (final dispose in [false, true]) {
    test('user: 늦은 결과는 세션 변경·폼 폐기 이후 반영되지 않는다 ($dispose)', () async {
      final pending = Completer<SelectedImage?>();
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(false),
          imageSelectionGatewayProvider.overrideWithValue(
            FakeImageSelectionGateway(() => pending.future),
          ),
        ],
      );
      final provider = userProfileEditControllerProvider(
        const UserProfileEditArgs(
          user: UserProfile(id: 'user', name: '초록집사'),
        ),
      );
      container.listen(provider, (_, _) {});
      final selection = container.read(provider.notifier).selectImage();
      if (dispose) {
        container.dispose();
      } else {
        container.read(userDataSessionProvider.notifier).start();
      }
      pending.complete(testSelectedImage());
      expect(await selection, isNull);
      if (!dispose) {
        expect(container.read(provider).selectedImage, isNull);
        container.dispose();
      }
    });
  }
}
