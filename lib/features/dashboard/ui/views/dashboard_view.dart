import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/theme/theme.dart';
import '../domain/dashboards_notifier.dart';
import '../../domain/dashboard_sync_service.dart';
import '../../../widgets/framework/widget_definition.dart';
import '../../../widgets/framework/widget_instance.dart';
import '../../../widgets/framework/widget_registry.dart';
import '../../../widgets/framework/widget_schema_validator.dart';
import '../../../widgets/framework/widget_schema_migration.dart';
import '../../../widgets/framework/widget_local_cache.dart';
import '../../../widgets/ui/base/widget_card.dart';
import '../../../widgets/ui/types/weather/weather_widget.dart';
import '../../../widgets/ui/types/protein/protein_tracker_widget.dart';
import '../../../widgets/ui/types/parties/parties_widget.dart';
import '../../../widgets/ui/types/carbs/carbs_tracker_widget.dart';
import '../../../widgets/ui/types/water/water_tracker_widget.dart';
import '../../../widgets/ui/types/steps/steps_tracker_widget.dart';
import '../../../widgets/ui/types/sleep/sleep_tracker_widget.dart';
import '../../../widgets/ui/types/weight/weight_tracker_widget.dart';
import '../../../widgets/ui/types/briefing/tagesbriefing_widget.dart';
import '../../../widgets/ui/types/body_fat/body_fat_tracker_widget.dart';
import '../../../widgets/ui/types/heart_rate/heart_rate_tracker_widget.dart';
import '../../../widgets/ui/types/mood/mood_tracker_widget.dart';
import '../../../widgets/ui/types/tasks/tasks_widget.dart';
import '../../../widgets/ui/types/stress/stress_tracker_widget.dart';
import '../../../widgets/ui/types/screen_time/screen_time_tracker_widget.dart';
import '../../../widgets/ui/types/medications/medications_tracker_widget.dart';
import '../../../widgets/ui/types/calendar/calendar_widget.dart';
import '../../../widgets/ui/types/quick_notes/quick_notes_widget.dart';
import '../../../widgets/ui/types/fat/fat_tracker_widget.dart';
import '../../../widgets/ui/types/calories/calorie_tracker_widget.dart';
import '../../../widgets/ui/types/fiber/fiber_tracker_widget.dart';
import '../../../widgets/ui/types/sugar/sugar_tracker_widget.dart';
import '../../../widgets/ui/types/caffeine/caffeine_tracker_widget.dart';
import '../../../widgets/ui/types/active_minutes/active_minutes_tracker_widget.dart';
import '../../../widgets/ui/types/distance/distance_tracker_widget.dart';
import '../../../widgets/ui/types/custom/custom_tracker_widget.dart';

// Singleton widget registry — created once, shared across the app
final _sharedRegistry = WidgetRegistry()
  ..register(WeatherWidget())
  ..register(ProteinTrackerWidget())
  ..register(PartiesWidget())
  ..register(CarbsTrackerWidget())
  ..register(WaterTrackerWidget())
  ..register(StepsTrackerWidget())
  ..register(SleepTrackerWidget())
  ..register(WeightTrackerWidget())
  ..register(TagesbriefingWidget())
  ..register(BodyFatTrackerWidget())
  ..register(HeartRateTrackerWidget())
  ..register(MoodTrackerWidget())
  ..register(TasksWidget())
  ..register(StressTrackerWidget())
  ..register(ScreenTimeTrackerWidget())
  ..register(MedicationsTrackerWidget())
  ..register(CalendarWidget())
  ..register(QuickNotesWidget())
  ..register(FatTrackerWidget())
  ..register(CalorieTrackerWidget())
  ..register(FiberTrackerWidget())
  ..register(SugarTrackerWidget())
  ..register(CaffeineTrackerWidget())
  ..register(ActiveMinutesTrackerWidget())
  ..register(DistanceTrackerWidget())
  ..register(CustomTrackerWidget());

// Providers
final widgetRegistryProvider = Provider<WidgetRegistry>((ref) => _sharedRegistry);

final dashboardWidgetsProvider =
    StateNotifierProvider<DashboardWidgetsNotifier, List<WidgetInstance>>((
      ref,
    ) {
      return DashboardWidgetsNotifier();
    });

final isEditingProvider = StateProvider<bool>((ref) => false);
final isSyncingProvider = StateProvider<bool>((ref) => false);

