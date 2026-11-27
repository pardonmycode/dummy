import 'package:flutter_test/flutter_test.dart';
import 'package:widgetly/features/dashboard/domain/dashboard_sync_service.dart';

void main() {
  group('Dashboard sync service', () {
    late DashboardSyncService syncService;

    setUp(() {
      syncService = DashboardSyncService();
    });

    test('exportLayout produces valid versioned JSON', () {
      final dashboard = {
        'id': 'test-dash',
        'name': 'Test Dashboard',
        'widgets': [
          {'id': 'a', 'widgetType': 'weather'},
          {'id': 'b', 'widgetType': 'steps_tracker'},
        ],
      };

      final json = syncService.exportLayout(dashboard);

      // Should be valid JSON
      expect(json, isNotEmpty);
      // Should contain version
      expect(json, contains('"version":2'));
      // Should contain dashboard name
      expect(json, contains('Test Dashboard'));
    });

    test('importLayout handles versioned format', () {
      final json = '''
      {
        "version": 2,
        "exportedAt": "2026-11-27T10:00:00Z",
        "dashboard": {
          "id": "imported-dash",
          "name": "Imported Dashboard",
          "widgets": []
        }
      }
      ''';

      final result = syncService.importLayout(json);

      expect(result.isSuccess, isTrue);
      expect(result.value!['name'], 'Imported Dashboard');
      expect(result.value!['id'], 'imported-dash');
    });

    test('importLayout handles legacy format', () {
      final json = '''
      {
        "id": "legacy-dash",
        "name": "Legacy Dashboard",
        "widgets": []
      }
      ''';

      final result = syncService.importLayout(json);

      expect(result.isSuccess, isTrue);
      expect(result.value!['name'], 'Legacy Dashboard');
    });

    test('importLayout rejects invalid JSON', () {
      final result = syncService.importLayout('not valid json');

      expect(result.isError, isTrue);
    });

    test('importLayout rejects non-object JSON', () {
      final result = syncService.importLayout('"just a string"');

      expect(result.isError, isTrue);
    });
  });
}