import 'package:flutter_test/flutter_test.dart';
import 'package:widgetly/features/widgets/framework/widget_data_repository.dart';
import 'package:widgetly/features/widgets/framework/mock_widget_data_repository.dart';
import 'package:widgetly/features/widgets/framework/api_widget_data_repository.dart';

void main() {
  group('WidgetDataRepository interface', () {
    test('MockWidgetDataRepository implements WidgetDataRepository', () {
      final repo = MockWidgetDataRepository();
      expect(repo, isA<WidgetDataRepository>());
    });

    test('ApiWidgetDataRepository implements WidgetDataRepository', () {
      final repo = ApiWidgetDataRepository(baseUrl: 'http://example.com');
      expect(repo, isA<WidgetDataRepository>());
    });

    test('MockWidgetDataRepository can provide data', () async {
      final repo = MockWidgetDataRepository();
      final data = await repo.getData('weather', {});
      expect(data, isNotNull);
      expect(data['data'], isNotNull);
    });

    test('MockWidgetDataRepository supports refresh', () async {
      final repo = MockWidgetDataRepository();
      final data1 = await repo.getData('weather', {});
      final data2 = await repo.refresh('weather', {});
      expect(data2, isNotNull);
    });
  });
}
