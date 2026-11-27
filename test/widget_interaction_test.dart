import 'package:material_ui/material_ui.dart';
import 'package:material_ui/material_ui.dart' show GlobalMaterialLocalizations;
import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetly/features/widgets/framework/widget_definition.dart';
import 'package:widgetly/features/widgets/framework/widget_instance.dart';
import 'package:widgetly/features/dashboard/ui/views/dashboard_view.dart';
import 'package:widgetly/core/i18n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_helpers.dart';

void main() {
  setUp(setupTestEnvironment);
  tearDown(teardownTestEnvironment);

  group('Widget instance serialization', () {
    test('WidgetInstance can be serialized and deserialized', () {
      final instance = WidgetInstance(
        widgetType: 'weather',
        size: WidgetSize.medium,
        config: {'location': 'Berlin'},
      );

      final json = instance.toJson();
      final restored = WidgetInstance.fromJson(json);

      expect(restored.widgetType, 'weather');
      expect(restored.size, WidgetSize.medium);
      expect(restored.config['location'], 'Berlin');
    });

    test('WidgetInstance handles missing fields', () {
      // Should not throw with minimal data
      final instance = WidgetInstance.fromJson({
        'widgetType': 'weather',
      });

      expect(instance.widgetType, 'weather');
      expect(instance.config, isNotNull);
    });

    test('WidgetInstance clone creates new ID', () {
      final instance = WidgetInstance(
        widgetType: 'weather',
        config: {'location': 'Berlin'},
      );

      final clone = instance.clone();

      expect(clone.id, isNot(instance.id));
      expect(clone.widgetType, instance.widgetType);
      expect(clone.config['location'], instance.config['location']);
    });
  });

  group('Dashboard widgets notifier', () {
    test('Can add widget', () {
      final container = ProviderContainer();
      final notifier = container.read(dashboardWidgetsProvider.notifier);
      
      // Default has 2 widgets, adding 1 makes 3
      final initialCount = container.read(dashboardWidgetsProvider).length;
      notifier.addWidget('weather');
      expect(container.read(dashboardWidgetsProvider).length, initialCount + 1);
      expect(
        container.read(dashboardWidgetsProvider).last.widgetType,
        'weather',
      );

      container.dispose();
    });

    test('Can remove widget', () {
      final container = ProviderContainer();
      final notifier = container.read(dashboardWidgetsProvider.notifier);

      notifier.addWidget('weather');
      final id = container.read(dashboardWidgetsProvider).last.id;
      notifier.removeWidget(id);

      expect(
        container
            .read(dashboardWidgetsProvider)
            .any((w) => w.id == id),
        false,
      );

      container.dispose();
    });

    test('Can update widget config', () {
      final container = ProviderContainer();
      final notifier = container.read(dashboardWidgetsProvider.notifier);

      notifier.addWidget('weather', config: {'location': 'Berlin'});
      
      // Get widgets and update last one
      final widgets = container.read(dashboardWidgetsProvider);
      if (widgets.isNotEmpty) {
        final id = widgets.last.id;
        // Should not throw
        expect(() => notifier.updateConfig(id, {'location': 'München'}),
            returnsNormally);
      }

      container.dispose();
    });

    test('Can duplicate widget', () {
      final container = ProviderContainer();
      final notifier = container.read(dashboardWidgetsProvider.notifier);

      notifier.addWidget('weather');
      final widgets = container.read(dashboardWidgetsProvider);
      final id = widgets.last.id;
      notifier.duplicateWidget(id);

      expect(
        container
            .read(dashboardWidgetsProvider)
            .where((w) => w.widgetType == 'weather')
            .length,
        widgets.where((w) => w.widgetType == 'weather').length + 1,
      );

      container.dispose();
    });
  });

  group('Dashboard view integration', () {
    testWidgets('Dashboard renders without errors', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3.0;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('de')],
            home: DashboardView(),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should render without errors
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}