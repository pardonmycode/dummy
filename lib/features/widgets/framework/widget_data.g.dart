// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WidgetData _$WidgetDataFromJson(Map<String, dynamic> json) => _WidgetData(
  schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
  data: json['data'] as Map<String, dynamic>? ?? const {},
  sources:
      (json['sources'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  generatedAt: _generatedAtFromJson(json['generatedAt']),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$WidgetDataToJson(_WidgetData instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'data': instance.data,
      'sources': instance.sources,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };
