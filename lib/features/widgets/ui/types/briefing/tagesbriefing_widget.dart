import 'package:flutter/material.dart';

import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../ui/components/design_system.dart';

/// Tagesbriefing widget - AI-generated daily briefing combining weather,
/// calendar, tasks, and news.
class TagesbriefingWidget extends WidgetDefinition {
  @override
  String get id => 'tagesbriefing';

  @override
  String get name => 'Tagesbriefing';

  @override
  String get description => 'KI-Zusammenfassung für deinen Tag';

  @override
  String get category => 'Briefing';

  @override
  IconData get icon => Icons.wb_sunny;

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

    final summary = data.data['summary'] as String? ?? '';
    final weather = data.data['weather'] as String? ?? '';
    final appointments = data.data['appointments'] as List<dynamic>? ?? [];
    final tasks = data.data['tasks'] as List<dynamic>? ?? [];
    final news = data.data['news'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: AppTheme.accent),
                    const SizedBox(width: 8),
                    Text('KI-Zusammenfassung', style: AppTheme.labelMedium),
                  ],
                ),
                const SizedBox(height: 4),
                Text(summary, style: AppTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),

          // Weather
          if (weather.isNotEmpty)
            _BriefingSection(
              icon: Icons.wb_sunny,
              title: 'Wetter',
              content: weather,
            ),

          // Appointments
          if (appointments.isNotEmpty)
            _BriefingSection(
              icon: Icons.event,
              title: 'Termine heute',
              items: appointments
                  .map((a) => a['title']?.toString() ?? 'Termin')
                  .toList(),
            ),

          // Tasks
          if (tasks.isNotEmpty)
            _BriefingSection(
              icon: Icons.check_circle,
              title: 'Wichtige Aufgaben',
              items: tasks
                  .map((t) => t['title']?.toString() ?? 'Aufgabe')
                  .toList(),
            ),

          // News
          if (news.isNotEmpty)
            _BriefingSection(
              icon: Icons.newspaper,
              title: 'News',
              items: news
                  .map((n) => n['headline']?.toString() ?? 'Nachricht')
                  .toList(),
            ),

          // Source
          SourceSection(sources: data.sources),
        ],
      ),
    );
  }
}

class _BriefingSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final List<String>? items;

  const _BriefingSection({
    required this.icon,
    required this.title,
    this.content = '',
    this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(title, style: AppTheme.bodyMedium),
            ],
          ),
          if (content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 4),
              child: Text(content, style: AppTheme.bodySmall),
            ),
          if (items != null && items!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items!
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 6,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(item, style: AppTheme.bodySmall),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
