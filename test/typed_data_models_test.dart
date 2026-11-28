import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:widgetly/core/models/tracker_base.dart';
import 'package:widgetly/features/widgets/weather/data/weather_data.dart';
import 'package:widgetly/features/widgets/steps/data/steps_data.dart';
import 'package:widgetly/features/widgets/protein/data/protein_data.dart';
import 'package:widgetly/features/widgets/parties/data/party_event.dart';
import 'package:widgetly/features/widgets/water/data/water_data.dart';

void main() {
  group('Typed data models - JSON roundtrip', () {
    test('WeatherData roundtrip via jsonEncode/Decode', () {
      final data = WeatherData(
        temperature: 25.5,
        condition: 'sunny',
        icon: '☀️',
        hourly: [
          HourlyForecast(time: '14:00', temp: 26.0, icon: '☀️'),
          HourlyForecast(time: '15:00', temp: 25.0, icon: '⛅'),
        ],
        daily: [
          DailyForecast(date: '2026-11-28', high: 28.0, low: 18.0, icon: '☀️'),
        ],
      );

      // Encode to JSON string, then decode back to Map
      final jsonStr = jsonEncode(data.toJson());
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final restored = WeatherData.fromJson(json);

      expect(restored.temperature, 25.5);
      expect(restored.condition, 'sunny');
      expect(restored.hourly.length, 2);
      expect(restored.hourly[0].time, '14:00');
      expect(restored.daily.length, 1);
    });

    test('StepsData roundtrip via jsonEncode/Decode', () {
      final data = StepsData(
        steps: 8500,
        goal: 10000,
        distanceKm: 6.46,
        calories: 387,
        streak: 3,
      );

      final jsonStr = jsonEncode(data.toJson());
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final restored = StepsData.fromJson(json);

      expect(restored.steps, 8500);
      expect(restored.goal, 10000);
      expect(restored.distanceKm, 6.46);
      expect(restored.streak, 3);
    });

    test('ProteinData roundtrip via jsonEncode/Decode', () {
      final data = ProteinData(
        consumed: 120,
        goal: 150,
        meals: [
          ProteinMeal(name: 'Eier', protein: 30, time: '08:00'),
          ProteinMeal(name: 'Hähnchen', protein: 45, time: '12:30'),
        ],
      );

      final jsonStr = jsonEncode(data.toJson());
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final restored = ProteinData.fromJson(json);

      expect(restored.consumed, 120);
      expect(restored.meals.length, 2);
      expect(restored.meals[0].name, 'Eier');
      expect(restored.meals[1].protein, 45);
    });

    test('PartiesData roundtrip via jsonEncode/Decode', () {
      final data = PartiesData(
        events: [
          PartyEvent(
            name: 'Club Night',
            venue: 'Kraftwerk',
            time: '22:00',
            lat: 52.51,
            lng: 13.39,
            genre: 'club',
          ),
        ],
      );

      final jsonStr = jsonEncode(data.toJson());
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final restored = PartiesData.fromJson(json);

      expect(restored.events.length, 1);
      expect(restored.events[0].name, 'Club Night');
      expect(restored.events[0].lat, 52.51);
      expect(restored.events[0].genre, 'club');
    });

    test('WaterData roundtrip via jsonEncode/Decode', () {
      final entry = WaterEntry(
        amountMl: 250,
        timestamp: DateTime(2026, 11, 27, 10, 0),
      );
      final data = WaterData(
        consumed: 1250,
        goal: 2000,
        entries: [entry],
      );

      final jsonStr = jsonEncode(data.toJson());
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final restored = WaterData.fromJson(json);

      expect(restored.consumed, 1250);
      expect(restored.entries.length, 1);
      expect(restored.entries[0].amountMl, 250);
    });

    test('TrackerBase methods via extension', () {
      final tracker = TrackerBase(target: 10000, unit: 'steps');

      // addEntry returns new instance (immutability)
      final tracker2 = tracker.addEntry(500);
      expect(tracker2.entries.length, 1);
      expect(tracker.entries.length, 0); // original unchanged

      // calculateProgress works
      final progress = tracker2.calculateProgress();
      expect(progress, greaterThan(0.0));

      // getPeriodTotal works
      final total = tracker2.getPeriodTotal();
      expect(total, 500);

      // JSON serialization
      final json = tracker2.toJson();
      expect(json['target'], 10000);
      expect((json['entries'] as List).length, 1);
    });
  });
}
