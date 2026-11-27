// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_instance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WidgetInstance _$WidgetInstanceFromJson(Map<String, dynamic> json) =>
    _WidgetInstance(
      id: json['id'] as String? ?? '',
      widgetType: json['widgetType'] as String,
      size:
          $enumDecodeNullable(_$WidgetSizeEnumMap, json['size']) ??
          WidgetSize.medium,
      config: json['config'] == null
          ? const {}
          : _configFromJson(json['config']) ?? const {},
      gridPosition: json['gridPosition'] == null
          ? const {'row': 0, 'col': 0, 'rowSpan': 1, 'colSpan': 1}
          : _gridPositionFromJson(json['gridPosition']) ??
                const {'row': 0, 'col': 0, 'rowSpan': 1, 'colSpan': 1},
    );

Map<String, dynamic> _$WidgetInstanceToJson(_WidgetInstance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'widgetType': instance.widgetType,
      'size': _$WidgetSizeEnumMap[instance.size]!,
      'config': instance.config,
      'gridPosition': instance.gridPosition,
    };

const _$WidgetSizeEnumMap = {
  WidgetSize.small: 'small',
  WidgetSize.medium: 'medium',
  WidgetSize.large: 'large',
};
