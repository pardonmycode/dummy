import 'package:shared_preferences/shared_preferences.dart';

import '../framework/widget_definition.dart';
import 'package:widgetly/core/logging/app_logger.dart';

/// Simple logger function for background refresh.
void _log(String message) {
  appLogger.i('Background Refresh: $message');
}

/// Converts a RefreshInterval enum to a Duration.
Duration intervalToDuration(RefreshInterval interval) {
  switch (interval) {
    case RefreshInterval.never:
      return const Duration(days: 365);
    case RefreshInterval.manual:
      return const Duration(days: 365);
    case RefreshInterval.minutes15:
      return const Duration(minutes: 15);
    case RefreshInterval.minutes30:
      return const Duration(minutes: 30);
    case RefreshInterval.hours1:
      return const Duration(hours: 1);
    case RefreshInterval.hours6:
      return const Duration(hours: 6);
    case RefreshInterval.hours12:
      return const Duration(hours: 12);
    case RefreshInterval.days1:
      return const Duration(days: 1);
  }
}

/// Service that manages widget refresh on app resume.
/// Uses AppLifecycleListener to refresh widgets when returning to the app.
class WidgetBackgroundRefresh {
  SharedPreferences? _prefs;
  final Map<String, Future<void> Function()> _refreshCallbacks = {};

  /// Register a refresh callback for a widget instance.
  void register({
    required String instanceId,
    required Future<void> Function() onRefresh,
  }) {
    _refreshCallbacks[instanceId] = onRefresh;
    _log('Registered refresh callback for $instanceId');
  }

  /// Unregister a refresh callback.
  void unregister(String instanceId) {
    _refreshCallbacks.remove(instanceId);
    _log('Unregistered refresh callback for $instanceId');
  }

  /// Clear all registered refresh callbacks.
  void clearAll() {
    _refreshCallbacks.clear();
  }

  /// Refresh all registered widgets. Called when app resumes from background.
  Future<void> refreshAllOnResume() async {
    if (_refreshCallbacks.isEmpty) {
      _log('No refresh callbacks registered');
      return;
    }

    _log('App resumed - refreshing ${_refreshCallbacks.length} widgets');
    final futures = <Future<void>>[];

    for (final config in _refreshCallbacks.entries) {
      futures.add(config.value().catchError((e) {
        _log('Error refreshing ${config.key}: $e');
      }));
    }

    await Future.wait(futures, eagerError: false);
    _log('Resume refresh complete');
  }

  /// Dispose of the service.
  void dispose() {
    clearAll();
    _prefs = null;
  }
}

/// Global background refresh service instance.
final widgetBackgroundRefresh = WidgetBackgroundRefresh();
