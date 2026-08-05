import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/place_feature_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_registration_place_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('사용자 장소를 Plant 등록 장소 모델로 변환한다', () async {
    final container = ProviderContainer(
      overrides: [
        userPlaceSummariesProvider.overrideWith(
          (ref) => [
            const PlaceSummary(id: 'place-1', name: '거실'),
            const PlaceSummary(id: 'place-2', name: '작업실'),
          ],
        ),
      ],
    );
    addTearDown(container.dispose);

    final places = await container.read(plantRegistrationPlaceProvider.future);

    expect([for (final place in places) place.id], ['place-1', 'place-2']);
    expect([for (final place in places) place.name], ['거실', '작업실']);
  });
}
