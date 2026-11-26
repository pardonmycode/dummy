import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../widgets/framework/widget_instance.dart';

/// A named dashboard configuration.
class Dashboard {
  final String id;
  final String name;
  final List<WidgetInstance> widgets;

  Dashboard({
    String? id,
    required this.name,
    List<WidgetInstance>? widgets,
  }) : id = id ?? const Uuid().v4(),
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
          ?.map(
            (w) => WidgetInstance.fromJson(
              Map<String, dynamic>.from(w as Map),
            ),
          )
          .toList() ??
          [],
    );
  }
}

/// State notifier for managing multiple dashboards.
class DashboardsNotifier extends Notifier<List<Dashboard>> {
  static const String _storageKey = 'dashboards';

  @override
  List<Dashboard> build() {
    return [
      Dashboard(name: 'Mein Dashboard'),
    ];
  }

  // Expose dashboards list
  List<Dashboard> get dashboards => state;

  // Active dashboard (nullable)
  Dashboard? get active {
    final activeId = _getActiveId();
    if (activeId == null) return null;
    try {
      return state.firstWhere((d) => d.id == activeId);
    } catch (e) {
      return null;
    }
  }

  // Get or create default active
  Dashboard get _activeOrFirst {
    return active ?? state.first;
  }

  void setActive(String id) {
    _setActiveId(id);
    state = List<Dashboard>.from(state); // Trigger rebuild
  }

  Future<Dashboard> create(String name) async {
    final dashboard = Dashboard(name: name);
    state = [...state, dashboard];
    _setActiveId(dashboard.id);
    _saveDashboards();
    return dashboard;
  }

  void delete(String id) {
    if (state.length <= 1) return;
    state = state.where((d) => d.id != id).toList();
    _saveDashboards();
  }

  void rename(String id, String name) {
    state = state
        .map((d) => d.id == id ? Dashboard(id: d.id, name: name, widgets: d.widgets) : d)
        .toList();
    _saveDashboards();
  }

  Future<void> saveActive(List<WidgetInstance> widgets) async {
    final activeId = _getActiveId() ?? _activeOrFirst.id;
    state = state
        .map((d) => d.id == activeId ? Dashboard(id: d.id, name: d.name, widgets: widgets) : d)
        .toList();
    _saveDashboards();
  }

  void loadActiveWidgets(List<WidgetInstance> currentWidgets) {
    // No-op for now — would load into the dashboardWidgetsProvider
  }

  String? _getActiveId() {
    return null; // Simplified — would read from prefs
  }

  void _setActiveId(String id) {
    // Would write to prefs
  }

  void _saveDashboards() {
    // Simplified — would write to prefs
    SharedPreferences.getInstance().then((prefs) {
      final json = jsonEncode(state.map((d) => d.toJson()).toList());
      prefs.setString(_storageKey, json);
    }).catchError((e) {
      print('Failed to save dashboards: $e');
    });
  }
}