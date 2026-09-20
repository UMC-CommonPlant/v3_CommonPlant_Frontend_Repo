import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/core/network/weather_api_client.dart';
import 'package:commonplant_frontend/features/place/data/datasources/weather_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_weather_repository.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_weather.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final weatherServiceKeyProvider = Provider<String>((ref) {
  return AppEnvironment.weatherServiceKey;
});

final placeWeatherRepositoryProvider =
    Provider.autoDispose<PlaceWeatherRepository>((ref) {
      return PlaceWeatherRepository(
        DioWeatherRemoteDataSource(
          ref.watch(weatherDioProvider),
          serviceKey: ref.watch(weatherServiceKeyProvider),
        ),
      );
    });

/// 장소 DTO 좌표 계약 확정 후 변환한 기상청 격자만 전달한다.
/// 수동 새로고침은 이 Provider를 invalidate하며, 기존 흐름은 취소된다.
final placeWeatherProvider = FutureProvider.autoDispose
    .family<PlaceWeather, WeatherGrid>((ref, grid) {
      requireUserDataSession(ref);
      final cancellation = CancelToken();
      ref.onDispose(cancellation.cancel);
      return ref
          .watch(placeWeatherRepositoryProvider)
          .fetch(grid, cancellation);
    }, retry: (retryCount, error) => null);
