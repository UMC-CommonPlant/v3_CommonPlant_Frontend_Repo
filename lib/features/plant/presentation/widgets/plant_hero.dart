import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class PlantHero extends StatelessWidget {
  const PlantHero({
    super.key,
    required this.placeName,
    required this.name,
    required this.species,
    this.imageUrl,
    this.imageAsset,
  });

  final String placeName;
  final String name;
  final String species;
  final String? imageUrl;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x20,
        0,
        AppSpacing.x20,
        AppSpacing.x16,
      ),
      child: Column(
        children: [
          _PlantHeroImage(
            placeName: placeName,
            name: name,
            imageUrl: imageUrl,
            imageAsset: imageAsset,
          ),
          const SizedBox(height: AppSpacing.x8),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.size24Medium.copyWith(
              color: AppColors.textHeadline,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            species,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.size16Medium.copyWith(
              color: AppColors.textStrong,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantHeroImage extends StatelessWidget {
  const _PlantHeroImage({
    required this.placeName,
    required this.name,
    required this.imageUrl,
    required this.imageAsset,
  });

  final String placeName;
  final String name;
  final String? imageUrl;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 335 ? constraints.maxWidth : 335.0;
        final scale = width / 335;
        final height = 208 * scale;

        return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: AppColors.surfaceMuted),
                _buildImage(scale),
                Positioned(
                  top: AppSpacing.x8 * scale,
                  left: 0,
                  right: 0,
                  child: Center(child: _PlaceBadge(label: placeName)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(double scale) {
    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        semanticLabel: '$name 식물 사진',
        errorBuilder: (context, error, stackTrace) => const _EmptyPlantImage(),
      );
    }

    if (imageAsset != null) {
      return Positioned(
        left: 0,
        top: -126 * scale,
        child: Image.asset(
          imageAsset!,
          width: 495 * scale,
          height: 369 * scale,
          fit: BoxFit.cover,
          semanticLabel: '$name 식물 사진',
        ),
      );
    }

    return const _EmptyPlantImage();
  }
}

class _EmptyPlantImage extends StatelessWidget {
  const _EmptyPlantImage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.iconInactive,
        size: 40,
        semanticLabel: '식물 이미지 없음',
      ),
    );
  }
}

class _PlaceBadge extends StatelessWidget {
  const _PlaceBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.brandStrong,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x10,
            AppSpacing.x4,
            AppSpacing.x16,
            AppSpacing.x4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_home_outlined,
                color: AppColors.onBrand,
                size: AppSizes.iconMedium,
              ),
              const SizedBox(width: AppSpacing.x4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.size14Bold.copyWith(
                    color: AppColors.onBrand,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
