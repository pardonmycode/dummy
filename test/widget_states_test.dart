import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart' as fl;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widgetly/core/i18n/app_localizations.dart';
import "package:widgetly/features/dashboard/ui/views/providers.dart";
import 'package:widgetly/features/widgets/framework/widget_definition.dart';
import 'package:widgetly/features/widgets/framework/widget_data.dart';
import 'package:widgetly/features/widgets/ui/types/protein/protein_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/weather/weather_widget.dart';
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
    testWidgets('Weather widget shows content when loading', (tester) async {
      final weather = WeatherWidget();
      final typedData = weather.parseData(null);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            fl.GlobalMaterialLocalizations.delegate,
            fl.GlobalWidgetsLocalizations.delegate,
            fl.GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) {
              return Material(
                child: SizedBox(
                  width: 300,
                  height: 200,
                  child: weather.buildView(
                    context,
                    typedData,
                    WidgetDataState.loading,
                    const WidgetConfig({}),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Loading state shows default content
      expect(find.byType(Column), findsWidgets);
    });
  });

  group('Widget rendering - error state', () {
    testWidgets('Weather widget shows content when error', (tester) async {
      final weather = WeatherWidget();
      final typedData = weather.parseData(null);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            fl.GlobalMaterialLocalizations.delegate,
            fl.GlobalWidgetsLocalizations.delegate,
            fl.GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) {
              return Material(
                child: SizedBox(
                  width: 300,
                  height: 200,
                  child: weather.buildView(
                    context,
                    typedData,
                    WidgetDataState.error,
                    const WidgetConfig({}),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Error state shows default content
      expect(find.byType(Column), findsWidgets);
    });
  });

  group('Widget rendering - empty state', () {
    testWidgets('Weather widget shows empty state', (tester) async {
      final weather = WeatherWidget();
      final typedData = weather.parseData(null);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            fl.GlobalMaterialLocalizations.delegate,
            fl.GlobalWidgetsLocalizations.delegate,
            fl.GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) {
              return Material(
                child: SizedBox(
                  width: 300,
                  height: 200,
                  child: weather.buildView(
                    context,
                    typedData,
                    WidgetDataState.empty,
                    const WidgetConfig({}),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsOneWidget);
    });
  });

  group('Widget rendering - ready state', () {
    testWidgets('Weather widget renders with data', (tester) async {
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
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            fl.GlobalMaterialLocalizations.delegate,
            fl.GlobalWidgetsLocalizations.delegate,
            fl.GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) {
              return Material(
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: weather.buildView(
                    context,
                    typedData,
                    WidgetDataState.ready,
                    const WidgetConfig({'location': 'Berlin'}),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('22.0°C'), findsOneWidget);
    });
  });

  group('Edge cases - missing fields', () {
    testWidgets('Weather handles missing optional fields', (tester) async {
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
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            fl.GlobalMaterialLocalizations.delegate,
            fl.GlobalWidgetsLocalizations.delegate,
            fl.GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) {
              return Material(
                child: weather.buildView(
                  context,
                  typedData,
                  WidgetDataState.ready,
                  const WidgetConfig({}),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Material), findsOneWidget);
    });

    testWidgets('Protein tracker handles missing goal', (tester) async {
      final protein = ProteinTrackerWidget();
      final rawJson = {
        'consumed': 50,
      };
      final typedData = protein.parseData(
        WidgetData(data: rawJson, generatedAt: DateTime.now()),
      );

      // Should not throw when goal is missing
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            fl.GlobalMaterialLocalizations.delegate,
            fl.GlobalWidgetsLocalizations.delegate,
            fl.GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) {
              return Material(
                child: protein.buildView(
                  context,
                  typedData,
                  WidgetDataState.ready,
                  const WidgetConfig({}),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Material), findsOneWidget);
    });
  });

  group('Edge cases - empty collections', () {
    testWidgets('Weather handles empty hourly/daily arrays', (tester) async {
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

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            fl.GlobalMaterialLocalizations.delegate,
            fl.GlobalWidgetsLocalizations.delegate,
            fl.GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) {
              return Material(
                child: weather.buildView(
                  context,
                  typedData,
                  WidgetDataState.ready,
                  const WidgetConfig({}),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Material), findsOneWidget);
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