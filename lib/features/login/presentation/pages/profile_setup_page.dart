import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/core/theme/app_theme_tokens.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_circle_image_box.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final FocusNode _nicknameFocusNode = FocusNode();
  bool _hasImage = false;

  bool get _canSubmit {
    final nickname = _nicknameController.text.trim();
    return nickname.length >= 2 && nickname.length <= 10;
  }

  CommonTextFieldValidation _validateNickname(String value, bool isFocused) {
    final nickname = value.trim();
    if (nickname.isEmpty || isFocused) {
      return const CommonTextFieldValidation(
        state: CommonTextFieldState.normal,
      );
    }
    if (nickname.length < 2 || nickname.length > 10) {
      return const CommonTextFieldValidation(
        state: CommonTextFieldState.error,
        helperText: '2~10자의 닉네임으로 입력해주세요',
      );
    }
    if (nickname == '커먼플랜트') {
      return const CommonTextFieldValidation(
        state: CommonTextFieldState.error,
        helperText: '이미 사용 중인 닉네임입니다',
      );
    }
    return const CommonTextFieldValidation(
      state: CommonTextFieldState.success,
      helperText: '사용가능한 닉네임 입니다',
    );
  }

  @override
  void dispose() {
    _nicknameFocusNode.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _showImagePicker() {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: tokens.surfaceBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.large),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.x20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '프로필 사진',
                  style: AppTextStyles.size20Medium.copyWith(
                    color: AppColors.textHeadline,
                  ),
                ),
                const SizedBox(height: AppSpacing.x16),
                CommonButton(
                  label: '샘플 이미지 선택',
                  onPressed: () {
                    setState(() => _hasImage = true);
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: AppSpacing.x8),
                CommonButton.secondary(
                  label: '기본 이미지로 계속하기',
                  onPressed: () {
                    setState(() => _hasImage = false);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: '프로필 설정',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.x16),
          Center(
            child: CommonCircleImageBox(
              onTap: _showImagePicker,
              imageProvider: _hasImage
                  ? const AssetImage(AppImageAssets.leafAvatarPlaceholder)
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.x40),
          Text(
            '닉네임',
            style: AppTextStyles.size16Bold.copyWith(
              color: AppColors.textStrong,
            ),
          ),
          const SizedBox(height: AppSpacing.x8),
          CommonTextField(
            controller: _nicknameController,
            focusNode: _nicknameFocusNode,
            hintText: '닉네임을 입력해 주세요',
            maxLength: 10,
            validator: _validateNickname,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.x32),
          CommonButton(
            label: '완료',
            onPressed: _canSubmit
                ? () => context.go(AppRoutePaths.terms)
                : null,
          ),
        ],
      ),
    );
  }
}
