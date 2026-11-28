import 'package:material_ui/material_ui.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../framework/widget_data.dart';

/// Custom tracker widget - user can define name, unit, and goal.
class CustomTrackerWidget extends WidgetDefinition<Map<String, dynamic>> {
  @override
  String get id => 'custom_tracker';

  @override
  String get name => 'Eigener Tracker';

  @override
  String get description =>
      'Eigenen Tracker mit Name, Einheit und Ziel erstellen';

  @override
  String get category => 'Gesundheit';

  @override
  IconData get icon => Icons.create_new_folder;

  @override
  Color get color => Colors.purple;

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
    Map<String, dynamic> data,
    WidgetDataState state,
    WidgetConfig config, {
    void Function(String type, Map<String, dynamic> entry)? onQuickAdd,
  }) {
    final trackerName = data['name'] ?? 'Mein Tracker';
    final unit = data['unit'] ?? 'Einheiten';
    final goal = (data['goal'] as num?)?.toInt() ?? 100;
    final current = (data['current'] as num?)?.toInt() ?? 0;
    final remaining = goal - current;
    final progress = current / goal;
    final entries = data['entries'] as List? ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(trackerName, style: AppTheme.titleMedium),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTheme.labelMedium.copyWith(color: Colors.purple),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$current $unit', style: AppTheme.bodySmall),
              Text('von $goal $unit', style: AppTheme.bodySmall),
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
                          progress >= 1.0 ? Colors.green : Colors.purple,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$current', style: AppTheme.titleSmall),
                          Text(unit, style: AppTheme.labelSmall),
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
                      Text('Noch $remaining $unit', style: AppTheme.bodyMedium),
                      const SizedBox(height: 4),
                      if (remaining > 0)
                        Text('Weiter so! 💪', style: AppTheme.bodySmall)
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

          if (entries.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final name = entry['name'] ?? 'Eintrag';
                final amount = (entry['amount'] as num?)?.toInt() ?? 0;
                final time = entry['time'] ?? '';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: AppTheme.bodyMedium),
                            if (time.isNotEmpty)
                              Text(time, style: AppTheme.labelSmall),
                          ],
                        ),
                      ),
                      Text('+$amount', style: AppTheme.labelMedium),
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
