import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../framework/widget_registry.dart';
import '../../ui/types/weather/weather_widget.dart';
import '../../ui/types/protein/protein_tracker_widget.dart';

class WidgetCatalogPage extends ConsumerWidget {
  const WidgetCatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registry = WidgetRegistry();
    registry.register(WeatherWidget());
    registry.register(ProteinTrackerWidget());

    return Scaffold(
      appBar: AppBar(title: const Text('Widget-Katalog')),
      body: ListView(
        children: registry.getAll().map((def) {
          return ListTile(
            leading: Icon(def.icon, color: def.color),
            title: Text(def.name),
            subtitle: Text(def.description),
          );
        }).toList(),
      ),
    );
  }
}
