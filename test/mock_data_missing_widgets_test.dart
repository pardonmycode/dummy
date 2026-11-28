import 'package:flutter_test/flutter_test.dart';
import 'package:widgetly/features/widgets/framework/mock_widget_data_provider.dart';

void main() {
  group('Mock data provider - missing widget types', () {
    late MockWidgetDataProvider provider;

    setUp(() {
      provider = MockWidgetDataProvider();
    });

    test('parties widget returns mock data', () async {
      final data = await provider.getData('parties', null);
      expect(data, isNotNull);
      expect(data['data'], isNotNull);
      expect(data['data']['events'], isA<List>());
      expect(data['data']['events'].length, greaterThan(0));
    });

    test('carbs_tracker widget returns mock data', () async {
      final data = await provider.getData('carbs_tracker', null);
      expect(data, isNotNull);
      expect(data['data'], isNotNull);
      expect(data['data']['goal'], isNotNull);
    });

    test('water_tracker widget returns mock data', () async {
      final data = await provider.getData('water_tracker', null);
      expect(data, isNotNull);
      expect(data['data'], isNotNull);
      expect(data['data']['goal'], isNotNull);
    });

    test('steps_tracker widget returns mock data', () async {
      final data = await provider.getData('steps_tracker', null);
      expect(data, isNotNull);
      expect(data['data'], isNotNull);
      expect(data['data']['goal'], isNotNull);
    });
  });
}