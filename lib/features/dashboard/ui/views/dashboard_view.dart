import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import '../../../../core/theme/theme.dart';
import '../../../widgets/framework/widget_definition.dart';
import '../../../widgets/framework/widget_instance.dart';
import '../../../widgets/framework/widget_registry.dart';
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

// Providers
final widgetRegistryProvider = Provider<WidgetRegistry>((ref) {
  final registry = WidgetRegistry();
  registry.register(WeatherWidget());
  registry.register(ProteinTrackerWidget());
  registry.register(PartiesWidget());
  registry.register(CarbsTrackerWidget());
  registry.register(WaterTrackerWidget());
  registry.register(StepsTrackerWidget());
  registry.register(SleepTrackerWidget());
  registry.register(WeightTrackerWidget());
  registry.register(TagesbriefingWidget());
  registry.register(BodyFatTrackerWidget());
  registry.register(HeartRateTrackerWidget());
  registry.register(MoodTrackerWidget());
  registry.register(TasksWidget());
  registry.register(StressTrackerWidget());
  registry.register(ScreenTimeTrackerWidget());
  registry.register(MedicationsTrackerWidget());
  registry.register(CalendarWidget());
  registry.register(QuickNotesWidget());
  return registry;
});

final dashboardWidgetsProvider =
    StateNotifierProvider<DashboardWidgetsNotifier, List<WidgetInstance>>((
      ref,
    ) {
      return DashboardWidgetsNotifier();
    });

final isEditingProvider = StateProvider<bool>((ref) => false);

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
        'data': {
          'goal': 8,
          'slept': 7.5,
          'quality': 8,
        },
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
        'data': {
          'current': 22.5,
          'goal': 18.0,
          'start': 25.0,
          'trend': 'down',
        },
        'sources': ['Lokale Einträge'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (widgetType == 'heart_rate_tracker') {
      return {
        'schemaVersion': 1,
        'data': {
          'current': 72,
          'resting': 62,
          'max': 145,
          'trend': 'down',
        },
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
            {'title': 'Einkaufen für die Woche', 'time': '10:00', 'priority': 'high'},
            {'title': 'Projektbericht fertigstellen', 'time': '12:00', 'priority': 'high'},
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
            {'name': 'Vitamin D', 'dose': '1000 IE', 'time': '08:00', 'taken': true, 'type': 'supplement'},
            {'name': 'Omega-3', 'dose': '1 Kapsel', 'time': '08:00', 'taken': true, 'type': 'supplement'},
            {'name': 'Aspirin', 'dose': '100mg', 'time': '20:00', 'taken': false},
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
            {'title': 'Team Meeting', 'start': '09:00', 'end': '10:00', 'location': 'Konferenzraum'},
            {'title': 'Mittagessen mit Kunden', 'start': '12:30', 'end': '13:30'},
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
            {'content': 'Einkaufsliste: Milch, Brot, Eier', 'type': 'text', 'tags': ['einkaufen']},
            {'content': 'Meeting-Notes: Deadline verschoben auf Freitag', 'type': 'text', 'tags': ['arbeit']},
            {'content': 'Gespräch mit Dr. Schmidt', 'type': 'voice', 'timestamp': '10:30'},
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
        title: const Text('Mein Dashboard'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () =>
                ref.read(isEditingProvider.notifier).update((s) => !s),
            tooltip: isEditing ? 'Fertig' : 'Bearbeiten',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showWidgetCatalog(context, ref),
            tooltip: 'Widget hinzufügen',
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
                        .read(dashboardWidgetsProvider.notifier)
                        .duplicateWidget(instance.id);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
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
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchWidgetData(ref, instance),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return WidgetCard(
            definition: definition,
            data: null,
            state: WidgetDataState.loading,
            config: WidgetConfig(instance.config),
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

        return WidgetCard(
          definition: definition,
          data: WidgetData.fromJson(snapshot.data!),
          state: WidgetDataState.ready,
          config: WidgetConfig(instance.config),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchWidgetData(
    WidgetRef ref,
    WidgetInstance instance,
  ) async {
    final provider = ref.read(mockDataProviderProvider);
    return provider.getData(instance.widgetType, instance.config);
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
              const Text('Widgets hinzufügen', style: AppTheme.titleMedium),
              const SizedBox(height: 16),
              ...widgets.map((def) {
                return ListTile(
                  leading: Icon(def.icon, color: def.color),
                  title: Text(def.name),
                  subtitle: Text(def.description),
                  trailing: Icon(Icons.add, color: AppTheme.primary),
                  onTap: () {
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
}
