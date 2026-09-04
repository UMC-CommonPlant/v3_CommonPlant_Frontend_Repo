import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/current_user_provider.dart';
import 'package:commonplant_frontend/features/user/presentation/widgets/user_profile_avatar.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const double _profileHeaderHeight = 171;
const double _profileAvatarSize = 95;
const double _profileHeaderTop = 30;
const double _profileContentTop = 85;

class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).unwrapPrevious();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              const Positioned(
                left: 0,
                right: 0,
                top: _profileHeaderTop,
                height: _profileHeaderHeight,
                child: _ProfileHeaderBackground(),
              ),
              Positioned.fill(
                child: currentUser.when(
                  data: (user) => _UserProfileContent(user: user),
                  error: (error, stackTrace) => _UserProfileStatus(
                    message: '회원 정보를 불러오지 못했어요',
                    actionLabel: '다시 시도',
                    onAction: () => ref.invalidate(currentUserProvider),
                  ),
                  loading: () => const _UserProfileStatus(
                    message: '회원 정보를 불러오고 있어요',
                    isLoading: true,
                  ),
                ),
              ),
              Positioned(
                right: AppSpacing.x10,
                top: 0,
                child: Semantics(
                  button: true,
                  label: '설정 열기',
                  child: IconButton(
                    key: const ValueKey('userSettingsButton'),
                    onPressed: () => context.push(AppRoutePaths.userSettings),
                    icon: const CommonSvgIcon(
                      AppIconAssets.settings,
                      width: AppSizes.navigationBarSideWidth,
                      height: AppSizes.navigationBarSideWidth,
                      semanticsLabel: '설정',
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: AppSizes.navigationBarSideWidth,
                      height: AppSizes.navigationBarSideWidth,
                    ),
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

class _UserProfileContent extends StatelessWidget {
  const _UserProfileContent({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: _profileContentTop,
        bottom: AppSpacing.x40,
      ),
      child: Column(
        children: [
          UserProfileAvatar(size: _profileAvatarSize, imageUrl: user.imgUrl),
          const SizedBox(height: AppSpacing.x20),
          SizedBox(
            width: double.infinity,
            height: AppSizes.navigationBarSideWidth,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.navigationBarSideWidth,
                  ),
                  child: Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.size28Bold,
                  ),
                ),
                Positioned(
                  right: AppSpacing.x32,
                  child: Semantics(
                    button: true,
                    label: '회원 정보 수정',
                    child: IconButton(
                      key: const ValueKey('userProfileEditButton'),
                      onPressed: () =>
                          context.push(AppRoutePaths.userProfileEdit),
                      icon: const CommonSvgIcon(
                        AppIconAssets.edit,
                        width: AppSizes.iconMedium,
                        height: AppSizes.iconMedium,
                        color: AppColors.iconInactive,
                        semanticsLabel: '수정',
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: AppSizes.navigationBarSideWidth,
                        height: AppSizes.navigationBarSideWidth,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x4),
          Text(
            user.email ?? '이메일 정보 없음',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.size14Medium.copyWith(
              color: AppColors.textBody,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserProfileStatus extends StatelessWidget {
  const _UserProfileStatus({
    required this.message,
    this.isLoading = false,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final bool isLoading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x20,
          _profileHeaderHeight,
          AppSpacing.x20,
          AppSpacing.x20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading) ...[
              const CircularProgressIndicator(color: AppColors.brandPrimary),
              const SizedBox(height: AppSpacing.x16),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.size16Medium,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.x16),
              CommonButton.secondary(
                label: actionLabel!,
                size: CommonButtonSize.medium,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileHeaderBackground extends StatelessWidget {
  const _ProfileHeaderBackground();

  @override
  Widget build(BuildContext context) {
    return const CommonSvgIcon(
      AppIconAssets.userProfileHeader,
      width: double.infinity,
      height: _profileHeaderHeight,
      fit: BoxFit.fill,
      semanticsLabel: '마이페이지 배경',
    );
  }
}
