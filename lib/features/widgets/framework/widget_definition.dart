import 'package:material_ui/material_ui.dart';
import 'widget_data.dart';

/// Widget size variants for responsive layouts.
enum WidgetSize {
  small, // S: Compact, key info only
  medium, // M: Standard view
  large, // L: Expanded, detailed
}

/// Refresh interval for widget data.
enum RefreshInterval {
  never,
  manual,
  minutes15,
  minutes30,
  hours1,
  hours6,
  hours12,
  days1,
}

/// Widget lifecycle state.
enum WidgetDataState {
  loading, // Data is being fetched
  ready, // Data is available and fresh
  stale, // Data is available but may be outdated
  error, // Data fetch failed
  empty, // No data available
  offline, // No network, showing cached data
}

/// Standard actions a widget can perform.
enum WidgetAction { open, share, save, refresh, configure, remove }

/// Configuration for a widget instance.
class WidgetConfig {
  final Map<String, dynamic> settings;

  const WidgetConfig([this.settings = const {}]);

  T? get<T>(String key) => settings[key] as T?;
}

/// Definition for a widget type.
/// Generic parameter [T] is the typed data model for this widget.
abstract class WidgetDefinition<T> {
  /// Unique identifier for this widget type.
  String get id;

  /// Display name of the widget.
  String get name;

  /// Short description.
  String get description;

  /// Category for grouping in the widget catalog.
  String get category;

  /// Icon for the widget.
  IconData get icon;

  /// Theme color for the widget.
  Color get color => Colors.blue;

  /// Default size for this widget.
  WidgetSize get defaultSize => WidgetSize.medium;

  /// Supported sizes.
  Set<WidgetSize> get supportedSizes => {
    WidgetSize.small,
    WidgetSize.medium,
    WidgetSize.large,
  };

  /// Default refresh interval.
  RefreshInterval get defaultRefreshInterval => RefreshInterval.hours1;

  /// Configuration options for this widget.
  /// Returns a list of config field definitions.
  List<WidgetConfigField> get configFields => [];

  /// Parse raw WidgetData into the typed data model [T].
  T parseData(WidgetData? data);

  /// Build the widget UI from typed data and state.
  /// [onQuickAdd] is an optional callback for tracker widgets to report quick-add actions.
  Widget buildView(
    BuildContext context,
    T data,
    WidgetDataState state,
    WidgetConfig config, {
    void Function(String type, Map<String, dynamic> entry)? onQuickAdd,
  });
}

/// Configuration field definition for widget forms.
class WidgetConfigField {
  final String key;
  final String label;
  final String? description;
  final String type; // 'string', 'number', 'bool', 'select'
  final dynamic defaultValue;
  final List<Map<String, dynamic>>? options; // For select fields
  final double? min;
  final double? max;
  final String? unit;

  const WidgetConfigField({
    required this.key,
    required this.label,
    this.description,
    this.type = 'string',
    this.defaultValue,
    this.options,
    this.min,
    this.max,
    this.unit,
  });
}
