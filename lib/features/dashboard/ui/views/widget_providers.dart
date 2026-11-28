import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/dashboard_notifier.dart';
import 'providers.dart'
    show activeDashboardProvider, mockDataProviderProvider;
import '../../../widgets/framework/widget_providers.dart';
import '../../../widgets/framework/widget_schema_migration.dart';

/// Memoized data provider — caches the Future per widget instance
/// so rebuilds don't trigger new fetches. Uses select to only watch
/// the specific instance by ID to avoid reloading all widgets on changes.
final widgetDataProvider = FutureProvider.autoDispose.family<
    Map<String, dynamic>?, String>((ref, instanceId) async {
  final instance = ref.watch(
    dashboardNotifierProvider.select((asyncDashboards) {
      final dashboards = asyncDashboards.value ?? [];
      final active = dashboards.firstWhere(
        (d) => d.id == ref.read(activeDashboardProvider),
        orElse: () => dashboards.first,
      );
      return active.widgets.firstWhere(
        (w) => w.id == instanceId,
        orElse: () => throw StateError('Widget $instanceId not found'),
      );
    }),
  );
  final provider = ref.watch(mockDataProviderProvider);
  var data = await provider.getData(instance.widgetType, instance.config);

  // Apply schema migrations if needed
  final migrationRegistry = ref.watch(widgetMigrationRegistryProvider);
  final expectedVersion = getExpectedVersion(instance.widgetType);
  data = await migrationRegistry.migrateData(
    widgetType: instance.widgetType,
    data: data,
    targetVersion: expectedVersion,
  );

  // Save to local cache
  final cache = ref.watch(widgetLocalCacheProvider);
  await cache.setCachedData(
    widgetType: instance.widgetType,
    instanceId: instance.id,
    data: data,
  );

  return data;
});

/// Cached data provider — returns cached data while main provider loads.
/// Uses FutureProvider to memoize the cache lookup.
final widgetCacheDataProvider = FutureProvider.family<
    Map<String, dynamic>?, String>((ref, instanceId) async {
  final instance = ref.watch(
    dashboardNotifierProvider.select((asyncDashboards) {
      final dashboards = asyncDashboards.value ?? [];
      final active = dashboards.firstWhere(
        (d) => d.id == ref.read(activeDashboardProvider),
        orElse: () => dashboards.first,
      );
      return active.widgets.firstWhere(
        (w) => w.id == instanceId,
        orElse: () => throw StateError('Widget $instanceId not found'),
      );
    }),
  );
  final cache = ref.watch(widgetLocalCacheProvider);
  return cache.getCachedData(
    widgetType: instance.widgetType,
    instanceId: instance.id,
  );
});