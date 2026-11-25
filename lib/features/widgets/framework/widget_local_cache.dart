import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Per-widget-instance local cache with timestamps using SharedPreferences.
/// Stores cached widget data so widgets can show cached data when offline.
class WidgetLocalCache {
  static const String _prefix = 'widget_cache_';
  static const String _timestampPrefix = 'widget_cache_ts_';

  Future<void> setCachedData({
    required String widgetType,
    required String instanceId,
    required Map<String, dynamic> data,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _cacheKey(widgetType, instanceId);
    final tsKey = _timestampKey(widgetType, instanceId);

    final json = jsonEncode(data);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await Future.wait([
      prefs.setString(key, json),
      prefs.setInt(tsKey, timestamp),
    ]);
  }

  Future<Map<String, dynamic>?> getCachedData({
    required String widgetType,
    required String instanceId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _cacheKey(widgetType, instanceId);

    final json = prefs.getString(key);
    if (json == null) {
      return null;
    }

    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<int?> getCacheTimestamp({
    required String widgetType,
    required String instanceId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final tsKey = _timestampKey(widgetType, instanceId);
    return prefs.getInt(tsKey);
  }

  /// Check if cached data is stale (older than maxAge).
  Future<bool> isStale({
    required String widgetType,
    required String instanceId,
    Duration maxAge = const Duration(hours: 1),
  }) async {
    final timestamp = await getCacheTimestamp(
      widgetType: widgetType,
      instanceId: instanceId,
    );
    if (timestamp == null) {
      return true;
    }

    final age = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
    return age > maxAge;
  }

  Future<void> clearCache({
    required String widgetType,
    required String instanceId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _cacheKey(widgetType, instanceId);
    final tsKey = _timestampKey(widgetType, instanceId);

    await Future.wait([
      prefs.remove(key),
      prefs.remove(tsKey),
    ]);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) {
      return key.startsWith(_prefix) || key.startsWith(_timestampPrefix);
    }).toList();

    await Future.wait(keys.map((key) => prefs.remove(key)));
  }

  String _cacheKey(String widgetType, String instanceId) {
    return '$_prefix$widgetType:$instanceId';
  }

  String _timestampKey(String widgetType, String instanceId) {
    return '$_timestampPrefix$widgetType:$instanceId';
  }
}

/// Singleton instance of the local cache.
final widgetLocalCache = WidgetLocalCache();