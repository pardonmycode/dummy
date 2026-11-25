import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/theme.dart';
import 'features/dashboard/ui/views/dashboard_view.dart';

// Export providers for testing
export 'features/dashboard/ui/views/dashboard_view.dart'
    show
        dashboardWidgetsProvider,
        widgetRegistryProvider,
        isEditingProvider,
        mockDataProviderProvider,
        widgetDataProvider;

void main() {
  runApp(const ProviderScope(child: WidgetlyApp()));
}

class WidgetlyApp extends StatelessWidget {
  const WidgetlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widgetly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const DashboardView(),
    );
  }
}
