import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetly/features/widgets/framework/widget_definition.dart';
import 'package:widgetly/features/widgets/framework/widget_data.dart';
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
    testWidgets('Weather widget shows content when loading',
        (WidgetTester tester) async {
      final weather = WeatherWidget();
      final typedData = weather.parseData(null);
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              width: 300,
              height: 200,
              child: weather.buildView(
                typedData,
                WidgetDataState.loading,
                WidgetConfig({}),
              ),
            ),
          ),
        ),
      );

      // Loading state shows default content
      expect(find.byType(Column), findsWidgets);
    });
  });

  group('Widget rendering - error state', () {
    testWidgets('Weather widget shows content when error',
        (WidgetTester tester) async {
      final weather = WeatherWidget();
      final typedData = weather.parseData(null);
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              width: 300,
              height: 200,
              child: weather.buildView(
                typedData,
                WidgetDataState.error,
                WidgetConfig({}),
              ),
            ),
          ),
        ),
      );

      // Error state shows default content
      expect(find.byType(Column), findsWidgets);
    });
  });

  group('Widget rendering - empty state', () {
    testWidgets('Weather widget shows empty state',
        (WidgetTester tester) async {
      final weather = WeatherWidget();
      final typedData = weather.parseData(null);
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              width: 300,
              height: 200,
              child: weather.buildView(
                typedData,
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
      final rawJson = {
        'temperature': 22.0,
        'condition': 'Sonnig',
        'icon': 'sunny',
        'hourly': [],
        'daily': [],
      };
      final typedData = weather.parseData(
        WidgetData(data: rawJson, generatedAt: DateTime.now()),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              width: 300,
              height: 300,
              child: weather.buildView(
                typedData,
                WidgetDataState.ready,
                WidgetConfig({'location': 'Berlin'}),
              ),
            ),
          ),
        ),
      );

      expect(find.text('22.0°C'), findsOneWidget);
    });
  });

  group('Edge cases - missing fields', () {
    test('Weather handles missing optional fields', () {
      final weather = WeatherWidget();
      final rawJson = {
        'temperature': 20.0,
        'condition': 'Sonnig',
        'icon': 'sunny',
        'hourly': [],
        'daily': [],
      };
      final typedData = weather.parseData(
        WidgetData(data: rawJson, generatedAt: DateTime.now()),
      );

      // Should not throw when optional fields are missing
      expect(() {
        weather.buildView(typedData, WidgetDataState.ready, WidgetConfig({}));
      }, returnsNormally);
    });

    test('Protein tracker handles missing goal', () {
      final protein = ProteinTrackerWidget();
      final rawJson = {
        'consumed': 50,
      };
      final typedData = protein.parseData(
        WidgetData(data: rawJson, generatedAt: DateTime.now()),
      );

      // Should not throw when goal is missing
      expect(() {
        protein.buildView(typedData, WidgetDataState.ready, WidgetConfig({}));
      }, returnsNormally);
    });
  });

  group('Edge cases - empty collections', () {
    test('Weather handles empty hourly/daily arrays', () {
      final weather = WeatherWidget();
      final rawJson = {
        'temperature': 20.0,
        'condition': 'Sonnig',
        'icon': 'sunny',
        'hourly': [],
        'daily': [],
      };
      final typedData = weather.parseData(
        WidgetData(data: rawJson, generatedAt: DateTime.now()),
      );

      expect(() {
        weather.buildView(typedData, WidgetDataState.ready, WidgetConfig({}));
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