// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Dashboard _$DashboardFromJson(Map<String, dynamic> json) => _Dashboard(
  id: json['id'] as String? ?? '',
  name: json['name'] as String,
  widgets:
      (json['widgets'] as List<dynamic>?)
          ?.map((e) => WidgetInstance.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$DashboardToJson(_Dashboard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'widgets': instance.widgets,
    };
