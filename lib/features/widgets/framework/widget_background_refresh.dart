import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../framework/widget_definition.dart';
import '../framework/widget_registry.dart';

/// Simple logger function for background refresh.
void _log(String message) {
  print('[Background Refresh] $message');
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

/// Configuration for background refresh.
class BackgroundRefreshConfig {
  final String widgetType;
  final String instanceId;
  final RefreshInterval interval;
  final Future<void> Function() onRefresh;

  const BackgroundRefreshConfig({
    required this.widgetType,
    required this.instanceId,
    required this.interval,
    required this.onRefresh,
  });
}

/// Service that manages periodic background refresh for widgets.
/// Checks each widget's refresh interval and refreshes data when stale.
class WidgetBackgroundRefresh {
  Timer? _timer;
  bool _isRunning = false;
  SharedPreferences? _prefs;

  // Registered refresh tasks
  final Map<String, BackgroundRefreshConfig> _registered = {};

  /// Check if background refresh is currently running.
  bool get isRunning => _isRunning;

  /// Register a widget instance for background refresh.
  /// Uses the widget definition's default refresh interval unless overridden.
  void register({
    required String instanceId,
    required String widgetType,
    required WidgetRegistry registry,
    RefreshInterval? overrideInterval,
    required Future<void> Function() onRefresh,
  }) {
    final definition = registry.get(widgetType);
    final interval =
        overrideInterval ?? definition?.defaultRefreshInterval ?? RefreshInterval.hours1;

    _registered[instanceId] = BackgroundRefreshConfig(
      widgetType: widgetType,
      instanceId: instanceId,
      interval: interval,
      onRefresh: onRefresh,
    );

    _log('Registered $instanceId ($widgetType) with interval $interval');
  }

  /// Unregister a widget instance from background refresh.
  void unregister(String instanceId) {
    _registered.remove(instanceId);
    _log('Unregistered $instanceId');
  }

  /// Clear all registered refresh tasks.
  void clearAll() {
    _registered.clear();
  }

  /// Start periodic background refresh for all registered widgets.
  void start({Duration? checkInterval}) {
    if (_isRunning) return;

    // Check every 5 minutes by default
    final interval = checkInterval ?? const Duration(minutes: 5);

    _timer = Timer.periodic(interval, (timer) {
      _checkAndRefreshAll();
    });

    _isRunning = true;
    _log('Started, checking every $interval');
  }

  /// Stop background refresh.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _log('Stopped');
  }

  /// Force refresh all widgets immediately.
  Future<void> refreshAllNow() async {
    _log('Force refreshing all widgets');
    final configs = List<BackgroundRefreshConfig>.from(_registered.values);
    
    // Refresh all in parallel
    final futures = configs.map((config) async {
      try {
        await config.onRefresh();
        await _setLastRefreshed(config.instanceId, DateTime.now());
        _log('Refreshed ${config.instanceId}');
      } catch (e) {
        _log('Error refreshing ${config.instanceId}: $e');
      }
    });
    
    await Future.wait(futures, eagerError: false);
  }

  /// Force refresh a specific widget instance.
  Future<void> refreshNow(String instanceId) async {
    final config = _registered[instanceId];
    if (config == null) {
      _log('$instanceId not registered');
      return;
    }
    try {
      await config.onRefresh();
      await _setLastRefreshed(instanceId, DateTime.now());
      _log('Refreshed $instanceId');
    } catch (e) {
      _log('Error refreshing $instanceId: $e');
    }
  }

  /// Check all registered widgets and refresh any that are stale.
  Future<void> _checkAndRefreshAll() async {
    final now = DateTime.now();
    
    // Collect stale widget refresh futures
    final staleRefreshes = <Future<void>>[];
    
    for (final config in _registered.values) {
      try {
        // Skip widgets that don't auto-refresh
        if (config.interval == RefreshInterval.never ||
            config.interval == RefreshInterval.manual) {
          continue;
        }
        
        final lastRefreshed = await _getLastRefreshed(config.instanceId);
        final maxAge = intervalToDuration(config.interval);
        
        bool isStale;
        if (lastRefreshed == null) {
          isStale = true;
        } else {
          isStale = now.difference(lastRefreshed) > maxAge;
        }
        
        if (isStale) {
          _log('Refreshing stale widget ${config.instanceId} (${config.widgetType})');
          staleRefreshes.add(config.onRefresh().then((_) =>
            _setLastRefreshed(config.instanceId, now)));
        }
      } catch (e) {
        _log('Error checking ${config.instanceId}: $e');
      }
    }
    
    // Refresh all stale widgets in parallel
    if (staleRefreshes.isNotEmpty) {
      await Future.wait(staleRefreshes, eagerError: false);
    }
  }

  /// Get the last refresh time for a widget instance.
  Future<DateTime?> _getLastRefreshed(String instanceId) async {
    try {
      final prefs = await _getPrefs();
      final ts = prefs.getInt('bg_refresh_ts_$instanceId');
      if (ts == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(ts);
    } catch (e) {
      return null;
    }
  }

  /// Set the last refresh time for a widget instance.
  Future<void> _setLastRefreshed(
    String instanceId,
    DateTime timestamp,
  ) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setInt(
        'bg_refresh_ts_$instanceId',
        timestamp.millisecondsSinceEpoch,
      );
    } catch (e) {
      _log('Error saving timestamp: $e');
    }
  }

  /// Get or create SharedPreferences instance (cached).
  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  /// Dispose of the service.
  void dispose() {
    stop();
    clearAll();
    _prefs = null;
  }
}

/// Global background refresh service instance.
final widgetBackgroundRefresh = WidgetBackgroundRefresh();