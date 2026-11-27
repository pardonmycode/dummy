import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
  @override
  Widget buildView(
    WidgetData? data,
    WidgetDataState state,
    WidgetConfig config, {
    void Function(String type, Map<String, dynamic> entry)? onQuickAdd,
  }) {
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

    // Convert event coordinates to LatLng markers
    final markers = <Marker>[];
    final locations = <LatLng>[];
    for (final e in events) {
      final lat = (e['lat'] ?? e['y'] ?? 0.0) as num;
      final lng = (e['lng'] ?? e['x'] ?? 0.0) as num;
      if (lat == 0.0 && lng == 0.0) continue;
      final point = LatLng(lat.toDouble(), lng.toDouble());
      locations.add(point);
      markers.add(
        Marker(
          point: point,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.accent,
              shape: BoxShape.circle,
              boxShadow: AppTheme.shadowSm,
            ),
            child: Icon(
              _eventIcon(e['genre']?.toString()),
              size: 14,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // Calculate map center from event locations
    LatLng mapCenter = const LatLng(52.52, 13.405); // Berlin default
    if (locations.isNotEmpty) {
      final avgLat = locations.fold(0.0, (a, b) => a + b.latitude) / locations.length;
      final avgLng = locations.fold(0.0, (a, b) => a + b.longitude) / locations.length;
      mapCenter = LatLng(avgLat, avgLng);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Interactive OpenStreetMap with event markers
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: mapCenter,
                initialZoom: 13.0,
                minZoom: 10.0,
                maxZoom: 16.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  maxZoom: 19,
                  userAgentPackageName: 'com.nousresearch.widgetly',
                ),
                MarkerLayer(
                  markers: markers,
                ),
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
                    color: AppTheme.accent.withValues(alpha: 0.1),
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
