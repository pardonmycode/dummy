import 'package:material_ui/material_ui.dart';

import '../../../../../../core/i18n/app_localizations.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../framework/widget_data.dart';

/// Calorie tracker widget - shows daily calorie intake with goal progress.
class CalorieTrackerWidget extends WidgetDefinition<Map<String, dynamic>> {
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
    final goal = (data['goal'] as num?)?.toInt() ?? 2000;
    final consumed = (data['consumed'] as num?)?.toInt() ?? 0;
    final burned = (data['burned'] as num?)?.toInt() ?? 0;
    final remaining = goal - consumed;
    final progress = consumed / goal;
    final meals = data['meals'] as List? ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$consumed ${l10n.caloriesOf} $goal ${l10n.caloriesUnit}', style: AppTheme.titleMedium),
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
                          Text(l10n.caloriesUnit, style: AppTheme.labelSmall),
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
                        'Noch $remaining ${l10n.caloriesUnit}',
                        style: AppTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.caloriesBurned(burned: burned),
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
                final mealName = meal['name'] ?? l10n.caloriesMealName;
                final mealCalories = (meal['calories'] as num?)?.toInt() ?? 0;
                final mealTime = meal['time'] ?? '';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.restaurant, size: 16, color: Colors.grey),
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
                      Text(l10n.caloriesMeal(amount: mealCalories), style: AppTheme.labelMedium),
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
