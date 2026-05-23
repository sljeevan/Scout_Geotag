import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class DynamicDropdownField extends StatelessWidget {
  const DynamicDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label, errorText: errorText),
      style: const TextStyle(color: AppColors.textPrimary),
      dropdownColor: AppColors.surface,
      items: options
          .map(
            (option) => DropdownMenuItem(
              value: option,
              child: Text(
                option,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
