import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetly/core/i18n/app_localizations.dart';
import 'package:widgetly/core/theme/theme.dart';
import 'package:widgetly/features/dashboard/ui/views/dashboard_view.dart';
import 'package:widgetly/features/widgets/framework/widget_instance.dart';

void showTemplates(
  BuildContext context,
  WidgetRef ref,
) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.templates, style: AppTheme.titleMedium),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Fitness'),
              subtitle: const Text('Workout & Gesundheit Widgets'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(dashboardWidgetsProvider.notifier).setWidgets([
                  WidgetInstance(
                    widgetType: 'steps_tracker',
                    config: {},
                  ),
                  WidgetInstance(
                    widgetType: 'protein_tracker',
                    config: {'goal': 150},
                  ),
                  WidgetInstance(
                    widgetType: 'water_tracker',
                    config: {},
                  ),
                  WidgetInstance(
                    widgetType: 'weight_tracker',
                    config: {},
                  ),
                ]);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.fitnessTemplateApplied)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('Arbeit'),
              subtitle: const Text('Produktivitäts-Widgets'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(dashboardWidgetsProvider.notifier).setWidgets([
                  WidgetInstance(widgetType: 'tasks', config: {}),
                  WidgetInstance(widgetType: 'calendar', config: {}),
                  WidgetInstance(widgetType: 'quick_notes', config: {}),
                ]);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.workTemplateApplied)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_fire_department),
              title: const Text('Wetter & Umweltaufklärung'),
              subtitle: const Text('Wetter, UV & Luftqualität'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(dashboardWidgetsProvider.notifier).setWidgets([
                  WidgetInstance(
                    widgetType: 'weather',
                    config: {'location': 'Berlin'},
                  ),
                ]);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.weatherTemplateApplied)),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
