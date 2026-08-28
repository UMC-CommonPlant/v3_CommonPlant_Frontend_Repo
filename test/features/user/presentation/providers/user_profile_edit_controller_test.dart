import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/user/data/dtos/user_requests.dart';
import 'package:commonplant_frontend/features/user/data/repositories/user_repository.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/current_user_provider.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_profile_edit_controller.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_profile_edit_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/user_data_session.dart';

void main() {
  const initialUser = UserProfile(
    id: 'user-237',
    name: '커먼플랜트',
    email: 'common@plant.dev',
  );
  const args = UserProfileEditArgs(user: initialUser);

  for (final fails in [false, true]) {
    test(
      '회원정보 요청 중 이름을 바꿔도 잠금을 유지하고 ${fails ? '새 입력으로 재시도한다' : '성공을 한 번 반환한다'}',
      () async {
        final barrier = Completer<void>();
        final repository = _RecordingUserRepository(initialUser: initialUser)
          ..writeBarrier = barrier;
        final container = ProviderContainer(
          overrides: [
            authenticatedUserDataSession,
            useRemoteApiProvider.overrideWithValue(true),
            userRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);
        final provider = userProfileEditControllerProvider(args);
        container.listen(provider, (_, _) {});
        container.listen(currentUserProvider, (_, _) {});
        await container.read(currentUserProvider.future);
        final controller = container.read(provider.notifier);
        controller.updateName('초록집사');
        final first = controller.submit();
        controller.updateName('다음집사');
        final duringSubmit = container.read(provider);
        final duplicate = controller.submit();
        if (fails) {
          barrier.completeError(StateError('첫 요청 실패'));
        } else {
          barrier.complete();
        }
        final results = await Future.wait([first, duplicate]);

        expect(duringSubmit.isSubmitting, isTrue);
        expect(duringSubmit.canSubmit, isFalse);
        expect(duringSubmit.currentName, '다음집사');
        expect(repository.updateCalls, 1);
        expect(repository.latestRequest?.name, '초록집사');
        expect(results, [!fails, false]);
        if (!fails) {
          expect(container.read(currentUserProvider).requireValue.name, '초록집사');
          return;
        }

        expect(container.read(provider).submitErrorMessage, isNotNull);
        expect(container.read(provider).canSubmit, isTrue);
        repository.writeBarrier = null;
        expect(await controller.submit(), isTrue);
        expect(repository.updateCalls, 2);
        expect(repository.latestRequest?.name, '다음집사');
        expect(container.read(currentUserProvider).requireValue.name, '다음집사');
      },
    );
  }

  test('변경되지 않거나 유효하지 않은 이름은 제출할 수 없다', () async {
    final container = ProviderContainer(
      overrides: [
        authenticatedUserDataSession,
        useRemoteApiProvider.overrideWithValue(false),
      ],
    );
    addTearDown(container.dispose);
    final currentUserSubscription = container.listen(
      currentUserProvider,
      (_, _) {},
    );
    final formSubscription = container.listen(
      userProfileEditControllerProvider(args),
      (_, _) {},
    );
    addTearDown(currentUserSubscription.close);
    addTearDown(formSubscription.close);
    await container.read(currentUserProvider.future);

    final controller = container.read(
      userProfileEditControllerProvider(args).notifier,
    );
    expect(
      container.read(userProfileEditControllerProvider(args)).canSubmit,
      isFalse,
    );

    controller.updateName('한');

    expect(
      container.read(userProfileEditControllerProvider(args)).isNameValid,
      isFalse,
    );
    expect(await controller.submit(), isFalse);
  });

  test('API 비사용 모드 수정은 현재 사용자 화면 상태를 갱신한다', () async {
    final container = ProviderContainer(
      overrides: [
        authenticatedUserDataSession,
        useRemoteApiProvider.overrideWithValue(false),
      ],
    );
    addTearDown(container.dispose);
    final currentUserSubscription = container.listen(
      currentUserProvider,
      (_, _) {},
    );
    final formSubscription = container.listen(
      userProfileEditControllerProvider(args),
      (_, _) {},
    );
    addTearDown(currentUserSubscription.close);
    addTearDown(formSubscription.close);
    await container.read(currentUserProvider.future);

    final controller = container.read(
      userProfileEditControllerProvider(args).notifier,
    );
    controller.updateName('새싹집사');

    expect(await controller.submit(), isTrue);
    expect(container.read(currentUserProvider).requireValue.name, '새싹집사');
  });

  test('API 사용 모드 수정은 PUT 요청 결과로 현재 사용자를 교체한다', () async {
    final repository = _RecordingUserRepository(initialUser: initialUser);
    final container = ProviderContainer(
      overrides: [
        authenticatedUserDataSession,
        useRemoteApiProvider.overrideWithValue(true),
        userRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final currentUserSubscription = container.listen(
      currentUserProvider,
      (_, _) {},
    );
    final formSubscription = container.listen(
      userProfileEditControllerProvider(args),
      (_, _) {},
    );
    addTearDown(currentUserSubscription.close);
    addTearDown(formSubscription.close);
    await container.read(currentUserProvider.future);

    final controller = container.read(
      userProfileEditControllerProvider(args).notifier,
    );
    controller.updateName('초록집사');

    expect(await controller.submit(), isTrue);
    expect(repository.updateCalls, 1);
    expect(repository.latestRequest?.name, '초록집사');
    expect(container.read(currentUserProvider).requireValue.name, '초록집사');
  });

  test('수정 API 오류는 사용자용 실패 상태로 변환한다', () async {
    final repository = _RecordingUserRepository(
      initialUser: initialUser,
      updateError: StateError('수정 실패'),
    );
    final container = ProviderContainer(
      overrides: [
        authenticatedUserDataSession,
        useRemoteApiProvider.overrideWithValue(true),
        userRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final currentUserSubscription = container.listen(
      currentUserProvider,
      (_, _) {},
    );
    final formSubscription = container.listen(
      userProfileEditControllerProvider(args),
      (_, _) {},
    );
    addTearDown(currentUserSubscription.close);
    addTearDown(formSubscription.close);
    await container.read(currentUserProvider.future);
    final controller = container.read(
      userProfileEditControllerProvider(args).notifier,
    );
    controller.updateName('초록집사');

    expect(await controller.submit(), isFalse);
    expect(
      container
          .read(userProfileEditControllerProvider(args))
          .submitErrorMessage,
      '회원 정보를 수정하지 못했어요',
    );
  });
}

class _RecordingUserRepository extends Fake implements UserRepository {
  _RecordingUserRepository({required this.initialUser, this.updateError});

  final UserProfile initialUser;
  final Object? updateError;
  Completer<void>? writeBarrier;
  int updateCalls = 0;
  UpdateUserRequest? latestRequest;

  @override
  Future<UserProfile> fetchMe() async => initialUser;

  @override
  Future<UserProfile> updateMe(
    UpdateUserRequest request, {
    MultipartFile? image,
  }) async {
    updateCalls++;
    latestRequest = request;
    await writeBarrier?.future;

    if (updateError != null) {
      return Future<UserProfile>.error(updateError!);
    }

    return initialUser.copyWith(name: request.name);
  }
}
