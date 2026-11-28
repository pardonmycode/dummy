import 'package:material_ui/material_ui.dart';

import '../../../../../../core/i18n/app_localizations.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../framework/widget_data.dart';

/// Budget and expenses widget - tracks spending vs budget.
class BudgetWidget extends WidgetDefinition<Map<String, dynamic>> {
  @override
  String get id => 'budget';

  @override
  String get name => 'Budget und Ausgaben';

  @override
  String get description => 'Ausgaben im Blick behalten';

  @override
  String get category => 'Finanzen';

  @override
  IconData get icon => Icons.account_balance_wallet;

  @override
  Color get color => Colors.green;

  @override
  WidgetSize get defaultSize => WidgetSize.medium;

  @override
  Set<WidgetSize> get supportedSizes => {WidgetSize.medium, WidgetSize.large};

  @override
  RefreshInterval get defaultRefreshInterval => RefreshInterval.manual;

  @override
  Map<String, dynamic> parseData(WidgetData? data) {
    if (data == null) {
      return {};
    }
    return data.data;
  }


  @override
  Widget buildView(
    BuildContext context,
    Map<String, dynamic> data,
    WidgetDataState state,
    WidgetConfig config, {
    void Function(String type, Map<String, dynamic> entry)? onQuickAdd,
  }) {
    final l10n = context.l10n;
    // Loading state
    if (state == WidgetDataState.loading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 8),
          Text(l10n.budgetLoading, style: AppTheme.bodySmall),
        ],
      );
    }

    // Error state
    if (state == WidgetDataState.error) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 32, color: AppTheme.error),
          const SizedBox(height: 8),
          Text(l10n.budgetError, style: AppTheme.bodySmall),
        ],
      );
    }

    // Empty state
    if (state == WidgetDataState.empty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_wallet_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(l10n.budgetEmpty, style: AppTheme.bodySmall),
        ],
      );
    }

    return _buildContent(context, data);
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> data) {
    final l10n = context.l10n;
    final budget = (data['budget'] as num?)?.toDouble() ?? 0;
    final spent = (data['spent'] as num?)?.toDouble() ?? 0;
    final remaining = budget - spent;
    final period = data['period'] as String? ?? l10n.translate('month');
    final categories = data['categories'] as List<dynamic>? ?? [];
    final recent = data['recent'] as List<dynamic>? ?? [];

    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final isOver = spent > budget;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Budget summary
          Text(period, style: AppTheme.titleMedium),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.budgetRemainingLabel, style: AppTheme.bodySmall),
              Text(
                '${remaining.toStringAsFixed(2)} €',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isOver ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              isOver ? Colors.red : Colors.green,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.budgetSpentLabel, style: AppTheme.labelSmall),
              Text(
                '${spent.toStringAsFixed(2)} € ${l10n.proteinOf} ${budget.toStringAsFixed(2)} €',
                style: AppTheme.labelSmall,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Spending by category
          if (categories.isNotEmpty) ...[
            Text(l10n.budgetByCategory, style: AppTheme.titleSmall),
            const SizedBox(height: 4),
            ...categories.map((item) {
              final name = item['name']?.toString() ?? l10n.translate('category');
              final amount = (item['amount'] as num?)?.toDouble() ?? 0;
              final icon = item['icon']?.toString() ?? 'category';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(_categoryIcon(icon), size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(name, style: AppTheme.bodyMedium)),
                    Text(
                      '${amount.toStringAsFixed(2)} €',
                      style: AppTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }),
          ],

          // Recent transactions
          if (recent.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(l10n.budgetRecent, style: AppTheme.titleSmall),
            const SizedBox(height: 4),
            ...recent.map((item) {
              final name = item['name']?.toString() ?? l10n.translate('transaction');
              final amount = (item['amount'] as num?)?.toDouble() ?? 0;
              final isIncome = item['income'] == true;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(name, style: AppTheme.bodyMedium)),
                    Text(
                      '${isIncome ? '+' : '-'}${amount.toStringAsFixed(2)} €',
                      style: AppTheme.bodyMedium.copyWith(
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  IconData _categoryIcon(String icon) {
    switch (icon) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'bills':
        return Icons.receipt;
      case 'health':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'housing':
        return Icons.home;
      default:
        return Icons.category;
    }
  }
}
