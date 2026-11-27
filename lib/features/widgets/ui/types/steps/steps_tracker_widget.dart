import 'package:material_ui/material_ui.dart';

import '../../../../../../core/models/tracker_base.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';

/// Steps tracker widget using shared TrackerBase model.
class StepsTrackerWidget extends WidgetDefinition {
  @override
  String get id => 'steps_tracker';

  @override
  String get name => 'Schritte';

  @override
  String get description => 'Tägliche Schritte tracken';

  @override
  String get category => 'Gesundheit';

  @override
  IconData get icon => Icons.directions_walk;

  @override
  Color get color => AppTheme.success;

  @override
  WidgetSize get defaultSize => WidgetSize.medium;

  @override
  Widget buildView(
    WidgetData? data,
    WidgetDataState state,
    WidgetConfig config,
  ) {
    if (data == null) {
      return const SizedBox();
    }

    // Use shared TrackerBase model
    final tracker = TrackerBase(
      target: (data.data['goal'] as num?) ?? 10000,
      unit: 'Schritte',
      period: TimePeriod.day,
    );

    // Parse entries from data
    final rawEntries = data.data['entries'] as List? ?? [];
    for (final entry in rawEntries) {
      if (entry is Map && entry['value'] != null && entry['timestamp'] != null) {
        tracker.entries.add(TrackerEntry(
          value: entry['value'],
          timestamp: DateTime.parse(entry['timestamp']),
          note: entry['note'],
        ));
      }
    }

    final steps = tracker.getPeriodTotal();
    final progress = tracker.calculateProgress();
    final streak = tracker.calculateStreak();
    final distance = steps * 0.00076; // Average step length in km

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$steps Schritte', style: AppTheme.titleMedium),
            Icon(Icons.directions_walk, color: AppTheme.success),
          ],
        ),
        const SizedBox(height: 8),

        // Progress ring
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? Colors.green : AppTheme.success,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: AppTheme.titleSmall,
                  ),
                  Text('Ziel', style: AppTheme.labelSmall),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Streak
        if (streak > 0)
          Row(
            children: [
              Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
              const SizedBox(width: 4),
              Text('$streak Tage Streak', style: AppTheme.labelMedium),
            ],
          ),
        const SizedBox(height: 4),

        // Stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  '${distance.toStringAsFixed(1)} km',
                  style: AppTheme.bodyMedium,
                ),
                Text('Distanz', style: AppTheme.labelSmall),
              ],
            ),
            Column(
              children: [
                Text(
                  '${(distance * 60).toInt()} kcal',
                  style: AppTheme.bodyMedium,
                ),
                Text('Kalorien', style: AppTheme.labelSmall),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
