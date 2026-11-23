import 'package:flutter/material.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../ui/components/design_system.dart';

/// Water intake tracker widget.
class WaterTrackerWidget extends WidgetDefinition {
  @override
  String get id => 'water_tracker';

  @override
  String get name => 'Wasser';

  @override
  String get description => 'Tägliche Wasseraufnahme tracken';

  @override
  String get category => 'Gesundheit';

  @override
  IconData get icon => Icons.water_drop;

  @override
  Color get color => AppTheme.info;

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

    final goal = (data.data['goal'] as num?)?.toInt() ?? 2000;
    final consumed = (data.data['consumed'] as num?)?.toInt() ?? 0;
    final glasses = consumed ~/ 250;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${consumed}ml von ${goal}ml', style: AppTheme.titleMedium),
            Icon(Icons.water_drop, color: AppTheme.info),
          ],
        ),
        const SizedBox(height: 8),

        // Water glasses visualization
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(8, (index) {
            final isFilled = index < glasses;
            return Icon(
              Icons.water_drop,
              size: 24,
              color: isFilled ? AppTheme.info : Colors.grey.shade300,
            );
          }),
        ),
        const SizedBox(height: 8),

        // Add water button
        ActionButton(
          label: '+ 250ml',
          icon: Icons.add,
          primary: true,
          width: 120,
          onPressed: () {
            // Add water logic
          },
        ),
      ],
    );
  }
}
