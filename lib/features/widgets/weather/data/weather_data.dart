import '../../../framework/widget_definition.dart';

class WeatherData {
  final double temperature;
  final String condition;
  final String icon;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.hourly,
    required this.daily,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['current']['temp'],
      condition: json['current']['condition'],
      icon: json['current']['icon'],
      hourly: (json['hourly'] as List)
          .map((h) => HourlyForecast.fromJson(h))
          .toList(),
      daily: (json['daily'] as List)
          .map((d) => DailyForecast.fromJson(d))
          .toList(),
    );
  }
}

class HourlyForecast {
  final String time;
  final double temp;
  final String icon;

  HourlyForecast({required this.time, required this.temp, required this.icon});

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: json['time'],
      temp: json['temp'],
      icon: json['icon'],
    );
  }
}

class DailyForecast {
  final String date;
  final double high;
  final double low;
  final String icon;

  DailyForecast({
    required this.date,
    required this.high,
    required this.low,
    required this.icon,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['date'],
      high: json['high'],
      low: json['low'],
      icon: json['icon'],
    );
  }
}
