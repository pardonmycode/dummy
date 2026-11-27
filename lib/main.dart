import 'package:material_ui/material_ui.dart' as flutter;
import 'package:material_ui/material_ui.dart' show GlobalMaterialLocalizations, GlobalWidgetsLocalizations;
import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart' as flutter_localizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/i18n/app_localizations.dart';
import 'core/theme/theme.dart';
import 'features/dashboard/ui/views/dashboard_view.dart';
import 'features/widgets/framework/widget_schema_migration.dart';
import 'features/widgets/framework/widget_background_refresh.dart';

// Export providers for testing
export 'features/dashboard/ui/views/dashboard_view.dart'
    show
        dashboardWidgetsProvider,
        widgetRegistryProvider,
        isEditingProvider,
        mockDataProviderProvider,
        widgetDataProvider;

void main() {
  registerDefaultMigrations();
  
  // Start background refresh for widgets
  widgetBackgroundRefresh.start();
  
  runApp(const ProviderScope(child: WidgetlyApp()));
}

class WidgetlyApp extends StatefulWidget {
  const WidgetlyApp({super.key});

  @override
  State<WidgetlyApp> createState() => _WidgetlyAppState();
}

class _WidgetlyAppState extends State<WidgetlyApp> {
  @override
  void dispose() {
    // Stop background refresh when app is disposed
    widgetBackgroundRefresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return flutter.MaterialApp(
      title: 'Widgetly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: flutter.ThemeMode.system,
      supportedLocales: const [
        flutter.Locale('en'),
        flutter.Locale('de'),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        flutter_localizations.GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (flutter.Locale? locale, Iterable<flutter.Locale> supported) {
        final localeCode = locale?.languageCode;
        if (localeCode != null) {
          for (final supportedLocale in supported) {
            if (supportedLocale.languageCode == localeCode) {
              return supportedLocale;
            }
          }
        }
        return supported.first;
      },
      home: const DashboardView(),
    );
  }
}