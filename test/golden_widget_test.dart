import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart' as fl;
import 'package:widgetly/core/i18n/app_localizations.dart';
import 'package:widgetly/features/widgets/framework/widget_data.dart';
import 'package:widgetly/features/widgets/framework/widget_definition.dart';
import 'package:widgetly/features/widgets/framework/widget_instance.dart';
import 'package:widgetly/features/widgets/framework/widget_registry.dart';
import 'package:widgetly/features/widgets/ui/base/widget_card.dart';
import 'package:widgetly/features/widgets/ui/types/weather/weather_widget.dart';
import 'package:widgetly/features/widgets/ui/types/steps/steps_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/protein/protein_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/parties/parties_widget.dart';
import 'package:widgetly/features/widgets/ui/types/water/water_tracker_widget.dart';

void main() {
  testWidgets('Weather widget renders at medium size', (tester) async {
    final registry = WidgetRegistry();
    registry.register(WeatherWidget());

    const instance = WidgetInstance(
      widgetType: 'weather',
      size: WidgetSize.medium,
      config: {'location': 'Berlin'},
    );
    final definition = registry.get('weather')!;
    final data = WidgetData.fromJson({
      'schemaVersion': 1,
      'data': {
        'temperature': 25.0,
        'condition': 'sunny',
        'icon': 'sunny',
        'hourly': [],
        'daily': [],
      },
      'generatedAt': '2026-01-01T00:00:00.000Z',
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            fl.GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 300,
              child: WidgetCard(
                definition: definition,
                instance: instance,
                data: data,
                state: WidgetDataState.ready,
                config: WidgetConfig(instance.config),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(Container), findsWidgets);
  });

  testWidgets('Steps widget renders at medium size', (tester) async {
    final registry = WidgetRegistry();
    registry.register(StepsTrackerWidget());

    const instance = WidgetInstance(
      widgetType: 'steps_tracker',
      size: WidgetSize.medium,
    );
    final definition = registry.get('steps_tracker')!;
    final data = WidgetData.fromJson({
      'schemaVersion': 1,
      'data': {
        'steps': 8500,
        'goal': 10000,
      },
      'generatedAt': '2026-01-01T00:00:00.000Z',
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            fl.GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 300,
              child: WidgetCard(
                definition: definition,
                instance: instance,
                data: data,
                state: WidgetDataState.ready,
                config: WidgetConfig(instance.config),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(Container), findsWidgets);
  });

  testWidgets('Protein widget renders at medium size', (tester) async {
    final registry = WidgetRegistry();
    registry.register(ProteinTrackerWidget());

    const instance = WidgetInstance(
      widgetType: 'protein_tracker',
      size: WidgetSize.medium,
    );
    final definition = registry.get('protein_tracker')!;
    final data = WidgetData.fromJson({
      'schemaVersion': 1,
      'data': {
        'consumed': 120,
        'goal': 150,
      },
      'generatedAt': '2026-01-01T00:00:00.000Z',
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            fl.GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 300,
              child: WidgetCard(
                definition: definition,
                instance: instance,
                data: data,
                state: WidgetDataState.ready,
                config: WidgetConfig(instance.config),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(Container), findsWidgets);
  });

  testWidgets('Parties widget renders at large size', (tester) async {
    final registry = WidgetRegistry();
    registry.register(PartiesWidget());

    const instance = WidgetInstance(
      widgetType: 'parties',
      size: WidgetSize.large,
    );
    final definition = registry.get('parties')!;
    final data = WidgetData.fromJson({
      'schemaVersion': 1,
      'data': {
        'events': [
          {
            'name': 'Club Night',
            'venue': 'Kraftwerk',
            'time': '22:00',
            'lat': 52.51,
            'lng': 13.39,
          },
        ],
      },
      'generatedAt': '2026-01-01T00:00:00.000Z',
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            fl.GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 400,
              child: WidgetCard(
                definition: definition,
                instance: instance,
                data: data,
                state: WidgetDataState.ready,
                config: WidgetConfig(instance.config),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(Container), findsWidgets);
  });

  testWidgets('Water widget renders at medium size', (tester) async {
    final registry = WidgetRegistry();
    registry.register(WaterTrackerWidget());

    const instance = WidgetInstance(
      widgetType: 'water_tracker',
      size: WidgetSize.medium,
    );
    final definition = registry.get('water_tracker')!;
    final data = WidgetData.fromJson({
      'schemaVersion': 1,
      'data': {
        'consumed': 1250,
        'goal': 2000,
      },
      'generatedAt': '2026-01-01T00:00:00.000Z',
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            fl.GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 300,
              child: WidgetCard(
                definition: definition,
                instance: instance,
                data: data,
                state: WidgetDataState.ready,
                config: WidgetConfig(instance.config),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(Container), findsWidgets);
  });
}