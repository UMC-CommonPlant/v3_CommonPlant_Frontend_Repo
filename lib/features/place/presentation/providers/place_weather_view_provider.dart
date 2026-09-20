import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_weather.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_weather_display.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_weather_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 백엔드 확정 후 바꿀 유일한 장소 → 기상청 격자 공급 지점.
/// PLACE-07의 필드·좌표계가 미정이므로 임시 필드/기본 좌표를 읽지 않는다.
/// 변경 파일·계약·검증: docs/work-history/place-weather-ui-306.md
final placeWeatherGridProvider = Provider.autoDispose
    .family<WeatherGrid?, String>((ref, placeId) {
      return null;
    });

final placeWeatherViewProvider = NotifierProvider.autoDispose
    .family<
      PlaceWeatherViewController,
      AsyncValue<PlaceWeatherDisplay?>,
      String
    >(PlaceWeatherViewController.new);

class PlaceWeatherViewController
    extends Notifier<AsyncValue<PlaceWeatherDisplay?>> {
  PlaceWeatherViewController(this.placeId);

  final String placeId;

  @override
  AsyncValue<PlaceWeatherDisplay?> build() {
    if (!ref.watch(useRemoteApiProvider)) return const AsyncData(null);
    final grid = ref.watch(placeWeatherGridProvider(placeId));
    if (grid == null) return const AsyncData(null);

    return ref
        .watch(placeWeatherProvider(grid))
        .unwrapPrevious()
        .whenData(PlaceWeatherDisplay.fromWeather);
  }

  void retry() {
    if (!ref.mounted || !ref.read(useRemoteApiProvider)) return;
    final grid = ref.read(placeWeatherGridProvider(placeId));
    if (grid == null) return;
    final source = placeWeatherProvider(grid);
    // 화면 rebuild 전 두 번째 탭도 원본 Provider의 loading으로 차단한다.
    final current = ref.read(source);
    if (current.isLoading || !current.hasError) return;
    ref.invalidate(source);
  }
}
