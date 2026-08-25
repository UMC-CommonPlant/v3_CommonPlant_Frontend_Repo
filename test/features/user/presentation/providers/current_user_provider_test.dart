import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/user/data/repositories/user_repository.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/current_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('API 비사용 모드에서 기존 Home 사용자명을 보존한다', () async {
    final repository = _RecordingUserRepository();
    final container = ProviderContainer(
      overrides: [
        useRemoteApiProvider.overrideWithValue(false),
        userRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final user = await container.read(currentUserProvider.future);

    expect(user.id, 'local-user');
    expect(user.name, '커먼(유저 네임');
    expect(repository.fetchMeCalls, 0);
  });

  test('API 사용 모드에서 UserRepository.fetchMe 결과를 반환한다', () async {
    final repository = _RecordingUserRepository(
      result: const UserProfile(id: 'user-232', name: '새싹집사'),
    );
    final container = ProviderContainer(
      overrides: [
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
