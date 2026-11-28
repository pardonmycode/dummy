import 'package:material_ui/material_ui.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../framework/widget_data.dart';

/// Screen time tracker widget - shows daily screen time by app.
class ScreenTimeTrackerWidget extends WidgetDefinition<Map<String, dynamic>> {
  @override
  String get id => 'screen_time_tracker';

  @override
  String get name => 'Bildschirmzeit';

  @override
  String get description => 'Tägliche Bildschirmzeit tracken';

  @override
  String get category => 'Gesundheit';

  @override
  IconData get icon => Icons.screen_lock_portrait;

  @override
  Color get color => AppTheme.primary;

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
    final totalMinutes = (data['total'] as num?)?.toInt() ?? 0;
    final goalMinutes = (data['goal'] as num?)?.toInt() ?? 480;
    final apps = data['apps'] as List<dynamic>? ?? [];

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    final goalHours = goalMinutes ~/ 60;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${hours}h ${minutes}m', style: AppTheme.titleMedium),
              Text('Ziel: ${goalHours}h', style: AppTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 8),

          LinearProgressIndicator(
            value: (totalMinutes / goalMinutes).clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
          const SizedBox(height: 12),

          // Top apps
          if (apps.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                final name = app['name']?.toString() ?? 'App';
                final appMinutes = (app['minutes'] as num?)?.toInt() ?? 0;
                final appHours = appMinutes ~/ 60;
                final appMins = appMinutes % 60;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.apps, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(child: Text(name, style: AppTheme.bodyMedium)),
                      Text(
                        appHours > 0
                            ? '${appHours}h ${appMins}m'
                            : '${appMins}m',
                        style: AppTheme.bodySmall,
                      ),
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
