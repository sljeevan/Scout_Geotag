import 'package:flutter/material.dart';

class DynamicCategorySelector extends StatelessWidget {
  const DynamicCategorySelector({
    super.key,
    required this.categories,
    required this.value,
    required this.onChanged,
  });

  final List<String> categories;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(labelText: 'Category'),
      items: categories
          .map((category) =>
              DropdownMenuItem(value: category, child: Text(category)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
