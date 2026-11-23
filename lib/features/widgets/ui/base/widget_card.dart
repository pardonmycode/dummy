import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../framework/widget_definition.dart';

/// Base card wrapper for all widgets with header, states, and actions.
class WidgetCard extends StatelessWidget {
  final WidgetDefinition definition;
  final WidgetData? data;
  final WidgetDataState state;
  final WidgetConfig config;
  final VoidCallback? onRefresh;
  final VoidCallback? onConfigure;
  final VoidCallback? onRemove;

  const WidgetCard({
    super.key,
    required this.definition,
    this.data,
    required this.state,
    required this.config,
    this.onRefresh,
    this.onConfigure,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final border = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
    final subColor = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

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
              border: Border(
                bottom: BorderSide(color: border, width: 0.5),
              ),
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
                if (onRefresh != null)
                  IconButton(
                    icon: Icon(Icons.refresh, size: 14),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onRefresh,
                  ),
                if (onConfigure != null)
                  IconButton(
                    icon: Icon(Icons.settings, size: 14),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onConfigure,
                  ),
              ],
            ),
          ),
          // Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              child: _buildBody(context),
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

  Widget _buildBody(BuildContext context) {
    switch (state) {
      case WidgetDataState.loading:
        return _buildLoading();
      case WidgetDataState.error:
        return _buildError();
      case WidgetDataState.empty:
        return _buildEmpty();
      case WidgetDataState.offline:
        return Column(
          children: [
            Icon(Icons.cloud_off, size: 32, color: Colors.grey),
            const SizedBox(height: 8),
            Text('Offline', style: AppTheme.bodySmall),
            const SizedBox(height: 8),
            definition.buildView(data, state, config),
          ],
        );
      default:
        return definition.buildView(data, state, config);
    }
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(strokeWidth: 2),
    );
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
