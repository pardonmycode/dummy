import 'package:material_ui/material_ui.dart' as flutter;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
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
  late WidgetRegistry registry;

  setUp(() {
    registry = WidgetRegistry();
    registry.register(WeatherWidget());
    registry.register(StepsTrackerWidget());
    registry.register(ProteinTrackerWidget());
    registry.register(PartiesWidget());
    registry.register(WaterTrackerWidget());
  });

  group('Golden tests - widget rendering', () {
    testWidgets('Weather widget renders at medium size', (tester) async {
      final instance = WidgetInstance(
        widgetType: 'weather',
        size: WidgetSize.medium,
        config: {'location': 'Berlin'},
      );
      final definition = registry.get('weather')!;
      final data = WidgetData.fromJson({
        'current': {'temperature': 25, 'condition': 'sunny'},
      });

      await tester.pumpWidget(
        flutter.MaterialApp(
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
      );

      expect(find.byType(WidgetCard), findsOneWidget);
    });

    testWidgets('Steps widget renders at medium size', (tester) async {
      final instance = WidgetInstance(
        widgetType: 'steps_tracker',
        size: WidgetSize.medium,
      );
      final definition = registry.get('steps_tracker')!;
      final data = WidgetData.fromJson({
        'steps': 8500,
        'goal': 10000,
      });

      await tester.pumpWidget(
        flutter.MaterialApp(
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
      );

      expect(find.byType(WidgetCard), findsOneWidget);
    });

    testWidgets('Protein widget renders at medium size', (tester) async {
      final instance = WidgetInstance(
        widgetType: 'protein_tracker',
        size: WidgetSize.medium,
      );
      final definition = registry.get('protein_tracker')!;
      final data = WidgetData.fromJson({
        'consumed': 120,
        'goal': 150,
      });

      await tester.pumpWidget(
        flutter.MaterialApp(
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
      );

      expect(find.byType(WidgetCard), findsOneWidget);
    });

    testWidgets('Parties widget renders at large size', (tester) async {
      final instance = WidgetInstance(
        widgetType: 'parties',
        size: WidgetSize.large,
      );
      final definition = registry.get('parties')!;
      final data = WidgetData.fromJson({
        'events': [
          {
            'name': 'Club Night',
            'venue': 'Kraftwerk',
            'time': '22:00',
            'lat': 52.51,
            'lng': 13.39,
          },
        ],
      });

      await tester.pumpWidget(
        flutter.MaterialApp(
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
      );

      expect(find.byType(WidgetCard), findsOneWidget);
    });

    testWidgets('Water widget renders at medium size', (tester) async {
      final instance = WidgetInstance(
        widgetType: 'water_tracker',
        size: WidgetSize.medium,
      );
      final definition = registry.get('water_tracker')!;
      final data = WidgetData.fromJson({
        'consumed': 1250,
        'goal': 2000,
      });

      await tester.pumpWidget(
        flutter.MaterialApp(
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
      );

      expect(find.byType(WidgetCard), findsOneWidget);
    });
  });
}
