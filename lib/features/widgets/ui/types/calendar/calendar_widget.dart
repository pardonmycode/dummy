import 'package:flutter/material.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';

/// Calendar widget - shows upcoming events and next appointments.
class CalendarWidget extends WidgetDefinition {
  @override
  String get id => 'calendar';

  @override
  String get name => 'Kalender';

  @override
  String get description => 'Nächste Termine und Events';

  @override
  String get category => 'Produktivität';

  @override
  IconData get icon => Icons.calendar_today;

  @override
  Color get color => AppTheme.primary;

  @override
  WidgetSize get defaultSize => WidgetSize.medium;

  @override
  Set<WidgetSize> get supportedSizes => {WidgetSize.medium, WidgetSize.large};

  @override
  Widget buildView(
    WidgetData? data,
    WidgetDataState state,
    WidgetConfig config,
  ) {
    if (data == null) {
      return const SizedBox();
    }

    final today = data.data['today'] as String? ?? '';
    final events = data.data['events'] as List<dynamic>? ?? [];
    final freeSlots = data.data['freeSlots'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today header
          Text(today, style: AppTheme.titleMedium),
          const SizedBox(height: 8),

          // Events
          if (events.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.event, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text('Keine Events heute', style: AppTheme.bodySmall),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final title = event['title']?.toString() ?? 'Event';
                final startTime = event['start']?.toString() ?? '';
                final endTime = event['end']?.toString() ?? '';
                final location = event['location']?.toString() ?? '';
                final isAllDay = event['allDay'] == true;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.event, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppTheme.bodyMedium),
                            Text(
                              isAllDay ? 'Ganztägig' : '$startTime - $endTime',
                              style: AppTheme.bodySmall,
                            ),
                            if (location.isNotEmpty)
                              Text(location, style: AppTheme.labelSmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          // Free slots
          if (freeSlots.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Freie Zeitfenster', style: AppTheme.labelMedium),
            const SizedBox(height: 4),
            ...freeSlots.map((slot) {
              final start = slot['start']?.toString() ?? '';
              final end = slot['end']?.toString() ?? '';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.green),
                    const SizedBox(width: 8),
                    Text('$start - $end', style: AppTheme.bodySmall),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}
