import 'package:flutter_test/flutter_test.dart';
import 'package:widgetly/features/widgets/framework/widget_instance.dart';
import 'package:widgetly/features/dashboard/domain/dashboard.dart';
import 'package:widgetly/features/widgets/framework/widget_data.dart';
import 'package:widgetly/features/widgets/framework/widget_definition.dart';
import 'dart:convert';

void main() {
  group('Phase 3.1: Freezed models', () {
    test('WidgetInstance has freezed copyWith and equality', () {
      final instance = WidgetInstance(
        id: 'test-id',
        widgetType: 'weather',
        size: WidgetSize.medium,
      );

      // Freezed provides copyWith
      final updated = instance.copyWith(size: WidgetSize.large);
      expect(updated.id, equals('test-id'));
      expect(updated.widgetType, equals('weather'));
      expect(updated.size, equals(WidgetSize.large));

      // Freezed provides structural equality
      final copy = instance.copyWith();
      expect(copy, equals(instance));
      expect(copy.hashCode, equals(instance.hashCode));
    });

    test('Dashboard has freezed copyWith and equality', () {
      final dashboard = Dashboard(id: 'test-dash-id', name: 'Test Dashboard');
      final updated = dashboard.copyWith(name: 'Updated Name');

      expect(updated.id, equals('test-dash-id'));
      expect(updated.name, equals('Updated Name'));
      expect(updated.widgets, equals([]));

      // Structural equality
      expect(updated.copyWith(name: 'Test Dashboard'), equals(dashboard));
    });

    test('WidgetData has freezed copyWith and equality', () {
      final data = WidgetData(
        schemaVersion: 1,
        data: {'temp': 20},
        generatedAt: DateTime(2026, 1, 1),
      );

      final updated = data.copyWith(data: {'temp': 25});
      expect(updated.schemaVersion, equals(1));
      expect(updated.data['temp'], equals(25));
      expect(updated.generatedAt, equals(DateTime(2026, 1, 1)));
    });

    test('WidgetInstance JSON roundtrip preserves types', () {
      final instance = WidgetInstance(
        id: 'test-id',
        widgetType: 'steps_tracker',
        size: WidgetSize.small,
        config: {'goal': 10000},
        gridPosition: {'row': 1, 'col': 0, 'rowSpan': 1, 'colSpan': 1},
      );

      final json = jsonEncode(instance.toJson());
      final decoded = WidgetInstance.fromJson(jsonDecode(json));

      expect(decoded.id, equals('test-id'));
      expect(decoded.widgetType, equals('steps_tracker'));
      expect(decoded.size, equals(WidgetSize.small));
      expect(decoded.config['goal'], equals(10000));
      expect(decoded.gridPosition!['row'], equals(1));
    });

    test('Dashboard JSON roundtrip', () {
      final dashboard = Dashboard(
        id: 'test-dash-id',
        name: 'Health Dashboard',
        widgets: [
          WidgetInstance(widgetType: 'weather', size: WidgetSize.medium),
          WidgetInstance(widgetType: 'steps_tracker', size: WidgetSize.small),
        ],
      );

      final json = jsonEncode(dashboard.toJson());
      final decoded = Dashboard.fromJson(jsonDecode(json));

      expect(decoded.name, equals('Health Dashboard'));
      expect(decoded.widgets.length, equals(2));
      expect(decoded.widgets[0].widgetType, equals('weather'));
    });

    test('WidgetData JSON roundtrip with DateTime', () {
      final data = WidgetData(
        schemaVersion: 2,
        data: {'value': 42},
        sources: [{'name': 'api', 'url': 'https://api.example.com'}],
        generatedAt: DateTime.utc(2026, 8, 8, 12, 0, 0),
        expiresAt: DateTime.utc(2026, 8, 8, 13, 0, 0),
      );

      final json = jsonEncode(data.toJson());
      final decoded = WidgetData.fromJson(jsonDecode(json));

      expect(decoded.schemaVersion, equals(2));
      expect(decoded.data['value'], equals(42));
      expect(decoded.sources.length, equals(1));
    });
  });
}
