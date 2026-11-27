import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'widget_data_repository.dart';

/// API-backed implementation of WidgetDataRepository.
/// Requires the backend API to be available at the given base URL.
class ApiWidgetDataRepository implements WidgetDataRepository {
  final String baseUrl;

  ApiWidgetDataRepository({required this.baseUrl});

  @override
  Future<Map<String, dynamic>> getData(String widgetType, Map<String, dynamic> config) async {
    final url = Uri.parse('$baseUrl/api/widgets/$widgetType');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('API returned ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to fetch $widgetType data: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> refresh(String widgetType, Map<String, dynamic> config) async {
    return getData(widgetType, config);
  }
}
