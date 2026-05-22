import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_button.dart';
import '../../data/models/tag_entry.dart';
import '../../state/project_state.dart';
import '../../theme/app_spacing.dart';
import 'config/form_config.dart';
import 'config/tag_constants.dart';
import 'models/location_model.dart';
import 'models/tag_models.dart';
import 'services/location_service.dart';
import 'widgets/dynamic_category_selector.dart';
import 'widgets/dynamic_form_renderer.dart';
import 'widgets/entity_details_section.dart';
import 'widgets/location_capture_section.dart';
import 'widgets/tag_type_selector.dart';

class TagScreen extends StatefulWidget {
  const TagScreen({super.key});

  @override
  State<TagScreen> createState() => _TagScreenState();
}

class _TagScreenState extends State<TagScreen> {
  final LocationService _locationService = LocationService();

  String? _tagType;
  String? _category;
  final Map<String, dynamic> _entityValues = {};
  final Map<String, dynamic> _metadata = {};
  final Map<String, String> _entityErrors = {};
  final Map<String, String> _metadataErrors = {};

  LocationCaptureState _locationState = LocationCaptureState.idle;
  LocationModel? _location;
  String? _locationMessage;
  double? _manualLatitude;
  double? _manualLongitude;
  String? _manualAddress;

  @override
  void initState() {
    super.initState();
    _captureLocation();
  }

  Future<void> _captureLocation() async {
    setState(() {
      _locationState = LocationCaptureState.loading;
      _locationMessage = null;
    });

    final result = await _locationService.captureCurrentLocation();
    setState(() {
      _locationState = result.state;
      _location = result.location;
      _locationMessage = result.message;
    });
  }

  List<String> get _categories {
    if (_tagType == null) return const [];
    return TagFormConfig.categoriesForTagType(_tagType!);
  }

  List<DynamicFieldConfig> get _entityFields {
    if (_tagType == null) return const [];
    return TagFormConfig.entityFieldsForTagType(_tagType!);
  }

  List<DynamicFieldConfig> get _activeFields {
    if (_category == null) return const [];
    return TagFormConfig.fieldsForCategory(_category!);
  }

  List<DynamicFieldConfig> get _visibleFields {
    if (_category == null) return const [];
    return TagFormConfig.visibleFields(_category!, _metadata);
  }

  void _onTagTypeChanged(String? value) {
    setState(() {
      _tagType = value;
      _category = null;
      _entityValues.clear();
      _entityErrors.clear();
      _metadata.clear();
      _metadataErrors.clear();
    });
  }

  void _onCategoryChanged(String? value) {
    setState(() {
      _category = value;
      _metadata.clear();
      _metadataErrors.clear();
    });
  }

  void _onEntityValueChanged(String key, dynamic value) {
    setState(() {
      if (value == null || (value is String && value.trim().isEmpty)) {
        _entityValues.remove(key);
      } else {
        _entityValues[key] = value;
      }
      _entityErrors.remove(key);
    });
  }

  void _onFieldValueChanged(String key, dynamic value) {
    setState(() {
      if (value == null || (value is String && value.trim().isEmpty)) {
        _metadata.remove(key);
      } else {
        _metadata[key] = value;
      }
      _metadataErrors.remove(key);
      _cleanupHiddenValues();
    });
  }

  void _onVisibleFieldsChanged(Set<String> visibleKeys) {
    if (_category == null) return;

    final staleMetadataKeys =
        _metadata.keys.where((key) => !visibleKeys.contains(key)).toList();
    final staleErrorKeys = _metadataErrors.keys
        .where((key) => !visibleKeys.contains(key))
        .toList();

    if (staleMetadataKeys.isEmpty && staleErrorKeys.isEmpty) {
      return;
    }

    setState(() {
      for (final key in staleMetadataKeys) {
        _metadata.remove(key);
      }
      for (final key in staleErrorKeys) {
        _metadataErrors.remove(key);
      }
    });
  }

