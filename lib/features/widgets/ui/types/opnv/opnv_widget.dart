import 'package:material_ui/material_ui.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';

/// Public transit departures widget - shows upcoming departures.
class OpnvWidget extends WidgetDefinition {
  @override
  String get id => 'opnv';

  @override
  String get name => 'ÖPNV-Abfahrten';

  @override
  String get description => 'Nächste Abfahrten an deiner Haltestelle';

  @override
  String get category => 'Verkehr';

  @override
  IconData get icon => Icons.train;

  @override
  Color get color => Colors.teal;

  @override
  WidgetSize get defaultSize => WidgetSize.medium;

  @override
  Set<WidgetSize> get supportedSizes => {WidgetSize.medium, WidgetSize.large};

  @override
  RefreshInterval get defaultRefreshInterval => RefreshInterval.minutes15;

  @override
  List<WidgetConfigField> get configFields => [
    WidgetConfigField(
      key: 'stop',
      label: 'Haltestelle',
      description: 'Name deiner Haltestelle',
      type: 'string',
      defaultValue: 'Alexanderplatz',
    ),
  ];

  @override
  @override
  Widget buildView(
    WidgetData? data,
    WidgetDataState state,
    WidgetConfig config, {
    void Function(String type, Map<String, dynamic> entry)? onQuickAdd,
  }) {
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
          Text('Abfahrten werden geladen...', style: AppTheme.bodySmall),
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
          Text('Fehler beim Laden der Abfahrten', style: AppTheme.bodySmall),
        ],
      );
    }

    // Empty state
    if (state == WidgetDataState.empty || data == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.train_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text('Keine Abfahrten verfügbar', style: AppTheme.bodySmall),
        ],
      );
    }

    return _buildContent(data);
  }

  Widget _buildContent(WidgetData data) {
    final stop = data.data['stop'] as String? ?? 'Haltestelle';
    final departures = data.data['departures'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: AppTheme.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(stop, style: AppTheme.titleMedium, maxLines: 1),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (departures.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.train_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text('Keine Abfahrten in Kürze', style: AppTheme.bodySmall),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: departures.length,
              itemBuilder: (context, index) {
                final departure = departures[index];
                final line = departure['line']?.toString() ?? 'Line';
                final destination = departure['destination']?.toString() ?? '';
                final time = departure['time']?.toString() ?? '';
                final delay = departure['delay'] as int?;
                final platform = departure['platform']?.toString() ?? '';
                final isCancelled = departure['cancelled'] == true;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      // Line badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _lineColor(line),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          line,
                          style: AppTheme.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Time and destination
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(time, style: AppTheme.bodyMedium),
                                if (delay != null && delay > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      '+${delay} Min',
                                      style: AppTheme.labelSmall.copyWith(
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                if (isCancelled)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      'Ausgefallen',
                                      style: AppTheme.labelSmall.copyWith(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              destination,
                              style: AppTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (platform.isNotEmpty)
                              Text(
                                'Gleis $platform',
                                style: AppTheme.labelSmall,
                              ),
                          ],
                        ),
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

  Color _lineColor(String line) {
    // Simplified line colors for Berlin U-Bahn
    if (line.startsWith('U1') || line.startsWith('U6')) return Colors.red;
    if (line.startsWith('U2') || line.startsWith('U8')) return Colors.blue;
    if (line.startsWith('U3')) return Colors.green;
    if (line.startsWith('U4')) return Colors.purple;
    if (line.startsWith('U5') || line.startsWith('U55')) return Colors.yellow;
    if (line.startsWith('U7')) return Colors.orange;
    if (line.startsWith('U9')) return Colors.brown;
    return Colors.grey;
  }
}
