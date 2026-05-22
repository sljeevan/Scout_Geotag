import 'package:flutter/material.dart';

class DynamicTextField extends StatelessWidget {
  const DynamicTextField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.keyboardType,
    this.errorText,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(label),
      initialValue: initialValue,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, errorText: errorText),
    );
  }
}
