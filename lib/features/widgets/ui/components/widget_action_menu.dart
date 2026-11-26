import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../framework/widget_definition.dart';

/// Standardized action menu for all widget cards.
/// Provides consistent actions: open details, share, save favorite, refresh, configure, remove.
class WidgetActionMenu extends StatelessWidget {
  final WidgetAction? action;
  final VoidCallback? onOpen;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onRefresh;
  final VoidCallback? onConfigure;
  final VoidCallback? onRemove;

  const WidgetActionMenu({
    super.key,
    this.action,
    this.onOpen,
    this.onShare,
    this.onSave,
    this.onRefresh,
    this.onConfigure,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (action != null) {
      // Single action button
      return IconButton(
        icon: Icon(_actionIcon(action!), size: 14),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: _actionHandler(action!),
      );
    }

    // Popup menu with all actions
    return PopupMenuButton<WidgetAction>(
      icon: Icon(Icons.more_vert, size: 14),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      itemBuilder: (context) => [
        if (onOpen != null)
          const PopupMenuItem(
            value: WidgetAction.open,
            child: ListTile(
              leading: Icon(Icons.open_in_new, size: 18),
              title: Text('Details öffnen'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (onShare != null)
          const PopupMenuItem(
            value: WidgetAction.share,
            child: ListTile(
              leading: Icon(Icons.share, size: 18),
              title: Text('Teilen'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (onSave != null)
          const PopupMenuItem(
            value: WidgetAction.save,
            child: ListTile(
              leading: Icon(Icons.favorite, size: 18),
              title: Text('Als Favorit speichern'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (onRefresh != null)
          const PopupMenuItem(
            value: WidgetAction.refresh,
            child: ListTile(
              leading: Icon(Icons.refresh, size: 18),
              title: Text('Aktualisieren'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (onConfigure != null)
          const PopupMenuItem(
            value: WidgetAction.configure,
            child: ListTile(
              leading: Icon(Icons.settings, size: 18),
              title: Text('Konfigurieren'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (onRemove != null)
          const PopupMenuItem(
            value: WidgetAction.remove,
            child: ListTile(
              leading: Icon(Icons.delete, size: 18),
              title: Text('Entfernen'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
      ],
      onSelected: (selected) {
        _handleAction(selected);
      },
    );
  }

  IconData _actionIcon(WidgetAction action) {
    switch (action) {
      case WidgetAction.open:
        return Icons.open_in_new;
      case WidgetAction.share:
        return Icons.share;
      case WidgetAction.save:
        return Icons.favorite;
      case WidgetAction.refresh:
        return Icons.refresh;
      case WidgetAction.configure:
        return Icons.settings;
      case WidgetAction.remove:
        return Icons.delete;
    }
  }

  VoidCallback? _actionHandler(WidgetAction action) {
    switch (action) {
      case WidgetAction.open:
        return onOpen;
      case WidgetAction.share:
        return onShare;
      case WidgetAction.save:
        return onSave;
      case WidgetAction.refresh:
        return onRefresh;
      case WidgetAction.configure:
        return onConfigure;
      case WidgetAction.remove:
        return onRemove;
    }
  }

  void _handleAction(WidgetAction selected) {
    switch (selected) {
      case WidgetAction.open:
        onOpen?.call();
        break;
      case WidgetAction.share:
        onShare?.call();
        break;
      case WidgetAction.save:
        onSave?.call();
        break;
      case WidgetAction.refresh:
        onRefresh?.call();
        break;
      case WidgetAction.configure:
        onConfigure?.call();
        break;
      case WidgetAction.remove:
        onRemove?.call();
        break;
    }
  }
}