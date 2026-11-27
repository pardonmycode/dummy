import 'package:flutter_test/flutter_test.dart';
import 'package:widgetly/features/widgets/framework/widget_schema_cache.dart';

void main() {
  group('WidgetSchemaCache', () {
    test('compiles schema once per type', () {
      final cache = WidgetSchemaCache();
      
      // First compile
      final schema1 = cache.getOrCreate('weather', {'type': 'object'});
      
      // Second compile returns same instance
      final schema2 = cache.getOrCreate('weather', {'type': 'object'});
      
      expect(schema1, same(schema2));
      
      // Different type gets different schema
      final schema3 = cache.getOrCreate('steps', {'type': 'object'});
      expect(schema3, isNot(same(schema1)));
    });

    test('can be cleared', () {
      final cache = WidgetSchemaCache();
      cache.getOrCreate('weather', {'type': 'object'});
      expect(cache.size, 1);
      
      cache.clear();
      expect(cache.size, 0);
    });
  });
}
