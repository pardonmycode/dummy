import 'package:freezed_annotation/freezed_annotation.dart';

part 'water_data.freezed.dart';
part 'water_data.g.dart';

/// Water intake entry.
@freezed
abstract class WaterEntry with _$WaterEntry {
  const factory WaterEntry({
    required num amountMl,
    required DateTime timestamp,
  }) = _WaterEntry;

  factory WaterEntry.fromJson(Map<String, dynamic> json) =>
      _$WaterEntryFromJson(json);
}

/// Typed data model for water tracker widget.
@freezed
abstract class WaterData with _$WaterData {
  const factory WaterData({
    required num consumed,
    required num goal,
    @Default([]) List<WaterEntry> entries,
  }) = _WaterData;

  factory WaterData.fromJson(Map<String, dynamic> json) =>
      _$WaterDataFromJson(json);
}
