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
void registerDefaultMigrations() {
  // Weather widget: v1 -> v2 (added feelsLike field)
  widgetMigrationRegistry.addMigration(MigrationEntry(
    widgetType: 'weather',
    fromVersion: 1,
    toVersion: 2,
    description: 'Add feelsLike to current weather data',
    migrate: (data) {
      final updated = jsonDecode(jsonEncode(data)) as Map<String, dynamic>;
      final current = updated['data'] as Map<String, dynamic>?;
      if (current != null && current['feelsLike'] == null) {
        current['feelsLike'] = current['temperature'];
      }
      updated['schemaVersion'] = 2;
      return updated;
    },
  ));

  // Protein tracker: v1 -> v2 (added meals array)
  widgetMigrationRegistry.addMigration(MigrationEntry(
    widgetType: 'protein_tracker',
    fromVersion: 1,
    toVersion: 2,
    description: 'Add meals array to protein tracker',
    migrate: (data) {
      final updated = jsonDecode(jsonEncode(data)) as Map<String, dynamic>;
      final proteinData = updated['data'] as Map<String, dynamic>?;
      if (proteinData != null && proteinData['meals'] == null) {
        proteinData['meals'] = [];
      }
      updated['schemaVersion'] = 2;
      return updated;
    },
  ));

  // Tasks widget: v1 -> v2 (added priority field support)
  widgetMigrationRegistry.addMigration(MigrationEntry(
    widgetType: 'tasks',
    fromVersion: 1,
    toVersion: 2,
    description: 'Add priority field support to tasks',
    migrate: (data) {
      final updated = jsonDecode(jsonEncode(data)) as Map<String, dynamic>;
      final tasksData = updated['data'] as Map<String, dynamic>?;
      if (tasksData != null) {
        final tasks = tasksData['tasks'] as List<dynamic>?;
        if (tasks != null) {
          for (var i = 0; i < tasks.length; i++) {
            final task = tasks[i] as Map<String, dynamic>;
            if (task['priority'] == null) {
              task['priority'] = 'normal';
            }
          }
        }
      }
      updated['schemaVersion'] = 2;
      return updated;
    },
  ));

  // Calendar widget: v1 -> v2 (added freeSlots)
  widgetMigrationRegistry.addMigration(MigrationEntry(
    widgetType: 'calendar',
    fromVersion: 1,
    toVersion: 2,
    description: 'Add freeSlots to calendar data',
    migrate: (data) {
      final updated = jsonDecode(jsonEncode(data)) as Map<String, dynamic>;
      final calData = updated['data'] as Map<String, dynamic>?;
      if (calData != null && calData['freeSlots'] == null) {
        calData['freeSlots'] = [];
      }
      updated['schemaVersion'] = 2;
      return updated;
    },
  ));

  // Medications widget: v1 -> v2 (added type field)
  widgetMigrationRegistry.addMigration(MigrationEntry(
    widgetType: 'medications_tracker',
    fromVersion: 1,
    toVersion: 2,
    description: 'Add type field to medications',
    migrate: (data) {
      final updated = jsonDecode(jsonEncode(data)) as Map<String, dynamic>;
      final medData = updated['data'] as Map<String, dynamic>?;
      if (medData != null) {
        final meds = medData['medications'] as List<dynamic>?;
        if (meds != null) {
          for (var i = 0; i < meds.length; i++) {
            final med = meds[i] as Map<String, dynamic>;
            if (med['type'] == null) {
              med['type'] = 'medication';
            }
          }
        }
      }
      updated['schemaVersion'] = 2;
      return updated;
    },
  ));
}

/// Expected schema version for each widget type.
Map<String, int> getExpectedSchemaVersions() {
  return {
    'weather': 2,
    'protein_tracker': 2,
    'tasks': 2,
    'calendar': 2,
    'medications_tracker': 2,
  };
}

/// Get expected schema version for a widget type.
int getExpectedVersion(String widgetType) {
  return getExpectedSchemaVersions()[widgetType] ?? 1;
}