import 'dart:convert';

import 'package:flutter/foundation.dart';
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
  static const String _activeIdKey = 'active_dashboard_id';

  String? _activeId;

  @override
  List<Dashboard> build() {
    _loadActiveId();
    return [_loadDefaultDashboard()];
  }

  Dashboard _loadDefaultDashboard() {
    return Dashboard(name: 'Mein Dashboard');
  }

  // Expose dashboards list
  List<Dashboard> get dashboards => state;

  // Active dashboard (nullable)
  Dashboard? get active {
    if (_activeId == null) return null;
    try {
      return state.firstWhere((d) => d.id == _activeId);
    } catch (e) {
      return null;
    }
  }

  // Get or create default active
  Dashboard get _activeOrFirst {
    return active ?? state.first;
  }

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
        .map((d) => d.id == id ? Dashboard(id: d.id, name: name, widgets: d.widgets) : d)
        .toList();
    _saveDashboards();
  }

  Future<void> saveActive(List<WidgetInstance> widgets) async {
    final activeDash = _activeOrFirst;
    state = state
        .map((d) => d.id == activeDash.id ? Dashboard(id: d.id, name: d.name, widgets: widgets) : d)
        .toList();
    await _saveDashboards();
  }

  void loadActiveWidgets(List<WidgetInstance> currentWidgets) {
    // No-op for now — would load into the dashboardWidgetsProvider
  }

  void _loadActiveId() {
    // Simplified — would read from prefs
    _activeId = null;
  }

  void _saveActiveId() {
    // Simplified — would write to prefs
  }

  Future<void> _saveDashboards() async {
    // Simplified — would write to prefs
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(state.map((d) => d.toJson()).toList());
      await prefs.setString(_storageKey, json);
    } catch (e) {
      debugPrint('Failed to save dashboards: $e');
    }
  }
}