// Undo/Redo history
final undoHistoryProvider = StateProvider<List<List<WidgetInstance>>>((ref) => []);
final redoHistoryProvider = StateProvider<List<List<WidgetInstance>>>((ref) => []);

// Dashboard management
final dashboardsProvider = Provider<DashboardsNotifier>((ref) {
  return DashboardsNotifier();
});

final activeDashboardProvider = StateProvider<String?>((ref) => null);

// Mock widget data provider
class MockWidgetDataProvider {
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
          'summary': 'Heute sonnig mit 22°C. Am Nachmittag Regen möglich. Nimm morgen einen Regenschirm mit.',
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
          'summary': 'Heute ist ein guter Tag für deine Fitness-Ziele. Du hast 2 wichtige Termine und das Wetter ist ideal für deinen geplanten Lauf.',
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

    return {};
  }
}

final mockDataProviderProvider = Provider<MockWidgetDataProvider>(
  (ref) => MockWidgetDataProvider(),
);

/// Memoized data provider — caches the Future per widget instance
/// so rebuilds don't trigger new fetches.
final widgetDataProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, instanceId) async {
    final dashboardWidgets = ref.watch(dashboardWidgetsProvider);
    final instance = dashboardWidgets.firstWhere((w) => w.id == instanceId);
    final provider = ref.watch(mockDataProviderProvider);
    var data = await provider.getData(instance.widgetType, instance.config);

    // Apply schema migrations if needed
    final expectedVersion = getExpectedVersion(instance.widgetType);
    data = await widgetMigrationRegistry.migrateData(
      widgetType: instance.widgetType,
      data: data,
      targetVersion: expectedVersion,
    );

    // Save to local cache
    await widgetLocalCache.setCachedData(
      widgetType: instance.widgetType,
      instanceId: instance.id,
      data: data,
    );

    return data;
  },
);

/// State notifier for dashboard widgets with persistence
class DashboardWidgetsNotifier extends StateNotifier<List<WidgetInstance>> {
  DashboardWidgetsNotifier() : super(_defaultWidgets()) {
    _loadWidgets();
  }

  static List<WidgetInstance> _defaultWidgets() {
    return [
      WidgetInstance(
        widgetType: 'weather',
        size: WidgetSize.medium,
        config: {'location': 'Berlin'},
      ),
      WidgetInstance(
        widgetType: 'protein_tracker',
        size: WidgetSize.medium,
        config: {'goal': 150},
      ),
    ];
  }

  void addWidget(String widgetType, {Map<String, dynamic>? config}) {
    final widget = WidgetInstance(widgetType: widgetType, config: config ?? {});
    state = [...state, widget];
    _saveWidgets();
  }

  void removeWidget(String id) {
    state = state.where((w) => w.id != id).toList();
    _saveWidgets();
  }

  void duplicateWidget(String id) {
    final original = state.firstWhere((w) => w.id == id);
    final duplicate = original.clone();
    final index = state.indexWhere((w) => w.id == id);
    final widgets = List<WidgetInstance>.from(state);
    widgets.insert(index + 1, duplicate);
    state = widgets;
    _saveWidgets();
  }

  void moveWidget(int oldIndex, int newIndex) {
    final widgets = List<WidgetInstance>.from(state);
    if (newIndex > oldIndex) {
      newIndex--;
    }
    final item = widgets.removeAt(oldIndex);
    widgets.insert(newIndex, item);
    state = widgets;
    _saveWidgets();
  }

  void resizeWidget(String id, WidgetSize newSize) {
    state = state
        .map((w) => w.id == id ? w.clone(newSize: newSize) : w)
        .toList();
    _saveWidgets();
  }

  void updateConfig(String id, Map<String, dynamic> newConfig) {
    state = state
        .map((w) => w.id == id ? w.clone(newConfig: newConfig) : w)
        .toList();
    _saveWidgets();
  }

  void setWidgets(List<WidgetInstance> widgets) {
    state = widgets;
    _saveWidgets();
  }

  Future<void> _loadWidgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('dashboard_widgets');
      if (json != null) {
        final List<dynamic> data = jsonDecode(json);
        state = data
            .map(
              (item) => WidgetInstance.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }
    } catch (e) {
      print('Failed to load widgets: $e');
    }
  }

  Future<void> _saveWidgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(state.map((w) => w.toJson()).toList());
      await prefs.setString('dashboard_widgets', json);
    } catch (e) {
      print('Failed to save widgets: $e');
    }
  }
}

