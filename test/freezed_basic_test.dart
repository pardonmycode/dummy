import 'package:flutter_test/flutter_test.dart';
import 'package:widgetly/features/widgets/framework/widget_instance.dart';
import 'package:widgetly/features/widgets/framework/widget_definition.dart';

void main() {
  test('basic freezed instance', () {
    final instance = WidgetInstance(
      id: 'test-id',
      widgetType: 'weather',
      size: WidgetSize.medium,
    );
    expect(instance.id, equals('test-id'));
    expect(instance.widgetType, equals('weather'));
    expect(instance.size, equals(WidgetSize.medium));
    print('Instance: $instance');
    print('Type: ${instance.runtimeType}');
    
    final copy = instance.copyWith(size: WidgetSize.large);
    expect(copy.size, equals(WidgetSize.large));
    print('Copy: $copy');
  });
}
