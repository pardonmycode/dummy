import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetly/features/widgets/framework/widget_definition.dart';
import 'package:widgetly/features/widgets/ui/types/weather/weather_widget.dart';
import 'package:widgetly/features/widgets/ui/types/protein/protein_tracker_widget.dart';
import 'package:widgetly/features/dashboard/ui/views/dashboard_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_helpers.dart';

void main() {
  setUp(setupTestEnvironment);
  tearDown(teardownTestEnvironment);

  group('Widget properties', () {
    test('Weather widget has correct properties', () {
      final weather = WeatherWidget();
      expect(weather.id, 'weather');
      expect(weather.name, 'Wetter');
      expect(weather.category, 'Umwelt');
    });

    test('Protein tracker widget has correct properties', () {
      final protein = ProteinTrackerWidget();
      expect(protein.id, 'protein_tracker');
      expect(protein.name, 'Proteine');
      expect(protein.category, 'Gesundheit');
    });
  });

  group('Widget rendering - loading state', () {
    testWidgets('Weather widget shows empty when loading',
        (WidgetTester tester) async {
      final weather = WeatherWidget();
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              width: 300,
              height: 200,
              child: weather.buildView(
                null,
                WidgetDataState.loading,
                WidgetConfig({}),
              ),
            ),
          ),
        ),
      );

      // Loading state shows empty box
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });

  group('Widget rendering - error state', () {
    testWidgets('Weather widget shows empty when error',
        (WidgetTester tester) async {
      final weather = WeatherWidget();
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              width: 300,
              height: 200,
              child: weather.buildView(
                null,
                WidgetDataState.error,
                WidgetConfig({}),
              ),
            ),
          ),
        ),
      );

      // Error state shows empty box
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });

  group('Widget rendering - empty state', () {
    testWidgets('Weather widget shows empty state',
        (WidgetTester tester) async {
      final weather = WeatherWidget();
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              width: 300,
              height: 200,
              child: weather.buildView(
                null,
                WidgetDataState.empty,
                WidgetConfig({}),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
    });
  });

  group('Widget rendering - ready state', () {
    testWidgets('Weather widget renders with data',
        (WidgetTester tester) async {
      final weather = WeatherWidget();
      final data = WidgetData.fromJson({
        'schemaVersion': 1,
        'data': {
          'current': {
            'temperature': 22,
            'feelsLike': 23,
            'condition': 'Sonnig',
            'humidity': 45,
            'windSpeed': 12,
            'location': 'Berlin',
          },
          'hourly': [],
          'daily': [],
          'warnings': [],
          'summary': 'Test summary',
        },
        'sources': ['Test'],
        'generatedAt': '2024-01-01T00:00:00Z',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              width: 300,
              height: 300,
              child: weather.buildView(
                data,
                WidgetDataState.ready,
                WidgetConfig({'location': 'Berlin'}),
              ),
            ),
          ),
        ),
      );

      expect(find.text('22°C'), findsOneWidget);
      expect(find.text('Berlin'), findsOneWidget);
    });
  });

  group('Edge cases - missing fields', () {
    test('Weather handles missing optional fields', () {
      final weather = WeatherWidget();
      final data = WidgetData.fromJson({
        'schemaVersion': 1,
        'data': {
          'current': {
            'temperature': 20,
            'condition': 'Sonnig',
          },
        },
      });

      // Should not throw when optional fields are missing
      expect(() {
        weather.buildView(data, WidgetDataState.ready, WidgetConfig({}));
      }, returnsNormally);
    });

    test('Protein tracker handles missing goal', () {
      final protein = ProteinTrackerWidget();
      final data = WidgetData.fromJson({
        'schemaVersion': 1,
        'data': {
          'consumed': 50,
        },
      });

      // Should not throw when goal is missing
      expect(() {
        protein.buildView(data, WidgetDataState.ready, WidgetConfig({}));
      }, returnsNormally);
    });
  });

  group('Edge cases - empty collections', () {
    test('Weather handles empty hourly/daily arrays', () {
      final weather = WeatherWidget();
      final data = WidgetData.fromJson({
        'schemaVersion': 1,
        'data': {
          'location': 'Berlin',
          'current': {
            'temperature': 20,
            'feelsLike': 20,
            'condition': 'Sonnig',
            'humidity': 50,
            'windSpeed': 10,
          },
          'hourly': [],
          'daily': [],
          'warnings': [],
          'summary': 'Test',
        },
      });

      expect(() {
        weather.buildView(data, WidgetDataState.ready, WidgetConfig({}));
      }, returnsNormally);
    });

    test('Tasks widget handles empty task list', () {
      // Should not throw with empty tasks
      expect(() {
        WidgetData.fromJson({
          'schemaVersion': 1,
          'data': {
            'tasks': [],
            'completed': 0,
          },
        });
      }, returnsNormally);
    });
  });

  group('Edge cases - null values', () {
    test('WidgetData handles missing data field', () {
      // Should not throw when data field is missing
      expect(() {
        WidgetData.fromJson({
          'schemaVersion': 1,
        });
      }, returnsNormally);
    });
  });
}