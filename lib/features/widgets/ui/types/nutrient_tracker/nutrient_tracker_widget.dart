import 'package:material_ui/material_ui.dart';
import 'package:widgetly/core/models/tracker_base.dart';
import 'package:widgetly/core/theme/theme.dart';
import 'package:widgetly/features/widgets/framework/widget_definition.dart';
import '../../../framework/widget_data.dart';

/// Generic nutrient/metric tracker widget that can be configured
/// for any tracker type (protein, carbs, calories, water, etc.).
class NutrientTrackerWidget extends WidgetDefinition {
  final String nutrient;
  final String unit;
  final String defaultGoalKey;
  final String entryKey;
  final double defaultGoal;

  NutrientTrackerWidget({
    required this.nutrient,
    required this.unit,
    required this.defaultGoalKey,
    this.entryKey = 'entries',
    this.defaultGoal = 150,
  });

  @override
  String get id => '${nutrient}_tracker';

  @override
  String get name => _getNutrientName(nutrient);

  @override
  String get description => 'Tägliche ${name}-Aufnahme tracken';

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
      key: defaultGoalKey,
      label: 'Tagesziel ($unit)',
      description: 'Dein tägliches ${name}-Ziel',
      type: 'number',
      defaultValue: defaultGoal,
      min: 0,
      max: 10000,
      unit: unit,
    ),
  ];

  String _getNutrientName(String nutrient) {
    switch (nutrient) {
      case 'protein': return 'Proteine';
      case 'carbs': return 'Kohlenhydrate';
      case 'fat': return 'Fett';
      case 'fiber': return 'Ballaststoffe';
      case 'sugar': return 'Zucker';
      case 'caffeine': return 'Koffein';
      case 'water': return 'Wasser';
      case 'calories': return 'Kalorien';
      default: return nutrient;
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

    final goalKey = config.get(defaultGoalKey);
    final tracker = TrackerBase(
      target: goalKey ?? defaultGoal,
      unit: unit,
      period: TimePeriod.day,
    );

    // Parse entries from data
    final rawEntries = data.data[entryKey] as List? ?? [];
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
    final remaining = goal - consumed;
    final progress = tracker.calculateProgress();
    final streak = tracker.calculateStreak();
    final meals = data.data['meals'] as List? ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${consumed}$unit von ${goal}$unit', style: AppTheme.titleMedium),
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
                          Text(unit, style: AppTheme.labelSmall),
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
                      Text('Noch ${remaining}$unit', style: AppTheme.bodyMedium),
                      if (streak > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text('$streak Tage Streak', style: AppTheme.labelSmall),
                            ],
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
                final mealName = meal['name'] ?? 'Eintrag';
                final mealValue = (meal[nutrient] as num?)?.toInt() ?? 0;
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
                      Text('+${mealValue}$unit', style: AppTheme.labelMedium),
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
