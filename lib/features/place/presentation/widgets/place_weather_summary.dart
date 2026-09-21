import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_weather_display.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_weather_view_provider.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlaceWeatherSummary extends ConsumerWidget {
  const PlaceWeatherSummary({super.key, required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(placeWeatherViewProvider(placeId));
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: '지역 날씨',
      child: state.when(
        skipLoadingOnRefresh: false,
        loading: () => Semantics(
          liveRegion: true,
          label: '날씨를 불러오는 중',
          excludeSemantics: true,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox.square(
                dimension: AppSizes.iconMedium,
                child: CircularProgressIndicator(color: AppColors.brandStrong),
              ),
              SizedBox(height: AppSpacing.x8),
              _WeatherCaption('날씨 불러오는 중'),
            ],
          ),
        ),
        error: (_, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Semantics(
              liveRegion: true,
              child: const _WeatherCaption('날씨를 불러오지 못했어요'),
            ),
            IconButton(
              tooltip: '날씨 다시 불러오기',
              constraints: const BoxConstraints(
                minWidth: AppSizes.buttonHeight,
                minHeight: AppSizes.buttonHeight,
              ),
              color: AppColors.brandStrong,
              iconSize: AppSizes.iconMedium,
              onPressed: () =>
                  ref.read(placeWeatherViewProvider(placeId).notifier).retry(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        data: (weather) => weather == null
            ? const _WeatherCaption('날씨 정보를 조회할 수 없어요')
            : _WeatherReadings(weather: weather),
      ),
    );
  }
}

class _WeatherReadings extends StatelessWidget {
  const _WeatherReadings({required this.weather});

  final PlaceWeatherDisplay weather;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Wrap(
          alignment: WrapAlignment.end,
          spacing: AppSpacing.x8,
          runSpacing: AppSpacing.x4,
          children: [
            _WeatherMetric(
              asset: AppIconAssets.tagTemperature,
              label: weather.temperature,
              semanticsLabel: '기온 ${weather.temperature}',
            ),
            _WeatherMetric(
              asset: AppIconAssets.tagHumidity,
              label: weather.humidity,
              semanticsLabel: '습도 ${weather.humidity}',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x8),
        Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.x4,
          children: [
            Icon(
              switch (weather.symbol) {
                PlaceWeatherSymbol.sunny => Icons.wb_sunny_outlined,
                PlaceWeatherSymbol.partlyCloudy => Icons.wb_cloudy_outlined,
                PlaceWeatherSymbol.cloudy => Icons.cloud_outlined,
                PlaceWeatherSymbol.rain => Icons.water_drop_outlined,
                PlaceWeatherSymbol.sleet => Icons.cloudy_snowing,
                PlaceWeatherSymbol.snow => Icons.ac_unit,
              },
              size: AppSizes.iconSmall,
              color: AppColors.brandStrong,
            ),
            _WeatherCaption(weather.condition),
          ],
        ),
        const SizedBox(height: AppSpacing.x4),
        _WeatherCaption(weather.observationTime),
        if (weather.conditionTime != weather.observationTime)
          _WeatherCaption(weather.conditionTime),
        const _WeatherCaption('기상청 · 지역 날씨'),
      ],
    );
  }
}

class _WeatherMetric extends StatelessWidget {
  const _WeatherMetric({
    required this.asset,
    required this.label,
    required this.semanticsLabel,
  });

  final String asset;
  final String label;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.x4,
        children: [
          CommonSvgIcon(
            asset,
            width: AppSizes.iconSmall,
            height: AppSizes.iconSmall,
          ),
          Text(
            label,
            style: AppTextStyles.size14Medium.copyWith(
              color: AppColors.textHeadline,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherCaption extends StatelessWidget {
  const _WeatherCaption(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.end,
      style: AppTextStyles.size12Medium.copyWith(color: AppColors.textBody),
    );
  }
}
