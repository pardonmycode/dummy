import 'dart:convert';

/// Migration function type: transforms data from an old version to the new version.
typedef SchemaMigration = Map<String, dynamic> Function(Map<String, dynamic> data);

/// A registered schema migration.
class MigrationEntry {
  final String widgetType;
  final int fromVersion;
  final int toVersion;
  final String description;
  final SchemaMigration migrate;

  const MigrationEntry({
    required this.widgetType,
    required this.fromVersion,
    required this.toVersion,
    required this.description,
    required this.migrate,
  });
}

/// Registry for schema migrations.
/// Manages versioned migrations for widget data schemas.
class WidgetMigrationRegistry {
  final List<MigrationEntry> _migrations = [];

  /// Register a migration.
  void addMigration(MigrationEntry entry) {
    // Sort migrations by fromVersion for the same widget type
    _migrations.removeWhere((m) =>
      m.widgetType == entry.widgetType &&
      m.fromVersion == entry.fromVersion &&
      m.toVersion == entry.toVersion
    );
    _migrations.add(entry);
    _migrations.sort((a, b) {
      if (a.widgetType != b.widgetType) return a.widgetType.compareTo(b.widgetType);
      return a.fromVersion.compareTo(b.fromVersion);
    });
  }

  /// Get migrations for a widget type that need to be applied.
  List<MigrationEntry> getPendingMigrations(String widgetType, int currentVersion, int targetVersion) {
    if (currentVersion >= targetVersion) return [];

    final pending = _migrations
        .where((m) =>
          m.widgetType == widgetType &&
          m.fromVersion >= currentVersion &&
          m.fromVersion < targetVersion
        )
        .toList();

    // Sort by fromVersion to apply in sequence
    pending.sort((a, b) => a.fromVersion.compareTo(b.fromVersion));
    return pending;
  }

  /// Apply all pending migrations for a widget instance.
  Future<Map<String, dynamic>> migrateData({
    required String widgetType,
    required Map<String, dynamic> data,
    required int targetVersion,
  }) async {
    final currentVersion = data['schemaVersion'] ?? 1;

    if (currentVersion >= targetVersion) {
      return data;
    }

    var migrated = data;
    var version = currentVersion;

    while (version < targetVersion) {
      final migrations = getPendingMigrations(widgetType, version, targetVersion);
      if (migrations.isEmpty) {
        // No migration defined, bump version anyway
        migrated = _bumpVersion(migrated, version + 1);
        version = version + 1;
        continue;
      }

      // Apply the first migration in sequence
      final migration = migrations.first;
      try {
        migrated = migration.migrate(migrated);
        version = migration.toVersion;
      } catch (e) {
        print('Migration failed for $widgetType (v$version -> v${migration.toVersion}): $e');
        // Return last successful migration
        break;
      }
    }

    // Ensure final version is set correctly
    if (migrated['schemaVersion'] != targetVersion) {
      migrated = _bumpVersion(migrated, targetVersion);
    }

    return migrated;
  }

  Map<String, dynamic> _bumpVersion(Map<String, dynamic> data, int version) {
    final updated = Map<String, dynamic>.from(data);
    updated['schemaVersion'] = version;
    return updated;
  }
}

/// Global migration registry instance.
final widgetMigrationRegistry = WidgetMigrationRegistry();

/// Register built-in schema migrations.
/// Currently no migrations needed — schema versioning happens at the API boundary.
void registerDefaultMigrations([WidgetMigrationRegistry? registry]) {
  // No client-side migrations needed.
  // Schema versioning belongs at the API boundary (see issue 3.7).
}

/// Expected schema version for each widget type.
/// All widgets use schema version 1 — no client-side migrations needed.
Map<String, int> getExpectedSchemaVersions() {
  return {};
}

/// Get expected schema version for a widget type.
int getExpectedVersion(String widgetType) {
  return getExpectedSchemaVersions()[widgetType] ?? 1;
}