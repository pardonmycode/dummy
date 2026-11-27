import 'package:material_ui/material_ui.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../framework/widget_data.dart';

/// Mood tracker widget - shows current mood and weekly trend.
class MoodTrackerWidget extends WidgetDefinition {
  @override
  String get id => 'mood_tracker';

  @override
  String get name => 'Stimmung';

  @override
  String get description => 'Tägliche Stimmung tracken';

  @override
  String get category => 'Gesundheit';

  @override
  IconData get icon => Icons.sentiment_satisfied;

  @override
  Color get color => AppTheme.accent;

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

    final mood = (data.data['mood'] as num?)?.toInt() ?? 3;
    final note = data.data['note'] as String? ?? '';
    final week = data.data['week'] as List<dynamic>? ?? [];

    final moodIcons = [
      Icons.sentiment_very_dissatisfied,
      Icons.sentiment_dissatisfied,
      Icons.sentiment_neutral,
      Icons.sentiment_satisfied,
      Icons.sentiment_very_satisfied,
    ];

    final moodColors = [
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.green,
      Colors.deepPurple,
    ];

    final moodLabels = [
      'Sehr schlecht',
      'Schlecht',
      'Neutral',
      'Gut',
      'Sehr gut',
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's mood
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: moodColors[mood - 1].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              children: [
                Icon(
                  moodIcons[mood - 1],
                  size: 24,
                  color: moodColors[mood - 1],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Heute', style: AppTheme.labelSmall),
                      Text(moodLabels[mood - 1], style: AppTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(note, style: AppTheme.bodySmall),
          ],

          // Weekly trend
          if (week.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: week.map((dayMood) {
                final dayMoodInt = (dayMood as num).toInt();
                return Icon(
                  moodIcons[dayMoodInt - 1],
                  size: 16,
                  color: moodColors[dayMoodInt - 1],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
