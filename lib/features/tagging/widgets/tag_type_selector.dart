import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class TagTypeSelector extends StatelessWidget {
  const TagTypeSelector({
    super.key,
    required this.tagTypes,
    required this.value,
    required this.onChanged,
  });

  final List<String> tagTypes;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(labelText: 'Tag Type'),
      style: const TextStyle(color: AppColors.textPrimary),
      dropdownColor: AppColors.surface,
      items: tagTypes
          .map((tagType) => DropdownMenuItem(
                value: tagType,
                child: Text(
                  tagType,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
