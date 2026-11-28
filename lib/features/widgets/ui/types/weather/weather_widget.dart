import 'package:material_ui/material_ui.dart';

import '../../../../../../core/i18n/app_localizations.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../framework/widget_data.dart';
import '../../../weather/data/weather_data.dart';

/// Weather widget - shows current weather, hourly, and 7-day forecast.
class WeatherWidget extends WidgetDefinition<WeatherData> {
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
  List<WidgetConfigField> get configFields => [
    WidgetConfigField(
      key: 'location',
      label: 'Ort',
      description: 'Standort für Wetterinformationen',
      type: 'string',
      defaultValue: 'Berlin',
    ),
  ];

  @override
  WeatherData parseData(WidgetData? data) {
    if (data == null) {
      return WeatherData(
        temperature: 0,
        condition: 'unknown',
        icon: 'unknown',
        hourly: [],
        daily: [],
      );
    }
    return WeatherData.fromJson(data.data);
  }

  @override
  Widget buildView(

      BuildContext context,

      WeatherData data,
    WidgetDataState state,
    WidgetConfig config, {
    void Function(String type, Map<String, dynamic> entry)? onQuickAdd,
  }) {
    final l10n = context.l10n;
    // Empty state: no weather data available
    if (state == WidgetDataState.empty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wb_sunny_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(l10n.noWeatherData, style: AppTheme.bodySmall),
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
              Icon(Icons.cloud_off, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(l10n.offlineCached, style: AppTheme.caption),
            ],
          ),
          const SizedBox(height: 8),
          _buildContent(data),
        ],
      );
    }

    return _buildContent(data);
  }

  Widget _buildContent(WeatherData data) {
    final current = data.temperature;
    final condition = data.condition;
    final icon = data.icon;
    final hourly = data.hourly;
    final daily = data.daily;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current weather
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
            child: Row(
              children: [
                Icon(
                  _weatherIcon(icon),
                  size: 32,
                  color: AppTheme.warning,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${current}°C',
                        style: AppTheme.titleMedium,
                      ),
                      Text(
                        condition,
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Hourly forecast (simplified)
          if (hourly.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: hourly.take(6).map((h) {
                    return Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            h.time,
                            style: AppTheme.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Icon(_weatherIcon(h.icon), size: 16),
                          Text('${h.temp}°', style: AppTheme.caption),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Daily forecast (simplified)
          if (daily.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: daily.take(5).map((d) {
                    return Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            d.date,
                            style: AppTheme.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Icon(_weatherIcon(d.icon), size: 16),
                          Text(
                            '${d.high.toInt()}°/${d.low.toInt()}°',
                            style: AppTheme.caption,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
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
