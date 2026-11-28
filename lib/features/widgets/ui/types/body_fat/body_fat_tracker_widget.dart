import 'package:material_ui/material_ui.dart';

import '../../../../../../core/i18n/app_localizations.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../framework/widget_data.dart';

/// Body fat tracker widget - shows body fat percentage and progress.
class BodyFatTrackerWidget extends WidgetDefinition<Map<String, dynamic>> {
  @override
  String get id => 'body_fat_tracker';

  @override
  String get name => 'Körperfett';

  @override
  String get description => 'Körperfettprozentsatz tracken';

  @override
  String get category => 'Gesundheit';

  @override
  IconData get icon => Icons.fitness_center;

  @override
  Color get color => AppTheme.accent;

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
    final current = (data['current'] as num?)?.toDouble() ?? 0.0;
    final goal = (data['goal'] as num?)?.toDouble() ?? 0.0;
    final start = (data['start'] as num?)?.toDouble() ?? current;
    final trend = data['trend'] as String? ?? 'stable';

    final progress = (start - goal) != 0
        ? (current - start) / (start - goal)
        : 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${current.toStringAsFixed(1)}%',
                style: AppTheme.titleMedium,
              ),
              Text(
                '${l10n.weightGoal}: ${goal.toStringAsFixed(1)}%',
                style: AppTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),

          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0).toDouble(),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
          ),
          const SizedBox(height: 4),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              children: [
                Icon(
                  trend == 'down' ? Icons.trending_down : Icons.remove,
                  size: 16,
                  color: AppTheme.accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trend == 'down'
                        ? '${l10n.bodyFatLabel} ${l10n.takingOff}'
                        : '${l10n.bodyFatLabel} ${l10n.stableLabel}',
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
