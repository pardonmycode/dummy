/// Interface for widget data repositories.
/// Implementations can be mock, API-backed, or hybrid (stale-while-revalidate).
abstract class WidgetDataRepository {
  /// Fetch data for a widget type with optional configuration.
  Future<Map<String, dynamic>> getData(String widgetType, Map<String, dynamic> config);

  /// Force a refresh of data for a widget type.
  Future<Map<String, dynamic>> refresh(String widgetType, Map<String, dynamic> config);
}
