import 'package:flutter/material.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';

/// Medications and supplements tracker widget.
class MedicationsTrackerWidget extends WidgetDefinition {
  @override
  String get id => 'medications_tracker';

  @override
  String get name => 'Medikamente';

  @override
  String get description => 'Medikamente und Supplemente tracken';

  @override
  String get category => 'Gesundheit';

  @override
  IconData get icon => Icons.medication;

  @override
  Color get color => Colors.blue;

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

    final medications = data.data['medications'] as List<dynamic>? ?? [];
    final upcoming = data.data['upcoming'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's schedule
          Text('Heute', style: AppTheme.labelMedium),
          const SizedBox(height: 4),

          if (medications.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.medication, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text('Keine Medikamente für heute', style: AppTheme.bodySmall),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medications.length,
              itemBuilder: (context, index) {
                final med = medications[index];
                final name = med['name']?.toString() ?? 'Medikament';
                final dose = med['dose']?.toString() ?? '';
                final time = med['time']?.toString() ?? '';
                final taken = med['taken'] == true;
                final type = med['type']?.toString() ?? 'medication';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        taken ? Icons.check_circle : Icons.circle_outlined,
                        size: 16,
                        color: taken ? Colors.green : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AppTheme.bodyMedium.copyWith(
                                decoration: taken
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (dose.isNotEmpty || time.isNotEmpty)
                              Text(
                                [dose, time].where((s) => s.isNotEmpty).join(' · '),
                                style: AppTheme.labelSmall,
                              ),
                          ],
                        ),
                      ),
                      if (type == 'supplement')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Supplement',
                            style: AppTheme.labelSmall.copyWith(
                              color: Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

          // Upcoming
          if (upcoming.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Als Nächstes', style: AppTheme.labelMedium),
            const SizedBox(height: 4),
            ...upcoming
                .map((u) {
                  final name = u['name']?.toString() ?? 'Medikament';
                  final time = u['time']?.toString() ?? '';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(Icons.alarm, size: 14, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$name $time',
                            style: AppTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  );
                })
                .toList(),
          ],
        ],
      ),
    );
  }
}