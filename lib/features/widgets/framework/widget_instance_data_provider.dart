import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widget_data_repository.dart';
import 'mock_widget_data_repository.dart';

/// Provider for the widget data repository.
/// Override this in tests or for API-backed data.
final widgetDataRepositoryProvider = Provider<WidgetDataRepository>((ref) {
  return MockWidgetDataRepository();
});

/// Per-instance async data provider with stale-while-revalidate pattern.
/// Loads data from the repository and provides refresh capability.
/// Uses FutureProvider.family for simplicity — each instance ID gets
/// its own future that can be invalidated for refresh.
final widgetDataProvider = FutureProvider.family<Map<String, dynamic>, String>(
    (ref, instanceId) async {
  final repo = ref.watch(widgetDataRepositoryProvider);
  // In a real app, this would look up the widget type and config from
  // the dashboard state. For now, we use mock data.
  return await repo.getData('weather', {});
});
