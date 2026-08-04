import 'package:commonplant_frontend/features/plant/presentation/providers/plant_search_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('식물 검색 초기 상태는 결과를 보여주지 않는다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(plantSearchControllerProvider);

    expect(state.hasQuery, isFalse);
    expect(state.results, isEmpty);
  });

  test('공백을 제거하고 식물 이름을 검색한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(plantSearchControllerProvider.notifier).updateQuery('몬스 테라');

    final state = container.read(plantSearchControllerProvider);
    expect(state.hasQuery, isTrue);
    expect(state.results, hasLength(4));
  });

  test('검색어를 비우면 결과를 초기화한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(plantSearchControllerProvider.notifier);

    controller.updateQuery('몬스테라');
    controller.updateQuery('');

    final state = container.read(plantSearchControllerProvider);
    expect(state.hasQuery, isFalse);
    expect(state.results, isEmpty);
  });
}
