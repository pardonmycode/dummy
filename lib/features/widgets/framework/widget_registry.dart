import 'widget_definition.dart';

/// Central registry for all widget types.
class WidgetRegistry {
  final Map<String, WidgetDefinition> _widgets = {};

  /// Register a widget type.
  void register(WidgetDefinition widget) {
    if (_widgets.containsKey(widget.id)) {
      throw StateError('Widget with id "${widget.id}" is already registered.');
    }
    _widgets[widget.id] = widget;
  }

  /// Get a widget definition by id.
  WidgetDefinition? get(String id) {
    return _widgets[id];
  }

  /// Check if a widget is registered.
  bool contains(String id) {
    return _widgets.containsKey(id);
  }

  /// Get all registered widgets.
  List<WidgetDefinition> getAll() {
    return List.unmodifiable(_widgets.values);
  }

  /// Get widgets by category.
  List<WidgetDefinition> getByCategory(String category) {
    return _widgets.values
        .where((w) => w.category == category)
        .toList();
  }

  /// Get all categories.
  List<String> getCategories() {
    final categories = <String>{};
    for (final w in _widgets.values) {
      categories.add(w.category);
    }
    return categories.toList();
  }
}
