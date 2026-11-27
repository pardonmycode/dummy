import 'dart:async';

/// Mock widget data provider for development and testing.
/// Returns sample data for each widget type without network calls.
class MockWidgetDataProvider {
  /// In-memory storage for widget entries (water, steps, etc.)
  final Map<String, List<Map<String, dynamic>>> _entries = {};

  /// Add an entry for a widget instance
  void addEntry(String widgetType, String instanceId, Map<String, dynamic> entry) {
    final key = '$widgetType:$instanceId';
    if (_entries[key] == null) {
      _entries[key] = [];
    }
    _entries[key]!.add(entry);
  }

  /// Get entries for a widget instance
  List<Map<String, dynamic>> getEntries(String widgetType, String instanceId) {
    final key = '$widgetType:$instanceId';
    return _entries[key] ?? [];
  }

  Future<Map<String, dynamic>> getData(
    String widgetType,
    Map<String, dynamic>? config,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    if (widgetType == 'weather') {
      final location = config?['location'] ?? 'Berlin';
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
      final goal = config?['goal'] ?? 150;
      return {
        'schemaVersion': 1,
        'data': {
          'goal': goal,
          'consumed': 95,
          'meals': [
            {
              'name': 'Frühstück: Eier & Avocado',
              'protein': 25,
              'time': '08:00',
            },
            {'name': 'Mittag: Hähnchen & Reis', 'protein': 40, 'time': '12:30'},
            {'name': 'Snack: Protein Shake', 'protein': 30, 'time': '15:00'},
          ],
        },
        'sources': ['Lokale Einträge'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'sleep_tracker') {
      return {
        'schemaVersion': 1,
        'data': {'goal': 8, 'slept': 7.5, 'quality': 8},
        'sources': ['Apple Health'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'weight_tracker') {
      return {
        'schemaVersion': 1,
        'data': {
          'current': 82.5,
          'goal': 75.0,
          'start': 85.0,
          'trend': 'down',
          'lastChange': '-0.5 kg letzte Woche',
        },
        'sources': ['Lokale Einträge'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'tagesbriefing') {
      return {
        'schemaVersion': 1,
        'data': {
          'summary':
              'Heute ist ein guter Tag für deine Fitness-Ziele. Du hast 2 wichtige Termine und das Wetter ist ideal für deinen geplanten Lauf.',
          'weather': 'Sonnig, 22°C. Perfekt für Outdoor-Aktivitäten.',
          'appointments': [
            {'title': '10:00 - Meeting mit Team'},
            {'title': '14:00 - Zahnarzt'},
          ],
          'tasks': [
            {'title': 'Einkaufen für die Woche'},
            {'title': 'Projektbericht fertigstellen'},
          ],
          'news': [
            {'headline': 'Deine Lieblingsband gibt Konzert in Berlin'},
          ],
        },
        'sources': ['OpenWeatherMap', 'Google Calendar', 'Todo App'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'body_fat_tracker') {
      return {
        'schemaVersion': 1,
        'data': {'current': 22.5, 'goal': 18.0, 'start': 25.0, 'trend': 'down'},
        'sources': ['Lokale Einträge'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'heart_rate_tracker') {
      return {
        'schemaVersion': 1,
        'data': {'current': 72, 'resting': 62, 'max': 145, 'trend': 'down'},
        'sources': ['Apple Health'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'mood_tracker') {
      return {
        'schemaVersion': 1,
        'data': {
          'mood': 4,
          'note': 'Fühle mich gut nach dem Training',
          'week': [3, 4, 5, 4, 3, 4, 4],
        },
        'sources': ['Lokale Einträge'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'tasks') {
      return {
        'schemaVersion': 1,
        'data': {
          'tasks': [
            {
              'title': 'Einkaufen für die Woche',
              'time': '10:00',
              'priority': 'high',
            },
            {
              'title': 'Projektbericht fertigstellen',
              'time': '12:00',
              'priority': 'high',
            },
            {'title': 'E-Mails beantworten', 'time': '14:00'},
            {'title': 'Abendessen vorbereiten', 'time': '18:00'},
          ],
          'completed': 2,
        },
        'sources': ['Todo App'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'stress_tracker') {
      return {
        'schemaVersion': 1,
        'data': {
          'level': 45,
          'trend': 'down',
          'advice': 'Tiefenatmung kann helfen, den Stress zu reduzieren.',
        },
        'sources': ['Apple Health'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'screen_time_tracker') {
      return {
        'schemaVersion': 1,
        'data': {
          'total': 315,
          'goal': 480,
          'apps': [
            {'name': 'WhatsApp', 'minutes': 45},
            {'name': 'Instagram', 'minutes': 90},
            {'name': 'YouTube', 'minutes': 120},
            {'name': 'Browser', 'minutes': 60},
          ],
        },
        'sources': ['iOS Bildschirmzeit'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'medications_tracker') {
      return {
        'schemaVersion': 1,
        'data': {
          'medications': [
            {
              'name': 'Vitamin D',
              'dose': '1000 IE',
              'time': '08:00',
              'taken': true,
              'type': 'supplement',
            },
            {
              'name': 'Omega-3',
              'dose': '1 Kapsel',
              'time': '08:00',
              'taken': true,
              'type': 'supplement',
            },
            {
              'name': 'Aspirin',
              'dose': '100mg',
              'time': '20:00',
              'taken': false,
            },
          ],
          'upcoming': [
            {'name': 'Aspirin', 'time': 'in 2 Stunden'},
          ],
        },
        'sources': ['Lokale Einträge'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'calendar') {
      return {
        'schemaVersion': 1,
        'data': {
          'today': 'Mittwoch, 25. November',
          'events': [
            {
              'title': 'Team Meeting',
              'start': '09:00',
              'end': '10:00',
              'location': 'Konferenzraum',
            },
            {
              'title': 'Mittagessen mit Kunden',
              'start': '12:30',
              'end': '13:30',
            },
            {'title': 'Projekt Review', 'start': '15:00', 'end': '16:00'},
          ],
          'freeSlots': [
            {'start': '10:00', 'end': '12:30'},
            {'start': '16:30', 'end': '18:00'},
          ],
        },
        'sources': ['Google Calendar'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'quick_notes') {
      return {
        'schemaVersion': 1,
        'data': {
          'notes': [
            {
              'content': 'Einkaufsliste: Milch, Brot, Eier',
              'type': 'text',
              'tags': ['einkaufen'],
            },
            {
              'content': 'Meeting-Notes: Deadline verschoben auf Freitag',
              'type': 'text',
              'tags': ['arbeit'],
            },
            {
              'content': 'Gespräch mit Dr. Schmidt',
              'type': 'voice',
              'timestamp': '10:30',
            },
          ],
        },
        'sources': ['Lokale Einträge'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'fat_tracker') {
      return {
        'schemaVersion': 1,
        'data': {
          'goal': 70,
          'consumed': 45,
          'meals': [
            {'name': 'Frühstück: Eier & Avocado', 'fat': 15, 'time': '08:00'},
            {'name': 'Mittag: Hähnchen & Reis', 'fat': 18, 'time': '12:30'},
            {'name': 'Snack: Nüsse', 'fat': 12, 'time': '15:00'},
          ],
        },
        'sources': ['Lokale Einträge'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'calorie_tracker') {
      return {
        'schemaVersion': 1,
        'data': {
          'goal': 2000,
          'consumed': 1250,
          'burned': 350,
          'meals': [
            {'name': 'Frühstück: Porridge', 'calories': 350, 'time': '08:00'},
            {
              'name': 'Mittag: Hähnchen & Reis',
              'calories': 500,
              'time': '12:30',
            },
            {'name': 'Snack: Apfel & Nüsse', 'calories': 200, 'time': '15:00'},
          ],
        },
        'sources': ['Lokale Einträge'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'fiber_tracker') {
      return {
        'schemaVersion': 1,
        'data': {
          'goal': 30,
          'consumed': 18,
          'meals': [
            {'name': 'Frühstück: Haferflocken', 'fiber': 6, 'time': '08:00'},
            {
              'name': 'Mittag: Salat mit Vollkornbrot',
              'fiber': 8,
              'time': '12:30',
            },
            {'name': 'Snack: Beeren', 'fiber': 4, 'time': '15:00'},
          ],
        },
        'sources': ['Lokale Einträge'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'sugar_tracker') {
      return {
        'schemaVersion': 1,
        'data': {
          'goal': 50,
          'consumed': 32,
          'meals': [
            {
              'name': 'Frühstück: Joghurt mit Honig',
              'sugar': 15,
              'time': '08:00',
            },
            {'name': 'Snack: Schokoriegel', 'sugar': 12, 'time': '15:00'},
            {'name': 'Getränk: Saft', 'sugar': 5, 'time': '17:00'},
          ],
        },
        'sources': ['Lokale Einträge'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'caffeine_tracker') {
      return {
        'schemaVersion': 1,
        'data': {
          'goal': 400,
          'consumed': 250,
          'sources': [
            {'name': 'Kaffee', 'amount': 100, 'time': '08:00'},
            {'name': 'Tee', 'amount': 50, 'time': '11:00'},
            {'name': 'Energy Drink', 'amount': 100, 'time': '14:00'},
          ],
        },
        'sources': ['Lokale Einträge'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'active_minutes_tracker') {
      return {
        'schemaVersion': 1,
        'data': {
          'goal': 60,
          'minutes': 35,
          'activities': [
            {'name': 'Laufen', 'minutes': 20, 'time': '07:30'},
            {'name': 'Treppensteigen', 'minutes': 5, 'time': '09:00'},
            {'name': 'Radfahren', 'minutes': 10, 'time': '17:00'},
          ],
        },
        'sources': ['Apple Health'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'distance_tracker') {
      return {
        'schemaVersion': 1,
        'data': {
          'goal': 10000,
          'distance': 6500,
          'activities': [
            {'name': 'Laufen', 'distance': 3000, 'time': '07:30'},
            {'name': 'Zu Fuß gehen', 'distance': 2000, 'time': '12:00'},
            {'name': 'Radfahren', 'distance': 1500, 'time': '17:00'},
          ],
        },
        'sources': ['Apple Health'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'custom_tracker') {
      return {
        'schemaVersion': 1,
        'data': {
          'name': 'Leseminuten',
          'unit': 'min',
          'goal': 60,
          'current': 35,
          'entries': [
            {'name': 'Buch: Dune', 'amount': 20, 'time': '20:00'},
            {'name': 'Zeitung lesen', 'amount': 15, 'time': '08:00'},
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

    return {};
  }
}
