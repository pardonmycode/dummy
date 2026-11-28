import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../widgets/framework/widget_instance.dart';
import '../../widgets/framework/widget_definition.dart' show WidgetSize;
import 'dashboard.dart';

const _uuid = Uuid();

/// Consolidated notifier managing dashboards, widgets, and undo/redo history.
class DashboardNotifier extends AsyncNotifier<List<Dashboard>> {
  static const String _storageKey = 'dashboards';
  static const String _activeIdKey = 'active_dashboard_id';
  static const int _maxUndoSteps = 50;

  final List<List<WidgetInstance>> _undoStack = [];
  final List<List<WidgetInstance>> _redoStack = [];
  String? _activeId;

  @override
  Future<List<Dashboard>> build() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load active dashboard ID
      _activeId = prefs.getString(_activeIdKey);

      // Load dashboards
      final json = prefs.getString(_storageKey);
      if (json != null) {
        final List<dynamic> data = jsonDecode(json);
        final dashboards = data
            .map((item) =>
                Dashboard.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        if (dashboards.isNotEmpty) {
          // Validate active ID
          if (_activeId == null ||
              !dashboards.any((d) => d.id == _activeId)) {
            _activeId = dashboards.first.id;
            await _saveActiveId();
          }
          return dashboards;
        }
      }
    } catch (e) {
      debugPrint('Failed to load dashboards: $e');
    }

