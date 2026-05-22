import '../models/tag_models.dart';
import 'form_constants.dart';
import 'tag_constants.dart';

class TagFormConfig {
  static const formVersion = FormVersion.formVersion;
  static const schemaVersion = FormVersion.schemaVersion;

  static const tagTypes = TagTypes.all;

  static const Map<String, List<String>> categoriesByTagType = {
    TagTypes.project: [
      TagCategories.pvtHomes,
      TagCategories.residential,
      TagCategories.commercial,
      TagCategories.hospitality,
      TagCategories.retail,
    ],
    TagTypes.stakeholder: [
      TagCategories.architects,
      TagCategories.developers,
      TagCategories.pmc,
      TagCategories.contractor,
      TagCategories.facadeConsultant,
      TagCategories.greenConsultant,
    ],
    TagTypes.partner: [
      TagCategories.channelPartner,
      TagCategories.premiumPartner,
      TagCategories.pos,
    ],
  };

  static const Map<String, List<DynamicFieldConfig>> entityFieldsByTagType = {
    TagTypes.project: [
      DynamicFieldConfig(
        key: EntityFieldKeys.entityName,
        label: 'Project Name',
        type: DynamicFieldType.text,
        validation:
            FieldValidation(isRequired: true, minLength: 2, maxLength: 120),
        searchable: true,
      ),
      DynamicFieldConfig(
        key: EntityFieldKeys.projectCode,
        label: 'Project Code / ID',
        type: DynamicFieldType.text,
        validation: FieldValidation(maxLength: 60),
        searchable: true,
      ),
      DynamicFieldConfig(
        key: EntityFieldKeys.projectLocationName,
        label: 'Project Location Name',
        type: DynamicFieldType.text,
        validation: FieldValidation(maxLength: 120),
        searchable: true,
      ),
      DynamicFieldConfig(
        key: EntityFieldKeys.projectOwnerClient,
        label: 'Project Owner / Client',
        type: DynamicFieldType.text,
        validation: FieldValidation(maxLength: 120),
        searchable: true,
      ),
      DynamicFieldConfig(
        key: EntityFieldKeys.contactPerson,
        label: 'Contact Person',
        type: DynamicFieldType.text,
        validation: FieldValidation(maxLength: 120),
        searchable: true,
      ),
      DynamicFieldConfig(
        key: EntityFieldKeys.phone,
        label: 'Contact Number',
        type: DynamicFieldType.text,
        validation: FieldValidation(regexPattern: ValidationPatterns.phone),
        searchable: true,
      ),
      DynamicFieldConfig(
        key: EntityFieldKeys.email,
        label: 'Email',
        type: DynamicFieldType.text,
        validation: FieldValidation(regexPattern: ValidationPatterns.email),
        searchable: true,
      ),
      DynamicFieldConfig(
        key: EntityFieldKeys.address,
        label: 'Address',
        type: DynamicFieldType.text,
        validation: FieldValidation(maxLength: 200),
        searchable: true,
      ),
    ],
    TagTypes.stakeholder: [
      DynamicFieldConfig(
        key: EntityFieldKeys.entityName,
        label: 'Company / Firm Name',
        type: DynamicFieldType.text,
        validation:
            FieldValidation(isRequired: true, minLength: 2, maxLength: 120),
        searchable: true,
      ),
      DynamicFieldConfig(
        key: EntityFieldKeys.contactPerson,
        label: 'Primary Contact Name',
        type: DynamicFieldType.text,
        validation: FieldValidation(maxLength: 120),
        searchable: true,
      ),
      DynamicFieldConfig(
        key: EntityFieldKeys.phone,
        label: 'Mobile Number',
        type: DynamicFieldType.text,
        validation: FieldValidation(regexPattern: ValidationPatterns.phone),
        searchable: true,
      ),
      DynamicFieldConfig(
        key: EntityFieldKeys.email,
        label: 'Email',
        type: DynamicFieldType.text,
        validation: FieldValidation(regexPattern: ValidationPatterns.email),
        searchable: true,
      ),
      DynamicFieldConfig(
        key: EntityFieldKeys.address,
        label: 'Office Address',
        type: DynamicFieldType.text,
        validation: FieldValidation(maxLength: 200),
        searchable: true,
      ),
      DynamicFieldConfig(
        key: EntityFieldKeys.website,
        label: 'Website',
        type: DynamicFieldType.text,
        validation: FieldValidation(regexPattern: ValidationPatterns.website),
        searchable: true,
      ),
    ],
    TagTypes.partner: [
      DynamicFieldConfig(
        key: EntityFieldKeys.entityName,
        label: 'Partner Company Name',
        type: DynamicFieldType.text,
        validation:
            FieldValidation(isRequired: true, minLength: 2, maxLength: 120),
        searchable: true,
      ),
      DynamicFieldConfig(
        key: EntityFieldKeys.contactPerson,
        label: 'Contact Person',
        type: DynamicFieldType.text,
        validation: FieldValidation(maxLength: 120),
        searchable: true,
      ),
      DynamicFieldConfig(
        key: EntityFieldKeys.phone,
        label: 'Phone Number',
        type: DynamicFieldType.text,
        validation: FieldValidation(regexPattern: ValidationPatterns.phone),
        searchable: true,
      ),
      DynamicFieldConfig(
        key: EntityFieldKeys.email,
        label: 'Email',
        type: DynamicFieldType.text,
        validation: FieldValidation(regexPattern: ValidationPatterns.email),
        searchable: true,
      ),
      DynamicFieldConfig(
        key: EntityFieldKeys.operatingRegion,
        label: 'Operating Region',
        type: DynamicFieldType.text,
        validation: FieldValidation(maxLength: 120),
        searchable: true,
      ),
      DynamicFieldConfig(
        key: EntityFieldKeys.address,
        label: 'Address',
        type: DynamicFieldType.text,
        validation: FieldValidation(maxLength: 200),
        searchable: true,
      ),
    ],
  };