// Responsive grid configuration
class ResponsiveGridConfig {
  static int getColumns(double screenWidth) {
    if (screenWidth < 600) return 1; // Phone portrait
    if (screenWidth < 800) return 2; // Phone landscape / small tablet
    if (screenWidth < 1200) return 3; // Tablet
    return 4; // Desktop
  }

  static double getAspectRatio(WidgetSize size, double screenWidth) {
    if (size == WidgetSize.small) return 1.0;
    if (size == WidgetSize.medium) return 1.0;
    if (size == WidgetSize.large) return 1.4;
    return 1.0;
  }
}

// Dashboard view
class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final widgets = ref.watch(dashboardWidgetsProvider);
    final registry = ref.watch(widgetRegistryProvider);
    final isEditing = ref.watch(isEditingProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(context.l10n.myDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareLayout(context, ref),
            tooltip: 'Layout teilen',
          ),
          IconButton(
            icon: const Icon(Icons.import_contacts),
            onPressed: () => _importLayout(context, ref),
            tooltip: 'Layout importieren',
          ),
          IconButton(
            icon: ref.watch(isSyncingProvider)
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_sync),
            onPressed: ref.watch(isSyncingProvider)
                ? null
                : () => _showSyncOptions(context, ref),
            tooltip: context.l10n.sync,
          ),
          IconButton(
            icon: const Icon(Icons.grid_on),
            onPressed: () => _showTemplates(context, ref),
            tooltip: context.l10n.templates,
          ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: () => _undo(ref),
              tooltip: context.l10n.undo,
            ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.redo),
              onPressed: () => _redo(ref),
              tooltip: context.l10n.redo,
            ),
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              ref.read(isEditingProvider.notifier).update((s) => !s);
              if (isEditing) {
                // Save when exiting edit mode
                ref
                    .read(dashboardsProvider)
                    .saveActive(ref.read(dashboardWidgetsProvider));
              }
            },
            tooltip: isEditing ? context.l10n.done : context.l10n.edit,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showWidgetCatalog(context, ref),
            tooltip: context.l10n.addWidget,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh all widgets (simulated)
          await Future.delayed(const Duration(seconds: 1));
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return isEditing
                ? _buildEditingView(context, ref, widgets, registry)
                : _buildView(
                    context,
                    ref,
                    widgets,
                    registry,
                    constraints.maxWidth,
                  );
          },
        ),
      ),
    );
  }

  Widget _buildView(
    BuildContext context,
    WidgetRef ref,
    List<WidgetInstance> widgets,
    WidgetRegistry registry,
    double screenWidth,
  ) {
    final columns = ResponsiveGridConfig.getColumns(screenWidth);

    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AppTheme.spacingSm,
        mainAxisSpacing: AppTheme.spacingSm,
        childAspectRatio: ResponsiveGridConfig.getAspectRatio(
          widgets.isNotEmpty ? widgets.first.size : WidgetSize.medium,
          screenWidth,
        ),
      ),
      itemCount: widgets.length,
      itemBuilder: (context, index) {
        final instance = widgets[index];
        final definition = registry.get(instance.widgetType);

        if (definition == null) {
          return _buildPlaceholder(instance.widgetType);
        }

        return _buildWidgetCard(context, ref, instance, definition);
      },
    );
  }

  Widget _buildEditingView(
    BuildContext context,
    WidgetRef ref,
    List<WidgetInstance> widgets,
    WidgetRegistry registry,
  ) {
    return ReorderableListView(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      onReorder: (oldIndex, newIndex) {
        ref
            .read(undoHistoryProvider.notifier)
            .update((s) => [...s, widgets]);
        ref.read(redoHistoryProvider.notifier).update((s) => []);

        ref
            .read(dashboardWidgetsProvider.notifier)
            .moveWidget(oldIndex, newIndex);
      },
      children: widgets.map((instance) {
        final definition = registry.get(instance.widgetType);
        return Card(
          key: Key(instance.id),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (definition != null)
                  Icon(definition.icon, color: definition.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (definition != null)
                        Text(definition.name, style: AppTheme.titleSmall),
                      if (definition != null)
                        Text(definition.description, style: AppTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.drag_handle,
                    color: AppTheme.lightTextSecondary,
                  ),
                  onPressed: null,
                ),
                PopupMenuButton<WidgetSize>(
                  icon: Icon(
                    Icons.format_size,
                    color: AppTheme.lightTextSecondary,
                  ),
                  onSelected: (size) {
                    ref
                        .read(undoHistoryProvider.notifier)
                        .update((s) => [...s, widgets]);
                    ref.read(redoHistoryProvider.notifier).update((s) => []);

                    ref
                        .read(dashboardWidgetsProvider.notifier)
                        .resizeWidget(instance.id, size);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: WidgetSize.small,
                      child: Text('Klein'),
                    ),
                    const PopupMenuItem(
                      value: WidgetSize.medium,
                      child: Text('Mittel'),
                    ),
                    const PopupMenuItem(
                      value: WidgetSize.large,
                      child: Text('Groß'),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.copy, color: AppTheme.lightTextSecondary),
                  onPressed: () {
                    ref
                        .read(undoHistoryProvider.notifier)
                        .update((s) => [...s, widgets]);
                    ref.read(redoHistoryProvider.notifier).update((s) => []);

                    ref
                        .read(dashboardWidgetsProvider.notifier)
                        .duplicateWidget(instance.id);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    ref
                        .read(undoHistoryProvider.notifier)
                        .update((s) => [...s, widgets]);
                    ref.read(redoHistoryProvider.notifier).update((s) => []);

                    ref
                        .read(dashboardWidgetsProvider.notifier)
                        .removeWidget(instance.id);
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWidgetCard(
    BuildContext context,
    WidgetRef ref,
    WidgetInstance instance,
    WidgetDefinition definition,
  ) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadWidgetData(ref, instance),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Check local cache while waiting
          return FutureBuilder<Map<String, dynamic>?>(
            future: widgetLocalCache.getCachedData(
              widgetType: instance.widgetType,
              instanceId: instance.id,
            ),
            builder: (context, cacheSnapshot) {
              if (cacheSnapshot.hasData && cacheSnapshot.data != null) {
                // Show cached data with stale indicator
                return WidgetCard(
                  definition: definition,
                  data: WidgetData.fromJson(cacheSnapshot.data!),
                  state: WidgetDataState.stale,
                  config: WidgetConfig(instance.config),
                  onConfigure: () {
                    final card = WidgetCard(
                      definition: definition,
                      data: WidgetData.fromJson(cacheSnapshot.data!),
                      state: WidgetDataState.stale,
                      config: WidgetConfig(instance.config),
                    );
                    card.showConfigForm(context, ref, instance);
                  },
                  onRefresh: () {
                    ref.invalidate(widgetDataProvider(instance.id));
                  },
                );
              }
              // No cache, show loading
              return WidgetCard(
                definition: definition,
                data: null,
                state: WidgetDataState.loading,
                config: WidgetConfig(instance.config),
              );
            },
          );
        }

        if (snapshot.hasError) {
          return WidgetCard(
            definition: definition,
            data: null,
            state: WidgetDataState.error,
            config: WidgetConfig(instance.config),
          );
        }

        if (snapshot.data == null) {
          return WidgetCard(
            definition: definition,
            data: null,
            state: WidgetDataState.empty,
            config: WidgetConfig(instance.config),
          );
        }

        final rawJson = snapshot.data!;

        // Validate data against schema before rendering
        final validationErrors =
            validateWidgetData(instance.widgetType, rawJson);

        if (validationErrors != null && validationErrors.isNotEmpty) {
          return WidgetCard(
            definition: definition,
            data: null,
            state: WidgetDataState.ready,
            config: WidgetConfig(instance.config),
            validationErrors: validationErrors,
            onRefresh: () {
              ref.invalidate(widgetDataProvider(instance.id));
            },
          );
        }

        return WidgetCard(
          definition: definition,
          data: WidgetData.fromJson(rawJson),
          state: WidgetDataState.ready,
          config: WidgetConfig(instance.config),
          onConfigure: () {
            final card = WidgetCard(
              definition: definition,
              data: WidgetData.fromJson(rawJson),
              state: WidgetDataState.ready,
              config: WidgetConfig(instance.config),
            );
            card.showConfigForm(context, ref, instance);
          },
          onRefresh: () {
            ref.invalidate(widgetDataProvider(instance.id));
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _loadWidgetData(
    WidgetRef ref,
    WidgetInstance instance,
  ) async {
    try {
      final dashboardWidgets = ref.read(dashboardWidgetsProvider);
      final inst = dashboardWidgets.firstWhere((w) => w.id == instance.id);
      final provider = ref.read(mockDataProviderProvider);
      var data = await provider.getData(inst.widgetType, inst.config);

      // Apply schema migrations if needed
      final expectedVersion = getExpectedVersion(inst.widgetType);
      data = await widgetMigrationRegistry.migrateData(
        widgetType: inst.widgetType,
        data: data,
        targetVersion: expectedVersion,
      );

      // Save to local cache
      await widgetLocalCache.setCachedData(
        widgetType: inst.widgetType,
        instanceId: inst.id,
        data: data,
      );

      return data;
    } catch (e) {
      // On error, try to load from cache
      final cached = await widgetLocalCache.getCachedData(
        widgetType: instance.widgetType,
        instanceId: instance.id,
      );
      if (cached != null) {
        return cached;
      }
      throw e;
    }
  }

  void _undo(WidgetRef ref) {
    final undoHistory = ref.read(undoHistoryProvider);
    if (undoHistory.isEmpty) return;

    final current = ref.read(dashboardWidgetsProvider);
    final previous = undoHistory.last;
    ref.read(undoHistoryProvider.notifier).update(
      (s) => s.sublist(0, s.length - 1),
    );
    ref.read(redoHistoryProvider.notifier).update((s) => [...s, current]);
    ref.read(dashboardWidgetsProvider.notifier).setWidgets(previous);
  }

  void _redo(WidgetRef ref) {
    final redoHistory = ref.read(redoHistoryProvider);
    if (redoHistory.isEmpty) return;

    final current = ref.read(dashboardWidgetsProvider);
    final next = redoHistory.last;
    ref.read(redoHistoryProvider.notifier).update(
      (s) => s.sublist(0, s.length - 1),
    );
    ref.read(undoHistoryProvider.notifier).update((s) => [...s, current]);
    ref.read(dashboardWidgetsProvider.notifier).setWidgets(next);
  }

  Widget _buildPlaceholder(String type) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.extension, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text('Widget: $type', style: AppTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  void _showWidgetCatalog(BuildContext context, WidgetRef ref) {
    final registry = ref.read(widgetRegistryProvider);
    final widgets = registry.getAll();
    final currentWidgets = ref.read(dashboardWidgetsProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.addWidgets, style: AppTheme.titleMedium),
              const SizedBox(height: 16),
              ...widgets.map((def) {
                return ListTile(
                  leading: Icon(def.icon, color: def.color),
                  title: Text(def.name),
                  subtitle: Text(def.description),
                  trailing: Icon(Icons.add, color: AppTheme.primary),
                  onTap: () {
                    ref
                        .read(undoHistoryProvider.notifier)
                        .update((s) => [...s, currentWidgets]);
                    ref.read(redoHistoryProvider.notifier).update((s) => []);

                    ref
                        .read(dashboardWidgetsProvider.notifier)
                        .addWidget(def.id);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _shareLayout(BuildContext context, WidgetRef ref) {
    final syncService = DashboardSyncService();
    final widgets = ref.read(dashboardWidgetsProvider);
    final dashboard = ref.read(dashboardsProvider).active;

    if (dashboard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.error)),
      );
      return;
    }

    final layoutJson = syncService.exportLayout({
      'id': dashboard.id,
      'name': dashboard.name,
      'widgets': widgets.map((w) => w.toJson()).toList(),
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.editDashboard),
        content: SingleChildScrollView(
          child: SelectableText(layoutJson),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.close),
          ),
          TextButton.icon(
            icon: const Icon(Icons.copy),
            label: Text(context.l10n.add),
            onPressed: () {
              // Copy to clipboard (simplified)
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.layoutCopied)),
              );
            },
          ),
        ],
      ),
    );
  }

  void _importLayout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(context.l10n.editDashboard),
          content: TextField(
            controller: controller,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: context.l10n.searchWidgets,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                final syncService = DashboardSyncService();
                final importResult = syncService.importLayout(controller.text);
                if (importResult.isSuccess && importResult.value != null) {
                  final imported = importResult.value!;
                  if (imported['widgets'] != null) {
                    try {
                      final widgets = (imported['widgets'] as List)
                          .map(
                            (w) => WidgetInstance.fromJson(
                              Map<String, dynamic>.from(w as Map),
                            ),
                          )
                          .toList();
                      ref
                          .read(dashboardWidgetsProvider.notifier)
                          .setWidgets(widgets);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.l10n.layoutImported)),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Import fehlgeschlagen: $e')),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(importResult.error ?? 'Ungültiges JSON-Format')),
                  );
                }
              },
              child: Text(context.l10n.importLayout),
            ),
          ],
        );
      },
    );
  }

  void _showSyncOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.sync, style: AppTheme.titleMedium),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.cloud_upload),
                title: Text(context.l10n.uploadToServer),
                subtitle: Text(context.l10n.uploadDescription),
                onTap: () async {
                  Navigator.pop(ctx);
                  ref.read(isSyncingProvider.notifier).update((s) => true);
                  try {
                    final syncService = DashboardSyncService();
                    final widgets = ref.read(dashboardWidgetsProvider);
                    final dashboard = ref.read(dashboardsProvider).active;
                    if (dashboard != null) {
                      final syncResult = await syncService.syncToServer([
                        {
                          'id': dashboard.id,
                          'name': dashboard.name,
                          'widgets': widgets.map((w) => w.toJson()).toList(),
                        },
                      ]);
                      if (syncResult.isSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.l10n.layoutSynced)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(syncResult.error ?? context.l10n.syncFailed)),
                        );
                      }
                    }
                  } finally {
                    ref.read(isSyncingProvider.notifier).update((s) => false);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.cloud_download),
                title: Text(context.l10n.downloadFromServer),
                subtitle: Text(context.l10n.downloadDescription),
                onTap: () async {
                  Navigator.pop(ctx);
                  ref.read(isSyncingProvider.notifier).update((s) => true);
                  try {
                    final syncService = DashboardSyncService();
                    final syncResult = await syncService.syncFromServer();
                    if (syncResult.isSuccess) {
                      final remoteDashboards = syncResult.value ?? [];
                      if (remoteDashboards.isNotEmpty) {
                        final remote = remoteDashboards.first;
                        if (remote['widgets'] != null) {
                          try {
                            final widgets = (remote['widgets'] as List)
                                .map(
                                  (w) => WidgetInstance.fromJson(
                                    Map<String, dynamic>.from(w as Map),
                                  ),
                                )
                                .toList();
                            ref
                                .read(dashboardWidgetsProvider.notifier)
                                .setWidgets(widgets);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(context.l10n.layoutDownloaded)),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Download fehlgeschlagen: $e')),
                            );
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.l10n.noLayoutOnServer)),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(syncResult.error ?? context.l10n.downloadFailed)),
                      );
                    }
                  } finally {
                    ref.read(isSyncingProvider.notifier).update((s) => false);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTemplates(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.templates, style: AppTheme.titleMedium),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.fitness_center),
                title: const Text('Fitness'),
                subtitle: const Text('Workout & Gesundheit Widgets'),
                onTap: () {
                  Navigator.pop(ctx);
                  // Apply fitness template
                  ref.read(dashboardWidgetsProvider.notifier).setWidgets([
                    WidgetInstance(
                      widgetType: 'steps',
                      config: {},
                    ),
                    WidgetInstance(
                      widgetType: 'protein_tracker',
                      config: {'goal': 150},
                    ),
                    WidgetInstance(
                      widgetType: 'water',
                      config: {},
                    ),
                    WidgetInstance(
                      widgetType: 'weight_tracker',
                      config: {},
                    ),
                  ]);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.fitnessTemplateApplied)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.work),
                title: const Text('Arbeit'),
                subtitle: const Text('Produktivitäts-Widlets'),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(dashboardWidgetsProvider.notifier).setWidgets([
                    WidgetInstance(widgetType: 'tasks', config: {}),
                    WidgetInstance(widgetType: 'calendar', config: {}),
                    WidgetInstance(widgetType: 'quick_notes', config: {}),
                  ]);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.workTemplateApplied)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_fire_department),
                title: const Text('Wetter & Umweltaufklärung'),
                subtitle: const Text('Wetter, UV & Luftqualität'),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(dashboardWidgetsProvider.notifier).setWidgets([
                    WidgetInstance(
                      widgetType: 'weather',
                      config: {'location': 'Berlin'},
                    ),
                  ]);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.weatherTemplateApplied)),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
