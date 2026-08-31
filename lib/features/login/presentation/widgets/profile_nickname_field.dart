import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

const double _nicknameFieldHeight = 56;
const double _nicknameFieldHeightWithHelper = 80;

class ProfileNicknameField extends StatefulWidget {
  const ProfileNicknameField({
    required this.nickname,
    required this.onChanged,
    this.serverErrorMessage,
    super.key,
  });

  final String nickname;
  final ValueChanged<String> onChanged;
  final String? serverErrorMessage;

  @override
  State<ProfileNicknameField> createState() => _ProfileNicknameFieldState();
}

class _ProfileNicknameFieldState extends State<ProfileNicknameField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.nickname);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant ProfileNicknameField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.nickname != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.nickname,
        selection: TextSelection.collapsed(offset: widget.nickname.length),
      );
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool get _hasValidNickname {
    final nickname = widget.nickname.trim();
    return nickname.length >= 2 && nickname.length <= 10;
  }

  bool get _hasNicknameError {
    final nickname = widget.nickname.trim();
    return nickname.isNotEmpty && !_hasValidNickname;
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.nickname.isNotEmpty;
    final hasValidNickname = _hasValidNickname;
    final hasNicknameError = _hasNicknameError;
    final errorMessage =
        widget.serverErrorMessage ??
        (hasNicknameError ? '2~10자의 닉네임으로 입력해 주세요' : null);
    final hasError = errorMessage != null;
    final lineColor = hasError
        ? AppColors.danger
        : hasValidNickname
        ? AppColors.brandStrong
        : AppColors.textDisabled;

    return SizedBox(
      key: const ValueKey('profileNicknameField'),
      height: hasValidNickname || hasError
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
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: widget.onChanged,
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
          if (hasValidNickname && !hasError)
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
          if (hasError)
            Positioned(
              left: 0,
              top: 64,
              child: Text(
                errorMessage,
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
