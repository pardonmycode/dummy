import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../widgets/framework/widget_definition.dart';
import '../../../widgets/framework/widget_instance.dart';
import '../../../widgets/ui/base/widget_card.dart';

// Mock providers for now
final dashboardWidgetsProvider = StateProvider<List<WidgetInstance>>((ref) => [
  WidgetInstance(widgetType: 'weather'),
  WidgetInstance(widgetType: 'weather', size: WidgetSize.small),
  WidgetInstance(widgetType: 'weather', size: WidgetSize.large),
]);

// Mock widget registry
final widgetRegistryProvider = Provider((ref) {
  // Will be populated with real widgets later
  return null;
});

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Mein Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {},
            tooltip: 'Bearbeiten',
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {},
            tooltip: 'Widget hinzufügen',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingSm),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: AppTheme.spacingSm,
            mainAxisSpacing: AppTheme.spacingSm,
          ),
          itemCount: 3,
          itemBuilder: (context, index) {
            return _buildMockWidget(context, index);
          },
        ),
      ),
    );
  }

  Widget _buildMockWidget(BuildContext context, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Icon(Icons.wb_sunny_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Wetter', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                const Spacer(),
                Icon(Icons.more_vert, size: 14, color: Colors.grey),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wb_sunny, size: 48, color: Colors.orange),
                  const SizedBox(height: 8),
                  Text('22°C', style: AppTheme.titleMedium),
                  Text('Berlin, Deutschland', style: AppTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
