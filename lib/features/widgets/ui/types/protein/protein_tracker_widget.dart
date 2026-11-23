import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';

/// Protein tracker widget - shows daily protein intake with goal progress.
class ProteinTrackerWidget extends WidgetDefinition {
  @override
  String get id => 'protein_tracker';

  @override
  String get name => 'Proteine';

  @override
  String get description => 'Tägliche Protein-Aufnahme tracken';

  @override
  String get category => 'Gesundheit';

  @override
  IconData get icon => Icons.fitness_center;

  @override
  Color get color => AppTheme.primary;

  @override
  WidgetSize get defaultSize => WidgetSize.medium;

  @override
  Widget buildView(WidgetData? data, WidgetDataState state, WidgetConfig config) {
    if (data == null) {
      return const SizedBox();
    }

    final goal = (data.data['goal'] as num?)?.toInt() ?? 150;
    final consumed = (data.data['consumed'] as num?)?.toInt() ?? 0;
    final remaining = goal - consumed;
    final progress = consumed / goal;
    final meals = data.data['meals'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${consumed}g von ${goal}g', style: AppTheme.titleMedium),
            Text('${(progress * 100).toInt()}%',
                style: AppTheme.labelMedium
                    .copyWith(color: AppTheme.primary)),
          ],
        ),
        const SizedBox(height: 8),

        // Progress ring
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
                        progress >= 1.0 ? Colors.green : AppTheme.primary,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$consumed', style: AppTheme.titleSmall),
                        Text('g', style: AppTheme.labelSmall),
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
                    Text('Noch ${remaining}g', style: AppTheme.bodyMedium),
                    const SizedBox(height: 4),
                    if (remaining > 0)
                      Text('ca. ${remaining ~/ 25} weitere Mahlzeiten',
                          style: AppTheme.bodySmall)
                    else
                      Text('Ziel erreicht! 🎉',
                          style: AppTheme.bodySmall
                              .copyWith(color: Colors.green)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Meal log
        Expanded(
          child: meals.isEmpty
              ? const Center(
                  child: Text('Keine Mahlzeiten geloggt',
                      style: AppTheme.bodySmall))
              : ListView.builder(
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    final mealName = meal['name'] ?? 'Mahlzeit';
                    final mealProtein = (meal['protein'] as num?)?.toInt() ?? 0;
                    final mealTime = meal['time'] ?? '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.restaurant,
                              size: 16, color: Colors.grey),
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
                          Text('+${mealProtein}g',
                              style: AppTheme.labelMedium),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
