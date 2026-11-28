import 'package:material_ui/material_ui.dart';

import '../../../../../../core/i18n/app_localizations.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../framework/widget_data.dart';

/// Carbs tracker widget - shows daily carb intake with goal progress.
class CarbsTrackerWidget extends WidgetDefinition<Map<String, dynamic>> {
  @override
  String get id => 'carbs_tracker';

  @override
  String get name => 'Kohlenhydrate';

  @override
  String get description => 'Tägliche Kohlenhydrat-Aufnahme tracken';

  @override
  String get category => 'Gesundheit';

  @override
  IconData get icon => Icons.grain;

  @override
  Color get color => AppTheme.warning;

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
    final goal = (data['goal'] as num?)?.toInt() ?? 300;
    final consumed = (data['consumed'] as num?)?.toInt() ?? 0;
    final remaining = goal - consumed;
    final progress = consumed / goal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${consumed}g ${l10n.carbsOf} ${goal}g', style: AppTheme.titleMedium),
            Text(
              '${(progress * 100).toInt()}%',
              style: AppTheme.labelMedium.copyWith(color: AppTheme.warning),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress bar
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 1.0 ? Colors.green : AppTheme.warning,
          ),
        ),
        const SizedBox(height: 8),

        // Stats
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Column(
                  children: [
                    Text(l10n.carbsRemaining(remaining: remaining), style: AppTheme.bodyMedium),
                    Text(l10n.carbsToGoal, style: AppTheme.labelSmall),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Column(
                  children: [
                    Text('${consumed}', style: AppTheme.bodyMedium),
                    Text(l10n.carbsEaten, style: AppTheme.labelSmall),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
