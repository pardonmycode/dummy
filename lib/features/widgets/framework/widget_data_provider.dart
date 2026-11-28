import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import './widget_definition.dart';
import './widget_data.dart';
import './widget_schema_validator.dart';

/// Generic data provider for widgets with caching and error isolation.
class WidgetDataProvider {
  final Map<String, Future<Map<String, dynamic>>> _inFlightRequests = {};
  final Map<String, CachedWidgetData> _cache = {};
  final Map<String, WidgetDataState> _errorStates = {};

  /// Fetch data for a widget, with caching, validation, and error isolation.
  /// Validates data against the widget's JSON schema before caching/rendering.
  Future<WidgetDataState> fetchWidgetData({
    required String widgetType,
    required String instanceId,
    required Map<String, dynamic>? config,
    required Future<Map<String, dynamic>> Function() fetcher,
    required void Function(
      WidgetData? data,
      WidgetDataState state,
      List<String>? validationErrors,
    ) onComplete,
    Duration cacheDuration = const Duration(hours: 1),
    Duration errorTimeout = const Duration(seconds: 30),
  }) async {
    final cacheKey = _cacheKey(widgetType, instanceId, config);

    // Validate and report helper
    bool validateAndReport(Map<String, dynamic> data) {
      final errors = validateWidgetData(widgetType, data);
      if (errors != null && errors.isNotEmpty) {
        debugPrint('Widget schema validation failed for $widgetType:');
        for (final error in errors) {
          debugPrint('  - $error');
        }
        onComplete(WidgetData.fromJson(data), WidgetDataState.ready, errors);
        return true;
      }
      return false;
    }

    // Check cache first
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired(cacheDuration)) {
      if (!validateAndReport(cached.data)) {
        onComplete(WidgetData.fromJson(cached.data), WidgetDataState.ready, null);
      }
      return WidgetDataState.ready;
    }

    // Check if there's already an in-flight request
    if (_inFlightRequests.containsKey(cacheKey)) {
      // Wait for the existing request
      try {
        final data = await _inFlightRequests[cacheKey]!;
        _cache[cacheKey] = CachedWidgetData(
          data: data,
          timestamp: DateTime.now(),
        );
        _errorStates.remove(widgetType);
        if (!validateAndReport(data)) {
          onComplete(WidgetData.fromJson(data), WidgetDataState.ready, null);
        }
        return WidgetDataState.ready;
      } catch (e) {
        _errorStates[widgetType] = WidgetDataState.error;
        onComplete(null, WidgetDataState.error, null);
        return WidgetDataState.error;
      }
    }

    // Start new request
    late Future<Map<String, dynamic>> request;
    request = fetcher()
        .timeout(
          errorTimeout,
          onTimeout: () =>
              throw TimeoutException('Widget $widgetType timed out'),
        )
        .then((data) {
          _cache[cacheKey] = CachedWidgetData(
            data: data,
            timestamp: DateTime.now(),
          );
          _errorStates.remove(widgetType);
          return data;
        })
        .catchError((e) {
          _errorStates[widgetType] = WidgetDataState.error;
          // Fall back to stale cache
          if (cached != null) {
            return cached.data;
          }
          throw e;
        })
        .whenComplete(() {
          _inFlightRequests.remove(cacheKey);
        });

    _inFlightRequests[cacheKey] = request;

    try {
      final data = await request;
      if (!validateAndReport(data)) {
        onComplete(WidgetData.fromJson(data), WidgetDataState.ready, null);
      }
      return WidgetDataState.ready;
    } catch (e) {
      if (cached != null) {
        if (!validateAndReport(cached.data)) {
          onComplete(WidgetData.fromJson(cached.data), WidgetDataState.stale, null);
        }
        return WidgetDataState.stale;
      }
      onComplete(null, WidgetDataState.error, null);
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

  String _cacheKey(
    String widgetType,
    String instanceId,
    Map<String, dynamic>? config,
  ) {
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
