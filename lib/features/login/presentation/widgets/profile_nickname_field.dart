import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

const double _nicknameFieldHeight = 56;
const double _nicknameFieldHeightWithHelper = 80;

class ProfileNicknameField extends StatelessWidget {
  const ProfileNicknameField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    super.key,
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
