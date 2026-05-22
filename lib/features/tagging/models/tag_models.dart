import 'dart:convert';

import 'location_model.dart';

enum DynamicFieldType { select, text, number, boolean }

class FieldCondition {
  const FieldCondition({
    required this.fieldKey,
    required this.equals,
  });

  final String fieldKey;
  final Object equals;

  bool matches(Map<String, dynamic> values) => values[fieldKey] == equals;
}

class FieldValidation {
  const FieldValidation({
    this.isRequired = false,
    this.minLength,
    this.maxLength,
    this.regexPattern,
    this.minValue,
    this.maxValue,
    this.validationMessage,
  });

  final bool isRequired;
  final int? minLength;
  final int? maxLength;
  final String? regexPattern;
  final num? minValue;
  final num? maxValue;
  final String? validationMessage;

  String? validate({
    required DynamicFieldType type,
    required String label,
    required dynamic value,
  }) {
    if (isRequired) {
      if (value == null) {
        return validationMessage ?? '$label is required';
      }
      if (value is String && value.trim().isEmpty) {
        return validationMessage ?? '$label is required';
      }
    }

    if (value == null) return null;

    if (type == DynamicFieldType.text || type == DynamicFieldType.select) {
      final text = value.toString().trim();
      if (text.isEmpty) return null;

      if (minLength != null && text.length < minLength!) {
        return validationMessage ??
            '$label must be at least $minLength characters';
      }
      if (maxLength != null && text.length > maxLength!) {
        return validationMessage ??
            '$label must be at most $maxLength characters';
      }
      if (regexPattern != null && regexPattern!.isNotEmpty) {
        final regex = RegExp(regexPattern!);
        if (!regex.hasMatch(text)) {
          return validationMessage ?? '$label format is invalid';
        }
      }
    }

    if (type == DynamicFieldType.number) {
      final num? numeric =
          value is num ? value : num.tryParse(value.toString());
      if (numeric == null) {
        return validationMessage ?? '$label must be a valid number';
      }
      if (minValue != null && numeric < minValue!) {
        return validationMessage ?? '$label must be at least $minValue';
      }
      if (maxValue != null && numeric > maxValue!) {
        return validationMessage ?? '$label must be at most $maxValue';
      }
    }

    return null;
  }
}

class DynamicFieldConfig {
  const DynamicFieldConfig({
    required this.key,
    required this.label,
    required this.type,
    this.options = const [],
    this.conditions = const [],
    this.validation = const FieldValidation(),
    this.analyticsKey,
    this.searchable = false,
    this.exportable = true,
  });

  final String key;
  final String label;
  final DynamicFieldType type;
  final List<String> options;
  final List<FieldCondition> conditions;
  final FieldValidation validation;
  final String? analyticsKey;
  final bool searchable;
  final bool exportable;

  bool isVisible(Map<String, dynamic> values) {
    if (conditions.isEmpty) return true;
    return conditions.every((condition) => condition.matches(values));
  }

  String? validateValue(dynamic value) {
    return validation.validate(type: type, label: label, value: value);
  }
}

class TagSubmission {
  const TagSubmission({
    required this.formVersion,
    required this.schemaVersion,
    required this.tagType,
    required this.category,
    required this.entityName,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
    required this.location,
    required this.searchable,
    required this.metadata,
    required this.entityDetails,
  });

  final int formVersion;
  final int schemaVersion;
  final String tagType;
  final String category;
  final String entityName;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final LocationModel location;
  final Map<String, dynamic> searchable;
  final Map<String, dynamic> metadata;
  final Map<String, dynamic> entityDetails;

  Map<String, dynamic> toJson() => {
        'form_version': formVersion,
        'schema_version': schemaVersion,
        'tag_type': tagType,
        'category': category,
        'entity_name': entityName,
        'contact_person': contactPerson,
        'phone': phone,
        'email': email,
        'address': address,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'location_accuracy': location.accuracy,
        'captured_at': location.capturedAt.toUtc().toIso8601String(),
        'resolved_address': location.address,
        'location': location.toJson(),
        'entity_details': entityDetails,
        'searchable': searchable,
        'metadata': metadata,
      };

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
