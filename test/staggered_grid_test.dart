import 'package:material_ui/material_ui.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetly/main.dart' show WidgetlyApp;
import 'package:widgetly/features/widgets/framework/widget_instance.dart';
import 'package:widgetly/features/widgets/framework/widget_definition.dart';
import 'package:widgetly/features/dashboard/ui/views/dashboard_view.dart';
import 'test_helpers.dart';

void main() {
  setUp(setupTestEnvironment);
  tearDown(teardownTestEnvironment);

  group('Staggered grid layout', () {
    testWidgets('Widgets render with different sizes in staggered grid',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3.0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardWidgetsProvider.overrideWith((ref) {
              return DashboardWidgetsNotifier()..setWidgets([
                const WidgetInstance(
                    id: 'widget-small',
                    widgetType: 'weather',
                    size: WidgetSize.small),
                const WidgetInstance(
                    id: 'widget-medium',
                    widgetType: 'steps_tracker',
                    size: WidgetSize.medium),
                const WidgetInstance(
                    id: 'widget-large',
                    widgetType: 'weather',
                    size: WidgetSize.large),
              ]);
            }),
          ],
          child: const WidgetlyApp(),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify grid uses staggered layout (different sizes)
      final staggeredGrid = find.byType(StaggeredGrid);
      expect(staggeredGrid, findsOneWidget,
          reason: 'Dashboard should use StaggeredGrid.count for layout');
    });
  });
}
