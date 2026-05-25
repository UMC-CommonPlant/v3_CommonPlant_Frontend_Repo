import 'dart:math' as math;

import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/profile_setup_state_provider.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const double _figmaFrameWidth = 375;
const double _figmaFrameHeight = 812;
const double _sheetRearTop = 40;
const double _sheetTop = 50;
const double _sheetRadius = 10;
const double _backButtonTop = 63;
const double _profileContentTop = 147;
const double _profileAvatarBoxSize = 100;
const double _profileAvatarImageSize = 83.33;
const double _bottomActionsTop = 626;
const double _termsRowHeight = 56;
const double _nicknameFieldHeight = 56;
const double _nicknameFieldHeightWithHelper = 80;
const double _profileActionSheetButtonHeight = 56;
const double _profileActionSheetHorizontalInset = 8;
const double _profileActionSheetRadius = 14;
const double _profilePermissionDialogWidth = 270;
const double _profilePermissionDialogHeight = 248;
const double _profilePermissionActionHeight = 44;

enum _ProfileImageSheetAction { selectFromAlbum, resetToDefault }

enum _ProfilePhotoPermissionAction { selectLimited, allowAll, deny }

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final FocusNode _nicknameFocusNode = FocusNode();
  bool _hasImage = false;

  bool get _canSubmit {
    final nickname = _nicknameController.text.trim();
    return nickname.length >= 2 && nickname.length <= 10;
  }

  @override
  void dispose() {
    _nicknameFocusNode.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _openProfileImageSheet() async {
    _nicknameFocusNode.unfocus();

    final action = await showModalBottomSheet<_ProfileImageSheetAction>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.textHeadline.withValues(alpha: 0.6),
      elevation: 0,
      builder: (context) => const _ProfileImageActionSheet(),
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case _ProfileImageSheetAction.selectFromAlbum:
        await _openPhotoPermissionDialog();
      case _ProfileImageSheetAction.resetToDefault:
        setState(() => _hasImage = false);
    }
  }

  Future<void> _openPhotoPermissionDialog() async {
    final action = await showDialog<_ProfilePhotoPermissionAction>(
      context: context,
      barrierColor: AppColors.textHeadline.withValues(alpha: 0.6),
      builder: (context) => const _ProfilePhotoPermissionDialog(),
    );

    if (!mounted) {
      return;
    }

    switch (action) {
      case _ProfilePhotoPermissionAction.selectLimited:
      case _ProfilePhotoPermissionAction.allowAll:
        setState(() => _hasImage = true);
      case _ProfilePhotoPermissionAction.deny:
      case null:
        break;
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutePaths.login);
  }

  void _openTerms(TermsReturnDestination destination) {
    context.push(AppRoutePaths.termsLocation(next: destination.queryValue));
  }

  void _handleTermsCheck(bool isAccepted) {
    if (isAccepted) {
      ref
          .read(profileSetupStateProvider.notifier)
          .setPrivacyTermsAccepted(false);
      return;
    }

    _openTerms(TermsReturnDestination.profile);
  }

  void _handleComplete(bool isTermsAccepted) {
    if (isTermsAccepted) {
      context.go(AppRoutePaths.home);
      return;
    }

    _openTerms(TermsReturnDestination.home);
  }

  @override
  Widget build(BuildContext context) {
    final isTermsAccepted = ref.watch(
      profileSetupStateProvider.select((state) => state.isPrivacyTermsAccepted),
    );

    return Scaffold(
      backgroundColor: AppColors.textHeadline,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final verticalScale = math.min(
            1.0,
            constraints.maxHeight / _figmaFrameHeight,
          );
          final contentWidth = math.min(
            _figmaFrameWidth - (AppSpacing.x20 * 2),
            math.max(0.0, constraints.maxWidth - (AppSpacing.x20 * 2)),
          );
          final horizontalInset = math.max(
            AppSpacing.x20,
            (constraints.maxWidth - contentWidth) / 2,
          );

          return Stack(
            children: [
              Positioned(
                top: _sheetRearTop * verticalScale,
                left: AppSpacing.x16,
                right: AppSpacing.x16,
                height: AppSpacing.x10,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(_sheetRadius),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: _sheetTop * verticalScale,
                left: 0,
                right: 0,
                bottom: 0,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(_sheetRadius),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: _backButtonTop * verticalScale,
                left: 0,
                child: SizedBox(
                  width: AppSizes.navigationBarSideWidth,
                  height: AppSizes.navigationBarHeight,
                  child: IconButton(
                    tooltip: '뒤로가기',
                    onPressed: _goBack,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: AppSizes.navigationBackIconSize,
                      color: AppColors.textStrong,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: _profileContentTop * verticalScale,
                left: horizontalInset,
                width: contentWidth,
                child: Column(
                  children: [
                    _ProfileAvatar(
                      hasImage: _hasImage,
                      onTap: _openProfileImageSheet,
                    ),
                    const SizedBox(height: AppSpacing.x16),
                    _ProfileNicknameField(
                      controller: _nicknameController,
                      focusNode: _nicknameFocusNode,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: _bottomActionsTop * verticalScale,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    _TermsAgreementRow(
                      isAccepted: isTermsAccepted,
                      onCheckPressed: () => _handleTermsCheck(isTermsAccepted),
                      onViewPressed: () =>
                          _openTerms(TermsReturnDestination.profile),
                    ),
                    const SizedBox(height: AppSpacing.x16),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalInset,
                      ),
                      child: _ProfileCompleteButton(
                        enabled: _canSubmit,
                        onPressed: () => _handleComplete(isTermsAccepted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileImageActionSheet extends StatelessWidget {
  const _ProfileImageActionSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _profileActionSheetHorizontalInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(_profileActionSheetRadius),
              child: ColoredBox(
                color: AppColors.white,
                child: Column(
                  children: [
                    _ProfileActionSheetTitle(label: '프로필 사진 설정'),
                    _ProfileActionSheetButton(
                      label: '앨범에서 사진 선택',
                      onTap: () => Navigator.of(
                        context,
                      ).pop(_ProfileImageSheetAction.selectFromAlbum),
                    ),
                    _ProfileActionSheetButton(
                      label: '기본 이미지로 변경',
                      onTap: () => Navigator.of(
                        context,
                      ).pop(_ProfileImageSheetAction.resetToDefault),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x12),
            ClipRRect(
              borderRadius: BorderRadius.circular(_profileActionSheetRadius),
              child: ColoredBox(
                color: AppColors.white,
                child: _ProfileActionSheetButton(
                  label: '취소',
                  isEmphasized: true,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x8),
          ],
        ),
      ),
    );
  }
}

class _ProfileActionSheetTitle extends StatelessWidget {
  const _ProfileActionSheetTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _profileActionSheetButtonHeight,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.size12Medium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const _ProfileSheetDivider(),
        ],
      ),
    );
  }
}

class _ProfileActionSheetButton extends StatelessWidget {
  const _ProfileActionSheetButton({
    required this.label,
    required this.onTap,
    this.isEmphasized = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final style = isEmphasized
        ? AppTextStyles.size18Medium.copyWith(
            color: AppColors.actionBlue,
            fontWeight: FontWeight.w700,
          )
        : AppTextStyles.size18Medium.copyWith(color: AppColors.actionBlue);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: _profileActionSheetButtonHeight,
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                ),
              ),
              if (!isEmphasized) const _ProfileSheetDivider(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSheetDivider extends StatelessWidget {
  const _ProfileSheetDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColorPrimitives.separatorColors.withValues(alpha: 0.36),
    );
  }
}

class _ProfilePhotoPermissionDialog extends StatelessWidget {
  const _ProfilePhotoPermissionDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.alertSurface,
      clipBehavior: Clip.antiAlias,
      constraints: const BoxConstraints(),
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.dialog),
      ),
      child: SizedBox(
        width: _profilePermissionDialogWidth,
        height: _profilePermissionDialogHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x16,
                  vertical: AppSpacing.x16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '‘커먼플랜트’이(가) 사용자의 사진에 접근하려고 합니다.',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.size16Bold.copyWith(
                        color: AppColors.textHeadline,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '프로필 사진, 장소, 식물을 등록하거나,\n식물에 관한 메모를 등록할 때 사용합니다.',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.size12Medium.copyWith(
                        color: AppColors.textHeadline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _ProfilePermissionActionButton(
              label: '사진 선택...',
              onTap: () => Navigator.of(
                context,
              ).pop(_ProfilePhotoPermissionAction.selectLimited),
            ),
            _ProfilePermissionActionButton(
              label: '모든 사진에 대한 접근 허용',
              onTap: () => Navigator.of(
                context,
              ).pop(_ProfilePhotoPermissionAction.allowAll),
            ),
            _ProfilePermissionActionButton(
              label: '허용 안 함',
              onTap: () =>
                  Navigator.of(context).pop(_ProfilePhotoPermissionAction.deny),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePermissionActionButton extends StatelessWidget {
  const _ProfilePermissionActionButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: _profilePermissionActionHeight,
          child: Column(
            children: [
              const _ProfileSheetDivider(),
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.size16Medium.copyWith(
                      color: AppColors.actionBlue,
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

enum TermsReturnDestination {
  profile('profile'),
  home('home');

  const TermsReturnDestination(this.queryValue);

  final String queryValue;
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.hasImage, required this.onTap});

  final bool hasImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: hasImage ? '프로필 이미지' : '프로필 추가',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          key: const ValueKey('profileAvatar'),
          width: _profileAvatarBoxSize,
          height: _profileAvatarBoxSize,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (hasImage)
                ClipOval(
                  child: Image.asset(
                    AppImageAssets.profileSetupSampleAvatar,
                    width: _profileAvatarImageSize,
                    height: _profileAvatarImageSize,
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  ),
                )
              else
                const CommonSvgIcon(
                  AppIconAssets.addPerson,
                  width: _profileAvatarBoxSize,
                  height: _profileAvatarBoxSize,
                  semanticsLabel: '프로필 기본 이미지',
                ),
              if (!hasImage)
                const Positioned(
                  right: 6,
                  bottom: 8,
                  child: CommonSvgIcon(
                    AppIconAssets.plus,
                    width: AppSizes.profileImageOverlaySize,
                    height: AppSizes.profileImageOverlaySize,
                    semanticsLabel: '프로필 이미지 추가',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileNicknameField extends StatelessWidget {
  const _ProfileNicknameField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  bool get _hasValidNickname {
    final nickname = controller.text.trim();
    return nickname.length >= 2 && nickname.length <= 10;
  }

  bool get _hasNicknameError {
    final nickname = controller.text.trim();
    return nickname.isNotEmpty && !_hasValidNickname;
  }

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.isNotEmpty;
    final hasValidNickname = _hasValidNickname;
    final hasNicknameError = _hasNicknameError;
    final lineColor = hasNicknameError
        ? AppColors.danger
        : hasValidNickname
        ? AppColors.brandStrong
        : AppColors.textDisabled;

    return SizedBox(
      key: const ValueKey('profileNicknameField'),
      height: hasValidNickname || hasNicknameError
          ? _nicknameFieldHeightWithHelper
          : _nicknameFieldHeight,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: _nicknameFieldHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: lineColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: onChanged,
                      maxLength: 10,
                      style: AppTextStyles.size18Medium.copyWith(
                        color: AppColors.textHeadline,
                      ),
                      decoration: InputDecoration(
                        hintText: '닉네임을 입력해 주세요',
                        hintStyle: AppTextStyles.size18Medium.copyWith(
                          color: AppColors.textDisabled,
                        ),
                        counterText: '',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.x16,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  if (!hasText)
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.size14Medium.copyWith(
                          color: AppColors.textBody,
                        ),
                        children: const [
                          TextSpan(
                            text: '0',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: '/10'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (hasValidNickname)
            Positioned(
              left: 0,
              top: 64,
              child: Text(
                '사용 가능한 닉네임입니다',
                style: AppTextStyles.size12Medium.copyWith(
                  color: AppColors.brandStrong,
                ),
              ),
            ),
          if (hasNicknameError)
            Positioned(
              left: 0,
              top: 64,
              child: Text(
                '2~10자의 닉네임으로 입력해 주세요',
                style: AppTextStyles.size12Medium.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TermsAgreementRow extends StatelessWidget {
  const _TermsAgreementRow({
    required this.isAccepted,
    required this.onCheckPressed,
    required this.onViewPressed,
  });

  final bool isAccepted;
  final VoidCallback onCheckPressed;
  final VoidCallback onViewPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('profileTermsRow'),
      height: _termsRowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x20,
          vertical: AppSpacing.x16,
        ),
        child: Row(
          children: [
            Semantics(
              button: true,
              container: true,
              label: isAccepted ? '개인정보 이용약관 동의됨' : '개인정보 이용약관 동의 필요',
              child: GestureDetector(
                key: const ValueKey('profileTermsCheckButton'),
                behavior: HitTestBehavior.opaque,
                onTap: onCheckPressed,
                child: ExcludeSemantics(
                  child: Container(
                    width: AppSizes.iconMedium,
                    height: AppSizes.iconMedium,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAccepted
                          ? AppColors.brandAccent
                          : AppColors.textDisabled,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: AppSizes.iconSmall,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x12),
            Flexible(
              child: Text(
                '개인정보 이용 약관 동의',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.size16Medium.copyWith(
                  color: AppColors.textHeadline,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x8),
            GestureDetector(
              onTap: onViewPressed,
              child: Text(
                '보기',
                style: AppTextStyles.size16Bold.copyWith(
                  color: AppColors.iconInactive,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCompleteButton extends StatelessWidget {
  const _ProfileCompleteButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return CommonButton(
        key: const ValueKey('profileCompleteButton'),
        label: '완료',
        backgroundColor: AppColors.surfaceDisabled,
        foregroundColor: AppColors.textDisabled,
        onPressed: null,
      );
    }

    return CommonButton.secondary(
      key: const ValueKey('profileCompleteButton'),
      label: '완료',
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.brandPrimary,
      borderColor: AppColors.brandPrimary,
      onPressed: onPressed,
    );
  }
}
