import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widget_local_cache.dart';
import 'widget_schema_migration.dart';
import 'widget_background_refresh.dart';

/// Provider for the widget local cache.
final widgetLocalCacheProvider = Provider<WidgetLocalCache>((ref) {
  return WidgetLocalCache();
});

/// Provider for the widget migration registry.
final widgetMigrationRegistryProvider = Provider<WidgetMigrationRegistry>((ref) {
  final registry = WidgetMigrationRegistry();
  registerDefaultMigrations(registry);
  return registry;
});

/// Provider for the widget background refresh service.
final widgetBackgroundRefreshProvider = Provider<WidgetBackgroundRefresh>((ref) {
  return WidgetBackgroundRefresh();
});