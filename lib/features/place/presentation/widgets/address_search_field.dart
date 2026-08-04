import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/shared/widgets/common_search_text_field.dart';
import 'package:flutter/material.dart';

class AddressSearchField extends StatefulWidget {
  const AddressSearchField({
    required this.initialQuery,
    required this.onChanged,
    super.key,
  });

  final String initialQuery;
  final ValueChanged<String> onChanged;

  @override
  State<AddressSearchField> createState() => _AddressSearchFieldState();
}

class _AddressSearchFieldState extends State<AddressSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonSearchTextField(
      controller: _controller,
      hintText: '주소를 입력해 주세요.',
      horizontalPadding: AppSpacing.x20,
      onChanged: widget.onChanged,
    );
  }
}
