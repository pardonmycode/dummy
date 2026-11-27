import 'package:material_ui/material_ui.dart';
import 'package:widgetly/core/theme/theme.dart';
import 'package:widgetly/features/widgets/framework/widget_definition.dart';
import '../../../framework/widget_data.dart';

/// Generic metric tracker widget for goal-based metrics
/// (sleep, active minutes, distance, body fat, etc.).
class MetricTrackerWidget extends WidgetDefinition {
  final String _id;
  final String _name;
  final String _description;
  final String _unit;
  final IconData _icon;
  final Color _color;
  final String goalKey;
  final String valueKey;
  final double defaultGoal;

  MetricTrackerWidget({
    required String id,
    required String name,
    required String description,
    required String unit,
    required IconData icon,
    required Color color,
    this.goalKey = 'goal',
    this.valueKey = 'value',
    this.defaultGoal = 100,
  })  : _id = id,
        _name = name,
        _description = description,
        _unit = unit,
        _icon = icon,
        _color = color;

  @override
  String get id => _id;

  @override
  String get name => _name;

  @override
  String get description => _description;

  @override
  String get category => 'Gesundheit';

  @override
  IconData get icon => _icon;

  @override
  Color get color => _color;

  @override
  WidgetSize get defaultSize => WidgetSize.medium;

  @override
  List<WidgetConfigField> get configFields => [
    WidgetConfigField(
      key: goalKey,
      label: 'Ziel ($_unit)',
      description: 'Dein tägliches Ziel',
      type: 'number',
      defaultValue: defaultGoal,
      min: 0,
      max: 10000,
      unit: _unit,
    ),
  ];

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

    final goal = (data.data[goalKey] as num?)?.toDouble() ?? defaultGoal;
    final value = (data.data[valueKey] as num?)?.toDouble() ?? 0.0;
    final remaining = goal - value;
    final progress = (value / goal).clamp(0.0, 1.0);
    final activities = data.data['activities'] as List? ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$value $_unit von ${goal.toInt()} $_unit', style: AppTheme.titleMedium),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTheme.labelMedium.copyWith(color: _color),
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
                          progress >= 1.0 ? Colors.green : _color,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$value', style: AppTheme.titleSmall),
                          Text(_unit, style: AppTheme.labelSmall),
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
                      Text('Noch ${remaining.toInt()} $_unit', style: AppTheme.bodyMedium),
                      const SizedBox(height: 4),
                      if (remaining > 0)
                        Text('Weiter so! 💪', style: AppTheme.bodySmall)
                      else
                        Text(
                          'Ziel erreicht! 🎉',
                          style: AppTheme.bodySmall.copyWith(color: Colors.green),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          if (activities.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                final actName = activity['name'] ?? 'Aktivität';
                final actValue = (activity['value'] as num?)?.toDouble() ?? 0.0;
                final time = activity['time'] ?? '';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(_icon, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(actName, style: AppTheme.bodyMedium),
                            if (time.isNotEmpty)
                              Text(time, style: AppTheme.labelSmall),
                          ],
                        ),
                      ),
                      Text('+${actValue.toInt()} $_unit', style: AppTheme.labelMedium),
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