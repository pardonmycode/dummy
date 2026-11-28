// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'steps_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StepsData _$StepsDataFromJson(Map<String, dynamic> json) => _StepsData(
  steps: json['steps'] as num,
  goal: json['goal'] as num,
  distanceKm: json['distanceKm'] as num,
  calories: json['calories'] as num,
  streak: (json['streak'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$StepsDataToJson(_StepsData instance) =>
    <String, dynamic>{
      'steps': instance.steps,
      'goal': instance.goal,
      'distanceKm': instance.distanceKm,
      'calories': instance.calories,
      'streak': instance.streak,
    };
