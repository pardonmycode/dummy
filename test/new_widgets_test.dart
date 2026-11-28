import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart' as fl;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widgetly/core/i18n/app_localizations.dart';
import 'package:widgetly/features/dashboard/ui/views/dashboard_view.dart';
import 'package:widgetly/features/widgets/framework/mock_widget_data_provider.dart';
import 'package:widgetly/features/widgets/framework/widget_definition.dart';
import 'package:widgetly/features/widgets/framework/widget_data.dart';
import 'package:widgetly/features/widgets/ui/types/briefing/tagesbriefing_widget.dart';
import 'package:widgetly/features/widgets/ui/types/sleep/sleep_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/weight/weight_tracker_widget.dart';

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

  test('Sleep widget is registered and has correct properties', () {
    final sleep = SleepTrackerWidget();
    expect(sleep.id, 'sleep_tracker');
    expect(sleep.name, 'Schlaf');
    expect(sleep.category, 'Gesundheit');
    expect(sleep.defaultSize, WidgetSize.medium);
  });

  test('Weight widget is registered and has correct properties', () {
    final weight = WeightTrackerWidget();
    expect(weight.id, 'weight_tracker');
    expect(weight.name, 'Gewicht');
    expect(weight.category, 'Gesundheit');
    expect(weight.defaultSize, WidgetSize.medium);
  });

  test('Tagesbriefing widget is registered and has correct properties', () {
    final briefing = TagesbriefingWidget();
    expect(briefing.id, 'tagesbriefing');
    expect(briefing.name, 'Tagesbriefing');
    expect(briefing.category, 'Briefing');
    expect(briefing.defaultSize, WidgetSize.large);
    expect(
      briefing.supportedSizes,
      containsAll([WidgetSize.medium, WidgetSize.large]),
    );
  });

  testWidgets('Sleep widget renders with data', (tester) async {
    final sleep = SleepTrackerWidget();
    final rawJson = {
      'goal': 8,
      'slept': 7.5,
      'quality': 8,
    };
    final typedData = sleep.parseData(
      WidgetData(data: rawJson, generatedAt: DateTime.now()),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          fl.GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Builder(
          builder: (context) {
            return Material(
              child: SizedBox(
                width: 300,
                height: 200,
                child: sleep.buildView(
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

    expect(find.text('7.5h von 8h'), findsOneWidget);
    expect(find.text('Qualität: 8/10'), findsOneWidget);
  });

  testWidgets('Weight widget renders with data', (tester) async {
    final weight = WeightTrackerWidget();
    final rawJson = {
      'current': 82.5,
      'goal': 75.0,
      'start': 85.0,
      'trend': 'down',
      'lastChange': '-0.5 kg letzte Woche',
    };
    final typedData = weight.parseData(
      WidgetData(data: rawJson, generatedAt: DateTime.now()),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          fl.GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Builder(
          builder: (context) {
            return Material(
              child: SizedBox(
                width: 300,
                height: 200,
                child: weight.buildView(
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

    expect(find.text('82.5 kg'), findsOneWidget);
    expect(find.text('Gewichtsabnahme'), findsOneWidget);
  });

  testWidgets('Tagesbriefing widget renders with data', (tester) async {
    final briefing = TagesbriefingWidget();
    final rawJson = {
      'summary': 'Guter Tag!',
      'weather': 'Sonnig, 22°C',
      'appointments': [
        {'title': '10:00 - Meeting'},
      ],
      'tasks': [
        {'title': 'Einkaufen'},
      ],
      'news': [],
    };
    final typedData = briefing.parseData(
      WidgetData(data: rawJson, generatedAt: DateTime.now()),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          fl.GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Builder(
          builder: (context) {
            return Material(
              child: SizedBox(
                width: 300,
                height: 400,
                child: briefing.buildView(
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

    expect(find.text('Guter Tag!'), findsOneWidget);
    expect(find.text('Sonnig, 22°C'), findsOneWidget);
    expect(find.text('10:00 - Meeting'), findsOneWidget);
    expect(find.text('Einkaufen'), findsOneWidget);
  });

  test('Dashboard registry contains all new widgets', () {
    final container = ProviderContainer();
    final registry = container.read(widgetRegistryProvider);

    expect(registry.contains('sleep_tracker'), isTrue);
    expect(registry.contains('weight_tracker'), isTrue);
    expect(registry.contains('tagesbriefing'), isTrue);
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

  test('Mock data provider returns correct data for new widgets', () async {
    final provider = MockWidgetDataProvider();

    final sleepData = await provider.getData('sleep_tracker', null);
    expect(sleepData['data']['goal'], 8);
    expect(sleepData['data']['slept'], 7.5);

    final weightData = await provider.getData('weight_tracker', null);
    expect(weightData['data']['current'], 82.5);
    expect(weightData['data']['trend'], 'down');

    final briefingData = await provider.getData('tagesbriefing', null);
    expect(briefingData['data']['summary'], isNotEmpty);
    expect(briefingData['data']['appointments'].length, 2);
  });
}