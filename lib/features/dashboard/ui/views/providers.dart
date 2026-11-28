import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/dashboard_notifier.dart';
import '../../../widgets/framework/widget_definition.dart';
import '../../../widgets/framework/widget_instance.dart';
import '../../../widgets/framework/widget_providers.dart';
import '../../../widgets/framework/widget_schema_migration.dart';
import '../../../widgets/framework/mock_widget_data_provider.dart';
import 'widget_catalog.dart';

export 'widget_catalog.dart' show widgetRegistryProvider;

// Singleton Uuid instance
const _uuid = Uuid();

// Dashboard state providers
final isEditingProvider = StateProvider<bool>((ref) => false);
final isSyncingProvider = StateProvider<bool>((ref) => false);
final activeDashboardProvider = StateProvider<String?>((ref) => null);
final mockDataProviderProvider = Provider<MockWidgetDataProvider>(
  (ref) => MockWidgetDataProvider(),
);

// Undo/Redo history — bounded to prevent unbounded growth
final _maxUndoHistory = 50;
final undoHistoryProvider = StateProvider<List<List<WidgetInstance>>>((ref) => []);
final redoHistoryProvider = StateProvider<List<List<WidgetInstance>>>((ref) => []);

/// Push current state to undo history (bounded).
void pushUndo(WidgetRef ref, List<WidgetInstance> state) {
  ref.read(undoHistoryProvider.notifier).update((history) {
    if (history.length >= _maxUndoHistory) {
      return [history[0], ...history.sublist(1), state];
    }
    return [...history, state];
  });
  ref.read(redoHistoryProvider.notifier).state = [];
}

/// State notifier for dashboard widgets with persistence
class DashboardWidgetsNotifier extends StateNotifier<List<WidgetInstance>> {
  DashboardWidgetsNotifier() : super([]) {
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
      } else {
        state = _defaultWidgets();
        _saveWidgets();
      }
    } catch (e) {
      debugPrint('[DashboardWidgetsNotifier] Failed to load widgets: $e');
      state = _defaultWidgets();
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

final dashboardWidgetsProvider =
    StateNotifierProvider<DashboardWidgetsNotifier, List<WidgetInstance>>((
      ref,
    ) {
      return DashboardWidgetsNotifier();
    });