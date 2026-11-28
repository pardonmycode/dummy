import 'package:material_ui/material_ui.dart';

import '../../../../../../core/models/tracker_base.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../framework/widget_data.dart';
import '../../../protein/data/protein_data.dart';

/// Protein tracker widget using typed ProteinData model.
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
  List<WidgetConfigField> get configFields => [
    WidgetConfigField(
      key: 'goal',
      label: 'Tagesziel (g)',
      description: 'Dein tägliches Protein-Ziel in Gramm',
      type: 'number',
      defaultValue: 150,
      min: 50,
      max: 500,
      unit: 'g',
    ),
  ];

  /// Parse raw data into typed ProteinData model.
  ProteinData _parseData(WidgetData data) {
    try {
      final consumed = (data.data['consumed'] as num?) ?? 0;
      final goal = (data.data['goal'] as num?) ?? 150;
      final rawMeals = data.data['meals'] as List? ?? [];
      
      final meals = <ProteinMeal>[];
      for (final meal in rawMeals) {
        if (meal is Map) {
          meals.add(ProteinMeal(
            name: meal['name']?.toString() ?? 'Mahlzeit',
            protein: (meal['protein'] as num?) ?? 0,
            time: meal['time']?.toString(),
          ));
        }
      }
      
      return ProteinData(consumed: consumed, goal: goal, meals: meals);
    } catch (e) {
      // Fallback: compute from entries using TrackerBase
      final tracker = TrackerBase(
        target: (data.data['goal'] as num?) ?? 150,
        unit: 'g',
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
      return ProteinData(
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
    final meals = typedData.meals;
    final remaining = goal - consumed;
    final progress = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${consumed}g von ${goal}g', style: AppTheme.titleMedium),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTheme.labelMedium.copyWith(color: AppTheme.primary),
              ),
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
                        Text(
                          'ca. ${remaining ~/ 25} weitere Mahlzeiten',
                          style: AppTheme.bodySmall,
                        )
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

          // Meal log
          if (meals.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
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
                            Text(meal.name, style: AppTheme.bodyMedium),
                            if (meal.time != null && meal.time!.isNotEmpty)
                              Text(meal.time!, style: AppTheme.labelSmall),
                          ],
                        ),
                      ),
                      Text('+${meal.protein}g', style: AppTheme.labelMedium),
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
