import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetly/core/i18n/app_localizations.dart';
import 'package:widgetly/features/widgets/framework/widget_definition.dart';
import 'package:widgetly/features/widgets/framework/widget_data.dart';
import 'package:widgetly/features/widgets/weather/data/weather_data.dart';
import 'package:widgetly/features/widgets/ui/types/weather/weather_widget.dart';

void main() {
  group('WidgetDefinition<T> generic typing', () {
    test('WeatherWidget uses typed WeatherData model', () {
      final widget = WeatherWidget();

      // Build raw WidgetData
      final rawJson = {
        'temperature': 25.0,
        'condition': 'sunny',
        'icon': 'sunny',
        'hourly': [
          {'time': '14:00', 'temp': 25.0, 'icon': 'sunny'},
          {'time': '15:00', 'temp': 24.0, 'icon': 'sunny'},
        ],
        'daily': [
          {'date': 'today', 'high': 27.0, 'low': 18.0, 'icon': 'sunny'},
        ],
      };

      final widgetData = WidgetData(
        data: rawJson,
        generatedAt: DateTime.now(),
      );

      // Parse to typed model
      final typedData = widget.parseData(widgetData);

      // Verify it's a typed WeatherData object
      expect(typedData, isA<WeatherData>());
      expect(typedData.temperature, 25.0);
      expect(typedData.condition, 'sunny');
      expect(typedData.hourly.length, 2);
      expect(typedData.daily.length, 1);
    });

    testWidgets('buildView receives typed data', (tester) async {
      final widget = WeatherWidget();
      const typedData = WeatherData(
        temperature: 20.0,
        condition: 'cloudy',
        icon: 'cloudy',
        hourly: [],
        daily: [],
      );

      // Pump a widget with a Builder to get context
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final view = widget.buildView(
                context,
                typedData,
                WidgetDataState.ready,
                const WidgetConfig(),
              );
              return view;
            },
          ),
        ),
      );

      // Wait for async localization loading
      await tester.pump();
      await tester.pump();

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    test('parseData handles empty data gracefully', () {
      final widget = WeatherWidget();
      final emptyData = WidgetData(
        data: {},
        generatedAt: DateTime.now(),
      );

      // Should not throw on empty data
      expect(() => widget.parseData(emptyData), isNot(throwsException));
    });
  });
}