    // Create default dashboard
    final defaultDashboard = _createDefaultDashboard();
    _activeId = defaultDashboard.id;
    await _saveDashboards([defaultDashboard]);
    return [defaultDashboard];
  }

  // --- Public getters ---

  List<Dashboard> get dashboards => state.value ?? [];

  Dashboard? get activeDashboard {
    final ds = state.value ?? [];
    if (_activeId == null) return null;
    try {
      return ds.firstWhere((d) => d.id == _activeId);
    } catch (_) {
      return null;
    }
  }

  Dashboard get _activeOrFirst {
    final ds = state.value ?? [];
    return activeDashboard ?? ds.first;
  }

  bool get canUndo => _undoStack.isNotEmpty;

  bool get canRedo => _redoStack.isNotEmpty;

  // --- Dashboard management ---

  void setActive(String id) {
    _activeId = id;
    _saveActiveId();
    state = AsyncValue.data(dashboards); // Trigger rebuild
  }

  Future<Dashboard> create(String name) async {
    final dashboard = Dashboard(id: _uuid.v4(), name: name);
    final ds = [...dashboards, dashboard];
    state = AsyncValue.data(ds);
    setActive(dashboard.id);
    await _saveDashboards(ds);
    return dashboard;
  }

  void delete(String id) {
    if (dashboards.length <= 1) return;
    final ds = dashboards.where((d) => d.id != id).toList();
    state = AsyncValue.data(ds);
    if (_activeId == id) {
      _activeId = ds.first.id;
      _saveActiveId();
    }
    _saveDashboards(ds);
  }

  void rename(String id, String name) {
    final ds = dashboards
        .map((d) => d.id == id ? d.copyWith(name: name) : d)
        .toList();
    state = AsyncValue.data(ds);
    _saveDashboards(ds);
  }

  // --- Active widget management (with undo/redo) ---

  void addActiveWidget(WidgetInstance widget) {
    final active = _activeOrFirst;
    pushUndo();
    final ds = dashboards
        .map((d) {
          if (d.id == active.id) {
            return d.copyWith(widgets: [...d.widgets, widget]);
          }
          return d;
        })
        .toList();
    state = AsyncValue.data(ds);
    _saveDashboards(ds);
  }

  void removeActiveWidget(int index) {
    final active = _activeOrFirst;
    if (index < 0 || index >= active.widgets.length) return;
    pushUndo();
    final ds = dashboards
        .map((d) {
          if (d.id == active.id) {
            final widgets = List<WidgetInstance>.from(d.widgets);
            widgets.removeAt(index);
            return d.copyWith(widgets: widgets);
          }
          return d;
        })
        .toList();
    state = AsyncValue.data(ds);
    _saveDashboards(ds);
  }

  void moveActiveWidget(int fromIndex, int toIndex) {
    final active = _activeOrFirst;
    if (fromIndex < 0 ||
        fromIndex >= active.widgets.length ||
        toIndex < 0 ||
        toIndex >= active.widgets.length) {
      return;
    }
    pushUndo();
    final ds = dashboards
        .map((d) {
          if (d.id == active.id) {
            final widgets = List<WidgetInstance>.from(d.widgets);
            final widget = widgets.removeAt(fromIndex);
            widgets.insert(toIndex, widget);
            return d.copyWith(widgets: widgets);
          }
          return d;
        })
        .toList();
    state = AsyncValue.data(ds);
    _saveDashboards(ds);
  }

  void resizeActiveWidget(int index, WidgetSize size) {
    final active = _activeOrFirst;
    if (index < 0 || index >= active.widgets.length) return;
    pushUndo();
    final ds = dashboards
        .map((d) {
          if (d.id == active.id) {
            final widgets = d.widgets.map((w) => w).toList();
            widgets[index] = widgets[index].copyWith(size: size);
            return d.copyWith(widgets: widgets);
          }
          return d;
        })
        .toList();
    state = AsyncValue.data(ds);
    _saveDashboards(ds);
  }

  void updateActiveWidgetConfig(int index, Map<String, dynamic> config) {
    final active = _activeOrFirst;
    if (index < 0 || index >= active.widgets.length) return;
    pushUndo();
    final ds = dashboards
        .map((d) {
          if (d.id == active.id) {
            final widgets = d.widgets.map((w) => w).toList();
            widgets[index] = widgets[index].copyWith(config: config);
            return d.copyWith(widgets: widgets);
          }
          return d;
        })
        .toList();
    state = AsyncValue.data(ds);
    _saveDashboards(ds);
  }

  /// Replace all widgets on the active dashboard (for templates, import, etc.)
  void setAllActiveWidgets(List<WidgetInstance> widgets) {
    final active = _activeOrFirst;
    pushUndo();
    final ds = dashboards
        .map((d) {
          if (d.id == active.id) {
            return d.copyWith(widgets: List.from(widgets));
          }
          return d;
        })
        .toList();
    state = AsyncValue.data(ds);
    _saveDashboards(ds);
  }

  // --- Undo/Redo ---

  void pushUndo() {
    final active = _activeOrFirst;
    _undoStack.add(List<WidgetInstance>.from(active.widgets));
    if (_undoStack.length > _maxUndoSteps) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    final previous = _undoStack.removeLast();
    final active = _activeOrFirst;
    _redoStack.add(List<WidgetInstance>.from(active.widgets));
    final ds = dashboards
        .map((d) {
          if (d.id == active.id) {
            return d.copyWith(widgets: previous);
          }
          return d;
        })
        .toList();
    state = AsyncValue.data(ds);
    _saveDashboards(ds);
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final next = _redoStack.removeLast();
    final active = _activeOrFirst;
    _undoStack.add(List<WidgetInstance>.from(active.widgets));
    final ds = dashboards
        .map((d) {
          if (d.id == active.id) {
            return d.copyWith(widgets: next);
          }
          return d;
        })
        .toList();
    state = AsyncValue.data(ds);
    _saveDashboards(ds);
  }

  // --- Persistence ---

  Dashboard _createDefaultDashboard() {
    return Dashboard(
      id: _uuid.v4(),
      name: 'Mein Dashboard',
      widgets: [
        WidgetInstance.create(widgetType: 'weather', config: {'location': 'Berlin'}),
        WidgetInstance.create(widgetType: 'protein_tracker', config: {'goal': 150}),
      ],
    );
  }

  Future<void> _saveActiveId() async {
    if (_activeId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeIdKey, _activeId!);
    } catch (e) {
      debugPrint('Failed to save active dashboard id: $e');
    }
  }

  Future<void> _saveDashboards(List<Dashboard> dashboards) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(dashboards.map((d) => d.toJson()).toList());
      await prefs.setString(_storageKey, json);
    } catch (e) {
      debugPrint('Failed to save dashboards: $e');
    }
  }
}

/// Riverpod provider for the consolidated dashboard notifier.
final dashboardNotifierProvider =
    AsyncNotifierProvider<DashboardNotifier, List<Dashboard>>(
        DashboardNotifier.new);
