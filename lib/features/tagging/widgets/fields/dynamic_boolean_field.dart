import 'package:flutter/material.dart';

class DynamicBooleanField extends StatelessWidget {
  const DynamicBooleanField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final bool? value;
  final ValueChanged<bool> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label, errorText: errorText),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Yes'),
            selected: value == true,
            onSelected: (_) => onChanged(true),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('No'),
            selected: value == false,
            onSelected: (_) => onChanged(false),
          ),
        ],
      ),
    );
  }
}
