import 'package:material_ui/material_ui.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../framework/widget_data.dart';

/// Tasks widget - shows today's important tasks.
class TasksWidget extends WidgetDefinition<Map<String, dynamic>> {
  @override
  String get id => 'tasks';

  @override
  String get name => 'Aufgaben';

  @override
  String get description => 'Heutige wichtige Aufgaben';

  @override
  String get category => 'Produktivität';

  @override
  IconData get icon => Icons.checklist;

  @override
  Color get color => AppTheme.primary;

  @override
  WidgetSize get defaultSize => WidgetSize.medium;

  @override
  Set<WidgetSize> get supportedSizes => {WidgetSize.medium, WidgetSize.large};

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
    final tasks = data['tasks'] as List<dynamic>? ?? [];
    final completed = (data['completed'] as num?)?.toInt() ?? 0;
    final total = tasks.length;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Heute', style: AppTheme.titleMedium),
              Text(
                '$completed/$total erledigt',
                style: AppTheme.labelMedium.copyWith(color: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 4),

          if (total > 0)
            LinearProgressIndicator(
              value: (completed / total).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),

          const SizedBox(height: 8),

          // Task list
          if (tasks.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.task_alt, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text('Keine Aufgaben für heute', style: AppTheme.bodySmall),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final title = task['title']?.toString() ?? 'Aufgabe';
                final priority = task['priority']?.toString() ?? 'normal';
                final isCompleted = task['completed'] == true;
                final time = task['time']?.toString() ?? '';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        size: 16,
                        color: isCompleted ? Colors.green : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTheme.bodyMedium.copyWith(
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isCompleted ? null : Colors.black,
                              ),
                            ),
                            if (time.isNotEmpty)
                              Text(time, style: AppTheme.labelSmall),
                          ],
                        ),
                      ),
                      if (priority == 'high')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Wichtig',
                            style: AppTheme.labelSmall.copyWith(
                              color: Colors.red,
                            ),
                          ),
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
