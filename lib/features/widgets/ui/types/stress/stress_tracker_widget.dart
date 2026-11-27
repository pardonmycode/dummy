import 'package:flutter/material.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';

/// Stress tracker widget - shows stress level and trend.
class StressTrackerWidget extends WidgetDefinition {
  @override
  String get id => 'stress_tracker';

  @override
  String get name => 'Stress';

  @override
  String get description => 'Täglichen Stresslevel tracken';

  @override
  String get category => 'Gesundheit';

  @override
  IconData get icon => Icons.heart_broken;

  @override
  Color get color => Colors.orange;

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

    final level = (data.data['level'] as num?)?.toInt() ?? 50;
    final advice = data.data['advice'] as String? ?? '';

    final levelColor = level < 30
        ? Colors.green
        : level < 70
        ? Colors.orange
        : Colors.red;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Heute', style: AppTheme.titleMedium),
              Text(
                '$level%',
                style: AppTheme.titleMedium.copyWith(color: levelColor),
              ),
            ],
          ),
          const SizedBox(height: 8),

          LinearProgressIndicator(
            value: level / 100.0,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(levelColor),
          ),
          const SizedBox(height: 4),

          Text(
            level < 30
                ? 'Niedriger Stress'
                : level < 70
                ? 'Mäßiger Stress'
                : 'Hoher Stress',
            style: AppTheme.bodySmall,
          ),
          const SizedBox(height: 8),

          if (advice.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(child: Text(advice, style: AppTheme.bodySmall)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
