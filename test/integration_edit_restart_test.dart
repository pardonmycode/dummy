import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:widgetly/features/dashboard/domain/dashboard.dart';
import 'package:widgetly/features/widgets/framework/widget_instance.dart';
import 'package:widgetly/features/widgets/framework/widget_definition.dart';

void main() {
  group('Integration: edit-add-move-resize-restart', () {
    test('Layout survives restart after add, move, resize', () {
      // Start with empty dashboard
      var dashboard = const Dashboard(
        id: 'test-dashboard',
        name: 'Test Dashboard',
      );

      // Add widgets
      const weather = WidgetInstance(
        widgetType: 'weather',
        size: WidgetSize.small,
      );
      const steps = WidgetInstance(
        widgetType: 'steps_tracker',
        size: WidgetSize.medium,
      );
      const water = WidgetInstance(
        widgetType: 'water_tracker',
        size: WidgetSize.large,
      );

      // Add by creating new dashboard with widgets list
      dashboard = dashboard.copyWith(widgets: [weather, steps, water]);

      expect(dashboard.widgets.length, 3);

      // Move widget: move steps to end (index 2)
      final widgets = dashboard.widgets.toList();
      final stepsWidget = widgets.removeAt(1);
      widgets.add(stepsWidget);
      dashboard = dashboard.copyWith(widgets: widgets);

      expect(dashboard.widgets[0].id, weather.id);
      expect(dashboard.widgets[1].id, water.id);
      expect(dashboard.widgets[2].id, steps.id);

      // Resize widget
      final resizedWidgets = dashboard.widgets.map((w) {
        if (w.id == steps.id) {
          return w.copyWith(size: WidgetSize.large);
        }
        return w;
      }).toList();
      dashboard = dashboard.copyWith(widgets: resizedWidgets);

      expect(dashboard.widgets[2].size, WidgetSize.large);

      // Serialize to JSON (restart)
      final jsonStr = jsonEncode(dashboard.toJson());

      // Restart: deserialize from JSON
      final restored = Dashboard.fromJson(jsonDecode(jsonStr));

      // Verify layout survived restart
      expect(restored.widgets.length, 3);
      expect(restored.widgets[0].id, weather.id);
      expect(restored.widgets[1].id, water.id);
      expect(restored.widgets[2].id, steps.id);
      expect(restored.widgets[2].size, WidgetSize.large);
    });
  });
}
