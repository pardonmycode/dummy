import 'package:flutter_test/flutter_test.dart';
import 'package:widgetly/features/dashboard/ui/views/dashboard_view.dart';
import 'package:widgetly/features/dashboard/ui/views/widget_catalog.dart';

void main() {
  group('Split dashboard components', () {
    test('DashboardView exists', () {
      expect(DashboardView(), isNotNull);
    });

    test('widgetRegistryProvider is defined', () {
      expect(widgetRegistryProvider, isNotNull);
    });
  });
}
