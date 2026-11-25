import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetly/features/widgets/framework/widget_definition.dart';
import 'package:widgetly/features/widgets/ui/types/body_fat/body_fat_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/heart_rate/heart_rate_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/mood/mood_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/tasks/tasks_widget.dart';
import 'package:widgetly/features/dashboard/ui/views/dashboard_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      // Ignore
    }
  });

  test('Body Fat widget properties', () {
    final bodyFat = BodyFatTrackerWidget();
    expect(bodyFat.id, 'body_fat_tracker');
    expect(bodyFat.name, 'Körperfett');
    expect(bodyFat.category, 'Gesundheit');
  });

  test('Heart Rate widget properties', () {
    final heartRate = HeartRateTrackerWidget();
    expect(heartRate.id, 'heart_rate_tracker');
    expect(heartRate.name, 'Puls');
    expect(heartRate.category, 'Gesundheit');
  });

  test('Mood widget properties', () {
    final mood = MoodTrackerWidget();
    expect(mood.id, 'mood_tracker');
    expect(mood.name, 'Stimmung');
    expect(mood.category, 'Gesundheit');
  });

  test('Tasks widget properties', () {
    final tasks = TasksWidget();
    expect(tasks.id, 'tasks');
    expect(tasks.name, 'Aufgaben');
    expect(tasks.category, 'Produktivität');
  });

  testWidgets('Body Fat widget renders', (WidgetTester tester) async {
    final bodyFat = BodyFatTrackerWidget();
    final data = WidgetData.fromJson({
      'schemaVersion': 1,
      'data': {
        'current': 22.5,
        'goal': 18.0,
        'start': 25.0,
        'trend': 'down',
      },
      'sources': ['Lokale Einträge'],
      'generatedAt': '2024-01-01T00:00:00Z',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            width: 300,
            height: 200,
            child: bodyFat.buildView(data, WidgetDataState.ready, WidgetConfig({})),
          ),
        ),
      ),
    );

    expect(find.text('22.5%'), findsOneWidget);
    expect(find.text('Körperfett nimmt ab'), findsOneWidget);
  });

  testWidgets('Heart Rate widget renders', (WidgetTester tester) async {
    final heartRate = HeartRateTrackerWidget();
    final data = WidgetData.fromJson({
      'schemaVersion': 1,
      'data': {
        'current': 72,
        'resting': 62,
        'max': 145,
        'trend': 'down',
      },
      'sources': ['Apple Health'],
      'generatedAt': '2024-01-01T00:00:00Z',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            width: 300,
            height: 200,
            child: heartRate.buildView(data, WidgetDataState.ready, WidgetConfig({})),
          ),
        ),
      ),
    );

    expect(find.text('72 bpm'), findsOneWidget);
    expect(find.text('Ruhepuls verbessert sich'), findsOneWidget);
  });

  testWidgets('Mood widget renders', (WidgetTester tester) async {
    final mood = MoodTrackerWidget();
    final data = WidgetData.fromJson({
      'schemaVersion': 1,
      'data': {
        'mood': 4,
        'note': 'Fühle mich gut',
        'week': [3, 4, 5, 4, 3, 4, 4],
      },
      'sources': ['Lokale Einträge'],
      'generatedAt': '2024-01-01T00:00:00Z',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            width: 300,
            height: 200,
            child: mood.buildView(data, WidgetDataState.ready, WidgetConfig({})),
          ),
        ),
      ),
    );

    expect(find.text('Gut'), findsOneWidget);
    expect(find.text('Fühle mich gut'), findsOneWidget);
  });

  testWidgets('Tasks widget renders', (WidgetTester tester) async {
    final tasks = TasksWidget();
    final data = WidgetData.fromJson({
      'schemaVersion': 1,
      'data': {
        'tasks': [
          {'title': 'Einkaufen', 'time': '10:00', 'priority': 'high'},
          {'title': 'Bericht', 'time': '12:00'},
        ],
        'completed': 1,
      },
      'sources': ['Todo App'],
      'generatedAt': '2024-01-01T00:00:00Z',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            width: 300,
            height: 300,
            child: tasks.buildView(data, WidgetDataState.ready, WidgetConfig({})),
          ),
        ),
      ),
    );

    expect(find.text('Heute'), findsOneWidget);
    expect(find.text('Einkaufen'), findsOneWidget);
    expect(find.text('Wichtig'), findsOneWidget);
  });

  test('Dashboard registry contains all widgets', () {
    final container = ProviderContainer();
    final registry = container.read(widgetRegistryProvider);

    expect(registry.contains('body_fat_tracker'), isTrue);
    expect(registry.contains('heart_rate_tracker'), isTrue);
    expect(registry.contains('mood_tracker'), isTrue);
    expect(registry.contains('tasks'), isTrue);

    // Should have 13 widgets total (9 previous + 4 new)
    expect(registry.getAll().length, 13);

    container.dispose();
  });
}