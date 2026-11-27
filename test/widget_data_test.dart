import 'package:flutter_test/flutter_test.dart';
import 'package:widgetly/features/widgets/framework/widget_data.dart';

void main() {
  test('create widget data', () {
    final data = WidgetData(
      schemaVersion: 1,
      data: {'temp': 20},
      generatedAt: DateTime(2026, 1, 1),
    );
    print('Data: $data');
    print('Type: ${data.runtimeType}');
    expect(data.schemaVersion, equals(1));
  });
}
