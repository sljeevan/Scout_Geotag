import 'package:flutter/material.dart';

import '../models/tag_models.dart';
import 'fields/dynamic_boolean_field.dart';
import 'fields/dynamic_dropdown_field.dart';
import 'fields/dynamic_text_field.dart';

class DynamicFormRenderer extends StatelessWidget {
  const DynamicFormRenderer({
    super.key,
    required this.fields,
    required this.values,
    required this.onValueChanged,
    required this.errors,
    this.onVisibleFieldsChanged,
  });

  final List<DynamicFieldConfig> fields;
  final Map<String, dynamic> values;
  final void Function(String key, dynamic value) onValueChanged;
  final Map<String, String> errors;
  final ValueChanged<Set<String>>? onVisibleFieldsChanged;

  @override
  Widget build(BuildContext context) {
    final visibleFields =
        fields.where((field) => field.isVisible(values)).toList();
    final visibleKeys = visibleFields.map((field) => field.key).toSet();

    if (onVisibleFieldsChanged != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onVisibleFieldsChanged!(visibleKeys);
      });
    }

    if (visibleFields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: visibleFields.map((field) {
        final widget = _buildField(field);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: widget,
        );
      }).toList(),
    );
  }

  Widget _buildField(DynamicFieldConfig field) {
    final value = values[field.key];
    final errorText = errors[field.key];

    switch (field.type) {
      case DynamicFieldType.select:
        return DynamicDropdownField(
          label: field.label,
          value: value as String?,
          options: field.options,
          errorText: errorText,
          onChanged: (newValue) => onValueChanged(field.key, newValue),
        );
      case DynamicFieldType.text:
        return DynamicTextField(
          label: field.label,
          initialValue: (value as String?) ?? '',
          errorText: errorText,
          onChanged: (newValue) => onValueChanged(field.key, newValue),
        );
      case DynamicFieldType.number:
        return DynamicTextField(
          label: field.label,
          initialValue: value?.toString() ?? '',
          keyboardType: TextInputType.number,
          errorText: errorText,
          onChanged: (newValue) {
            final trimmed = newValue.trim();
            if (trimmed.isEmpty) {
              onValueChanged(field.key, null);
              return;
            }
            final parsed = num.tryParse(trimmed);
            onValueChanged(field.key, parsed ?? trimmed);
          },
        );
      case DynamicFieldType.boolean:
        return DynamicBooleanField(
          label: field.label,
          value: value as bool?,
          errorText: errorText,
          onChanged: (newValue) => onValueChanged(field.key, newValue),
        );
    }
  }
}
