import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetly/core/i18n/app_localizations.dart';
import 'package:widgetly/core/theme/theme.dart';
import 'package:widgetly/features/dashboard/domain/dashboard_sync_service.dart';
import 'package:widgetly/features/dashboard/ui/views/dashboard_view.dart';
import 'package:widgetly/features/widgets/framework/widget_instance.dart';

void showSyncOptions(
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
            Text(context.l10n.sync, style: AppTheme.titleMedium),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.cloud_upload),
              title: Text(context.l10n.uploadToServer),
              subtitle: Text(context.l10n.uploadDescription),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(ctx);
                ref.read(isSyncingProvider.notifier).update((s) => true);
                try {
                  final syncService = DashboardSyncService();
                  final widgets = ref.read(dashboardWidgetsProvider);
                  final dashboard = ref.read(dashboardsProvider.notifier).active;
                  if (dashboard != null) {
                    final syncResult = await syncService.syncToServer([
                      {
                        'id': dashboard.id,
                        'name': dashboard.name,
                        'widgets': widgets.map((w) => w.toJson()).toList(),
                      },
                    ]);
                    if (syncResult.isSuccess) {
                      messenger.showSnackBar(
                        SnackBar(content: Text(context.l10n.layoutSynced)),
                      );
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            syncResult.error ?? context.l10n.syncFailed,
                          ),
                        ),
                      );
                    }
                  }
                } finally {
                  ref.read(isSyncingProvider.notifier).update((s) => false);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_download),
              title: Text(context.l10n.downloadFromServer),
              subtitle: Text(context.l10n.downloadDescription),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(ctx);
                ref.read(isSyncingProvider.notifier).update((s) => true);
                try {
                  final syncService = DashboardSyncService();
                  final syncResult = await syncService.syncFromServer();
                  if (syncResult.isSuccess) {
                    final remoteDashboards = syncResult.value ?? [];
                    if (remoteDashboards.isNotEmpty) {
                      final remote = remoteDashboards.first;
                      if (remote['widgets'] != null) {
                        try {
                          final widgets = (remote['widgets'] as List)
                              .map(
                                (w) => WidgetInstance.fromJson(
                                  Map<String, dynamic>.from(w as Map),
                                ),
                              )
                              .toList();
                          ref
                              .read(dashboardWidgetsProvider.notifier)
                              .setWidgets(widgets);
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.layoutDownloaded),
                            ),
                          );
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Download fehlgeschlagen: $e'),
                            ),
                          );
                        }
                      }
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.noLayoutOnServer),
                        ),
                      );
                    }
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          syncResult.error ?? context.l10n.downloadFailed,
                        ),
                      ),
                    );
                  }
                } finally {
                  ref.read(isSyncingProvider.notifier).update((s) => false);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
