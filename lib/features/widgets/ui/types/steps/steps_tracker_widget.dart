import 'package:material_ui/material_ui.dart';

import '../../../../../../core/i18n/app_localizations.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../framework/widget_data.dart';
import '../../../steps/data/steps_data.dart';

/// Steps tracker widget using typed StepsData model.
class StepsTrackerWidget extends WidgetDefinition<StepsData> {
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

  /// Parse raw data into typed StepsData model.
  @override
  StepsData parseData(WidgetData? data) {
    if (data == null) {
      return StepsData.fromJson({});
    }
    try {
      return StepsData(
        steps: (data.data['steps'] as num?) ?? 0,
        goal: (data.data['goal'] as num?) ?? 10000,
        distanceKm: (data.data['distanceKm'] as num?) ?? 0,
        calories: (data.data['calories'] as num?) ?? 0,
        streak: (data.data['streak'] as int?) ?? 0,
      );
    } catch (e) {
      // Fallback to fromJson
      return StepsData.fromJson(data.data);
    }
  }

  @override
  Widget buildView(

      BuildContext context,

      StepsData data,
    WidgetDataState state,
    WidgetConfig config, {
    void Function(String type, Map<String, dynamic> entry)? onQuickAdd,
  }) {
    final l10n = context.l10n;
    final steps = data.steps;
    final goal = data.goal;
    final distance = data.distanceKm;
    final calories = data.calories;
    final streak = data.streak;

    final progress = goal > 0 ? (steps / goal).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$steps ${l10n.stepsLabel}', style: AppTheme.titleMedium),
            const Icon(Icons.directions_walk, color: AppTheme.success),
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
                  Text(l10n.stepsGoalLabel, style: AppTheme.labelSmall),
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
              const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
              const SizedBox(width: 4),
              Text(l10n.stepsStreak(streak: streak), style: AppTheme.labelMedium),
            ],
          ),
        const SizedBox(height: 4),

        // Stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('${distance.toStringAsFixed(1)} ${l10n.distanceKm}', style: AppTheme.bodyMedium),
                Text(l10n.stepsDistanceLabel, style: AppTheme.labelSmall),
              ],
            ),
            Column(
              children: [
                Text('${calories.toInt()} ${l10n.caloriesUnit}', style: AppTheme.bodyMedium),
                Text(l10n.stepsCaloriesLabel, style: AppTheme.labelSmall),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
