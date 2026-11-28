import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widgetly/features/dashboard/ui/views/dashboard_view.dart';
import 'package:widgetly/features/widgets/framework/widget_instance.dart';

void main() {
  group('Widget move operations', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('move widget down by one position works', () {
      final widgets = [
        const WidgetInstance(id: 'a', widgetType: 'weather'),
        const WidgetInstance(id: 'b', widgetType: 'steps_tracker'),
        const WidgetInstance(id: 'c', widgetType: 'water_tracker'),
      ];
      container.read(dashboardWidgetsProvider.notifier).setWidgets(widgets);

      // Move 'a' to position 1 (down by one)
      // ReorderableListView gives newIndex=2 when dropping after item at index 1
      // (because the dragged item is removed from the list before onReorder fires)
      container.read(dashboardWidgetsProvider.notifier).moveWidget(0, 1);

      final result = container.read(dashboardWidgetsProvider);
      expect(result[0].id, 'b', reason: 'Widget at index 0 should be b');
      expect(result[1].id, 'a', reason: 'Widget at index 1 should be a');
      expect(result[2].id, 'c', reason: 'Widget at index 2 should be c');
    });

    test('move widget up by one position works', () {
      final widgets = [
        const WidgetInstance(id: 'a', widgetType: 'weather'),
        const WidgetInstance(id: 'b', widgetType: 'steps_tracker'),
        const WidgetInstance(id: 'c', widgetType: 'water_tracker'),
      ];
      container.read(dashboardWidgetsProvider.notifier).setWidgets(widgets);

      // Move 'b' up to position 0
      container.read(dashboardWidgetsProvider.notifier).moveWidget(1, 0);

      final result = container.read(dashboardWidgetsProvider);
      expect(result[0].id, 'b', reason: 'Widget at index 0 should be b');
      expect(result[1].id, 'a', reason: 'Widget at index 1 should be a');
      expect(result[2].id, 'c', reason: 'Widget at index 2 should be c');
    });

    test('move widget to end works', () {
      final widgets = [
        const WidgetInstance(id: 'a', widgetType: 'weather'),
        const WidgetInstance(id: 'b', widgetType: 'steps_tracker'),
        const WidgetInstance(id: 'c', widgetType: 'water_tracker'),
      ];
      container.read(dashboardWidgetsProvider.notifier).setWidgets(widgets);

      // Move 'a' to the end
      container.read(dashboardWidgetsProvider.notifier).moveWidget(0, 2);

      final result = container.read(dashboardWidgetsProvider);
      expect(result[0].id, 'b');
      expect(result[1].id, 'c');
      expect(result[2].id, 'a', reason: 'Widget at end should be a');
    });

    test('move widget to beginning works', () {
      final widgets = [
        const WidgetInstance(id: 'a', widgetType: 'weather'),
        const WidgetInstance(id: 'b', widgetType: 'steps_tracker'),
        const WidgetInstance(id: 'c', widgetType: 'water_tracker'),
      ];
      container.read(dashboardWidgetsProvider.notifier).setWidgets(widgets);

      // Move 'c' to the beginning
      container.read(dashboardWidgetsProvider.notifier).moveWidget(2, 0);

      final result = container.read(dashboardWidgetsProvider);
      expect(result[0].id, 'c', reason: 'Widget at beginning should be c');
      expect(result[1].id, 'a');
      expect(result[2].id, 'b');
    });
  });
}
