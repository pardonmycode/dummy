// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WeatherData _$WeatherDataFromJson(Map<String, dynamic> json) => _WeatherData(
  temperature: (json['temperature'] as num).toDouble(),
  condition: json['condition'] as String,
  icon: json['icon'] as String,
  hourly:
      (json['hourly'] as List<dynamic>?)
          ?.map((e) => HourlyForecast.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  daily:
      (json['daily'] as List<dynamic>?)
          ?.map((e) => DailyForecast.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$WeatherDataToJson(_WeatherData instance) =>
    <String, dynamic>{
      'temperature': instance.temperature,
      'condition': instance.condition,
      'icon': instance.icon,
      'hourly': instance.hourly,
      'daily': instance.daily,
    };

_HourlyForecast _$HourlyForecastFromJson(Map<String, dynamic> json) =>
    _HourlyForecast(
      time: json['time'] as String,
      temp: (json['temp'] as num).toDouble(),
      icon: json['icon'] as String,
    );

Map<String, dynamic> _$HourlyForecastToJson(_HourlyForecast instance) =>
    <String, dynamic>{
      'time': instance.time,
      'temp': instance.temp,
      'icon': instance.icon,
    };

_DailyForecast _$DailyForecastFromJson(Map<String, dynamic> json) =>
    _DailyForecast(
      date: json['date'] as String,
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      icon: json['icon'] as String,
    );

Map<String, dynamic> _$DailyForecastToJson(_DailyForecast instance) =>
    <String, dynamic>{
      'date': instance.date,
      'high': instance.high,
      'low': instance.low,
      'icon': instance.icon,
    };
