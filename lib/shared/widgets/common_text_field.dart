import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

enum CommonTextFieldState { normal, success, error, disabled }

typedef CommonTextFieldValidator =
    CommonTextFieldValidation Function(String value, bool isFocused);

class CommonTextFieldValidation {
  const CommonTextFieldValidation({required this.state, this.helperText});

  final CommonTextFieldState state;
  final String? helperText;
}

class CommonTextField extends StatefulWidget {
  const CommonTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.helperText,
    this.trailing,
    this.onChanged,
    this.state = CommonTextFieldState.normal,
    this.enabled = true,
    this.maxLength,
    this.showClearButton = true,
    this.forceFocusedDecoration = false,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? helperText;
  final Widget? trailing;
  final ValueChanged<String>? onChanged;
  final CommonTextFieldState state;
  final bool enabled;
  final int? maxLength;
  final bool showClearButton;
  final bool forceFocusedDecoration;
  final TextInputType? keyboardType;
  final CommonTextFieldValidator? validator;

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  late TextEditingController _internalController;
  late FocusNode _internalFocusNode;

  TextEditingController get _controller =>
      widget.controller ?? _internalController;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  bool get _isFocused => _focusNode.hasFocus;
  bool get _usesFocusedDecoration =>
      _isFocused || widget.forceFocusedDecoration;
  bool get _hasText => _controller.text.isNotEmpty;

  CommonTextFieldValidation get _validation {
    return widget.validator?.call(_controller.text, _isFocused) ??
        CommonTextFieldValidation(
          state: widget.state,
          helperText: widget.helperText,
        );
  }

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController();
    _internalFocusNode = FocusNode();
    _controller.addListener(_handleInputStateChanged);
    _focusNode.addListener(_handleInputStateChanged);
  }

  @override
  void didUpdateWidget(covariant CommonTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _internalController).removeListener(
        _handleInputStateChanged,
      );
      _controller.addListener(_handleInputStateChanged);
    }

    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode).removeListener(
        _handleInputStateChanged,
      );
      _focusNode.addListener(_handleInputStateChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleInputStateChanged);
    _focusNode.removeListener(_handleInputStateChanged);
    _internalController.dispose();
    _internalFocusNode.dispose();
    super.dispose();
  }

  void _handleInputStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  Widget? _buildTrailing() {
    final children = <Widget>[];

    if (widget.trailing != null) {
      children.add(widget.trailing!);
    }

    if (widget.showClearButton && _usesFocusedDecoration && _hasText) {
      children.add(_CommonTextFieldClearButton(onPressed: _clearText));
    }

    if (widget.maxLength != null) {
      children.add(
        _CommonTextFieldCounter(
          currentLength: _controller.text.length,
          maxLength: widget.maxLength!,
          focused: _usesFocusedDecoration,
        ),
      );
    }

    if (children.isEmpty) {
      return null;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) const SizedBox(width: AppSpacing.x8),
          children[index],
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final validation = _validation;
    final fieldStyle = _CommonTextFieldStyle.resolve(
      state: validation.state,
      enabled: widget.enabled,
      usesFocusedDecoration: _usesFocusedDecoration,
    );
    final trailing = _buildTrailing();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: fieldStyle.decoration,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: fieldStyle.enabled,
                  onChanged: widget.onChanged,
                  maxLength: widget.maxLength,
                  keyboardType: widget.keyboardType,
                  style: fieldStyle.inputTextStyle,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: fieldStyle.hintTextStyle,
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.x16,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.x12),
                trailing,
              ],
            ],
          ),
        ),
        if (validation.helperText != null) ...[
          const SizedBox(height: AppSpacing.x8),
          Text(validation.helperText!, style: fieldStyle.helperTextStyle),
        ],
      ],
    );
  }
}

class _CommonTextFieldStyle {
  const _CommonTextFieldStyle({
    required this.enabled,
    required this.lineColor,
    required this.helperColor,
  });

  final bool enabled;
  final Color lineColor;
  final Color helperColor;

  static _CommonTextFieldStyle resolve({
    required CommonTextFieldState state,
    required bool enabled,
    required bool usesFocusedDecoration,
  }) {
    return _CommonTextFieldStyle(
      enabled: enabled && state != CommonTextFieldState.disabled,
      lineColor: switch (state) {
        CommonTextFieldState.error => AppColors.danger,
        CommonTextFieldState.success => AppColors.brandStrong,
        CommonTextFieldState.disabled => AppColors.textDisabled,
        CommonTextFieldState.normal =>
          usesFocusedDecoration
              ? AppColors.textHeadline
              : AppColors.textDisabled,
      },
      helperColor: switch (state) {
        CommonTextFieldState.error => AppColors.danger,
        CommonTextFieldState.success => AppColors.brandStrong,
        CommonTextFieldState.disabled ||
        CommonTextFieldState.normal => AppColors.textBody,
      },
    );
  }

  BoxDecoration get decoration {
    return BoxDecoration(
      border: Border(bottom: BorderSide(color: lineColor)),
    );
  }

  TextStyle get inputTextStyle {
    return AppTextStyles.size18Medium.copyWith(color: AppColors.textHeadline);
  }

  TextStyle get hintTextStyle {
    return AppTextStyles.size18Medium.copyWith(color: AppColors.textDisabled);
  }

  TextStyle get helperTextStyle {
    return AppTextStyles.size12Medium.copyWith(color: helperColor);
  }
}

class _CommonTextFieldCounter extends StatelessWidget {
  const _CommonTextFieldCounter({
    required this.currentLength,
    required this.maxLength,
    required this.focused,
  });

  final int currentLength;
  final int maxLength;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.size14Medium.copyWith(color: AppColors.textBody),
        children: [
          TextSpan(
            text: '$currentLength',
            style: AppTextStyles.size14Bold.copyWith(
              color: focused ? AppColors.textHeadline : AppColors.textBody,
            ),
          ),
          TextSpan(text: '/$maxLength'),
        ],
      ),
    );
  }
}

class _CommonTextFieldClearButton extends StatelessWidget {
  const _CommonTextFieldClearButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.textFieldClearButtonSize,
      height: AppSizes.textFieldClearButtonSize,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(
          width: AppSizes.textFieldClearButtonSize,
          height: AppSizes.textFieldClearButtonSize,
        ),
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: const CommonSvgIcon(
          AppIconAssets.delete,
          width: AppSizes.textFieldClearIconSize,
          height: AppSizes.textFieldClearIconSize,
          semanticsLabel: '텍스트 삭제',
        ),
      ),
    );
  }
}
