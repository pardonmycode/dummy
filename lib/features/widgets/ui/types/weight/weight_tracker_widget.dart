import 'package:material_ui/material_ui.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';

/// Weight tracker widget - shows current weight, goal, and progress.
class WeightTrackerWidget extends WidgetDefinition {
  @override
  String get id => 'weight_tracker';

  @override
  String get name => 'Gewicht';

  @override
  String get description => 'Gewichtsverlauf und Ziel tracken';

  @override
  String get category => 'Gesundheit';

  @override
  IconData get icon => Icons.scale;

  @override
  Color get color => AppTheme.primary;

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

    final current = (data.data['current'] as num?)?.toDouble() ?? 0.0;
    final goal = (data.data['goal'] as num?)?.toDouble() ?? 0.0;
    final start = (data.data['start'] as num?)?.toDouble() ?? current;
    final trend = data.data['trend'] as String? ?? 'stable';
    final lastChange = data.data['lastChange'] as String? ?? '';

    final diff = current - goal;
    final progress = (start - goal) != 0
        ? (current - start) / (start - goal)
        : 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current weight display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aktuell', style: AppTheme.labelSmall),
                  Text(
                    '${current.toStringAsFixed(1)} kg',
                    style: AppTheme.titleMedium,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Ziel', style: AppTheme.labelSmall),
                  Text(
                    '${goal.toStringAsFixed(1)} kg',
                    style: AppTheme.titleSmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0).toDouble(),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
          const SizedBox(height: 4),

          // Diff text
          Text(
            diff > 0
                ? 'Noch ${diff.toStringAsFixed(1)} kg abnehmen'
                : 'Ziel erreicht! 🎉',
            style: AppTheme.bodySmall,
          ),
          const SizedBox(height: 8),

          // Trend indicator
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _trendColor(trend).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              children: [
                Icon(_trendIcon(trend), size: 16, color: _trendColor(trend)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_trendText(trend), style: AppTheme.bodyMedium),
                      if (lastChange.isNotEmpty)
                        Text(lastChange, style: AppTheme.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _trendColor(String trend) {
    switch (trend) {
      case 'down':
        return Colors.green;
      case 'up':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _trendIcon(String trend) {
    switch (trend) {
      case 'down':
        return Icons.trending_down;
      case 'up':
        return Icons.trending_up;
      default:
        return Icons.remove;
    }
  }

  String _trendText(String trend) {
    switch (trend) {
      case 'down':
        return 'Gewichtsabnahme';
      case 'up':
        return 'Gewichtszunahme';
      default:
        return 'Gewicht stabil';
    }
  }
}
