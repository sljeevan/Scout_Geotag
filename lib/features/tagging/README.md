# SitePin Dynamic Tagging Module

## Architecture

TagScreen
- LocationCaptureSection
- TagTypeSelector
- EntityDetailsSection
- DynamicCategorySelector
- DynamicFormRenderer
- SaveButton (`AppButton`)

This preserves config-driven workflows while separating reusable concerns:
- `location_service.dart` handles GPS permissions, capture, reverse geocoding, retries.
- `entity_details_section.dart` renders mandatory core fields from config.
- `dynamic_form_renderer.dart` renders category-specific metadata fields.

## Data Strategy

First-class searchable fields (NOT only metadata):
- `entity_name`
- `contact_person`
- `phone`
- `email`
- `address`
- `latitude`
- `longitude`
- `location_accuracy`
- `captured_at`
- `resolved_address`
- `tag_type`
- `category`

`metadata` stores only dynamic category fields and workflow-specific values.

## Location Flow

On screen load:
1. Auto-capture GPS with high accuracy.
2. Resolve address using geocoding.
3. Show latitude/longitude/accuracy/timestamp/address.
4. Allow refresh and retry.
5. Handle permission denied, GPS disabled, timeout, and generic failure.
6. Allow manual lat/lon/address fallback if GPS is unavailable.

## Validation Flow

Both entity fields and dynamic category fields use the same config-based validator:
- `isRequired`
- `minLength`
- `maxLength`
- `regexPattern`
- `minValue`
- `maxValue`
- `validationMessage`

Validation is executed only for active/visible fields.

## Hidden Field Cleanup

Conditional metadata fields are cleaned automatically when hidden.
Example: if `green_building` changes from `true` to `false`, stale keys like
`certification` and `certification_target` are removed from metadata.

## Payload Shape

```json
{
  "form_version": 2,
  "schema_version": 2,
  "tag_type": "Project",
  "category": "Commercial",
  "entity_name": "Prestige Tech Park",
  "contact_person": "John Doe",
  "phone": "+91XXXXXXXXXX",
  "email": "john@example.com",
  "address": "Bangalore",
  "latitude": 12.9716,
  "longitude": 77.5946,
  "location_accuracy": 8.5,
  "captured_at": "2026-05-16T10:00:00Z",
  "resolved_address": "Bangalore, Karnataka, India",
  "location": {
    "latitude": 12.9716,
    "longitude": 77.5946,
    "accuracy": 8.5,
    "captured_at": "2026-05-16T10:00:00Z",
    "address": "Bangalore, Karnataka, India"
  },
  "entity_details": {
    "project_code": "PTP-001"
  },
  "searchable": {
    "tag_type": "Project",
    "category": "Commercial",
    "entity_name": "Prestige Tech Park",
    "project_stage": "Construction"
  },
  "metadata": {
    "green_building": true,
    "project_stage": "Construction",
    "building_type": "IT Park",
    "certification": "LEED"
  }
}
```

## DB Recommendation

```sql
CREATE TABLE site_tags (
  id BIGSERIAL PRIMARY KEY,
  site_id BIGINT NOT NULL,
  tag_type VARCHAR(60) NOT NULL,
  category VARCHAR(100) NOT NULL,
  entity_name VARCHAR(200) NOT NULL,
  contact_person VARCHAR(200),
  phone VARCHAR(30),
  email VARCHAR(200),
  address TEXT,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  location_accuracy DOUBLE PRECISION,
  captured_at TIMESTAMPTZ NOT NULL,
  resolved_address TEXT,
  searchable_json JSONB NOT NULL,
  metadata_json JSONB NOT NULL,
  form_version INT NOT NULL,
  schema_version INT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_site_tags_type_category ON site_tags(tag_type, category);
CREATE INDEX idx_site_tags_location ON site_tags(latitude, longitude);
CREATE INDEX idx_site_tags_searchable_gin ON site_tags USING GIN (searchable_json);
CREATE INDEX idx_site_tags_metadata_gin ON site_tags USING GIN (metadata_json);
```
