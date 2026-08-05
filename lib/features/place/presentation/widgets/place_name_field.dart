import 'package:commonplant_frontend/shared/widgets/common_text_field.dart';
import 'package:flutter/material.dart';

class PlaceNameField extends StatefulWidget {
  const PlaceNameField({
    super.key,
    required this.name,
    required this.hintText,
    required this.onChanged,
    this.forceFocusedDecoration = false,
  });

  final String name;
  final String hintText;
  final ValueChanged<String> onChanged;
  final bool forceFocusedDecoration;

  @override
  State<PlaceNameField> createState() => _PlaceNameFieldState();
}

class _PlaceNameFieldState extends State<PlaceNameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
  }

  @override
  void didUpdateWidget(covariant PlaceNameField oldWidget) {
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
      hintText: widget.hintText,
      maxLength: 10,
      forceFocusedDecoration: widget.forceFocusedDecoration,
      onChanged: widget.onChanged,
    );
  }
}
