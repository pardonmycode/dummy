import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetly/features/dashboard/ui/views/dashboard_view.dart';
import 'package:widgetly/features/widgets/framework/widget_instance.dart';

void main() {
  group('Template widget IDs', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('fitness template uses correct widget type IDs', () {
      // Simulate what the fitness template does
      final widgets = [
        WidgetInstance(widgetType: 'steps_tracker', config: {}),
        WidgetInstance(widgetType: 'protein_tracker', config: {'goal': 150}),
        WidgetInstance(widgetType: 'water_tracker', config: {}),
        WidgetInstance(widgetType: 'weight_tracker', config: {}),
      ];

      // All widget types should be recognized by the registry
      final registry = container.read(widgetRegistryProvider);
      for (final w in widgets) {
        final def = registry.get(w.widgetType);
        expect(
          def,
          isNotNull,
          reason: 'Widget type ${w.widgetType} should be registered',
        );
      }
    });
  });
}