  void _cleanupHiddenValues() {
    final visibleKeys = _visibleFields.map((field) => field.key).toSet();
    _metadata.removeWhere((fieldKey, _) => !visibleKeys.contains(fieldKey));
    _metadataErrors
        .removeWhere((fieldKey, _) => !visibleKeys.contains(fieldKey));
  }

  bool _validateEntityFields() {
    final nextErrors = <String, String>{};
    for (final field in _entityFields) {
      final value = _entityValues[field.key];
      final error = field.validateValue(value);
      if (error != null) {
        nextErrors[field.key] = error;
      }
    }

    setState(() {
      _entityErrors
        ..clear()
        ..addAll(nextErrors);
    });

    return nextErrors.isEmpty;
  }

  bool _validateVisibleFields() {
    final nextErrors = <String, String>{};

    for (final field in _visibleFields) {
      final value = _metadata[field.key];
      final error = field.validateValue(value);
      if (error != null) {
        nextErrors[field.key] = error;
      }
    }

    setState(() {
      _metadataErrors
        ..clear()
        ..addAll(nextErrors);
    });

    return nextErrors.isEmpty;
  }

  void _onManualLocationFieldChanged(String key, String value) {
    final trimmed = value.trim();
    setState(() {
      if (key == 'latitude') {
        _manualLatitude = double.tryParse(trimmed);
      } else if (key == 'longitude') {
        _manualLongitude = double.tryParse(trimmed);
      } else if (key == 'address') {
        _manualAddress = trimmed.isEmpty ? null : trimmed;
      }
    });
  }

  LocationModel? get _effectiveLocation {
    if (_location != null) return _location;
    if (_manualLatitude != null && _manualLongitude != null) {
      return LocationModel(
        latitude: _manualLatitude!,
        longitude: _manualLongitude!,
        accuracy: 999,
        capturedAt: DateTime.now(),
        address: _manualAddress,
      );
    }
    return null;
  }

  bool get _canSave => _tagType != null && _category != null;

  Map<String, dynamic> _buildSearchable({
    required List<DynamicFieldConfig> visibleFields,
    required LocationModel location,
  }) {
    final searchable = <String, dynamic>{
      'tag_type': _tagType,
      'category': _category,
      'entity_name': _entityValues[EntityFieldKeys.entityName],
      'contact_person': _entityValues[EntityFieldKeys.contactPerson],
      'phone': _entityValues[EntityFieldKeys.phone],
      'email': _entityValues[EntityFieldKeys.email],
      'address': _entityValues[EntityFieldKeys.address],
      'latitude': location.latitude,
      'longitude': location.longitude,
      'location_accuracy': location.accuracy,
      'captured_at': location.capturedAt.toUtc().toIso8601String(),
      'resolved_address': location.address,
    };

    for (final field in _entityFields) {
      final value = _entityValues[field.key];
      if (field.searchable && value != null) {
        searchable[field.analyticsKey ?? field.key] = value;
      }
    }

    for (final field in visibleFields) {
      final value = _metadata[field.key];
      if (field.searchable && value != null) {
        searchable[field.analyticsKey ?? field.key] = value;
      }
    }

    searchable.removeWhere((key, value) => value == null);
    return searchable;
  }

