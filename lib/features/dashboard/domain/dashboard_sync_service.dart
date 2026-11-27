import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

import '../../../../core/config/app_config.dart';
import '../../../../core/models/result.dart';

/// Service for syncing dashboard layouts with the backend.
/// Uses Result pattern for proper error handling.
class DashboardSyncService {
  static final _baseUrl = AppConfig.apiBaseUrl;
  static const _timeout = Duration(seconds: 15);

  /// Upload all local dashboards to the backend.
  Future<Result<bool, String>> syncToServer(
    List<Map<String, dynamic>> dashboards,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/dashboard/sync'),
        headers: _authHeaders(),
        body: jsonEncode({'dashboards': dashboards}),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return Result.success(true);
      }
      return Result.error('Server returned ${response.statusCode}');
    } on TimeoutException {
      return Result.error('Request timed out');
    } on SocketException {
      return Result.error('No network connection');
    } catch (e) {
      return Result.error('Sync failed: $e');
    }
  }

  /// Download all synced dashboards from the backend.
  Future<Result<List<Map<String, dynamic>>, String>> syncFromServer() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/dashboard/sync'),
        headers: _authHeaders(),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final dashboards = List<Map<String, dynamic>>.from(
          data['dashboards'] ?? [],
        );
        return Result.success(dashboards);
      }
      return Result.error('Server returned ${response.statusCode}');
    } on TimeoutException {
      return Result.error('Request timed out');
    } on SocketException {
      return Result.error('No network connection');
    } catch (e) {
      return Result.error('Sync failed: $e');
    }
  }

  /// Get all available dashboard templates.
  Future<Result<List<Map<String, dynamic>>, String>> getTemplates() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/dashboard/templates'),
        headers: _authHeaders(),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final templates = List<Map<String, dynamic>>.from(
          data['templates'] ?? [],
        );
        return Result.success(templates);
      }
      return Result.error('Server returned ${response.statusCode}');
    } on TimeoutException {
      return Result.error('Request timed out');
    } on SocketException {
      return Result.error('No network connection');
    } catch (e) {
      return Result.error('Templates failed: $e');
    }
  }

  /// Apply a template to a dashboard.
  Future<Result<bool, String>> applyTemplate(
    String templateId,
    int dashboardId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/dashboard/templates/$templateId/apply'),
        headers: _authHeaders(),
        body: jsonEncode({'dashboard_id': dashboardId}),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return Result.success(true);
      }
      return Result.error('Server returned ${response.statusCode}');
    } on TimeoutException {
      return Result.error('Request timed out');
    } on SocketException {
      return Result.error('No network connection');
    } catch (e) {
      return Result.error('Template apply failed: $e');
    }
  }

  /// Export current layout as JSON string with schema versioning.
  String exportLayout(Map<String, dynamic> dashboard) {
    final export = {
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'dashboard': dashboard,
    };
    return jsonEncode(export);
  }

  /// Import a layout from JSON string with validation.
  Result<Map<String, dynamic>, String> importLayout(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map) {
        return Result.error('Invalid JSON format: not an object');
      }

      // Handle both versioned and legacy formats
      if (decoded['version'] != null) {
        // Versioned format
        final dashboard = decoded['dashboard'];
        if (dashboard is! Map) {
          return Result.error('Invalid layout: missing dashboard object');
        }
        return Result.success(Map<String, dynamic>.from(dashboard));
      } else {
        // Legacy format (backward compatible)
        return Result.success(Map<String, dynamic>.from(decoded));
      }
    } on FormatException {
      return Result.error('Invalid JSON format');
    } catch (e) {
      return Result.error('Import failed: $e');
    }
  }

  /// Private helper for authentication headers.
  Map<String, String> _authHeaders() {
    // In production, retrieve token from secure storage or auth service
    final headers = {'Content-Type': 'application/json'};
    // TODO: Add actual auth token from AuthService
    // headers['Authorization'] = '***';
    return headers;
  }
}