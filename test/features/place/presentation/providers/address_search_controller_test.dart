import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/address_search_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('API 검색 미연결은 초기화와 검색어 변경에서 fixture를 반환하지 않는다', () {
    final container = ProviderContainer(
      overrides: [useRemoteApiProvider.overrideWithValue(true)],
    );
    addTearDown(container.dispose);
    container.listen(addressSearchControllerProvider, (_, _) {});

    expect(
      container.read(addressSearchControllerProvider).isAvailable,
      isFalse,
    );
    expect(container.read(addressSearchControllerProvider).results, isEmpty);
    container
        .read(addressSearchControllerProvider.notifier)
        .updateQuery('신도림역');
    expect(container.read(addressSearchControllerProvider).results, isEmpty);
    expect(container.read(addressSearchControllerProvider).query, isEmpty);
  });

  test('주소 검색은 초기 검색어와 결과를 제공한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(addressSearchControllerProvider);

    expect(state.query, initialAddressSearchQuery);
    expect(state.results, isNotEmpty);
    expect(state.results.first.title, '신도림역 1호선');
  });

  test('주소나 장소명으로 검색 결과를 필터링한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(addressSearchControllerProvider.notifier).updateQuery('경인로');

    final state = container.read(addressSearchControllerProvider);
    expect(state.query, '경인로');
    expect(state.results, hasLength(1));
    expect(state.results.single.address, '서울 구로구 경인로 688');
  });

  test('빈 검색어는 주소 전체 목록을 보여준다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(addressSearchControllerProvider.notifier).updateQuery(' ');

    expect(
      container.read(addressSearchControllerProvider).results,
      hasLength(9),
    );
  });
}
