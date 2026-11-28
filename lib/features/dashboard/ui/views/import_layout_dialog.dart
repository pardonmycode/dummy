import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetly/core/i18n/app_localizations.dart';
import 'package:widgetly/features/dashboard/domain/dashboard_sync_service.dart';
import 'package:widgetly/features/dashboard/ui/views/providers.dart';
import 'package:widgetly/features/widgets/framework/widget_instance.dart';

void showImportLayoutDialog(
  BuildContext context,
  WidgetRef ref,
) {
  showDialog(
    context: context,
    builder: (ctx) {
      final controller = TextEditingController();
      return AlertDialog(
        title: Text(context.l10n.editDashboard),
        content: TextField(
          controller: controller,
          maxLines: 10,
          decoration: InputDecoration(
            hintText: context.l10n.searchWidgets,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final syncService = DashboardSyncService();
              final importResult = syncService.importLayout(controller.text);
              if (importResult.isSuccess && importResult.value != null) {
                final imported = importResult.value!;
                if (imported['widgets'] != null) {
                  try {
                    final widgets = (imported['widgets'] as List)
                        .map(
                          (w) => WidgetInstance.fromJson(
                            Map<String, dynamic>.from(w as Map),
                          ),
                        )
                        .toList();
                    ref
                        .read(dashboardWidgetsProvider.notifier)
                        .setWidgets(widgets);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.layoutImported)),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Import fehlgeschlagen: $e')),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(importResult.error ?? 'Ungültiges JSON-Format')),
                );
              }
            },
            child: Text(context.l10n.importLayout),
          ),
        ],
      );
    },
  );
}
