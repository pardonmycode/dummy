import 'package:material_ui/material_ui.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../framework/widget_data.dart';

/// Personal News widget - shows curated news headlines.
class NewsWidget extends WidgetDefinition<Map<String, dynamic>> {
  @override
  String get id => 'news';

  @override
  String get name => 'Persönliche News';

  @override
  String get description => 'Kuratierte Nachrichten für dich';

  @override
  String get category => 'News & Medien';

  @override
  IconData get icon => Icons.newspaper;

  @override
  Color get color => Colors.orange;

  @override
  WidgetSize get defaultSize => WidgetSize.medium;

  @override
  Set<WidgetSize> get supportedSizes => {WidgetSize.medium, WidgetSize.large};

  @override
  RefreshInterval get defaultRefreshInterval => RefreshInterval.minutes30;

  @override
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
          Text('News werden geladen...', style: AppTheme.bodySmall),
        ],
      );
    }

    // Error state
    if (state == WidgetDataState.error) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 32, color: AppTheme.error),
          const SizedBox(height: 8),
          Text('Fehler beim Laden der News', style: AppTheme.bodySmall),
        ],
      );
    }

    // Empty state
    if (state == WidgetDataState.empty || data == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.newspaper_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text('Keine News verfügbar', style: AppTheme.bodySmall),
        ],
      );
    }

    return _buildContent(data);
  }

  Widget _buildContent(Map<String, dynamic> data) {
    final headlines = data['headlines'] as List<dynamic>? ?? [];
    final section = data['section'] as String? ?? 'Für dich';

    if (headlines.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.newspaper_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text('Keine News verfügbar', style: AppTheme.bodySmall),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section, style: AppTheme.titleMedium),
          const SizedBox(height: 8),
          ...headlines.map((item) {
            final headline = item['headline']?.toString() ?? 'Titel';
            final source = item['source']?.toString() ?? '';
            final time = item['time']?.toString() ?? '';
            final isBreaking = item['breaking'] == true;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isBreaking)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'BREAKING',
                            style: AppTheme.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  Text(
                    headline,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (source.isNotEmpty || time.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          if (source.isNotEmpty)
                            Text(source, style: AppTheme.labelSmall),
                          if (source.isNotEmpty && time.isNotEmpty)
                            const Text(' • '),
                          if (time.isNotEmpty)
                            Text(time, style: AppTheme.labelSmall),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
