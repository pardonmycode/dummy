import 'package:uuid/uuid.dart';

import 'widget_definition.dart';

/// Singleton Uuid instance to avoid recreating on every WidgetInstance.
final _uuid = Uuid();

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
  }) : id = id ?? _uuid.v4(),
       config = config ?? {},
       gridPosition =
           gridPosition ?? {'row': 0, 'col': 0, 'rowSpan': 1, 'colSpan': 1};

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
    // config: jsonDecode produces Map<String, dynamic>, but handle null
    Map<String, dynamic> config = {};
    if (json['config'] != null) {
      config = Map<String, dynamic>.from(json['config'] as Map);
    }

    // gridPosition: jsonDecode produces Map with num values, not int
    Map<String, int> gridPosition = {'row': 0, 'col': 0, 'rowSpan': 1, 'colSpan': 1};
    if (json['gridPosition'] != null) {
      final raw = json['gridPosition'] as Map;
      gridPosition = raw.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
    }

    return WidgetInstance(
      id: json['id'] as String?,
      widgetType: json['widgetType'] as String,
      size: WidgetSize.values.firstWhere(
        (s) => s.name == json['size'],
        orElse: () => WidgetSize.medium,
      ),
      config: config,
      gridPosition: gridPosition,
    );
  }
}
