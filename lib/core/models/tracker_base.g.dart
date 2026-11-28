// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracker_base.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrackerEntry _$TrackerEntryFromJson(Map<String, dynamic> json) =>
    _TrackerEntry(
      value: json['value'] as num,
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$TrackerEntryToJson(_TrackerEntry instance) =>
    <String, dynamic>{
      'value': instance.value,
      'timestamp': instance.timestamp.toIso8601String(),
      'note': instance.note,
    };

_TrackerBase _$TrackerBaseFromJson(Map<String, dynamic> json) => _TrackerBase(
  target: json['target'] as num,
  unit: json['unit'] as String,
  period:
      $enumDecodeNullable(_$TimePeriodEnumMap, json['period']) ??
      TimePeriod.day,
  entries:
      (json['entries'] as List<dynamic>?)
          ?.map((e) => TrackerEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$TrackerBaseToJson(_TrackerBase instance) =>
    <String, dynamic>{
      'target': instance.target,
      'unit': instance.unit,
      'period': _$TimePeriodEnumMap[instance.period]!,
      'entries': instance.entries,
    };

const _$TimePeriodEnumMap = {
  TimePeriod.day: 'day',
  TimePeriod.week: 'week',
  TimePeriod.month: 'month',
};
