import 'package:material_ui/material_ui.dart';

import '../../../../../../core/i18n/app_localizations.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../framework/widget_data.dart';

/// Heart rate tracker widget - shows current and resting heart rate.
class HeartRateTrackerWidget extends WidgetDefinition<Map<String, dynamic>> {
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
    final current = (data['current'] as num?)?.toInt() ?? 0;
    final resting = (data['resting'] as num?)?.toInt() ?? 0;
    final max = (data['max'] as num?)?.toInt() ?? 0;
    final trend = data['trend'] as String? ?? 'stable';

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
                  Text(l10n.heartRateCurrent, style: AppTheme.labelSmall),
                  Text('$current ${l10n.heartRateBpm}', style: AppTheme.titleMedium),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l10n.heartRateResting, style: AppTheme.labelSmall),
                  Text('$resting ${l10n.heartRateBpm}', style: AppTheme.titleSmall),
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
                  Text(l10n.heartRateMax, style: AppTheme.bodySmall),
                  Text('$max ${l10n.heartRateBpm}', style: AppTheme.bodyMedium),
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
                const Icon(Icons.heart_broken, size: 16, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trend == 'down'
                        ? l10n.heartRateImproving
                        : l10n.heartRateStable,
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
