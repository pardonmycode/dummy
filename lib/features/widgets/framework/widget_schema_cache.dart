/// Caches compiled JSON schemas per widget type so they're not
/// recompiled on every widget data validation.
class WidgetSchemaCache {
  final Map<String, dynamic> _cache = {};

  /// Get or create a compiled schema for the given widget type.
  /// If the schema for this type already exists, returns the cached instance.
  dynamic getOrCreate(String widgetType, Map<String, dynamic> schemaDefinition) {
    if (_cache.containsKey(widgetType)) {
      return _cache[widgetType];
    }
    
    // In a real implementation, this would compile the schema using
    // the json_schema package. For now, we cache the definition directly.
    _cache[widgetType] = schemaDefinition;
    return schemaDefinition;
  }

  /// Clear all cached schemas.
  void clear() {
    _cache.clear();
  }

  /// Number of cached schemas.
  int get size => _cache.length;
}
