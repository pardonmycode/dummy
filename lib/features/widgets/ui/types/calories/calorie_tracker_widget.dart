import 'package:flutter/material.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';

/// Calorie tracker widget - shows daily calorie intake with goal progress.
class CalorieTrackerWidget extends WidgetDefinition {
  @override
  String get id => 'calorie_tracker';

  @override
  String get name => 'Kalorien';

  @override
  String get description => 'Tägliche Kalorienaufnahme tracken';

  @override
  String get category => 'Gesundheit';

  @override
  IconData get icon => Icons.local_fire_department;

  @override
  Color get color => Colors.red;

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

    final goal = (data.data['goal'] as num?)?.toInt() ?? 2000;
    final consumed = (data.data['consumed'] as num?)?.toInt() ?? 0;
    final burned = (data.data['burned'] as num?)?.toInt() ?? 0;
    final remaining = goal - consumed;
    final progress = consumed / goal;
    final meals = data.data['meals'] as List? ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${consumed} von ${goal} kcal', style: AppTheme.titleMedium),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTheme.labelMedium.copyWith(color: Colors.red),
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
                          progress >= 1.0 ? Colors.green : Colors.red,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${consumed ~/ 100}',
                            style: AppTheme.titleSmall,
                          ),
                          Text('h kcal', style: AppTheme.labelSmall),
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
                        'Noch ${remaining} kcal',
                        style: AppTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Verbrannt heute: ${burned} kcal',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          if (meals.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                final mealName = meal['name'] ?? 'Mahlzeit';
                final mealCalories = (meal['calories'] as num?)?.toInt() ?? 0;
                final mealTime = meal['time'] ?? '';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.restaurant, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mealName, style: AppTheme.bodyMedium),
                            if (mealTime.isNotEmpty)
                              Text(mealTime, style: AppTheme.labelSmall),
                          ],
                        ),
                      ),
                      Text('$mealCalories kcal', style: AppTheme.labelMedium),
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
