import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../widgets/framework/widget_definition.dart';
import '../../../widgets/framework/widget_instance.dart';
import '../../../widgets/framework/widget_registry.dart';
import '../../../widgets/ui/base/widget_card.dart';
import '../../../widgets/ui/types/weather/weather_widget.dart';
import '../../../widgets/ui/types/protein/protein_tracker_widget.dart';

// Providers
final widgetRegistryProvider = Provider<WidgetRegistry>((ref) {
  final registry = WidgetRegistry();
  registry.register(WeatherWidget());
  registry.register(ProteinTrackerWidget());
  return registry;
});

final dashboardWidgetsProvider =
    StateProvider<List<WidgetInstance>>((ref) => [
          WidgetInstance(
            widgetType: 'weather',
            size: WidgetSize.medium,
          ),
          WidgetInstance(
            widgetType: 'protein_tracker',
            size: WidgetSize.medium,
            config: {'goal': 150},
          ),
        ]);

final isEditingProvider = StateProvider<bool>((ref) => false);

// Mock widget data provider
class MockWidgetDataProvider {
  Future<Map<String, dynamic>> getData(
      String widgetType, Map<String, dynamic>? config) async {
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
            {'level': 'info', 'message': 'UV-Index heute hoch (8)'}
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
            {'name': 'Frühstück: Eier & Avocado', 'protein': 25, 'time': '08:00'},
            {'name': 'Mittag: Hähnchen & Reis', 'protein': 40, 'time': '12:30'},
            {'name': 'Snack: Protein Shake', 'protein': 30, 'time': '15:00'},
          ],
        },
        'sources': ['Lokale Einträge'],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }

    return {};
  }
}

final mockDataProviderProvider =
    Provider<MockWidgetDataProvider>((ref) => MockWidgetDataProvider());

// Dashboard view
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Mein Dashboard'),
        actions: [
          Consumer(builder: (context, ref, child) {
            final isEditing = ref.watch(isEditingProvider);
            return IconButton(
              icon: Icon(isEditing ? Icons.check : Icons.edit),
              onPressed: () => ref.read(isEditingProvider.notifier).state =
                  !isEditing,
              tooltip: isEditing ? 'Fertig' : 'Bearbeiten',
            );
          }),
          Consumer(builder: (context, ref, child) {
            return IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showWidgetCatalog(context, ref),
              tooltip: 'Widget hinzufügen',
            );
          }),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final widgets = ref.watch(dashboardWidgetsProvider);
          final registry = ref.watch(widgetRegistryProvider);

          return GridView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: AppTheme.spacingSm,
              mainAxisSpacing: AppTheme.spacingSm,
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
        },
      ),
    );
  }

  Widget _buildWidgetCard(BuildContext context, WidgetRef ref,
      WidgetInstance instance, WidgetDefinition definition) {
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
      WidgetRef ref, WidgetInstance instance) async {
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
                    _addWidget(ref, def.id);
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

  void _addWidget(WidgetRef ref, String widgetType) {
    final widgets = ref.read(dashboardWidgetsProvider);
    final newWidget = WidgetInstance(widgetType: widgetType);
    widgets.add(newWidget);
    ref.read(dashboardWidgetsProvider.notifier).state = widgets;
  }
}
