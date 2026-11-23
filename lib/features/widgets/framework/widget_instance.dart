import 'package:uuid/uuid.dart';

import 'widget_definition.dart';

/// A concrete instance of a widget on a dashboard.
class WidgetInstance {
  final String id;
  final String widgetType;
  final WidgetSize size;
  final Map<String, dynamic> config;
  final Map<String, int> gridPosition;

  WidgetInstance({
    String? id,
    required this.widgetType,
    this.size = WidgetSize.medium,
    Map<String, dynamic>? config,
    Map<String, int>? gridPosition,
  })  : id = id ?? const Uuid().v4(),
        config = config ?? {},
        gridPosition = gridPosition ?? {'row': 0, 'col': 0, 'rowSpan': 1, 'colSpan': 1};

  /// Clone this instance.
  WidgetInstance clone({
    String? newId,
    WidgetSize? newSize,
    Map<String, dynamic>? newConfig,
    Map<String, int>? newGridPosition,
  }) {
    return WidgetInstance(
      id: newId,
      widgetType: widgetType,
      size: newSize ?? size,
      config: newConfig ?? config,
      gridPosition: newGridPosition ?? gridPosition,
    );
  }

  /// Serialize to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'widgetType': widgetType,
      'size': size.name,
      'config': config,
      'gridPosition': gridPosition,
    };
  }

  /// Deserialize from JSON.
  factory WidgetInstance.fromJson(Map<String, dynamic> json) {
    return WidgetInstance(
      id: json['id'] as String?,
      widgetType: json['widgetType'] as String,
      size: WidgetSize.values.firstWhere(
        (s) => s.name == json['size'],
        orElse: () => WidgetSize.medium,
      ),
      config: json['config'] as Map<String, dynamic>? ?? {},
      gridPosition: json['gridPosition'] as Map<String, int>? ??
          {'row': 0, 'col': 0, 'rowSpan': 1, 'colSpan': 1},
    );
  }
}
