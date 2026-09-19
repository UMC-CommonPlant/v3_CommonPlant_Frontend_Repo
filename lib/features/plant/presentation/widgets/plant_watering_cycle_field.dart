import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_text_field.dart';
import 'package:flutter/material.dart';

class PlantWateringCycleField extends StatefulWidget {
  const PlantWateringCycleField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.enabled,
    required this.helperText,
    this.errorText,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String helperText;
  final String? errorText;

  @override
  State<PlantWateringCycleField> createState() =>
      _PlantWateringCycleFieldState();
}

class _PlantWateringCycleFieldState extends State<PlantWateringCycleField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant PlantWateringCycleField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.value) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '물주기 주기',
          style: AppTextStyles.size18Medium.copyWith(
            color: AppColors.textStrong,
          ),
        ),
        const SizedBox(height: AppSpacing.x8),
        CommonTextField(
          controller: _controller,
          hintText: '예: 7',
          enabled: widget.enabled,
          keyboardType: TextInputType.number,
          trailing: Text(
            '일마다',
            style: AppTextStyles.size16Medium.copyWith(
              color: AppColors.textBody,
            ),
          ),
          onChanged: widget.onChanged,
          state: widget.errorText == null
              ? CommonTextFieldState.normal
              : CommonTextFieldState.error,
          helperText: widget.errorText ?? widget.helperText,
        ),
      ],
    );
  }
}