  static const Map<String, List<DynamicFieldConfig>> fieldsByCategory = {
    TagCategories.pvtHomes: [
      _greenBuildingField,
      _certificationField,
      _certificationTargetField
    ],
    TagCategories.commercial: [
      _greenBuildingField,
      DynamicFieldConfig(
        key: TagFieldKeys.projectStage,
        label: 'Project Stage',
        type: DynamicFieldType.select,
        options: FormOptions.projectStages,
        validation: FieldValidation(
            isRequired: true, validationMessage: 'Project stage is required'),
        analyticsKey: TagFieldKeys.projectStage,
        searchable: true,
      ),
      DynamicFieldConfig(
        key: TagFieldKeys.buildingType,
        label: 'Building Type',
        type: DynamicFieldType.select,
        options: FormOptions.buildingTypes,
        validation: FieldValidation(isRequired: true),
        analyticsKey: TagFieldKeys.buildingType,
        searchable: true,
      ),
      DynamicFieldConfig(
        key: TagFieldKeys.approxBuiltUpArea,
        label: 'Approx Built-up Area',
        type: DynamicFieldType.text,
        validation: FieldValidation(maxLength: 60),
        analyticsKey: TagFieldKeys.approxBuiltUpArea,
      ),
      DynamicFieldConfig(
        key: TagFieldKeys.facadeRequirement,
        label: 'Facade Requirement',
        type: DynamicFieldType.boolean,
        analyticsKey: TagFieldKeys.facadeRequirement,
        searchable: true,
      ),
      DynamicFieldConfig(
        key: TagFieldKeys.estimatedProjectValue,
        label: 'Estimated Project Value',
        type: DynamicFieldType.text,
        validation: FieldValidation(maxLength: 60),
        analyticsKey: TagFieldKeys.estimatedProjectValue,
      ),
      _certificationField,
      _certificationTargetField,
    ],
    TagCategories.residential: [
      _greenBuildingField,
      DynamicFieldConfig(
        key: TagFieldKeys.residentialType,
        label: 'Residential Type',
        type: DynamicFieldType.select,
        options: FormOptions.residentialTypes,
        validation: FieldValidation(isRequired: true),
        analyticsKey: TagFieldKeys.residentialType,
        searchable: true,
      ),
      DynamicFieldConfig(
        key: TagFieldKeys.numberOfUnits,
        label: 'Number of Units',
        type: DynamicFieldType.number,
        validation: FieldValidation(minValue: 1, maxValue: 1000000),
        analyticsKey: TagFieldKeys.numberOfUnits,
        searchable: true,
      ),
      DynamicFieldConfig(
        key: TagFieldKeys.targetSegment,
        label: 'Target Segment',
        type: DynamicFieldType.select,
        options: FormOptions.targetSegments,
        analyticsKey: TagFieldKeys.targetSegment,
        searchable: true,
      ),
      _certificationField,
      _certificationTargetField,
    ],
    TagCategories.hospitality: [
      _greenBuildingField,
      DynamicFieldConfig(
        key: TagFieldKeys.hospitalityType,
        label: 'Hospitality Type',
        type: DynamicFieldType.select,
        options: FormOptions.hospitalityTypes,
        validation: FieldValidation(isRequired: true),
        analyticsKey: TagFieldKeys.hospitalityType,
        searchable: true,
      ),
      DynamicFieldConfig(
        key: TagFieldKeys.starRating,
        label: 'Star Rating',
        type: DynamicFieldType.select,
        options: FormOptions.starRatings,
        analyticsKey: TagFieldKeys.starRating,
        searchable: true,
      ),
      _certificationField,
      _certificationTargetField,
    ],
    TagCategories.retail: [
      _greenBuildingField,
      _certificationField,
      _certificationTargetField
    ],
    TagCategories.architects: [
      DynamicFieldConfig(
        key: TagFieldKeys.firmName,
        label: 'Firm Name',
        type: DynamicFieldType.text,
        validation:
            FieldValidation(isRequired: true, minLength: 2, maxLength: 120),
        searchable: true,
      ),
      DynamicFieldConfig(
        key: TagFieldKeys.specialization,
        label: 'Specialization',
        type: DynamicFieldType.select,
        options: FormOptions.specializations,
        searchable: true,
      ),
      DynamicFieldConfig(
        key: TagFieldKeys.involvementStage,
        label: 'Involvement Stage',
        type: DynamicFieldType.select,
        options: FormOptions.involvementStages,
      ),
    ],
    TagCategories.developers: [
      DynamicFieldConfig(
        key: TagFieldKeys.developerScale,
        label: 'Developer Scale',
        type: DynamicFieldType.select,
        options: FormOptions.developerScales,
        searchable: true,
      ),
      DynamicFieldConfig(
        key: TagFieldKeys.activeProjectsCount,
        label: 'Active Projects Count',
        type: DynamicFieldType.number,
        validation: FieldValidation(minValue: 0, maxValue: 100000),
        searchable: true,
      ),
    ],
    TagCategories.pmc: [],
    TagCategories.contractor: [],
    TagCategories.facadeConsultant: [],
    TagCategories.greenConsultant: [],
    TagCategories.channelPartner: [
      DynamicFieldConfig(
        key: TagFieldKeys.coverageArea,
        label: 'Coverage Area',
        type: DynamicFieldType.text,
        validation: FieldValidation(maxLength: 120),
        searchable: true,
      ),
      DynamicFieldConfig(
        key: TagFieldKeys.primaryIndustry,
        label: 'Primary Industry',
        type: DynamicFieldType.text,
        validation: FieldValidation(maxLength: 120),
      ),
    ],
    TagCategories.premiumPartner: [
      DynamicFieldConfig(
        key: TagFieldKeys.annualRevenueBracket,
        label: 'Annual Revenue Bracket',
        type: DynamicFieldType.text,
        validation: FieldValidation(maxLength: 80),
        searchable: true,
      ),
      DynamicFieldConfig(
        key: TagFieldKeys.strategicAllianceLevel,
        label: 'Strategic Alliance Level',
        type: DynamicFieldType.text,
        validation: FieldValidation(maxLength: 80),
      ),
    ],
    TagCategories.pos: [],
  };

