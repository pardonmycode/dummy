import 'package:material_ui/material_ui.dart';

import '../../../../../../core/models/tracker_base.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../framework/widget_data.dart';
import '../../../ui/components/design_system.dart';
import '../../../water/data/water_data.dart';

/// Water intake tracker widget using typed WaterData model.
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

  /// Parse raw data into typed WaterData model.
  WaterData _parseData(WidgetData data) {
    try {
      final consumed = (data.data['consumed'] as num?) ?? 0;
      final goal = (data.data['goal'] as num?) ?? 2000;
      
      final rawEntries = data.data['entries'] as List? ?? [];
      final entries = <WaterEntry>[];
      for (final entry in rawEntries) {
        if (entry is Map && entry['amountMl'] != null) {
          entries.add(WaterEntry(
            amountMl: entry['amountMl'] as num,
            timestamp: DateTime.parse(entry['timestamp']?.toString() ?? ''),
          ));
        }
      }
      
      return WaterData(consumed: consumed, goal: goal, entries: entries);
    } catch (e) {
      // Fallback: compute from TrackerBase entries
      final tracker = TrackerBase(
        target: (data.data['goal'] as num?) ?? 2000,
        unit: 'ml',
        period: TimePeriod.day,
      );
      final rawEntries = data.data['entries'] as List? ?? [];
      for (final entry in rawEntries) {
        if (entry is Map && entry['value'] != null) {
          tracker.entries.add(TrackerEntry(
            value: entry['value'],
            timestamp: DateTime.parse(entry['timestamp']?.toString() ?? ''),
          ));
        }
      }
      return WaterData(
        consumed: tracker.getPeriodTotal(),
        goal: tracker.target,
      );
    }
  }

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

    // Parse raw data into typed model
    final typedData = _parseData(data);
    final goal = typedData.goal;
    final consumed = typedData.consumed;
    final progress = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
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

        // Add water button
        ActionButton(
          label: '+ 250ml',
          icon: Icons.add,
          primary: true,
          width: 120,
          onPressed: () {
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
