import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class CommonSearchTextField extends StatefulWidget {
  const CommonSearchTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = '식물을 입력해 주세요.',
    this.onChanged,
    this.enabled = true,
    this.horizontalPadding = 0,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final double horizontalPadding;

  @override
  State<CommonSearchTextField> createState() => _CommonSearchTextFieldState();
}

class _CommonSearchTextFieldState extends State<CommonSearchTextField> {
  late final TextEditingController _internalController;
  late final FocusNode _internalFocusNode;

  TextEditingController get _controller =>
      widget.controller ?? _internalController;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  bool get _hasText => _controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController();
    _internalFocusNode = FocusNode();
    _controller.addListener(_handleInputStateChanged);
  }

  @override
  void didUpdateWidget(covariant CommonSearchTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _internalController).removeListener(
        _handleInputStateChanged,
      );
      _controller.addListener(_handleInputStateChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleInputStateChanged);
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

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColorPrimitives.grayGray2)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppSizes.searchTextFieldHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
          child: Row(
            children: [
              const CommonSvgIcon(
                AppIconAssets.search,
                width: AppSizes.searchTextFieldIconSize,
                height: AppSizes.searchTextFieldIconSize,
                semanticsLabel: '검색',
              ),
              const SizedBox(width: AppSpacing.x16),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  onChanged: widget.onChanged,
                  style: AppTextStyles.size18Medium.copyWith(
                    color: AppColors.textHeadline,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: AppTextStyles.size18Medium.copyWith(
                      color: AppColors.textDisabled,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              if (_hasText) ...[
                const SizedBox(width: AppSpacing.x16),
                _SearchTextFieldClearButton(onPressed: _clearText),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchTextFieldClearButton extends StatelessWidget {
  const _SearchTextFieldClearButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: AppSizes.textFieldClearButtonSize,
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
          semanticsLabel: '검색어 삭제',
        ),
      ),
    );
  }
}
