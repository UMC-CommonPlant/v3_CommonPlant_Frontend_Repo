import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/user/data/repositories/user_repository.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/current_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/user_data_session.dart';

void main() {
  test('API 비사용 모드에서 Figma 기본 회원 정보를 제공한다', () async {
    final repository = _RecordingUserRepository();
    final container = ProviderContainer(
      overrides: [
        authenticatedUserDataSession,
        useRemoteApiProvider.overrideWithValue(false),
        userRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final user = await container.read(currentUserProvider.future);

    expect(user.id, 'local-user');
    expect(user.name, '커먼플랜트');
    expect(user.email, 'alwaysweave@gmail.com');
    expect(repository.fetchMeCalls, 0);
  });

  test('API 사용 모드에서 UserRepository.fetchMe 결과를 반환한다', () async {
    final repository = _RecordingUserRepository(
      result: const UserProfile(id: 'user-232', name: '새싹집사'),
    );
    final container = ProviderContainer(
      overrides: [
        authenticatedUserDataSession,
        useRemoteApiProvider.overrideWithValue(true),
        userRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final user = await container.read(currentUserProvider.future);

    expect(user.id, 'user-232');
    expect(user.name, '새싹집사');
    expect(repository.fetchMeCalls, 1);
  });

  test('repository 오류를 currentUserProvider 오류 상태로 전달한다', () async {
    final repository = _RecordingUserRepository(error: StateError('조회 실패'));
    final container = ProviderContainer(
      overrides: [
        authenticatedUserDataSession,
        useRemoteApiProvider.overrideWithValue(true),
        userRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(currentUserProvider.future),
      throwsA(isA<StateError>()),
    );
    expect(repository.fetchMeCalls, 1);
  });

  test('Home의 명시적 재시도를 위해 Provider 자동 재시도를 끄는다', () {
    final retry = currentUserProvider.retry;

    expect(retry, isNotNull);
    expect(retry!(0, StateError('조회 실패')), isNull);
  });

  test('수정 완료 회원 정보로 현재 사용자 상태를 교체한다', () async {
    final container = ProviderContainer(
      overrides: [
        authenticatedUserDataSession,
        useRemoteApiProvider.overrideWithValue(false),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(currentUserProvider, (_, _) {});
    addTearDown(subscription.close);
    await container.read(currentUserProvider.future);

    container
        .read(currentUserProvider.notifier)
        .replace(
          const UserProfile(
            id: 'local-user',
            name: '새싹집사',
            email: 'alwaysweave@gmail.com',
          ),
        );

    expect(container.read(currentUserProvider).requireValue.name, '새싹집사');
  });
}

class _RecordingUserRepository extends Fake implements UserRepository {
  _RecordingUserRepository({this.result, this.error});

  final UserProfile? result;
  final Object? error;
  int fetchMeCalls = 0;

  @override
  Future<UserProfile> fetchMe() async {
    fetchMeCalls++;
    if (error != null) {
      return Future<UserProfile>.error(error!);
    }

    return result ?? const UserProfile(id: 'unused', name: '미사용');
  }
}
