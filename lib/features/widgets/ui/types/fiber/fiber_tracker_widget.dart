import 'package:material_ui/material_ui.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';

/// Fiber tracker widget - shows daily fiber intake with goal progress.
class FiberTrackerWidget extends WidgetDefinition {
  @override
  String get id => 'fiber_tracker';

  @override
  String get name => 'Ballaststoffe';

  @override
  String get description => 'Tägliche Ballaststoff-Aufnahme tracken';

  @override
  String get category => 'Gesundheit';

  @override
  IconData get icon => Icons.grass;

  @override
  Color get color => Colors.green;

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

    final goal = (data.data['goal'] as num?)?.toInt() ?? 30;
    final consumed = (data.data['consumed'] as num?)?.toInt() ?? 0;
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
              Text('${consumed}g von ${goal}g', style: AppTheme.titleMedium),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTheme.labelMedium.copyWith(color: Colors.green),
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
                          progress >= 1.0 ? Colors.green : Colors.green,
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
                          'Mehr Obst und Gemüse hilft!',
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

          if (meals.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                final mealName = meal['name'] ?? 'Mahlzeit';
                final mealFiber = (meal['fiber'] as num?)?.toInt() ?? 0;
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
                      Text('+${mealFiber}g', style: AppTheme.labelMedium),
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
