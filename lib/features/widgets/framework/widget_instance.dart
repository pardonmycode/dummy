import 'package:uuid/uuid.dart';
import '../framework/widget_definition.dart';

/// A concrete instance of a widget on a dashboard.
class WidgetInstance {
  final String id;
  final String widgetType;
  final WidgetSize size;
  final WidgetConfig config;
  final int gridPosition;

  WidgetInstance({
    String? id,
    required this.widgetType,
    this.size = WidgetSize.medium,
    WidgetConfig? config,
    this.gridPosition = 0,
  })  : id = id ?? const Uuid().v4(),
        config = config ?? const WidgetConfig();

  /// Clone this instance.
  WidgetInstance clone({
    String? newId,
    WidgetSize? newSize,
    WidgetConfig? newConfig,
    int? newGridPosition,
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
      'config': config.settings,
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
      config: WidgetConfig(json['config'] as Map<String, dynamic>? ?? {}),
      gridPosition: json['gridPosition'] as int? ?? 0,
    );
  }
}
