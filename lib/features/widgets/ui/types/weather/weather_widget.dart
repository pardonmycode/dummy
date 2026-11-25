import 'package:flutter/material.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';

/// Weather widget - shows current weather, hourly, and 7-day forecast.
class WeatherWidget extends WidgetDefinition {
  @override
  String get id => 'weather';

  @override
  String get name => 'Wetter';

  @override
  String get description => 'Aktuelles Wetter und Vorhersage';

  @override
  String get category => 'Umwelt';

  @override
  IconData get icon => Icons.wb_sunny_outlined;

  @override
  RefreshInterval get defaultRefreshInterval => RefreshInterval.hours1;

  @override
  Widget buildView(
    WidgetData? data,
    WidgetDataState state,
    WidgetConfig config,
  ) {
    // Empty state: no weather data available
    if (state == WidgetDataState.empty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wb_sunny_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text('Keine Wetterdaten verfügbar', style: AppTheme.bodySmall),
        ],
      );
    }

    // Offline state: show cached data with indicator
    if (state == WidgetDataState.offline) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_off, size: 16, color: AppTheme.lightTextSecondary),
              const SizedBox(width: 4),
              Text('Offline - gecachte Daten', style: AppTheme.caption),
            ],
          ),
          const SizedBox(height: 8),
          if (data != null) _buildContent(data),
        ],
      );
    }

    if (data == null) {
      return const SizedBox();
    }

    return _buildContent(data);
  }

  Widget _buildContent(WidgetData data) {
    final current = data.data['current'] as Map<String, dynamic>?;
    final hourly = data.data['hourly'] as List<dynamic>?;
    final warnings = data.data['warnings'] as List<dynamic>?;
    final summary = data.data['summary'] as String?;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current weather
          if (current != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
              child: Row(
                children: [
                  Icon(
                    _weatherIcon(current['condition'] as String),
                    size: 32,
                    color: AppTheme.lightWarning,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${current['temperature'] ?? 0}°C',
                          style: AppTheme.titleMedium,
                        ),
                        Text(
                          current['condition'] as String,
                          style: AppTheme.bodySmall,
                        ),
                        if (current['location'] != null)
                          Text(
                            current['location'] as String,
                            style: AppTheme.caption,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // AI Summary
          if (summary != null && summary.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingXs),
                decoration: BoxDecoration(
                  color: AppTheme.lightInfo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 12,
                      color: AppTheme.lightInfo,
                    ),
                    const SizedBox(width: 4),
                    Expanded(child: Text(summary, style: AppTheme.caption)),
                  ],
                ),
              ),
            ),

          // Hourly forecast (simplified)
          if (hourly != null && hourly.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: hourly.take(6).map((h) {
                    final hour = h['time'] as String;
                    final temp = h['temp'] as int;
                    final condition = h['condition'] as String;
                    return Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            hour,
                            style: AppTheme.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Icon(_weatherIcon(condition), size: 16),
                          Text('$temp°', style: AppTheme.caption),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Warnings
          if (warnings != null && warnings.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingXs),
              decoration: BoxDecoration(
                color: AppTheme.lightWarning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, size: 12, color: AppTheme.lightWarning),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      warnings.first['message'] as String,
                      style: AppTheme.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _weatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Icons.wb_sunny;
      case 'partly cloudy':
        return Icons.wb_cloudy;
      case 'cloudy':
        return Icons.cloud;
      case 'rain':
      case 'rainy':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'snow':
      case 'snowy':
        return Icons.ac_unit;
      case 'fog':
        return Icons.foggy;
      default:
        return Icons.wb_sunny;
    }
  }
}
