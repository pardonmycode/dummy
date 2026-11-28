import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../framework/widget_definition.dart';
import '../../framework/widget_data.dart';
import '../../framework/widget_instance.dart';
import '../../../dashboard/ui/views/dashboard_view.dart'
    show dashboardWidgetsProvider, mockDataProviderProvider, widgetDataProvider;
import '../components/widget_action_menu.dart';

/// Base card wrapper for all widgets with header, states, and actions.
class WidgetCard extends ConsumerWidget {
  final WidgetDefinition<Object> definition;
  final WidgetInstance instance;
  final WidgetData? data;
  final WidgetDataState state;
  final WidgetConfig config;
  final VoidCallback? onRefresh;
  final VoidCallback? onConfigure;
  final VoidCallback? onRemove;
  final VoidCallback? onOpen;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final List<String>? validationErrors;

  const WidgetCard({
    super.key,
    required this.definition,
    required this.instance,
    this.data,
    required this.state,
    required this.config,
    this.onRefresh,
    this.onConfigure,
    this.onRemove,
    this.onOpen,
    this.onShare,
    this.onSave,
    this.validationErrors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bg = scheme.surface;
    final border = scheme.outline;
    final subColor = scheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: border, width: 1),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: border, width: 0.5)),
            ),
            child: Row(
              children: [
                Icon(definition.icon, size: 16, color: subColor),
                const SizedBox(width: AppTheme.spacingXs),
                Expanded(
                  child: Text(
                    definition.name,
                    style: AppTheme.label.copyWith(color: subColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStateIndicator(state),
                // Standardized action menu
                WidgetActionMenu(
                  onOpen: onOpen,
                  onShare: onShare,
                  onSave: onSave,
                  onRefresh: onRefresh,
                  onConfigure: onConfigure,
                  onRemove: onRemove,
                ),
              ],
            ),
          ),
          // Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              child: _buildBody(context, ref),
            ),
          ),
          // Footer with sources
          if (data?.sources.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSm,
                vertical: AppTheme.spacingXs,
              ),
              child: Text(
                'Quelle: ${data!.sources.first['name']}',
                style: AppTheme.caption.copyWith(color: subColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStateIndicator(WidgetDataState state) {
    switch (state) {
      case WidgetDataState.loading:
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 4),
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case WidgetDataState.stale:
        return Icon(Icons.access_time, size: 12, color: Colors.orange);
      case WidgetDataState.error:
        return Icon(Icons.error, size: 12, color: Colors.red);
      default:
        return Container();
    }
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    // Show validation errors if present
    if (validationErrors != null && validationErrors!.isNotEmpty) {
      return _buildValidationError();
    }

    Widget body;
    switch (state) {
      case WidgetDataState.loading:
        body = _buildLoading();
        break;
      case WidgetDataState.error:
        body = _buildError();
        break;
      case WidgetDataState.empty:
        body = _buildEmpty();
        break;
      case WidgetDataState.offline:
        // Parse typed data for offline state too
        final typedOfflineData = definition.parseData(data);
        body = Column(
          children: [
            Icon(Icons.cloud_off, size: 32, color: Colors.grey),
            const SizedBox(height: 8),
            Text('Offline', style: AppTheme.bodySmall),
            const SizedBox(height: 8),
            definition.buildView(context, typedOfflineData, state, config),
          ],
        );
        break;
      default:
        // Parse typed data before building view
        final typedData = definition.parseData(data);
        body = definition.buildView(context, typedData, state, config,
          onQuickAdd: (type, entry) {
            // Add entry to mock data provider via provider
            final provider = ref.read(mockDataProviderProvider);
            provider.addEntry(
              instance.widgetType,
              instance.id,
              entry,
            );
            // Refresh the widget data
            ref.invalidate(widgetDataProvider(instance.id));
          },
        );
    }

    // Wrap with RefreshIndicator for pull-to-refresh if onRefresh is provided
    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async {
          onRefresh!();
        },
        color: definition.color,
        child: body,
      );
    }

    return body;
  }

  Widget _buildValidationError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.warning_amber_rounded, size: 32, color: Colors.orange),
        const SizedBox(height: 8),
        Text(
          'Schema-Fehler',
          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: validationErrors!.map((error) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $error',
                    style: AppTheme.bodySmall.copyWith(color: Colors.orange),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Show configuration form for this widget.
  void showConfigForm(BuildContext context, WidgetRef ref, WidgetInstance instance) {
    final configFields = definition.configFields;
    if (configFields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Keine Konfiguration für ${definition.name}')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final config = Map<String, dynamic>.from(instance.config);
    final controllers = <String, TextEditingController>{};

    for (final field in configFields) {
      final currentValue = config[field.key] ?? field.defaultValue;
      controllers[field.key] =
          TextEditingController(text: currentValue?.toString() ?? '');
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Konfiguration: ${definition.name}'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: configFields.map((field) {
                      final controller = controllers[field.key]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(field.label, style: AppTheme.labelMedium),
                            if (field.description != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(field.description!, style: AppTheme.caption),
                              ),
                            if (field.type == 'select' && field.options != null)
                              DropdownButtonFormField<String>(
                                initialValue: controller.text.isEmpty
                                    ? null
                                    : controller.text,
                                items: field.options!.map((option) {
                                  return DropdownMenuItem<String>(
                                    value: option['value']?.toString(),
                                    child: Text(option['label']?.toString() ?? ''),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  controller.text = value ?? '';
                                  setState(() {});
                                },
                              )
                            else if (field.type == 'bool')
                              SwitchListTile(
                                title: const SizedBox.shrink(),
                                contentPadding: EdgeInsets.zero,
                                value: controller.text == 'true',
                                onChanged: (value) {
                                  controller.text = value.toString();
                                  setState(() {});
                                },
                              )
                            else
                              TextFormField(
                                controller: controller,
                                keyboardType:
                                    field.type == 'number'
                                        ? TextInputType.number
                                        : TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: field.defaultValue?.toString(),
                                  suffixText: field.unit,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Bitte eingeben';
                                  }
                                  if (field.type == 'number') {
                                    try {
                                      double.parse(value);
                                    } catch (e) {
                                      return 'Ungültige Zahl';
                                    }
                                  }
                                  return null;
                                },
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  for (final field in configFields) {
                    final controller = controllers[field.key]!;
                    final value = controller.text;
                    if (field.type == 'number') {
                      config[field.key] = double.tryParse(value) ?? field.defaultValue;
                    } else if (field.type == 'bool') {
                      config[field.key] = value == 'true';
                    } else {
                      config[field.key] = value;
                    }
                  }
                  ref
                      .read(dashboardWidgetsProvider.notifier)
                      .updateConfig(instance.id, config);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    ).then((_) {
      for (final c in controllers.values) {
        c.dispose();
      }
    });
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 32, color: Colors.red),
          const SizedBox(height: 8),
          Text('Fehler beim Laden', style: AppTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 32, color: Colors.grey),
          const SizedBox(height: 8),
          Text('Keine Daten', style: AppTheme.bodySmall),
        ],
      ),
    );
  }
}
