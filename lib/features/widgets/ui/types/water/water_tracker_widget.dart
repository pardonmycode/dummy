import 'package:material_ui/material_ui.dart';

import '../../../../../../core/models/tracker_base.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../framework/widget_data.dart';
import '../../../ui/components/design_system.dart';

/// Water intake tracker widget using shared TrackerBase model.
class WaterTrackerWidget extends WidgetDefinition {
  @override
  String get id => 'water_tracker';

  @override
  String get name => 'Wasser';

  @override
  String get description => 'Tägliche Wasseraufnahme tracken';

  @override
  String get category => 'Gesundheit';

  @override
  IconData get icon => Icons.water_drop;

  @override
  Color get color => AppTheme.info;

  @override
  WidgetSize get defaultSize => WidgetSize.medium;

  @override
  @override
  Widget buildView(
    WidgetData? data,
    WidgetDataState state,
    WidgetConfig config, {
    void Function(String type, Map<String, dynamic> entry)? onQuickAdd,
  }) {
    if (data == null) {
      return const SizedBox();
    }

    // Use shared TrackerBase model
    final tracker = TrackerBase(
      target: (data.data['goal'] as num?) ?? 2000,
      unit: 'ml',
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

    final goal = tracker.target;
    final consumed = tracker.getPeriodTotal();
    final progress = tracker.calculateProgress();
    final streak = tracker.calculateStreak();
    final glasses = consumed ~/ 250;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${consumed}ml von ${goal}ml', style: AppTheme.titleMedium),
            Icon(Icons.water_drop, color: AppTheme.info),
          ],
        ),
        const SizedBox(height: 8),

        // Water glasses visualization
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(8, (index) {
            final isFilled = index < glasses;
            return Icon(
              Icons.water_drop,
              size: 24,
              color: isFilled ? AppTheme.info : Colors.grey.shade300,
            );
          }),
        ),
        const SizedBox(height: 8),

        // Progress
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          color: AppTheme.info,
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

        // Add water button
        ActionButton(
          label: '+ 250ml',
          icon: Icons.add,
          primary: true,
          width: 120,
          onPressed: () {
            // Quick add using TrackerBase
            tracker.addEntry(250, note: 'Wasser');
            // Report the entry so it can be persisted
            if (onQuickAdd != null) {
              onQuickAdd('water', {
                'value': 250,
                'timestamp': DateTime.now().toIso8601String(),
                'note': 'Wasser',
              });
            }
          },
        ),
      ],
    );
  }
}
