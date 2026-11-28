import 'package:freezed_annotation/freezed_annotation.dart';

part 'protein_data.freezed.dart';
part 'protein_data.g.dart';

/// Meal entry for protein tracking.
@freezed
abstract class ProteinMeal with _$ProteinMeal {
  const factory ProteinMeal({
    required String name,
    required num protein,
    String? time,
  }) = _ProteinMeal;

  factory ProteinMeal.fromJson(Map<String, dynamic> json) =>
      _$ProteinMealFromJson(json);
}

/// Typed data model for protein tracker widget.
@freezed
abstract class ProteinData with _$ProteinData {
  const factory ProteinData({
    required num consumed,
    required num goal,
    @Default([]) List<ProteinMeal> meals,
  }) = _ProteinData;

  factory ProteinData.fromJson(Map<String, dynamic> json) =>
      _$ProteinDataFromJson(json);
}
