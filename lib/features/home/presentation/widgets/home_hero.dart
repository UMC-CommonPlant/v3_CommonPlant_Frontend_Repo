import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/current_user_provider.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({
    required this.topInset,
    required this.contentHeight,
    super.key,
  });

  final double topInset;
  final double contentHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: AppColors.surfaceAlt)),
        Positioned(
          left: 0,
          right: 0,
          top: topInset,
          height: contentHeight,
          child: CommonSvgIcon(
            AppImageAssets.homeMainHeroBackground,
            fit: BoxFit.fill,
            semanticsLabel: '메인 배경',
          ),
        ),
        Positioned(
          left: AppSpacing.x20,
          right: AppSpacing.x20,
          top: topInset + 48,
          child: const _HomeCurrentUserName(),
        ),
        Positioned(
          left: AppSpacing.x20,
          top: topInset + 76,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 44,
                child: Container(
                  width: 70,
                  height: 10,
                  color: AppColorPrimitives.unspecifiedGreenGray.withValues(
                    alpha: 0.16,
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.size20Medium.copyWith(
                    color: AppColors.textHeadline,
                    fontWeight: FontWeight.w700,
                  ),
                  children: const [
                    TextSpan(text: '님과 함께 친환경 한 걸음을\n'),
                    TextSpan(
                      text: '한걸음에',
                      style: TextStyle(color: AppColors.brandStrong),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 23,
          top: topInset + 110,
          width: 88,
          height: 64,
          child: const CommonSvgIcon(
            AppIconAssets.userIllustration,
            fit: BoxFit.fill,
            semanticsLabel: '유저 일러스트',
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: topInset + 161,
          height: 27,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFD8DEDD).withValues(alpha: 0.6),
                  const Color(0x00D8DEDD),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeCurrentUserName extends ConsumerWidget {
  const _HomeCurrentUserName();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).unwrapPrevious();

    return currentUser.when(
      skipLoadingOnRefresh: false,
      loading: () => Align(
        alignment: Alignment.centerLeft,
        child: Semantics(
          label: '사용자 정보 불러오는 중',
          child: const SizedBox.square(
            dimension: AppSizes.iconSmall,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.brandPrimary,
            ),
          ),
        ),
      ),
      error: (_, _) => Row(
        children: [
          Flexible(
            child: Text(
              '사용자 정보를 불러오지 못했어요',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.size14Medium.copyWith(
                color: AppColors.textBody,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.x8),
          TextButton(
            onPressed: () => ref.invalidate(currentUserProvider),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.brandPrimary,
              minimumSize: const Size(0, AppSizes.iconSmall),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: AppTextStyles.size14Bold,
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
      data: (user) => Text(
        user.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.size16Bold.copyWith(
          color: AppColorPrimitives.unspecifiedGreenGray,
        ),
      ),
    );
  }
}
