import 'package:material_ui/material_ui.dart';
import 'package:widgetly/features/widgets/framework/widget_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart' as fl;
import 'package:widgetly/features/widgets/framework/widget_definition.dart';
import 'package:widgetly/features/widgets/ui/types/body_fat/body_fat_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/heart_rate/heart_rate_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/mood/mood_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/tasks/tasks_widget.dart';
import "package:widgetly/features/dashboard/ui/views/providers.dart";
import 'package:widgetly/core/i18n/app_localizations.dart';
import 'test_helpers.dart';

void main() {
  setUp(setupTestEnvironment);
  tearDown(teardownTestEnvironment);

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

  testWidgets('Body Fat widget renders', (tester) async {
    final bodyFat = BodyFatTrackerWidget();
    final rawJson = {'current': 22.5, 'goal': 18.0, 'start': 25.0, 'trend': 'down'};
    final typedData = bodyFat.parseData(
      WidgetData(data: rawJson, generatedAt: DateTime.now()),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          fl.GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) {
            return Material(
              child: SizedBox(
                width: 300,
                height: 200,
                child: bodyFat.buildView(
                  context,
                  typedData,
                  WidgetDataState.ready,
                  const WidgetConfig({}),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('22.5%'), findsOneWidget);
    expect(find.text('Body fat decreasing'), findsOneWidget);
  });

  testWidgets('Heart Rate widget renders', (tester) async {
    final heartRate = HeartRateTrackerWidget();
    final rawJson = {'current': 72, 'resting': 62, 'max': 145, 'trend': 'down'};
    final typedData = heartRate.parseData(
      WidgetData(data: rawJson, generatedAt: DateTime.now()),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          fl.GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) {
            return Material(
              child: SizedBox(
                width: 300,
                height: 200,
                child: heartRate.buildView(
                  context,
                  typedData,
                  WidgetDataState.ready,
                  const WidgetConfig({}),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('72 bpm'), findsOneWidget);
    expect(find.text('Resting heart rate improving'), findsOneWidget);
  });

  testWidgets('Mood widget renders', (tester) async {
    final mood = MoodTrackerWidget();
    final rawJson = {
      'mood': 4,
      'note': 'Fühle mich gut',
      'week': [3, 4, 5, 4, 3, 4, 4],
    };
    final typedData = mood.parseData(
      WidgetData(data: rawJson, generatedAt: DateTime.now()),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          fl.GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) {
            return Material(
              child: SizedBox(
                width: 300,
                height: 200,
                child: mood.buildView(
                  context,
                  typedData,
                  WidgetDataState.ready,
                  const WidgetConfig({}),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Good'), findsOneWidget);
    expect(find.text('Good'), findsOneWidget);
  });

  testWidgets('Tasks widget renders', (tester) async {
    final tasks = TasksWidget();
    final rawJson = {
      'tasks': [
        {'title': 'Einkaufen', 'time': '10:00', 'priority': 'high'},
        {'title': 'Bericht', 'time': '12:00'},
      ],
      'completed': 1,
    };
    final typedData = tasks.parseData(
      WidgetData(data: rawJson, generatedAt: DateTime.now()),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          fl.GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) {
            return Material(
              child: SizedBox(
                width: 300,
                height: 300,
                child: tasks.buildView(
                  context,
                  typedData,
                  WidgetDataState.ready,
                  const WidgetConfig({}),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Einkaufen'), findsOneWidget);
    expect(find.text('Important'), findsOneWidget);
  });

  test('Dashboard registry contains all widgets', () {
    final container = ProviderContainer();
    final registry = container.read(widgetRegistryProvider);

    expect(registry.contains('body_fat_tracker'), isTrue);
    expect(registry.contains('heart_rate_tracker'), isTrue);
    expect(registry.contains('mood_tracker'), isTrue);
    expect(registry.contains('tasks'), isTrue);
    expect(registry.contains('stress_tracker'), isTrue);
    expect(registry.contains('screen_time_tracker'), isTrue);
    expect(registry.contains('medications_tracker'), isTrue);
    expect(registry.contains('calendar'), isTrue);
    expect(registry.contains('quick_notes'), isTrue);
    expect(registry.contains('fat_tracker'), isTrue);
    expect(registry.contains('calories_tracker'), isTrue);
    expect(registry.contains('fiber_tracker'), isTrue);
    expect(registry.contains('sugar_tracker'), isTrue);
    expect(registry.contains('caffeine_tracker'), isTrue);
    expect(registry.contains('active_minutes_tracker'), isTrue);
    expect(registry.contains('distance_tracker'), isTrue);
    expect(registry.contains('custom_tracker'), isTrue);

    // Should have 26 widgets total (6 original + 20 new)
    expect(registry.getAll().length, 26);

    container.dispose();
  });
}