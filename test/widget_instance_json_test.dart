import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:widgetly/features/widgets/framework/widget_instance.dart';
import 'package:widgetly/features/widgets/framework/widget_definition.dart';

void main() {
  group('WidgetInstance JSON roundtrip', () {
    test('serializes and deserializes through jsonEncode/jsonDecode', () {
      final instance = WidgetInstance(
        id: 'test-id-123',
        widgetType: 'steps_tracker',
        size: WidgetSize.small,
        config: {'target': 10000},
        gridPosition: {'row': 2, 'col': 1, 'rowSpan': 1, 'colSpan': 2},
      );

      // Serialize
      final json = instance.toJson();

      // Roundtrip through JSON encoding/decoding (as happens with persistence)
      final encoded = jsonEncode(json);
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;

      // Deserialize - this should not throw
      final restored = WidgetInstance.fromJson(decoded);

      // Verify all fields are preserved
      expect(restored.id, 'test-id-123');
      expect(restored.widgetType, 'steps_tracker');
      expect(restored.size, WidgetSize.small);
      expect(restored.config['target'], 10000);
      expect(restored.gridPosition!['row'], 2);
      expect(restored.gridPosition!['col'], 1);
      expect(restored.gridPosition!['rowSpan'], 1);
      expect(restored.gridPosition!['colSpan'], 2);

      // Ensure gridPosition values are int after deserialization
      expect(restored.gridPosition!['row'] is int, isTrue);
      expect(restored.gridPosition!['col'] is int, isTrue);
    });

    test('deserializes with missing gridPosition', () {
      final json = <String, dynamic>{
        'id': 'test-id',
        'widgetType': 'weather',
        'size': 'medium',
        'config': {},
      };

      final instance = WidgetInstance.fromJson(json);
      expect(instance.id, 'test-id');
      expect(instance.gridPosition!['row'], 0);
      expect(instance.gridPosition!['col'], 0);
    });

    test('deserializes with missing optional fields', () {
      final json = <String, dynamic>{
        'id': 'test-id',
        'widgetType': 'water_tracker',
      };

      final instance = WidgetInstance.fromJson(json);
      expect(instance.id, 'test-id');
      expect(instance.widgetType, 'water_tracker');
      expect(instance.size, WidgetSize.medium);
      expect(instance.config, {});
      expect(instance.gridPosition, {'row': 0, 'col': 0, 'rowSpan': 1, 'colSpan': 1});
    });

    test('roundtrip preserves config with mixed types', () {
      final instance = WidgetInstance(
        widgetType: 'test',
        config: {
          'string': 'hello',
          'number': 42,
          'double': 3.14,
          'bool': true,
          'list': [1, 2, 3],
          'nested': {'key': 'value'},
        },
      );

      final json = instance.toJson();
      final encoded = jsonEncode(json);
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final restored = WidgetInstance.fromJson(decoded);

      expect(restored.config['string'], 'hello');
      expect(restored.config['number'], 42);
      expect(restored.config['bool'], true);
    });
  });
}
