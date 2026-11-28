import 'package:material_ui/material_ui.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../framework/widget_data.dart';

/// Sleep tracker widget - shows sleep duration and quality.
class SleepTrackerWidget extends WidgetDefinition<Map<String, dynamic>> {
  @override
  String get id => 'sleep_tracker';

  @override
  String get name => 'Schlaf';

  @override
  String get description => 'Schlafdauer und -qualität tracken';

  @override
  String get category => 'Gesundheit';

  @override
  IconData get icon => Icons.bedtime;

  @override
  Color get color => AppTheme.accent;

  @override
  WidgetSize get defaultSize => WidgetSize.medium;

  @override
  List<WidgetConfigField> get configFields => [
    WidgetConfigField(
      key: 'goal',
      label: 'Schlafziel (h)',
      description: 'Dein tägliches Schlafziel in Stunden',
      type: 'number',
      defaultValue: 8,
      min: 4,
      max: 12,
      unit: 'h',
    ),
  ];

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
    final goal = (data['goal'] as num?)?.toInt() ?? 8;
    final slept = (data['slept'] as num?)?.toDouble() ?? 0.0;
    final quality = (data['quality'] as num?)?.toInt() ?? 0;
    final progress = slept / goal;
    final remaining = (goal - slept).round();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${slept}h von ${goal}h', style: AppTheme.titleMedium),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTheme.labelMedium.copyWith(color: AppTheme.accent),
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
                          progress >= 1.0 ? Colors.green : AppTheme.accent,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${slept.toInt()}', style: AppTheme.titleSmall),
                          Text('h', style: AppTheme.labelSmall),
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
                      Text('Noch ${remaining}h', style: AppTheme.bodyMedium),
                      const SizedBox(height: 4),
                      if (quality > 0)
                        Text(
                          'Qualität: ${quality}/10',
                          style: AppTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Sleep score
          if (quality > 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(Icons.nights_stay, size: 16, color: AppTheme.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      quality >= 7
                          ? 'Gute Schlafqualität'
                          : 'Verbesserungspotenzial',
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
