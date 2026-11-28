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
            'required': ['temperature', 'condition'],
            'properties': {
              'temperature': {'type': 'number'},
              'condition': {'type': 'string'},
              'icon': {'type': 'string'},
              'location': {'type': 'string'},
              'current': {'type': 'object'},
            },
          },
        },
      };
    case 'protein_tracker':
    case 'carbs_tracker':
    case 'fat_tracker':
    case 'calories_tracker':
    case 'fiber_tracker':
    case 'sugar_tracker':
    case 'caffeine_tracker':
    case 'water_tracker':
      return {
        ...getBaseSchema(),
        'properties': {
          ...getBaseSchema()['properties'],
          'data': {
            'type': 'object',
            'properties': {
              'consumed': {'type': 'number'},
              'goal': {'type': 'number'},
              'entries': {'type': 'array'},
              'meals': {'type': 'array'},
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
            'properties': {
              'goal': {'type': 'number'},
              'slept': {'type': 'number'},
              'quality': {'type': 'number'},
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
            'properties': {
              'current': {'type': 'number'},
              'goal': {'type': 'number'},
              'start': {'type': 'number'},
              'trend': {'type': 'string'},
            },
          },
        },
      };
    case 'steps_tracker':
      return {
        ...getBaseSchema(),
        'properties': {
          ...getBaseSchema()['properties'],
          'data': {
            'type': 'object',
            'properties': {
              'steps': {'type': 'number'},
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
            'properties': {
              'tasks': {'type': 'array'},
              'completed': {'type': 'number'},
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
            'properties': {
              'today': {'type': 'string'},
              'events': {'type': 'array'},
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
            'properties': {
              'notes': {'type': 'array'},
            },
          },
        },
      };
    case 'parties':
      return {
        ...getBaseSchema(),
        'properties': {
          ...getBaseSchema()['properties'],
          'data': {
            'type': 'object',
            'properties': {
              'events': {'type': 'array'},
            },
          },
        },
      };
    default:
      return getBaseSchema();
  }
}

/// Caches compiled validators per widget type to avoid recompiling on every validation.
final _validatorCache = <String, WidgetSchemaValidator>{};

/// Get or create a cached validator for the given widget type.
WidgetSchemaValidator _getValidator(String widgetType) {
  if (_validatorCache.containsKey(widgetType)) {
    return _validatorCache[widgetType]!;
  }
  final schema = getSchemaForWidget(widgetType);
  final validator = WidgetSchemaValidator(schema);
  _validatorCache[widgetType] = validator;
  return validator;
}

/// Validate widget data against its schema.
/// Returns null if valid, or a list of error messages if invalid.
List<String>? validateWidgetData(
  String widgetType,
  Map<String, dynamic> data,
) {
  final validator = _getValidator(widgetType);
  return validator.validate(data);
}