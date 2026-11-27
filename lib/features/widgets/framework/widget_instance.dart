import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'widget_definition.dart';

part 'widget_instance.freezed.dart';
part 'widget_instance.g.dart';

/// Singleton Uuid instance to avoid recreating on every WidgetInstance.
final _uuid = Uuid();

Map<String, dynamic>? _configFromJson(dynamic json) {
  if (json == null) return null;
  final map = json as Map;
  return map.map((k, v) => MapEntry(k.toString(), v));
}

Map<String, int>? _gridPositionFromJson(dynamic json) {
  if (json == null) return null;
  final map = json as Map;
  return map.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
}

/// A concrete instance of a widget on a dashboard.
@freezed
abstract class WidgetInstance with _$WidgetInstance {
  const factory WidgetInstance({
    @Default('') String id,
    required String widgetType,
    @Default(WidgetSize.medium) WidgetSize size,
    @JsonKey(fromJson: _configFromJson)
    @Default({}) Map<String, dynamic> config,
    @JsonKey(fromJson: _gridPositionFromJson)
    @Default({'row': 0, 'col': 0, 'rowSpan': 1, 'colSpan': 1}) Map<String, int> gridPosition,
  }) = _WidgetInstance;

  factory WidgetInstance.fromJson(Map<String, dynamic> json) =>
      _$WidgetInstanceFromJson(json);
}

extension WidgetInstanceClone on WidgetInstance {
  /// Clone this instance with optional overrides.
  WidgetInstance clone({
    String? newId,
    WidgetSize? newSize,
    Map<String, dynamic>? newConfig,
    Map<String, int>? newGridPosition,
  }) {
    return WidgetInstance(
      id: newId ?? _uuid.v4(),
      widgetType: widgetType,
      size: newSize ?? size,
      config: newConfig ?? config,
      gridPosition: newGridPosition ?? gridPosition,
    );
  }
}
