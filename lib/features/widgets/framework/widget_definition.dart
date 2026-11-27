import 'package:material_ui/material_ui.dart';

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

/// Data payload for a widget with metadata.
class WidgetData {
  final int schemaVersion;
  final Map<String, dynamic> data;
  final List<Map<String, dynamic>> sources;
  final DateTime generatedAt;
  final DateTime? expiresAt;

  const WidgetData({
    required this.schemaVersion,
    required this.data,
    required this.generatedAt,
    this.sources = const [],
    this.expiresAt,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  factory WidgetData.fromJson(Map<String, dynamic> json) {
    return WidgetData(
      schemaVersion: json['schemaVersion'] ?? 1,
      data: json['data'] ?? {},
      sources:
          (json['sources'] as List?)
              ?.map(
                (s) => s is Map
                    ? Map<String, dynamic>.from(s)
                    : {'name': s.toString()},
              )
              .toList() ??
          [],
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'])
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
    );
  }
}

/// Definition for a widget type.
abstract class WidgetDefinition {
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

  /// Build the widget UI from data and state.
  Widget buildView(
    WidgetData? data,
    WidgetDataState state,
    WidgetConfig config,
  );
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
