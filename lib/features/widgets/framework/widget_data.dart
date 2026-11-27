import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'widget_data.freezed.dart';
part 'widget_data.g.dart';

DateTime _generatedAtFromJson(dynamic json) {
  if (json == null) return DateTime.now();
  return DateTime.parse(json as String);
}

/// Data payload for a widget with metadata.
@freezed
abstract class WidgetData with _$WidgetData {
  const factory WidgetData({
    @Default(1) int schemaVersion,
    @Default({}) Map<String, dynamic> data,
    @Default([]) List<Map<String, dynamic>> sources,
    @JsonKey(fromJson: _generatedAtFromJson)
    required DateTime generatedAt,
    DateTime? expiresAt,
  }) = _WidgetData;

  factory WidgetData.fromJson(Map<String, dynamic> json) =>
      _$WidgetDataFromJson(json);
}
