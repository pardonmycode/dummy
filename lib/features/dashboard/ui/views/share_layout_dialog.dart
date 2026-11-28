import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetly/core/i18n/app_localizations.dart';
import 'package:widgetly/features/dashboard/domain/dashboard_sync_service.dart';
import 'package:widgetly/features/dashboard/domain/dashboard_notifier.dart';
import 'providers.dart'
    show dashboardWidgetsProvider;
import 'package:widgetly/features/widgets/framework/widget_instance.dart';

void showShareLayoutDialog(
  BuildContext context,
  WidgetRef ref,
  List<WidgetInstance> widgets,
) {
  final syncService = DashboardSyncService();
  final activeDashboard = ref.read(dashboardNotifierProvider.notifier).activeDashboard;

  if (activeDashboard == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.error)),
    );
    return;
  }

  final layoutJson = syncService.exportLayout({
    'id': activeDashboard.id,
    'name': activeDashboard.name,
    'widgets': widgets.map((w) => w.toJson()).toList(),
  });

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(context.l10n.editDashboard),
      content: SingleChildScrollView(
        child: SelectableText(layoutJson),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(context.l10n.close),
        ),
        TextButton.icon(
          icon: const Icon(Icons.copy),
          label: Text(context.l10n.add),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: layoutJson));
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.layoutCopied)),
            );
          },
        ),
      ],
    ),
  );
}
