import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widgetly/features/dashboard/domain/dashboard_notifier.dart';
import 'package:widgetly/features/widgets/framework/widget_instance.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer(
      overrides: [
        dashboardNotifierProvider.overrideWith(() => DashboardNotifier()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('DashboardNotifier', () {
    test('initializes with a default dashboard', () {
      final notifier = container.read(dashboardNotifierProvider.notifier);
      expect(notifier.dashboards.length, 1);
      expect(notifier.activeDashboard, isNotNull);
      expect(notifier.activeDashboard!.name, 'Mein Dashboard');
    });

    test('can add a widget and undo', () {
      final notifier = container.read(dashboardNotifierProvider.notifier);
      final initial = notifier.activeDashboard!.widgets.length;

      notifier.addActiveWidget(const WidgetInstance(widgetType: 'weather'));
      expect(notifier.activeDashboard!.widgets.length, initial + 1);

      notifier.undo();
      expect(notifier.activeDashboard!.widgets.length, initial);

      notifier.redo();
      expect(notifier.activeDashboard!.widgets.length, initial + 1);
    });

    test('can move widget within active dashboard', () {
      final notifier = container.read(dashboardNotifierProvider.notifier);
      notifier.addActiveWidget(const WidgetInstance(widgetType: 'weather'));
      notifier.addActiveWidget(const WidgetInstance(widgetType: 'steps_tracker'));
      notifier.addActiveWidget(const WidgetInstance(widgetType: 'water_tracker'));

      expect(notifier.activeDashboard!.widgets[0].widgetType, 'weather');
      expect(notifier.activeDashboard!.widgets[1].widgetType, 'steps_tracker');
      expect(notifier.activeDashboard!.widgets[2].widgetType, 'water_tracker');

      notifier.moveActiveWidget(0, 2);
      expect(notifier.activeDashboard!.widgets[0].widgetType, 'steps_tracker');
      expect(notifier.activeDashboard!.widgets[1].widgetType, 'water_tracker');
      expect(notifier.activeDashboard!.widgets[2].widgetType, 'weather');
    });

    test('can remove active widget', () {
      final notifier = container.read(dashboardNotifierProvider.notifier);
      notifier.addActiveWidget(const WidgetInstance(widgetType: 'weather'));
      notifier.addActiveWidget(const WidgetInstance(widgetType: 'steps_tracker'));

      notifier.removeActiveWidget(0);
      expect(notifier.activeDashboard!.widgets.length, 1);
      expect(notifier.activeDashboard!.widgets[0].widgetType, 'steps_tracker');
    });

    test('can set active dashboard', () async {
      final notifier = container.read(dashboardNotifierProvider.notifier);
      final newDash = await notifier.create('New Dashboard');
      notifier.setActive(newDash.id);
      expect(notifier.activeDashboard!.name, 'New Dashboard');
    });

    test('undo/redo is bounded to max steps', () {
      final notifier = container.read(dashboardNotifierProvider.notifier);
      notifier.addActiveWidget(const WidgetInstance(widgetType: 'weather'));
      notifier.addActiveWidget(const WidgetInstance(widgetType: 'steps'));
      notifier.addActiveWidget(const WidgetInstance(widgetType: 'water'));
      notifier.addActiveWidget(const WidgetInstance(widgetType: 'protein'));

      // Only last 3 should be undoable
      notifier.undo();
      notifier.undo();
      notifier.undo();
      expect(notifier.activeDashboard!.widgets.length, 1);

      // Fourth undo goes back to initial state (0 widgets)
      notifier.undo();
      expect(notifier.activeDashboard!.widgets.length, 0);
    });
  });
}
