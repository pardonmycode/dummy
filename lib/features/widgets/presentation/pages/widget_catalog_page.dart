import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../framework/widget_registry.dart';
import '../../framework/widget_definition.dart';
import '../../framework/widget_data.dart';
import '../../../dashboard/ui/views/dashboard_view.dart';
import '../../ui/types/weather/weather_widget.dart';
import '../../ui/types/protein/protein_tracker_widget.dart';
import '../../ui/types/parties/parties_widget.dart';
import '../../ui/types/carbs/carbs_tracker_widget.dart';
import '../../ui/types/water/water_tracker_widget.dart';
import '../../ui/types/steps/steps_tracker_widget.dart';
import '../../ui/types/sleep/sleep_tracker_widget.dart';
import '../../ui/types/weight/weight_tracker_widget.dart';
import '../../ui/types/briefing/tagesbriefing_widget.dart';
import '../../ui/types/body_fat/body_fat_tracker_widget.dart';
import '../../ui/types/heart_rate/heart_rate_tracker_widget.dart';
import '../../ui/types/mood/mood_tracker_widget.dart';
import '../../ui/types/tasks/tasks_widget.dart';
import '../../ui/types/stress/stress_tracker_widget.dart';
import '../../ui/types/screen_time/screen_time_tracker_widget.dart';
import '../../ui/types/medications/medications_tracker_widget.dart';
import '../../ui/types/calendar/calendar_widget.dart';
import '../../ui/types/quick_notes/quick_notes_widget.dart';
import '../../ui/types/fat/fat_tracker_widget.dart';
import '../../ui/types/calories/calorie_tracker_widget.dart';
import '../../ui/types/fiber/fiber_tracker_widget.dart';
import '../../ui/types/sugar/sugar_tracker_widget.dart';
import '../../ui/types/caffeine/caffeine_tracker_widget.dart';
import '../../ui/types/active_minutes/active_minutes_tracker_widget.dart';
import '../../ui/types/distance/distance_tracker_widget.dart';
import '../../ui/types/custom/custom_tracker_widget.dart';

class WidgetCatalogPage extends ConsumerStatefulWidget {
  const WidgetCatalogPage({super.key});

  @override
  ConsumerState<WidgetCatalogPage> createState() => _WidgetCatalogPageState();
}

class _WidgetCatalogPageState extends ConsumerState<WidgetCatalogPage> {
  String _searchQuery = '';
  String? _selectedCategory;

  late WidgetRegistry registry;

  @override
  void initState() {
    super.initState();
    registry = WidgetRegistry()
      ..register(WeatherWidget())
      ..register(ProteinTrackerWidget())
      ..register(PartiesWidget())
      ..register(CarbsTrackerWidget())
      ..register(WaterTrackerWidget())
      ..register(StepsTrackerWidget())
      ..register(SleepTrackerWidget())
      ..register(WeightTrackerWidget())
      ..register(TagesbriefingWidget())
      ..register(BodyFatTrackerWidget())
      ..register(HeartRateTrackerWidget())
      ..register(MoodTrackerWidget())
      ..register(TasksWidget())
      ..register(StressTrackerWidget())
      ..register(ScreenTimeTrackerWidget())
      ..register(MedicationsTrackerWidget())
      ..register(CalendarWidget())
      ..register(QuickNotesWidget())
      ..register(FatTrackerWidget())
      ..register(CalorieTrackerWidget())
      ..register(FiberTrackerWidget())
      ..register(SugarTrackerWidget())
      ..register(CaffeineTrackerWidget())
      ..register(ActiveMinutesTrackerWidget())
      ..register(DistanceTrackerWidget())
      ..register(CustomTrackerWidget());
  }

  List<String> get categories {
    final cats = registry.getCategories();
    cats.sort();
    return cats;
  }

  List<WidgetDefinition> get filteredWidgets {
    List<WidgetDefinition> widgets;
    if (_selectedCategory != null) {
      widgets = registry.getByCategory(_selectedCategory!);
    } else {
      widgets = registry.getAll();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      widgets = widgets.where((w) {
        return w.name.toLowerCase().contains(query) ||
            w.description.toLowerCase().contains(query);
      }).toList();
    }

    return widgets;
  }

  Map<String, dynamic> _getMockData(WidgetDefinition widget) {
    switch (widget.id) {
      case 'weather':
        return {
          'schemaVersion': 1,
          'data': {
            'location': 'Berlin',
            'current': {'temperature': 22, 'condition': 'Sonnig'},
            'hourly': [
              {'time': 'Jetzt', 'temp': 22, 'condition': 'Sonnig'},
              {'time': '14:00', 'temp': 24, 'condition': 'Sonnig'},
            ],
          },
          'sources': ['OpenWeatherMap API'],
          'generatedAt': DateTime.now().toIso8601String(),
        };
      case 'protein_tracker':
        return {
          'schemaVersion': 1,
          'data': {'goal': 150, 'consumed': 95},
          'sources': ['Lokale Einträge'],
          'generatedAt': DateTime.now().toIso8601String(),
        };
      default:
        // Generic mock data for other widgets
        return {
          'schemaVersion': 1,
          'data': {'value': 42, 'label': 'Beispieldaten'},
          'sources': ['Mock'],
          'generatedAt': DateTime.now().toIso8601String(),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final widgets = filteredWidgets;
    final cats = categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget-Katalog'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Widgets suchen...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Category filter chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(
                  label: const Text('Alle'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                ),
                ...cats.map((cat) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(cat),
                    selected: _selectedCategory == cat,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? cat : null;
                      });
                    },
                  ),
                )),
              ],
            ),
          ),

          // Widget grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: widgets.length,
              itemBuilder: (context, index) {
                final widget = widgets[index];
                return _buildCatalogItem(context, widget);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogItem(BuildContext context, WidgetDefinition widget) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Widget icon and name
            Row(
              children: [
                Icon(widget.icon, color: widget.color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.description,
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              widget.category,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            const Spacer(),
            // Preview button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showPreview(context, widget),
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text('Vorschau', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPreview(BuildContext context, WidgetDefinition widget) {
    final mockData = _getMockData(widget);
    final widgetData = WidgetData.fromJson(mockData);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.name),
          content: SizedBox(
            width: 300,
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: widget.buildView(
                  widgetData,
                  WidgetDataState.ready,
                  WidgetConfig({}),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Schließen'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(dashboardWidgetsProvider.notifier)
                    .addWidget(widget.id);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Hinzufügen'),
            ),
          ],
        );
      },
    );
  }
}