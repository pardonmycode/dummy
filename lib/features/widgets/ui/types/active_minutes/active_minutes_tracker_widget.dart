import 'package:material_ui/material_ui.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../framework/widget_data.dart';

/// Active minutes tracker widget - shows daily activity time.
class ActiveMinutesTrackerWidget extends WidgetDefinition<Map<String, dynamic>> {
  @override
  String get id => 'active_minutes_tracker';

  @override
  String get name => 'Aktive Minuten';

  @override
  String get description => 'Tägliche aktive Minuten tracken';

  @override
  String get category => 'Gesundheit';

  @override
  IconData get icon => Icons.sports_score;

  @override
  Color get color => Colors.teal;

  @override
  WidgetSize get defaultSize => WidgetSize.medium;

  @override
  @override
  Map<String, dynamic> parseData(WidgetData? data) {
    if (data == null) {
      return {};
    }
    return data.data;
  }


  @override
  Widget buildView(
    Map<String, dynamic> data,
    WidgetDataState state,
    WidgetConfig config, {
    void Function(String type, Map<String, dynamic> entry)? onQuickAdd,
  }) {
    final goal = (data['goal'] as num?)?.toInt() ?? 60;
    final minutes = (data['minutes'] as num?)?.toInt() ?? 0;
    final remaining = goal - minutes;
    final progress = minutes / goal;
    final activities = data['activities'] as List? ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${minutes}min von ${goal}min', style: AppTheme.titleMedium),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTheme.labelMedium.copyWith(color: Colors.teal),
              ),
            ],
          ),
          const SizedBox(height: 8),

          AspectRatio(
            aspectRatio: 1.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                          progress >= 1.0 ? Colors.green : Colors.teal,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$minutes', style: AppTheme.titleSmall),
                          Text('min', style: AppTheme.labelSmall),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Noch ${remaining}min', style: AppTheme.bodyMedium),
                      const SizedBox(height: 4),
                      if (remaining > 0)
                        Text('Weiter so! 🏃', style: AppTheme.bodySmall)
                      else
                        Text(
                          'Ziel erreicht! 🎉',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          if (activities.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                final name = activity['name'] ?? 'Aktivität';
                final mins = (activity['minutes'] as num?)?.toInt() ?? 0;
                final time = activity['time'] ?? '';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.sports_score, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: AppTheme.bodyMedium),
                            if (time.isNotEmpty)
                              Text(time, style: AppTheme.labelSmall),
                          ],
                        ),
                      ),
                      Text('$mins min', style: AppTheme.labelMedium),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
