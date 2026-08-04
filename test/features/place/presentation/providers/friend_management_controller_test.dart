import 'package:commonplant_frontend/features/place/presentation/fixtures/friend_management_fixture.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/friend_management_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('친구 관리는 placeId별 초기 선택 상태를 제공한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(friendManagementControllerProvider('place-1'));

    expect(state.placeId, 'place-1');
    expect(state.selectedFriends, hasLength(2));
    expect(state.results, hasLength(2));
  });

  test('검색어로 친구 목록을 필터링한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final provider = friendManagementControllerProvider('place-1');

    container.read(provider.notifier).updateQuery('파파');

    expect(container.read(provider).results, hasLength(1));
    expect(container.read(provider).results.single.name, '커먼 파파');
  });

  test('친구를 삭제하고 다시 선택할 수 있다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final provider = friendManagementControllerProvider('place-1');
    final controller = container.read(provider.notifier);
    final friend = friendManagementFixture.first;

    controller.remove(friend);
    expect(container.read(provider).isSelected(friend.id), isFalse);

    controller.select(friend);
    expect(container.read(provider).isSelected(friend.id), isTrue);
  });
}
