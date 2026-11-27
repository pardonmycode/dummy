import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import '../../../widgets/framework/mock_widget_data_provider.dart';
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
final dashboardsProvider = NotifierProvider<DashboardsNotifier, List<Dashboard>>(
  DashboardsNotifier.new,
);

final activeDashboardProvider = StateProvider<String?>((ref) => null);

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
      debugPrint('[DashboardWidgetsNotifier] Failed to load widgets: $e');
    }
  }

  Future<void> _saveWidgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(state.map((w) => w.toJson()).toList());
      await prefs.setString('dashboard_widgets', json);
    } catch (e) {
      debugPrint('[DashboardWidgetsNotifier] Failed to save widgets: $e');
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
                    .read(dashboardsProvider.notifier)
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
      onReorderItem: (oldIndex, newIndex) {
        final adjustedIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
        ref
            .read(undoHistoryProvider.notifier)
            .update((s) => [...s, widgets]);
        ref.read(redoHistoryProvider.notifier).update((s) => []);

        ref
            .read(dashboardWidgetsProvider.notifier)
            .moveWidget(oldIndex, adjustedIndex);
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
          instance: instance,
                  data: WidgetData.fromJson(cacheSnapshot.data!),
                  state: WidgetDataState.stale,
                  config: WidgetConfig(instance.config),
                  onConfigure: () {
                    final card = WidgetCard(
                      definition: definition,
          instance: instance,
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
          instance: instance,
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
          instance: instance,
            data: null,
            state: WidgetDataState.error,
            config: WidgetConfig(instance.config),
          );
        }

        if (snapshot.data == null) {
          return WidgetCard(
            definition: definition,
          instance: instance,
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
          instance: instance,
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
          instance: instance,
          data: WidgetData.fromJson(rawJson),
          state: WidgetDataState.ready,
          config: WidgetConfig(instance.config),
          onConfigure: () {
            final card = WidgetCard(
              definition: definition,
          instance: instance,
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
      rethrow;
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
    final dashboard = ref.read(dashboardsProvider.notifier).active;

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
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: layoutJson));
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
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(ctx);
                  ref.read(isSyncingProvider.notifier).update((s) => true);
                  try {
                    final syncService = DashboardSyncService();
                    final widgets = ref.read(dashboardWidgetsProvider);
                    final dashboard = ref.read(dashboardsProvider.notifier).active;
                    if (dashboard != null) {
                      final syncResult = await syncService.syncToServer([
                        {
                          'id': dashboard.id,
                          'name': dashboard.name,
                          'widgets': widgets.map((w) => w.toJson()).toList(),
                        },
                      ]);
                      if (syncResult.isSuccess) {
                        messenger.showSnackBar(
                          SnackBar(content: Text(context.l10n.layoutSynced)),
                        );
                      } else {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              syncResult.error ?? context.l10n.syncFailed,
                            ),
                          ),
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
                  final messenger = ScaffoldMessenger.of(context);
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
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(context.l10n.layoutDownloaded),
                              ),
                            );
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Download fehlgeschlagen: $e'),
                              ),
                            );
                          }
                        }
                      } else {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.noLayoutOnServer),
                          ),
                        );
                      }
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            syncResult.error ?? context.l10n.downloadFailed,
                          ),
                        ),
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
                      widgetType: 'steps_tracker',
                      config: {},
                    ),
                    WidgetInstance(
                      widgetType: 'protein_tracker',
                      config: {'goal': 150},
                    ),
                    WidgetInstance(
                      widgetType: 'water_tracker',
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
                subtitle: const Text('Produktivitäts-Widgets'),
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
