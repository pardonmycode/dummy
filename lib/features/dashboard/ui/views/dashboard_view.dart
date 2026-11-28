import 'dart:async';
import 'dart:convert';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/theme/theme.dart';
import '../domain/dashboards_notifier.dart';
import '../../../widgets/framework/widget_definition.dart';
import '../../../widgets/framework/widget_data.dart';
import '../../../widgets/framework/widget_instance.dart';
import '../../../widgets/framework/widget_registry.dart';
import '../../../widgets/framework/widget_schema_validator.dart';
import '../../../widgets/framework/widget_schema_migration.dart';
import '../../../widgets/framework/widget_providers.dart';
import '../../../widgets/framework/mock_widget_data_provider.dart';
import '../../../widgets/ui/base/widget_card.dart';
import 'widget_catalog.dart';
import 'share_layout_dialog.dart';
import 'import_layout_dialog.dart';
import 'sync_options_sheet.dart';
import 'template_sheet.dart';

export 'widget_catalog.dart' show widgetRegistryProvider;

// Singleton Uuid instance
const _uuid = Uuid();

// Providers

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
/// so rebuilds don't trigger new fetches. Uses select to only watch
/// the specific instance by ID to avoid reloading all widgets on changes.
final widgetDataProvider = FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, instanceId) async {
    final instance = ref.watch(
      dashboardWidgetsProvider.select(
        (widgets) => widgets.firstWhere(
          (w) => w.id == instanceId,
          orElse: () => throw StateError('Widget $instanceId not found'),
        ),
      ),
    );
    final provider = ref.watch(mockDataProviderProvider);
    var data = await provider.getData(instance.widgetType, instance.config);

    // Apply schema migrations if needed
    final migrationRegistry = ref.watch(widgetMigrationRegistryProvider);
    final expectedVersion = getExpectedVersion(instance.widgetType);
    data = await migrationRegistry.migrateData(
      widgetType: instance.widgetType,
      data: data,
      targetVersion: expectedVersion,
    );

    // Save to local cache
    final cache = ref.watch(widgetLocalCacheProvider);
    await cache.setCachedData(
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
        id: _uuid.v4(),
        widgetType: 'weather',
        size: WidgetSize.medium,
        config: {'location': 'Berlin'},
      ),
      WidgetInstance(
        id: _uuid.v4(),
        widgetType: 'protein_tracker',
        size: WidgetSize.medium,
        config: {'goal': 150},
      ),
    ];
  }

  void addWidget(String widgetType, {Map<String, dynamic>? config}) {
    final widget = WidgetInstance.create(
      widgetType: widgetType,
      config: config,
    );
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
        .map((w) => w.id == id ? w.copyWith(size: newSize) : w)
        .toList();
    _saveWidgets();
  }

  void updateConfig(String id, Map<String, dynamic> newConfig) {
    state = state
        .map((w) => w.id == id ? w.copyWith(config: newConfig) : w)
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
    final scheme = theme.colorScheme;
    final bg = scheme.surfaceContainerHighest;
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
          // Refresh all widget data by invalidating all providers
          final widgets = ref.read(dashboardWidgetsProvider);
          for (final widget in widgets) {
            ref.invalidate(widgetDataProvider(widget.id));
          }
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return isEditing
                ? _buildEditingView(context, ref, widgets, registry, scheme)
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

    return SingleChildScrollView(
      child: StaggeredGrid.count(
        crossAxisCount: columns,
        mainAxisSpacing: AppTheme.spacingSm,
        crossAxisSpacing: AppTheme.spacingSm,
        children: widgets.map((instance) {
          final definition = registry.get(instance.widgetType);
          if (definition == null) {
            return _buildStaggeredTile(
              instance.widgetType,
              instance.size,
              columns,
              _buildPlaceholder(instance.widgetType),
            );
          }
          return _buildStaggeredTile(
            instance.id,
            instance.size,
            columns,
            _buildWidgetCard(context, ref, instance, definition),
          );
        }).toList(),
      ),
    );
  }

  /// Build a staggered grid tile with size-appropriate span.
  /// S = 1x1 cell, M = 2x1 cell, L = 2x2 cells.
  StaggeredGridTile _buildStaggeredTile(
    String id,
    WidgetSize size,
    int columns,
    Widget child,
  ) {
    // Determine span based on size and column count
    int crossAxisCellCount = 1;
    int mainAxisCellCount = 1;

    if (size == WidgetSize.medium && columns >= 2) {
      crossAxisCellCount = 2;
    } else if (size == WidgetSize.large) {
      crossAxisCellCount = columns >= 4 ? 4 : columns;
      mainAxisCellCount = 2;
    }

    return StaggeredGridTile.count(
      key: Key(id),
      crossAxisCellCount: crossAxisCellCount,
      mainAxisCellCount: mainAxisCellCount,
      child: child,
    );
  }

  Widget _buildEditingView(
    BuildContext context,
    WidgetRef ref,
    List<WidgetInstance> widgets,
    WidgetRegistry registry,
    ColorScheme scheme,
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
                    color: scheme.onSurfaceVariant,
                  ),
                  onPressed: null,
                ),
                PopupMenuButton<WidgetSize>(
                  icon: Icon(
                    Icons.format_size,
                    color: scheme.onSurfaceVariant,
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
                  icon: Icon(Icons.copy, color: scheme.onSurfaceVariant),
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
                  icon: const Icon(Icons.delete, color: Colors.red),
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
    WidgetDefinition<Object> definition,
  ) {
    // Watch the provider directly instead of using FutureBuilder
    // so that invalidation triggers a refresh
    final snapshot = ref.watch(widgetDataProvider(instance.id));

    if (snapshot.isLoading) {
      final cache = ref.read(widgetLocalCacheProvider);
      return FutureBuilder<Map<String, dynamic>?>(
        future: cache.getCachedData(
          widgetType: instance.widgetType,
          instanceId: instance.id,
        ),
        builder: (context, cacheSnapshot) {
          if (cacheSnapshot.hasData && cacheSnapshot.data != null) {
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

    final rawJson = snapshot.value;
    if (rawJson == null) {
      return WidgetCard(
        definition: definition,
        instance: instance,
        data: null,
        state: WidgetDataState.empty,
        config: WidgetConfig(instance.config),
      );
    }

    // Validate data against schema before rendering
    final validationErrors = validateWidgetData(instance.widgetType, rawJson);

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
            const Icon(Icons.extension, size: 48, color: Colors.grey),
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
                  trailing: const Icon(Icons.add, color: AppTheme.primary),
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
    final widgets = ref.read(dashboardWidgetsProvider);
    showShareLayoutDialog(context, ref, widgets);
  }

  void _importLayout(BuildContext context, WidgetRef ref) {
    showImportLayoutDialog(context, ref);
  }

  void _showSyncOptions(BuildContext context, WidgetRef ref) {
    showSyncOptions(context, ref);
  }

  void _showTemplates(BuildContext context, WidgetRef ref) {
    showTemplates(context, ref);
  }
}
