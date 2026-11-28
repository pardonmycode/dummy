import 'package:flutter_test/flutter_test.dart';
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

    test('buildView receives typed data', () {
      final widget = WeatherWidget();
      final typedData = WeatherData(
        temperature: 20.0,
        condition: 'cloudy',
        icon: 'cloudy',
        hourly: [],
        daily: [],
      );

      // Should build without error
      final view = widget.buildView(
        typedData,
        WidgetDataState.ready,
        WidgetConfig(),
      );

      expect(view, isNotNull);
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
