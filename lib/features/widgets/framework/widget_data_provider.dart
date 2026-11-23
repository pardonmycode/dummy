import 'dart:convert';

import '../framework/widget_definition.dart';

/// Generic data provider for widgets with caching and error isolation.
class WidgetDataProvider {
  final Map<String, Future<Map<String, dynamic>>> _inFlightRequests = {};
  final Map<String, CachedWidgetData> _cache = {};
  final Map<String, WidgetDataState> _errorStates = {};

  /// Fetch data for a widget, with caching and error isolation.
  Future<WidgetDataState> fetchWidgetData({
    required String widgetType,
    required String instanceId,
    required Map<String, dynamic>? config,
    required Future<Map<String, dynamic>> Function() fetcher,
    required void Function(WidgetData? data, WidgetDataState state) onComplete,
    Duration cacheDuration = const Duration(hours: 1),
    Duration errorTimeout = const Duration(seconds: 30),
  }) async {
    final cacheKey = _cacheKey(widgetType, instanceId, config);

    // Check cache first
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired(cacheDuration)) {
      onComplete(WidgetData.fromJson(cached.data), WidgetDataState.ready);
      return WidgetDataState.ready;
    }

    // Check if there's already an in-flight request
    if (_inFlightRequests.containsKey(cacheKey)) {
      // Wait for the existing request
      try {
        final data = await _inFlightRequests[cacheKey]!;
        _cache[cacheKey] = CachedWidgetData(data: data, timestamp: DateTime.now());
        _errorStates.remove(widgetType);
        onComplete(WidgetData.fromJson(data), WidgetDataState.ready);
        return WidgetDataState.ready;
      } catch (e) {
        _errorStates[widgetType] = WidgetDataState.error;
        onComplete(null, WidgetDataState.error);
        return WidgetDataState.error;
      }
    }

    // Start new request
    late Future<Map<String, dynamic>> request;
    request = fetcher().timeout(
          errorTimeout,
          onTimeout: () => throw TimeoutException('Widget $widgetType timed out'),
        ).then((data) {
          _cache[cacheKey] = CachedWidgetData(data: data, timestamp: DateTime.now());
          _errorStates.remove(widgetType);
          return data;
        }).catchError((e) {
          _errorStates[widgetType] = WidgetDataState.error;
          // Fall back to stale cache
          if (cached != null) {
            return cached.data;
          }
          throw e;
        }).finally(() {
          _inFlightRequests.remove(cacheKey);
        });

    _inFlightRequests[cacheKey] = request;

    try {
      final data = await request;
      onComplete(WidgetData.fromJson(data), WidgetDataState.ready);
      return WidgetDataState.ready;
    } catch (e) {
      if (cached != null) {
        onComplete(WidgetData.fromJson(cached.data), WidgetDataState.stale);
        return WidgetDataState.stale;
      }
      onComplete(null, WidgetDataState.error);
      return WidgetDataState.error;
    }
  }

  /// Clear cache for a specific widget instance
  void clearCache({required String widgetType, required String instanceId}) {
    final keys = _cache.keys.where((k) => k.startsWith(widgetType)).toList();
    for (final key in keys) {
      _cache.remove(key);
    }
  }

  /// Clear all cache
  void clearAllCache() {
    _cache.clear();
  }

  String _cacheKey(String widgetType, String instanceId, Map<String, dynamic>? config) {
    final configHash = config != null ? jsonEncode(config).hashCode : 0;
    return '$widgetType:$instanceId:$configHash';
  }
}

class CachedWidgetData {
  final Map<String, dynamic> data;
  final DateTime timestamp;

  CachedWidgetData({required this.data, required this.timestamp});

  bool isExpired(Duration duration) {
    return DateTime.now().difference(timestamp) > duration;
  }
}

/// Provider for the shared WidgetDataProvider instance
final widgetDataProvider = WidgetDataProvider();
