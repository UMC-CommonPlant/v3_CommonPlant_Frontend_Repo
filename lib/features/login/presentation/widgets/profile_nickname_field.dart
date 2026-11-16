import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/profile_setup_state.dart';
import 'package:flutter/material.dart';

const double _nicknameFieldHeight = 56;

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
  bool _wasFocused = false;
  bool _hasBlurred = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.nickname);
    _focusNode = FocusNode()..addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _wasFocused = true;
    } else if (_wasFocused && !_hasBlurred) {
      setState(() => _hasBlurred = true);
    }
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
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage =
        widget.serverErrorMessage ??
        (_hasBlurred ? validateProfileNickname(widget.nickname) : null);
    final lineColor = errorMessage != null
        ? AppColors.danger
        : _hasBlurred
        ? AppColors.brandStrong
        : AppColors.textDisabled;

    return Column(
      key: const ValueKey('profileNicknameField'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
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
                    onTapOutside: (_) => _focusNode.unfocus(),
                    maxLength: profileNicknameMaxLength,
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
                if (widget.nickname.isEmpty)
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
                        TextSpan(text: '/$profileNicknameMaxLength'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: AppSpacing.x8),
          Text(
            errorMessage,
            style: AppTextStyles.size12Medium.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }
}
