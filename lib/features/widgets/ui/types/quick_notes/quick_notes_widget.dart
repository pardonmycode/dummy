import 'package:material_ui/material_ui.dart';

import '../../../../../../core/i18n/app_localizations.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../framework/widget_definition.dart';
import '../../../framework/widget_data.dart';

/// Quick notes widget - text, voice, and photo notes.
class QuickNotesWidget extends WidgetDefinition<Map<String, dynamic>> {
  @override
  String get id => 'quick_notes';

  @override
  String get name => 'Schnellnotizen';

  @override
  String get description => 'Text-, Sprach- und Fotonotizen';

  @override
  String get category => 'Produktivität';

  @override
  IconData get icon => Icons.sticky_note_2;

  @override
  Color get color => Colors.amber;

  @override
  WidgetSize get defaultSize => WidgetSize.medium;

  @override
  Set<WidgetSize> get supportedSizes => {WidgetSize.medium, WidgetSize.large};

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
    final l10n = context.l10n;
    final notes = data['notes'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notes list
          if (notes.isEmpty)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.sticky_note_2, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(l10n.notesEmpty, style: AppTheme.bodySmall),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                final content = note['content']?.toString() ?? '';
                final type = note['type']?.toString() ?? 'text';
                final timestamp = note['timestamp']?.toString() ?? '';
                final tags = note['tags'] as List<dynamic>? ?? [];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _noteIcon(type),
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(content, style: AppTheme.bodyMedium),
                            ),
                          ],
                        ),
                        if (tags.isNotEmpty || timestamp.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                ...tags.map((tag) {
                                  final tagStr = tag.toString();
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        tagStr,
                                        style: AppTheme.labelSmall,
                                      ),
                                    ),
                                  );
                                }),
                                if (timestamp.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      timestamp,
                                      style: AppTheme.labelSmall,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  IconData _noteIcon(String type) {
    switch (type) {
      case 'voice':
        return Icons.mic;
      case 'photo':
        return Icons.photo;
      case 'link':
        return Icons.link;
      default:
        return Icons.text_fields;
    }
  }
}