  TagSubmission? get _submission {
    if (!_canSave) return null;
    final location = _effectiveLocation;
    if (location == null) return null;

    final visibleFields = _visibleFields;

    return TagSubmission(
      formVersion: TagFormConfig.formVersion,
      schemaVersion: TagFormConfig.schemaVersion,
      tagType: _tagType!,
      category: _category!,
      entityName: (_entityValues[EntityFieldKeys.entityName] as String?) ?? '',
      contactPerson: _entityValues[EntityFieldKeys.contactPerson] as String?,
      phone: _entityValues[EntityFieldKeys.phone] as String?,
      email: _entityValues[EntityFieldKeys.email] as String?,
      address: _entityValues[EntityFieldKeys.address] as String?,
      location: location,
      searchable:
          _buildSearchable(visibleFields: visibleFields, location: location),
      metadata: Map<String, dynamic>.from(_metadata),
      entityDetails: Map<String, dynamic>.from(_entityValues),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.x3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Intelligent Tagging',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.x2),
          LocationCaptureSection(
            state: _locationState,
            location: _location,
            message: _locationMessage,
            onRefresh: _captureLocation,
            onOpenLocationSettings: _locationService.openLocationSettings,
            onOpenAppSettings: _locationService.openAppSettings,
            onManualFieldChanged: _onManualLocationFieldChanged,
          ),
          const SizedBox(height: AppSpacing.x2),
          _buildTagSetupCard(),
          const SizedBox(height: AppSpacing.x2),
          EntityDetailsSection(
            tagType: _tagType,
            fields: _entityFields,
            values: _entityValues,
            errors: _entityErrors,
            onValueChanged: _onEntityValueChanged,
          ),
          if (_category != null) ...[
            const SizedBox(height: AppSpacing.x2),
            _buildDynamicDetailsCard(),
          ],
          const SizedBox(height: AppSpacing.x2),
          AppButton(
            label: 'Save Tag',
            icon: Icons.save_outlined,
            onPressed: !_canSave
                ? null
                : () async {
                    if (_effectiveLocation == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Location is required. Capture GPS or provide manual coordinates.')),
                      );
                      return;
                    }

                    final entityValid = _validateEntityFields();
                    final metadataValid = _validateVisibleFields();

                    if (!entityValid || !metadataValid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Please fix validation errors before saving')),
                      );
                      return;
                    }

                    final data = _submission!;
                    await context.read<ProjectState>().saveTagEntry(
                          TagEntry(
                            tagType: data.tagType,
                            category: data.category,
                            entityName: data.entityName,
                            contactPerson: data.contactPerson,
                            phone: data.phone,
                            email: data.email,
                            address: data.address,
                            latitude: data.location.latitude,
                            longitude: data.location.longitude,
                            capturedAt:
                                data.location.capturedAt.millisecondsSinceEpoch,
                          ),
                        );
                    if (!mounted) return;
                    final stateError = context.read<ProjectState>().error;
                    if (stateError != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Save failed: $stateError')),
                      );
                      return;
                    }

                    if (_tagType == TagTypes.project) {
                      await context.read<ProjectState>().saveGeotag(
                            projectName: data.entityName,
                            developer: _entityValues[EntityFieldKeys.projectOwnerClient]
                                    as String? ??
                                data.contactPerson,
                            architect: _metadata[TagFieldKeys.firmName] as String?,
                            pmc: null,
                            facadeConsultant: null,
                            segment: data.category,
                            status: 'Active',
                            outcome: null,
                            remarks: data.metadata.isEmpty
                                ? null
                                : jsonEncode(data.metadata),
                            latitude: data.location.latitude,
                            longitude: data.location.longitude,
                          );

                      if (!mounted) return;
                      final projectError = context.read<ProjectState>().error;
                      if (projectError != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Save failed: $projectError')),
                        );
                        return;
                      }
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tag saved successfully')),
                    );
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildTagSetupCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tag Setup',
                style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: AppSpacing.x2),
            TagTypeSelector(
              tagTypes: TagFormConfig.tagTypes,
              value: _tagType,
              onChanged: _onTagTypeChanged,
            ),
            const SizedBox(height: AppSpacing.x2),
            DynamicCategorySelector(
              categories: _categories,
              value: _category,
              onChanged: _onCategoryChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dynamic Details',
                style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: AppSpacing.x2),
            DynamicFormRenderer(
              fields: _activeFields,
              values: _metadata,
              errors: _metadataErrors,
              onValueChanged: _onFieldValueChanged,
              onVisibleFieldsChanged: _onVisibleFieldsChanged,
            ),
          ],
        ),
      ),
    );
  }
}
