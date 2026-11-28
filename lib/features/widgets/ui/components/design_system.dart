import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';

/// A styled list tile for item rows.
class ListTileItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool dense;

  const ListTileItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textColor = scheme.onSurface;
    final subColor = scheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: dense ? AppTheme.spacingXs : AppTheme.spacingSm,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppTheme.spacingSm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyMedium.copyWith(color: textColor),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: AppTheme.bodySmall.copyWith(color: subColor),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

/// A styled filter chip.
class FilterChipItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const FilterChipItem({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap?.call(),
      backgroundColor: scheme.outline,
      selectedColor: scheme.primary,
      labelStyle: AppTheme.labelSmall,
      checkmarkColor: scheme.onPrimary,
    );
  }
}

/// A styled action button.
class ActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool primary;
  final bool loading;
  final double width;

  const ActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.primary = false,
    this.loading = false,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    if (primary) {
      return SizedBox(
        width: width,
        child: ElevatedButton.icon(
          icon: loading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : (icon != null ? Icon(icon, size: 16) : null),
          label: Text(label),
          onPressed: loading ? null : onPressed,
        ),
      );
    }
    return SizedBox(
      width: width,
      child: OutlinedButton.icon(
        icon: loading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : (icon != null ? Icon(icon, size: 16) : null),
        label: Text(label),
        onPressed: loading ? null : onPressed,
      ),
    );
  }
}

/// A styled text input field.
class InputField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? error;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;

  const InputField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.error,
    this.prefixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.labelMedium),
        const SizedBox(height: AppTheme.spacingXs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            errorText: error,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingSm,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// A source citation chip for AI data.
class SourceChip extends StatelessWidget {
  final String name;
  final String? url;
  final String? timestamp;
  final VoidCallback? onTap;

  const SourceChip({
    super.key,
    required this.name,
    this.url,
    this.timestamp,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bg = scheme.outline;
    final textColor = scheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link, size: 10, color: textColor),
            const SizedBox(width: 4),
            Text(
              name,
              style: AppTheme.caption.copyWith(color: textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// A section showing all sources for a widget's data.
class SourceSection extends StatelessWidget {
  final List<Map<String, dynamic>> sources;

  const SourceSection({super.key, required this.sources});

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Quelle: ', style: AppTheme.caption),
          ...sources.map(
            (s) => SourceChip(name: s['name']?.toString() ?? 'Unbekannt'),
          ),
        ],
      ),
    );
  }
}
