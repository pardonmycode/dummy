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
    // Wait for AsyncNotifier to initialize
    await container.read(dashboardNotifierProvider.future);
  });

  tearDown(() {
    container.dispose();
    SharedPreferences.setMockInitialValues({});
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

      notifier.addActiveWidget(WidgetInstance.create(widgetType: 'weather'));
      expect(notifier.activeDashboard!.widgets.length, initial + 1);

      notifier.undo();
      expect(notifier.activeDashboard!.widgets.length, initial);

      notifier.redo();
      expect(notifier.activeDashboard!.widgets.length, initial + 1);
    });

    test('can move widget within active dashboard', () {
      final notifier = container.read(dashboardNotifierProvider.notifier);
      notifier.addActiveWidget(WidgetInstance.create(widgetType: 'weather'));
      notifier.addActiveWidget(WidgetInstance.create(widgetType: 'steps_tracker'));
      notifier.addActiveWidget(WidgetInstance.create(widgetType: 'water_tracker'));

      final widgets = notifier.activeDashboard!.widgets;
      expect(widgets[widgets.length - 3].widgetType, 'weather');
      expect(widgets[widgets.length - 2].widgetType, 'steps_tracker');
      expect(widgets[widgets.length - 1].widgetType, 'water_tracker');

      notifier.moveActiveWidget(widgets.length - 3, widgets.length - 1);
      final moved = notifier.activeDashboard!.widgets;
      expect(moved[moved.length - 3].widgetType, 'steps_tracker');
      expect(moved[moved.length - 2].widgetType, 'water_tracker');
      expect(moved[moved.length - 1].widgetType, 'weather');
    });

    test('can remove active widget', () {
      final notifier = container.read(dashboardNotifierProvider.notifier);
      notifier.addActiveWidget(WidgetInstance.create(widgetType: 'weather'));
      notifier.addActiveWidget(WidgetInstance.create(widgetType: 'steps_tracker'));

      final initial = notifier.activeDashboard!.widgets.length;
      notifier.removeActiveWidget(initial - 2);
      expect(notifier.activeDashboard!.widgets.length, initial - 1);
      expect(notifier.activeDashboard!.widgets[initial - 2].widgetType, 'steps_tracker');
    });

    test('can set active dashboard', () async {
      final notifier = container.read(dashboardNotifierProvider.notifier);
      final newDash = await notifier.create('New Dashboard');
      notifier.setActive(newDash.id);
      expect(notifier.activeDashboard!.name, 'New Dashboard');
    });

    test('undo/redo is bounded to max steps', () {
      final notifier = container.read(dashboardNotifierProvider.notifier);
      final initial = notifier.activeDashboard!.widgets.length;
      notifier.addActiveWidget(WidgetInstance.create(widgetType: 'weather'));
      notifier.addActiveWidget(WidgetInstance.create(widgetType: 'steps'));
      notifier.addActiveWidget(WidgetInstance.create(widgetType: 'water'));
      notifier.addActiveWidget(WidgetInstance.create(widgetType: 'protein'));

      // Only last 3 should be undoable
      notifier.undo();
      notifier.undo();
      notifier.undo();
      expect(notifier.activeDashboard!.widgets.length, initial + 1);

      // Fourth undo goes back to initial state
      notifier.undo();
      expect(notifier.activeDashboard!.widgets.length, initial);
    });
  });
}
