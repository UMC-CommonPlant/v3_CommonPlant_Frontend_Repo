import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class MemoContentField extends StatefulWidget {
  const MemoContentField({
    required this.content,
    required this.maxLength,
    required this.onChanged,
    super.key,
  });

  final String content;
  final int maxLength;
  final ValueChanged<String> onChanged;

  @override
  State<MemoContentField> createState() => _MemoContentFieldState();
}

class _MemoContentFieldState extends State<MemoContentField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
  }

  @override
  void didUpdateWidget(covariant MemoContentField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.content != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.content,
        selection: TextSelection.collapsed(offset: widget.content.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLength = widget.content.characters.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
          ),
          child: TextField(
            controller: _controller,
            maxLength: widget.maxLength,
            minLines: 1,
            maxLines: 6,
            keyboardType: TextInputType.multiline,
            onChanged: widget.onChanged,
            style: AppTextStyles.size16Medium.copyWith(
              color: AppColors.textStrong,
            ),
            decoration: InputDecoration(
              hintText: '메모 내용을 입력해 주세요',
              hintStyle: AppTextStyles.size18Medium.copyWith(
                color: AppColors.textDisabled,
              ),
              counterText: '',
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.x16,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.x8),
        RichText(
          text: TextSpan(
            style: AppTextStyles.size14Medium.copyWith(
              color: AppColors.textBody,
            ),
            children: [
              TextSpan(
                text: '$currentLength',
                style: AppTextStyles.size14Bold.copyWith(
                  color: AppColors.textBody,
                ),
              ),
              TextSpan(text: '/${widget.maxLength}'),
            ],
          ),
        ),
      ],
    );
  }
}
