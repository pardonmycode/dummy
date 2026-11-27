import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../widgets/framework/widget_instance.dart';
import '../../widgets/framework/widget_definition.dart';

/// A named dashboard configuration.
class Dashboard {
  final String id;
  final String name;
  final List<WidgetInstance> widgets;

  Dashboard({
    String? id,
    required this.name,
    List<WidgetInstance>? widgets,
  })  : id = id ?? const Uuid().v4(),
        widgets = widgets ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'widgets': widgets.map((w) => w.toJson()).toList(),
    };
  }

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      id: json['id'] as String?,
      name: json['name'] as String,
      widgets: (json['widgets'] as List?)
              ?.map((w) =>
                  WidgetInstance.fromJson(Map<String, dynamic>.from(w as Map)))
              .toList() ??
          [],
    );
  }

  Dashboard copyWith({List<WidgetInstance>? widgets}) {
    return Dashboard(id: id, name: name, widgets: widgets ?? this.widgets);
  }
}

/// Consolidated notifier managing dashboards, widgets, and undo/redo history.
class DashboardNotifier extends Notifier<List<Dashboard>> {
  static const String _storageKey = 'dashboards';
  static const String _activeIdKey = 'active_dashboard_id';
  static const int _maxUndoSteps = 50;

  final int _maxHistory;
  String? _activeId;
  List<List<WidgetInstance>> _undoStack = [];
  List<List<WidgetInstance>> _redoStack = [];

  DashboardNotifier({int? maxHistory}) : _maxHistory = maxHistory ?? _maxUndoSteps;

  @override
  List<Dashboard> build() {
    final defaultDashboard = _loadDefaultDashboard();
    _activeId = defaultDashboard.id;
    return [defaultDashboard];
  }

  // --- Public getters ---

  List<Dashboard> get dashboards => state;

  Dashboard? get activeDashboard {
    if (_activeId == null) return null;
    try {
      return state.firstWhere((d) => d.id == _activeId);
    } catch (_) {
      return null;
    }
  }

  Dashboard get _activeOrFirst {
    return activeDashboard ?? state.first;
  }

  bool get canUndo => _undoStack.isNotEmpty;

  bool get canRedo => _redoStack.isNotEmpty;

  // --- Dashboard management ---

  void setActive(String id) {
    _activeId = id;
    _saveActiveId();
    state = List<Dashboard>.from(state); // Trigger rebuild
  }

  Future<Dashboard> create(String name) async {
    final dashboard = Dashboard(name: name);
    state = [...state, dashboard];
    setActive(dashboard.id);
    await _saveDashboards();
    return dashboard;
  }

  void delete(String id) {
    if (state.length <= 1) return;
    state = state.where((d) => d.id != id).toList();
    _saveDashboards();
  }

  void rename(String id, String name) {
    state = state
        .map((d) =>
            d.id == id ? Dashboard(id: d.id, name: name, widgets: d.widgets) : d)
        .toList();
    _saveDashboards();
  }

  // --- Active widget management (with undo/redo) ---

  void addActiveWidget(WidgetInstance widget) {
    final active = _activeOrFirst;
    pushUndo();
    state = state
        .map((d) {
          if (d.id == active.id) {
            return d.copyWith(widgets: [...d.widgets, widget]);
          }
          return d;
        })
        .toList();
    _saveDashboards();
  }

  void removeActiveWidget(int index) {
    final active = _activeOrFirst;
    if (index < 0 || index >= active.widgets.length) return;
    pushUndo();
    state = state
        .map((d) {
          if (d.id == active.id) {
            final widgets = List<WidgetInstance>.from(d.widgets);
            widgets.removeAt(index);
            return d.copyWith(widgets: widgets);
          }
          return d;
        })
        .toList();
    _saveDashboards();
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
    state = state
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
    _saveDashboards();
  }

  void resizeActiveWidget(int index, String size) {
    final active = _activeOrFirst;
    if (index < 0 || index >= active.widgets.length) return;
    pushUndo();
    state = state
        .map((d) {
          if (d.id == active.id) {
            final widgets = d.widgets.map((w) => w).toList();
            widgets[index] = widgets[index].clone(newSize: WidgetSize.values.firstWhere((s) => s.name == size));
            return d.copyWith(widgets: widgets);
          }
          return d;
        })
        .toList();
    _saveDashboards();
  }

  /// Replace all widgets on the active dashboard (for templates, import, etc.)
  void setAllActiveWidgets(List<WidgetInstance> widgets) {
    final active = _activeOrFirst;
    pushUndo();
    state = state
        .map((d) {
          if (d.id == active.id) {
            return d.copyWith(widgets: List.from(widgets));
          }
          return d;
        })
        .toList();
    _saveDashboards();
  }

  // --- Undo/Redo ---

  void pushUndo() {
    final active = _activeOrFirst;
    _undoStack.add(List<WidgetInstance>.from(active.widgets));
    if (_undoStack.length > _maxHistory) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    final previous = _undoStack.removeLast();
    final active = _activeOrFirst;
    _redoStack.add(List<WidgetInstance>.from(active.widgets));
    state = state
        .map((d) {
          if (d.id == active.id) {
            return d.copyWith(widgets: previous);
          }
          return d;
        })
        .toList();
    _saveDashboards();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final next = _redoStack.removeLast();
    final active = _activeOrFirst;
    _undoStack.add(List<WidgetInstance>.from(active.widgets));
    state = state
        .map((d) {
          if (d.id == active.id) {
            return d.copyWith(widgets: next);
          }
          return d;
        })
        .toList();
    _saveDashboards();
  }

  // --- Persistence ---

  Dashboard _loadDefaultDashboard() {
    return Dashboard(name: 'Mein Dashboard');
  }

  void _loadActiveId() {
    // Set default active ID to the first dashboard
    if (state.isNotEmpty) {
      _activeId = state.first.id;
    }
  }

  void _saveActiveId() {
    // Simplified — would write to prefs
  }

  Future<void> _saveDashboards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(state.map((d) => d.toJson()).toList());
      await prefs.setString(_storageKey, json);
    } catch (e) {
      debugPrint('Failed to save dashboards: $e');
    }
  }
}

/// Riverpod provider for the consolidated dashboard notifier.
final dashboardNotifierProvider =
    NotifierProvider<DashboardNotifier, List<Dashboard>>(DashboardNotifier.new);
