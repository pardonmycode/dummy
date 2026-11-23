import 'package:flutter/material.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../ui/components/design_system.dart';

/// Parties widget - shows nearby events/parties on a map.
class PartiesWidget extends WidgetDefinition {
  @override
  String get id => 'parties';

  @override
  String get name => 'Parties in der Umgebung';

  @override
  String get description => 'Events und Partys in deiner Nähe';

  @override
  String get category => 'Events';

  @override
  IconData get icon => Icons.celebration_outlined;

  @override
  Color get color => AppTheme.accent;

  @override
  WidgetSize get defaultSize => WidgetSize.large;

  @override
  Set<WidgetSize> get supportedSizes => {WidgetSize.medium, WidgetSize.large};

  @override
  Widget buildView(
    WidgetData? data,
    WidgetDataState state,
    WidgetConfig config,
  ) {
    if (data == null) {
      return const SizedBox();
    }

    final events = data.data['events'] as List<dynamic>?;

    if (events == null || events.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.celebration, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text('Keine Events gefunden', style: AppTheme.bodySmall),
          const SizedBox(height: 4),
          Text('Versuche später noch einmal', style: AppTheme.caption),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Map placeholder
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.lightBorder,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Stack(
              children: [
                // Simulated map background
                Positioned.fill(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1524661135-2f98d8bf521c?w=400&h=200&fit=crop',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: AppTheme.lightBorder),
                  ),
                ),
                // Event pins
                ...events.map((e) {
                  final x = (e['x'] as num).toDouble();
                  final y = (e['y'] as num).toDouble();
                  return Positioned(
                    left: x * 100,
                    top: y * 100,
                    child: GestureDetector(
                      onTap: () {
                        // Show event details
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.shadowSm,
                        ),
                        child: Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        // Event list
        Expanded(
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final e = events[index];
              return ListTileItem(
                title: e['name']?.toString() ?? 'Event',
                subtitle:
                    '${e['venue']?.toString()} · ${e['time']?.toString()}',
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(
                    _eventIcon(e['genre']?.toString()),
                    size: 16,
                    color: AppTheme.accent,
                  ),
                ),
                onTap: () {
                  // Navigate to event details
                },
              );
            },
          ),
        ),
        // Source
        SourceSection(sources: data.sources),
      ],
    );
  }

  IconData _eventIcon(String? genre) {
    if (genre == null) return Icons.celebration;
    switch (genre.toLowerCase()) {
      case 'concert':
      case 'musik':
        return Icons.music_note;
      case 'club':
        return Icons.nightlife;
      case 'party':
        return Icons.celebration;
      case 'festival':
        return Icons.festival;
      case 'open air':
        return Icons.outdoor_grill;
      default:
        return Icons.celebration;
    }
  }
}
