import 'package:material_ui/material_ui.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';

/// Heart rate tracker widget - shows current and resting heart rate.
class HeartRateTrackerWidget extends WidgetDefinition {
  @override
  String get id => 'heart_rate_tracker';

  @override
  String get name => 'Puls';

  @override
  String get description => 'Puls und Ruhepuls tracken';

  @override
  String get category => 'Gesundheit';

  @override
  IconData get icon => Icons.favorite;

  @override
  Color get color => Colors.red;

  @override
  WidgetSize get defaultSize => WidgetSize.medium;

  @override
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

    final current = (data.data['current'] as num?)?.toInt() ?? 0;
    final resting = (data.data['resting'] as num?)?.toInt() ?? 0;
    final max = (data.data['max'] as num?)?.toInt() ?? 0;
    final trend = data.data['trend'] as String? ?? 'stable';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aktuell', style: AppTheme.labelSmall),
                  Text('${current} bpm', style: AppTheme.titleMedium),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Ruhepuls', style: AppTheme.labelSmall),
                  Text('${resting} bpm', style: AppTheme.titleSmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (max > 0)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Max heute', style: AppTheme.bodySmall),
                  Text('${max} bpm', style: AppTheme.bodyMedium),
                ],
              ),
            ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              children: [
                Icon(Icons.heart_broken, size: 16, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trend == 'down'
                        ? 'Ruhepuls verbessert sich'
                        : 'Ruhepuls stabil',
                    style: AppTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
