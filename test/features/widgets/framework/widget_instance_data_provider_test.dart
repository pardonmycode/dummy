import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetly/features/widgets/framework/mock_widget_data_repository.dart';
import 'package:widgetly/features/widgets/framework/widget_data_repository.dart';
import 'package:widgetly/features/widgets/framework/widget_instance_data_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        widgetDataRepositoryProvider.overrideWith(
            (ref) => MockWidgetDataRepository()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('WidgetInstanceDataProvider', () {
    test('provides async data for widget instance', () {
      final asyncData = container.read(widgetDataProvider('test-widget-1'));
      expect(asyncData, isA<AsyncValue<Map<String, dynamic>>>());
    });

    test('can be refreshed via invalidate', () {
      final instance = 'test-widget-2';
      // Initial read
      final initial = container.read(widgetDataProvider(instance));
      expect(initial, isA<AsyncValue<Map<String, dynamic>>>());

      // Invalidate forces a reload
      container.invalidate(widgetDataProvider(instance));
      final refreshed = container.read(widgetDataProvider(instance));
      expect(refreshed, isA<AsyncValue<Map<String, dynamic>>>());
      // After invalidation, should be loading
      expect(refreshed.isLoading, true);
    });

    test('different instances are independent', () {
      final async1 = container.read(widgetDataProvider('instance-1'));
      final async2 = container.read(widgetDataProvider('instance-2'));

      expect(async1, isNot(same(async2)));
    });
  });
}
