import 'package:flutter_test/flutter_test.dart';
import 'package:widgetly/features/dashboard/ui/views/dashboard_view.dart';

void main() {
  group('Split dashboard components', () {
    test('DashboardView exists', () {
      expect(const DashboardView(), isNotNull);
    });

    test('widgetRegistryProvider is defined', () {
      expect(widgetRegistryProvider, isNotNull);
    });
  });
}
