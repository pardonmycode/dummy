import 'dart:async';
import 'widget_data_repository.dart';

/// Mock implementation of WidgetDataRepository for development and testing.
class MockWidgetDataRepository implements WidgetDataRepository {
  /// In-memory storage for widget entries
  final Map<String, List<Map<String, dynamic>>> _entries = {};

  @override
  Future<Map<String, dynamic>> getData(String widgetType, Map<String, dynamic> config) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    return _getMockData(widgetType, config);
  }

  @override
  Future<Map<String, dynamic>> refresh(String widgetType, Map<String, dynamic> config) async {
    return getData(widgetType, config);
  }

  Map<String, dynamic> _getMockData(String widgetType, Map<String, dynamic> config) {
    if (widgetType == 'weather') {
      final location = config['location'] ?? 'Berlin';
      return {
        'schemaVersion': 1,
        'data': {
          'location': location,
          'current': {
            'temperature': 22,
            'feelsLike': 23,
            'condition': 'Sonnig',
            'humidity': 45,
            'windSpeed': 12,
          },
          'hourly': [
            {'time': 'Jetzt', 'temp': 22, 'condition': 'Sonnig'},
            {'time': '14:00', 'temp': 24, 'condition': 'Sonnig'},
            {'time': '15:00', 'temp': 23, 'condition': 'Wolken'},
            {'time': '16:00', 'temp': 21, 'condition': 'Regen'},
            {'time': '17:00', 'temp': 20, 'condition': 'Regen'},
          ],
          'daily': [
            {'day': 'Mo', 'high': 24, 'low': 14, 'condition': 'Sonnig'},
            {'day': 'Di', 'high': 22, 'low': 13, 'condition': 'Regen'},
            {'day': 'Mi', 'high': 25, 'low': 15, 'condition': 'Sonnig'},
            {'day': 'Do', 'high': 23, 'low': 14, 'condition': 'Wolken'},
            {'day': 'Fr', 'high': 26, 'low': 16, 'condition': 'Sonnig'},
            {'day': 'Sa', 'high': 24, 'low': 15, 'condition': 'Regen'},
            {'day': 'So', 'high': 22, 'low': 13, 'condition': 'Wolken'},
          ],
          'warnings': [
            {'level': 'info', 'message': 'UV-Index heute hoch (8)'},
          ],
          'summary':
              'Heute sonnig mit 22°C. Am Nachmittag Regen möglich. Nimm morgen einen Regenschirm mit.',
        },
        'sources': ['OpenWeatherMap API'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'protein_tracker') {
      final goal = config['goal'] ?? 150;
      return {
        'schemaVersion': 1,
        'data': {
          'goal': goal,
          'consumed': 95,
          'meals': [
            {'name': 'Frühstück: Eier & Avocado', 'protein': 25, 'time': '08:00'},
            {'name': 'Mittag: Hähnchen & Reis', 'protein': 40, 'time': '12:30'},
            {'name': 'Snack: Protein Shake', 'protein': 30, 'time': '15:00'},
          ],
        },
        'sources': ['Lokale Einträge'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'steps_tracker') {
      return {
        'schemaVersion': 1,
        'data': {
          'goal': 10000,
          'steps': 6847,
          'distance': 4.8,
          'calories': 312,
          'time': '1h 23min',
        },
        'sources': ['Apple Health'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'water_tracker') {
      return {
        'schemaVersion': 1,
        'data': {
          'goal': 2000,
          'consumed': 1250,
          'entries': [
            {'value': 250, 'timestamp': '08:00', 'note': 'Wasser'},
            {'value': 500, 'timestamp': '12:30', 'note': 'Wasser'},
            {'value': 250, 'timestamp': '15:00', 'note': 'Tee'},
            {'value': 250, 'timestamp': '17:30', 'note': 'Wasser'},
          ],
        },
        'sources': ['Lokale Einträge'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'carbs_tracker') {
      return {
        'schemaVersion': 1,
        'data': {
          'goal': 250,
          'consumed': 145,
          'meals': [
            {'name': 'Frühstück: Porridge', 'carbs': 45, 'time': '08:00'},
            {'name': 'Mittag: Reis & Gemüse', 'carbs': 75, 'time': '12:30'},
            {'name': 'Snack: Obst', 'carbs': 25, 'time': '15:00'},
          ],
        },
        'sources': ['Lokale Einträge'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'parties') {
      return {
        'schemaVersion': 1,
        'data': {
          'events': [
            {
              'name': 'Techno Night',
              'venue': 'Berghain',
              'time': '22:00',
              'genre': 'club',
              'lat': 52.5233,
              'lng': 13.4147,
            },
            {
              'name': 'Live Musik: Indie Band',
              'venue': 'Kesselhaus',
              'time': '20:00',
              'genre': 'concert',
              'lat': 52.4965,
              'lng': 13.4251,
            },
            {
              'name': 'Sommerfest',
              'venue': 'Tempelhofer Feld',
              'time': '18:00',
              'genre': 'open air',
              'lat': 52.4707,
              'lng': 13.4075,
            },
          ],
        },
        'sources': ['Event API'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    // Default: empty data
    return {
      'schemaVersion': 1,
      'data': {},
      'sources': ['Mock'],
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }
}
