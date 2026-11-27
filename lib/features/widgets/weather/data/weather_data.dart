import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_data.freezed.dart';
part 'weather_data.g.dart';

/// Typed data model for weather widget.
@freezed
abstract class WeatherData with _$WeatherData {
  const factory WeatherData({
    required double temperature,
    required String condition,
    required String icon,
    @Default([]) List<HourlyForecast> hourly,
    @Default([]) List<DailyForecast> daily,
  }) = _WeatherData;

  factory WeatherData.fromJson(Map<String, dynamic> json) =>
      _$WeatherDataFromJson(json);
}

@freezed
abstract class HourlyForecast with _$HourlyForecast {
  const factory HourlyForecast({
    required String time,
    required double temp,
    required String icon,
  }) = _HourlyForecast;

  factory HourlyForecast.fromJson(Map<String, dynamic> json) =>
      _$HourlyForecastFromJson(json);
}

@freezed
abstract class DailyForecast with _$DailyForecast {
  const factory DailyForecast({
    required String date,
    required double high,
    required double low,
    required String icon,
  }) = _DailyForecast;

  factory DailyForecast.fromJson(Map<String, dynamic> json) =>
      _$DailyForecastFromJson(json);
}
