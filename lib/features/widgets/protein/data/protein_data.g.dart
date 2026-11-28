// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protein_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProteinMeal _$ProteinMealFromJson(Map<String, dynamic> json) => _ProteinMeal(
  name: json['name'] as String,
  protein: json['protein'] as num,
  time: json['time'] as String?,
);

Map<String, dynamic> _$ProteinMealToJson(_ProteinMeal instance) =>
    <String, dynamic>{
      'name': instance.name,
      'protein': instance.protein,
      'time': instance.time,
    };

_ProteinData _$ProteinDataFromJson(Map<String, dynamic> json) => _ProteinData(
  consumed: json['consumed'] as num,
  goal: json['goal'] as num,
  meals:
      (json['meals'] as List<dynamic>?)
          ?.map((e) => ProteinMeal.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ProteinDataToJson(_ProteinData instance) =>
    <String, dynamic>{
      'consumed': instance.consumed,
      'goal': instance.goal,
      'meals': instance.meals,
    };
