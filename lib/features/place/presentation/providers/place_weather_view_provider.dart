import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_weather.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_weather_display.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_weather_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 백엔드 확정 후 바꿀 유일한 장소 → 기상청 격자 공급 지점.
/// PLACE-07의 필드·좌표계가 미정이므로 임시 JSON 필드를 읽지 않는다.
/// 변경 파일·계약·검증: docs/work-history/place-weather-ui-306.md
final placeWeatherGridProvider = Provider.autoDispose
    .family<WeatherGrid?, String>((ref, placeId) {
      return null;
    });

// 사용자 지정 기본 위치. 좌표 출처와 변환 근거는 #307 작업 문서 참조.
final _pangyoStationGrid = WeatherGrid(nx: 62, ny: 123);

/// 조회·재시도·기본 위치 안내가 같은 장소 선택을 사용한다.
final placeWeatherLocationProvider = Provider.autoDispose
    .family<({WeatherGrid grid, bool usesFallback})?, String>((ref, placeId) {
      if (!ref.watch(useRemoteApiProvider)) return null;
      final grid = ref.watch(placeWeatherGridProvider(placeId));
      return (grid: grid ?? _pangyoStationGrid, usesFallback: grid == null);
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
    final location = ref.watch(placeWeatherLocationProvider(placeId));
    if (location == null) return const AsyncData(null);

    return ref
        .watch(placeWeatherProvider(location.grid))
        .unwrapPrevious()
        .whenData(PlaceWeatherDisplay.fromWeather);
  }

  void retry() {
    if (!ref.mounted) return;
    final location = ref.read(placeWeatherLocationProvider(placeId));
    if (location == null) return;
    final source = placeWeatherProvider(location.grid);
    // 화면 rebuild 전 두 번째 탭도 원본 Provider의 loading으로 차단한다.
    final current = ref.read(source);
    if (current.isLoading || !current.hasError) return;
    ref.invalidate(source);
  }
}
