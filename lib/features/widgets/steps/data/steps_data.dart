import 'package:freezed_annotation/freezed_annotation.dart';

part 'steps_data.freezed.dart';
part 'steps_data.g.dart';

/// Typed data model for steps tracker widget.
@freezed
abstract class StepsData with _$StepsData {
  const factory StepsData({
    required num steps,
    required num goal,
    required num distanceKm,
    required num calories,
    @Default(0) int streak,
  }) = _StepsData;

  factory StepsData.fromJson(Map<String, dynamic> json) =>
      _$StepsDataFromJson(json);
}
