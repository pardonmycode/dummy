// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WaterEntry _$WaterEntryFromJson(Map<String, dynamic> json) => _WaterEntry(
  amountMl: json['amountMl'] as num,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$WaterEntryToJson(_WaterEntry instance) =>
    <String, dynamic>{
      'amountMl': instance.amountMl,
      'timestamp': instance.timestamp.toIso8601String(),
    };

_WaterData _$WaterDataFromJson(Map<String, dynamic> json) => _WaterData(
  consumed: json['consumed'] as num,
  goal: json['goal'] as num,
  entries:
      (json['entries'] as List<dynamic>?)
          ?.map((e) => WaterEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$WaterDataToJson(_WaterData instance) =>
    <String, dynamic>{
      'consumed': instance.consumed,
      'goal': instance.goal,
      'entries': instance.entries,
    };
