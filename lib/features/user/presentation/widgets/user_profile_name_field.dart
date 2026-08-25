import 'package:commonplant_frontend/shared/widgets/common_text_field.dart';
import 'package:flutter/material.dart';

class UserProfileNameField extends StatefulWidget {
  const UserProfileNameField({
    super.key,
    required this.name,
    required this.onChanged,
  });

  final String name;
  final ValueChanged<String> onChanged;

  @override
  State<UserProfileNameField> createState() => _UserProfileNameFieldState();
}

class _UserProfileNameFieldState extends State<UserProfileNameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
  }

  @override
  void didUpdateWidget(covariant UserProfileNameField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.name != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.name,
        selection: TextSelection.collapsed(offset: widget.name.length),
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
    return CommonTextField(
      controller: _controller,
      hintText: '이름을 입력해 주세요',
      maxLength: 10,
      onChanged: widget.onChanged,
      validator: _validateName,
    );
  }
}

CommonTextFieldValidation _validateName(String value, bool isFocused) {
  final normalizedName = value.trim();

  if (normalizedName.isEmpty ||
      (normalizedName.length >= 2 && normalizedName.length <= 10)) {
    return const CommonTextFieldValidation(state: CommonTextFieldState.normal);
  }

  return const CommonTextFieldValidation(
    state: CommonTextFieldState.error,
    helperText: '2~10자의 이름으로 입력해 주세요',
  );
}
