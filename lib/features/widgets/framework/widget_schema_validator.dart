import 'dart:convert';

import 'package:json_schema/json_schema.dart';

/// Validates widget data against a JSON schema.
class WidgetSchemaValidator {
  final JsonSchema _schema;

  WidgetSchemaValidator(Map<String, dynamic> schemaJson)
      : _schema = JsonSchema.create(schemaJson);

  /// Validate data against the schema.
  /// Returns null if valid, or a list of error messages if invalid.
  List<String>? validate(Map<String, dynamic> data) {
    try {
      final validation = _schema.validate(data);
      if (validation.errors.isEmpty) {
        return null;
      }

      return validation.errors.map((error) {
        final path = error.instancePath ?? '';
        final message = error.message ?? 'Ungültiger Wert';
        return 'Feld "$path": $message';
      }).toList();
    } catch (e) {
      return ['Validierungsfehler: $e'];
    }
  }

  /// Validate raw JSON string.
  List<String>? validateRaw(String json) {
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return validate(data);
    } catch (e) {
      return ['JSON-Format ungültig: $e'];
    }
  }
}

/// Base JSON schema for widget data.
/// All widget schemas should extend this.
Map<String, dynamic> getBaseSchema() {
  return {
    'type': 'object',
    'required': ['schemaVersion', 'data'],
    'properties': {
      'schemaVersion': {'type': 'integer'},
      'data': {'type': 'object'},
      'sources': {
        'type': 'array',
        'items': {'type': 'object'},
      },
      'generatedAt': {'type': 'string', 'format': 'date-time'},
    },
  };
}

/// Get schema for a specific widget type.
Map<String, dynamic> getSchemaForWidget(String widgetType) {
  switch (widgetType) {
    case 'weather':
      return {
        ...getBaseSchema(),
        'properties': {
          ...getBaseSchema()['properties'],
          'data': {
            'type': 'object',
            'required': ['location', 'current'],
            'properties': {
              'location': {'type': 'string'},
              'current': {
                'type': 'object',
                'required': ['temperature', 'condition'],
                'properties': {
                  'temperature': {'type': 'number'},
                  'condition': {'type': 'string'},
                },
              },
            },
          },
        },
      };
    case 'protein_tracker':
      return {
        ...getBaseSchema(),
        'properties': {
          ...getBaseSchema()['properties'],
          'data': {
            'type': 'object',
            'required': ['goal', 'consumed'],
            'properties': {
              'goal': {'type': 'number'},
              'consumed': {'type': 'number'},
            },
          },
        },
      };
    case 'sleep_tracker':
      return {
        ...getBaseSchema(),
        'properties': {
          ...getBaseSchema()['properties'],
          'data': {
            'type': 'object',
            'required': ['goal', 'slept'],
            'properties': {
              'goal': {'type': 'number'},
              'slept': {'type': 'number'},
            },
          },
        },
      };
    case 'weight_tracker':
      return {
        ...getBaseSchema(),
        'properties': {
          ...getBaseSchema()['properties'],
          'data': {
            'type': 'object',
            'required': ['current', 'goal'],
            'properties': {
              'current': {'type': 'number'},
              'goal': {'type': 'number'},
            },
          },
        },
      };
    case 'tasks':
      return {
        ...getBaseSchema(),
        'properties': {
          ...getBaseSchema()['properties'],
          'data': {
            'type': 'object',
            'required': ['tasks'],
            'properties': {
              'tasks': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'required': ['title'],
                },
              },
            },
          },
        },
      };
    case 'calendar':
      return {
        ...getBaseSchema(),
        'properties': {
          ...getBaseSchema()['properties'],
          'data': {
            'type': 'object',
            'required': ['today'],
            'properties': {
              'today': {'type': 'string'},
              'events': {
                'type': 'array',
                'items': {'type': 'object'},
              },
            },
          },
        },
      };
    case 'quick_notes':
      return {
        ...getBaseSchema(),
        'properties': {
          ...getBaseSchema()['properties'],
          'data': {
            'type': 'object',
            'required': ['notes'],
            'properties': {
              'notes': {
                'type': 'array',
                'items': {'type': 'object'},
              },
            },
          },
        },
      };
    default:
      return getBaseSchema();
  }
}

/// Validate widget data against its schema.
/// Returns null if valid, or a list of error messages if invalid.
List<String>? validateWidgetData(
  String widgetType,
  Map<String, dynamic> data,
) {
  final schema = getSchemaForWidget(widgetType);
  final validator = WidgetSchemaValidator(schema);
  return validator.validate(data);
}