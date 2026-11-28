import 'package:material_ui/material_ui.dart';

import '../../../../../../core/i18n/app_localizations.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../framework/widget_data.dart';

/// Distance tracker widget - shows daily distance walked/run.
class DistanceTrackerWidget extends WidgetDefinition<Map<String, dynamic>> {
  @override
  String get id => 'distance_tracker';

  @override
  String get name => 'Distanz';

  @override
  String get description => 'Tägliche Distanz tracken';

  @override
  String get category => 'Gesundheit';

  @override
  IconData get icon => Icons.directions_run;

  @override
  Color get color => Colors.blue;

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
    BuildContext context,
    Map<String, dynamic> data,
    WidgetDataState state,
    WidgetConfig config, {
    void Function(String type, Map<String, dynamic> entry)? onQuickAdd,
  }) {
    final l10n = context.l10n;
    final goal = (data['goal'] as num?)?.toInt() ?? 10000;
    final distance = (data['distance'] as num?)?.toInt() ?? 0;
    final remaining = goal - distance;
    final progress = distance / goal;
    final activities = data['activities'] as List? ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${distance ~/ 1000}${l10n.distanceKm} ${l10n.proteinOf} ${goal ~/ 1000}${l10n.distanceKm}',
                style: AppTheme.titleMedium,
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTheme.labelMedium.copyWith(color: Colors.blue),
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
                          progress >= 1.0 ? Colors.green : Colors.blue,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${distance ~/ 1000}',
                            style: AppTheme.titleSmall,
                          ),
                          Text(l10n.distanceKm, style: AppTheme.labelSmall),
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
                      Text(
                        l10n.metricRemaining(remaining: remaining ~/ 1000, unit: l10n.distanceKm),
                        style: AppTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      if (remaining > 0)
                        Text(l10n.distanceKeepGoing, style: AppTheme.bodySmall)
                      else
                        Text(
                          l10n.goalReached,
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
                final name = activity['name'] ?? l10n.activityName;
                final dist = (activity['distance'] as num?)?.toInt() ?? 0;
                final time = activity['time'] ?? '';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.directions_run, size: 16, color: Colors.grey),
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
                      Text('${dist ~/ 1000}${l10n.distanceKm}', style: AppTheme.labelMedium),
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
