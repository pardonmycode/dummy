import 'package:flutter/material.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';

/// Steps tracker widget.
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

    final goal = (data.data['goal'] as num?)?.toInt() ?? 10000;
    final steps = (data.data['steps'] as num?)?.toInt() ?? 0;
    final progress = steps / goal;
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
