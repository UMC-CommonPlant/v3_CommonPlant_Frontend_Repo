import 'package:commonplant_frontend/shared/widgets/common_text_field.dart';
import 'package:flutter/material.dart';

class PlantNameField extends StatefulWidget {
  const PlantNameField({
    super.key,
    required this.name,
    required this.onChanged,
    this.serverErrorMessage,
  });

  final String name;
  final ValueChanged<String> onChanged;
  final String? serverErrorMessage;

  @override
  State<PlantNameField> createState() => _PlantNameFieldState();
}

class _PlantNameFieldState extends State<PlantNameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
  }

  @override
  void didUpdateWidget(covariant PlantNameField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.name == _controller.text) {
      return;
    }

    _controller.value = TextEditingValue(
      text: widget.name,
      selection: TextSelection.collapsed(offset: widget.name.length),
    );
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
      maxLength: 10,
      forceFocusedDecoration: true,
      onChanged: widget.onChanged,
      state: widget.serverErrorMessage == null
          ? CommonTextFieldState.normal
          : CommonTextFieldState.error,
      helperText: widget.serverErrorMessage,
    );
  }
}