  static List<String> categoriesForTagType(String tagType) =>
      categoriesByTagType[tagType] ?? const [];

  static List<DynamicFieldConfig> entityFieldsForTagType(String tagType) =>
      entityFieldsByTagType[tagType] ?? const [];

  static List<DynamicFieldConfig> fieldsForCategory(String category) =>
      fieldsByCategory[category] ?? const [];

  static List<DynamicFieldConfig> visibleFields(
      String category, Map<String, dynamic> values) {
    final fields = fieldsForCategory(category);
    return fields.where((field) => field.isVisible(values)).toList();
  }

  static const DynamicFieldConfig _greenBuildingField = DynamicFieldConfig(
    key: TagFieldKeys.greenBuilding,
    label: 'Green Building',
    type: DynamicFieldType.boolean,
    validation: FieldValidation(isRequired: true),
    searchable: true,
  );

  static const DynamicFieldConfig _certificationField = DynamicFieldConfig(
    key: TagFieldKeys.certification,
    label: 'Certification',
    type: DynamicFieldType.select,
    options: FormOptions.certifications,
    conditions: [
      FieldCondition(fieldKey: TagFieldKeys.greenBuilding, equals: true)
    ],
    validation: FieldValidation(isRequired: true),
    searchable: true,
  );

  static const DynamicFieldConfig _certificationTargetField =
      DynamicFieldConfig(
    key: TagFieldKeys.certificationTarget,
    label: 'Certification Target',
    type: DynamicFieldType.select,
    options: FormOptions.certificationTargets,
    conditions: [
      FieldCondition(fieldKey: TagFieldKeys.greenBuilding, equals: true)
    ],
    validation: FieldValidation(isRequired: true),
    searchable: true,
  );
}
