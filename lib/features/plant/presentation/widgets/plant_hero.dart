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

  ImageProvider<Object>? get _photo {
    final url = imageUrl?.trim();
    if (url != null && url.isNotEmpty) return NetworkImage(url);
    final asset = imageAsset;
    return asset == null ? null : AssetImage(asset);
  }

  @override
  Widget build(BuildContext context) {
    final photo = _photo;
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
                _buildImage(scale, photo),
                Positioned(
                  top: AppSpacing.x8 * scale,
                  left: 0,
                  right: 0,
                  child: Center(child: _PlaceBadge(label: placeName)),
                ),
                if (photo != null)
                  Positioned(
                    right: AppSpacing.x8,
                    bottom: AppSpacing.x8,
                    child: IconButton.filled(
                      tooltip: '식물 사진 확대',
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceBase,
                        foregroundColor: AppColors.textStrong,
                      ),
                      icon: const Icon(Icons.zoom_in_outlined),
                      onPressed: () => showDialog<void>(
                        context: context,
                        useSafeArea: false,
                        builder: (_) =>
                            _PlantPhotoViewer(photo: photo, plantName: name),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(double scale, ImageProvider<Object>? photo) {
    if (photo == null) return const _EmptyPlantImage();

    final isAsset = photo is AssetImage;
    final image = Image(
      image: photo,
      width: isAsset ? 495 * scale : null,
      height: isAsset ? 369 * scale : null,
      fit: BoxFit.cover,
      semanticLabel: '$name 식물 사진',
      errorBuilder: (context, error, stackTrace) => const _EmptyPlantImage(),
    );
    return isAsset
        ? Positioned(left: 0, top: -126 * scale, child: image)
        : image;
  }
}

class _PlantPhotoViewer extends StatelessWidget {
  const _PlantPhotoViewer({required this.photo, required this.plantName});

  final ImageProvider<Object> photo;
  final String plantName;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: AppColors.textHeadline,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: '닫기',
                onPressed: () => Navigator.of(context).pop(),
                color: AppColors.onBrand,
                icon: const Icon(Icons.close),
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                maxScale: 4,
                child: SizedBox.expand(
                  child: Image(
                    image: photo,
                    fit: BoxFit.contain,
                    semanticLabel: '$plantName 식물 사진',
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.onBrand,
                              semanticsLabel: '사진 불러오는 중',
                            ),
                          ),
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(
                        '사진을 불러오지 못했어요.',
                        style: AppTextStyles.size16Medium.copyWith(
                          color: AppColors.onBrand,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
