import 'package:material_ui/material_ui.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';

/// Stock and crypto watchlist widget - tracks portfolio symbols.
class StocksWidget extends WidgetDefinition {
  @override
  String get id => 'stocks';

  @override
  String get name => 'Aktien & Krypto';

  @override
  String get description => 'Watchlist für Aktien und Krypto';

  @override
  String get category => 'Finanzen';

  @override
  IconData get icon => MdiIcons.chartLine;

  @override
  Color get color => Colors.blue;

  @override
  WidgetSize get defaultSize => WidgetSize.medium;

  @override
  Set<WidgetSize> get supportedSizes => {WidgetSize.medium, WidgetSize.large};

  @override
  RefreshInterval get defaultRefreshInterval => RefreshInterval.minutes15;

  @override
  Widget buildView(
    WidgetData? data,
    WidgetDataState state,
    WidgetConfig config,
  ) {
    // Loading state
    if (state == WidgetDataState.loading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 8),
          Text('Kurse werden geladen...', style: AppTheme.bodySmall),
        ],
      );
    }

    // Error state
    if (state == WidgetDataState.error) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 32, color: AppTheme.lightError),
          const SizedBox(height: 8),
          Text('Fehler beim Laden der Kurse', style: AppTheme.bodySmall),
        ],
      );
    }

    // Empty state
    if (state == WidgetDataState.empty || data == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text('Watchlist ist leer', style: AppTheme.bodySmall),
        ],
      );
    }

    return _buildContent(data);
  }

  Widget _buildContent(WidgetData data) {
    final symbols = data.data['symbols'] as List<dynamic>? ?? [];
    final lastUpdate = data.data['lastUpdate'] as String? ?? '';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Watchlist', style: AppTheme.titleMedium),
              if (lastUpdate.isNotEmpty)
                Text(lastUpdate, style: AppTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 8),

          if (symbols.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.show_chart_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text('Keine Symbole in Watchlist', style: AppTheme.bodySmall),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: symbols.length,
              itemBuilder: (context, index) {
                final symbol = symbols[index];
                final ticker = symbol['ticker']?.toString() ?? 'TICKER';
                final name = symbol['name']?.toString() ?? ticker;
                final price = (symbol['price'] as num?)?.toDouble() ?? 0;
                final change = (symbol['change'] as num?)?.toDouble() ?? 0;
                final changePercent =
                    (symbol['changePercent'] as num?)?.toDouble() ?? 0;
                final type = symbol['type']?.toString() ?? 'stock';

                final isUp = change >= 0;
                final isCrypto = type == 'crypto';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      // Symbol icon
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCrypto
                              ? Colors.orange.shade100
                              : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            ticker.substring(0, ticker.length > 4 ? 3 : ticker.length),
                            style: AppTheme.labelMedium.copyWith(
                              color: isCrypto ? Colors.orange : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Name and ticker
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  ticker,
                                  style: AppTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (isCrypto)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Icon(
                                      MdiIcons.bitcoin,
                                      size: 12,
                                      color: Colors.orange,
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              name,
                              style: AppTheme.labelSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Price and change
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${price.toStringAsFixed(2)} €',
                            style: AppTheme.bodyMedium,
                          ),
                          Row(
                            children: [
                              Icon(
                                isUp ? Icons.arrow_upward : Icons.arrow_downward,
                                size: 12,
                                color: isUp ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${changePercent.toStringAsFixed(2)}%',
                                style: AppTheme.labelSmall.copyWith(
                                  color: isUp ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
