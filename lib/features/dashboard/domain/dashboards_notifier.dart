import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../features/widgets/framework/widget_instance.dart';

/// A named dashboard containing a collection of widgets.
class DashboardModel {
  final String id;
  String name;
  List<WidgetInstance> widgets;

  DashboardModel({
    required this.id,
    required this.name,
    required this.widgets,
  });

  /// Clone this dashboard with a new id.
  DashboardModel clone({String? newId}) {
    return DashboardModel(
      id: newId ?? id,
      name: name,
      widgets: widgets.map((w) => w.clone()).toList(),
    );
  }

  /// Serialize to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'widgets': widgets.map((w) => w.toJson()).toList(),
    };
  }

  /// Deserialize from JSON.
  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      id: json['id'] as String,
      name: json['name'] as String,
      widgets: (json['widgets'] as List)
          .map(
            (w) =>
                WidgetInstance.fromJson(Map<String, dynamic>.from(w as Map)),
          )
          .toList(),
    );
  }
}

/// Notifier managing multiple named dashboards.
class DashboardsNotifier {
  List<DashboardModel> _dashboards = [];
  String? _activeId;

  DashboardsNotifier() {
    _loadDashboards();
  }

  /// All dashboards.
  List<DashboardModel> get dashboards => _dashboards;

  /// The active dashboard.
  DashboardModel? get active {
    if (_activeId == null) return null;
    return _dashboards.firstWhere((d) => d.id == _activeId, orElse: () => _dashboards.first);
  }

  /// Set the active dashboard.
  Future<void> setActive(String id) async {
    _activeId = id;
    await _saveActiveId();
  }

  /// Create a new dashboard.
  Future<DashboardModel> create(String name) async {
    final dashboard = DashboardModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      widgets: [],
    );
    _dashboards.add(dashboard);
    await _saveDashboards();
    return dashboard;
  }

  /// Delete a dashboard.
  Future<void> delete(String id) async {
    final index = _dashboards.indexWhere((d) => d.id == id);
    if (index >= 0) {
      _dashboards.removeAt(index);
      if (_activeId == id && _dashboards.isNotEmpty) {
        _activeId = _dashboards.first.id;
      }
      await _saveDashboards();
    }
  }

  /// Rename a dashboard.
  Future<void> rename(String id, String name) async {
    final dashboard = _dashboards.firstWhere((d) => d.id == id);
    dashboard.name = name;
    await _saveDashboards();
  }

  /// Save the active dashboard's widgets.
  Future<void> saveActive(List<WidgetInstance> widgets) async {
    final dashboard = active;
    if (dashboard != null) {
      dashboard.widgets = widgets;
      await _saveDashboards();
    }
  }

  Future<void> _loadDashboards() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load dashboards
      final json = prefs.getString('dashboards');
      if (json != null) {
        final List<dynamic> data = jsonDecode(json);
        _dashboards = data
            .map(
              (item) =>
                  DashboardModel.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
            )
            .toList();
      }

      // Load active id
      _activeId = prefs.getString('active_dashboard');

      // If no dashboards, create default
      if (_dashboards.isEmpty) {
        final defaultDashboard = DashboardModel(
          id: 'default',
          name: 'Hauptdashboard',
          widgets: [],
        );
        _dashboards.add(defaultDashboard);
        _activeId = defaultDashboard.id;
        await _saveDashboards();
      }
    } catch (e) {
      print('Failed to load dashboards: $e');
    }
  }

  Future<void> _saveDashboards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(_dashboards.map((d) => d.toJson()).toList());
      await prefs.setString('dashboards', json);
      await _saveActiveId();
    } catch (e) {
      print('Failed to save dashboards: $e');
    }
  }

  Future<void> _saveActiveId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_activeId != null) {
        await prefs.setString('active_dashboard', _activeId!);
      }
    } catch (e) {
      print('Failed to save active dashboard id: $e');
    }
  }
}