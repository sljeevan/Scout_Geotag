import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../theme/app_spacing.dart';
import '../models/tag_models.dart';
import 'dynamic_form_renderer.dart';

class EntityDetailsSection extends StatelessWidget {
  const EntityDetailsSection({
    super.key,
    required this.tagType,
    required this.fields,
    required this.values,
    required this.errors,
    required this.onValueChanged,
  });

  final String? tagType;
  final List<DynamicFieldConfig> fields;
  final Map<String, dynamic> values;
  final Map<String, String> errors;
  final void Function(String key, dynamic value) onValueChanged;

  @override
  Widget build(BuildContext context) {
    if (tagType == null) {
      return const SizedBox.shrink();
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Entity Details',
              style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.x2),
          DynamicFormRenderer(
            fields: fields,
            values: values,
            errors: errors,
            onValueChanged: onValueChanged,
          ),
        ],
      ),
    );
  }
}
