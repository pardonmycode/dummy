import 'dart:async';

import 'package:material_ui/material_ui.dart' as flutter;
import 'package:material_ui/material_ui.dart' show GlobalMaterialLocalizations, GlobalWidgetsLocalizations;
import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart' as flutter_localizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:flutter/foundation.dart' show AppLifecycleState;
import 'package:material_ui/material_ui.dart';

import 'core/i18n/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/theme/theme.dart';
import 'features/widgets/framework/widget_schema_migration.dart';
import 'features/widgets/framework/widget_background_refresh.dart';

void main() {
  registerDefaultMigrations();
  runApp(const ProviderScope(child: WidgetlyApp()));
}

class WidgetlyApp extends StatefulWidget {
  const WidgetlyApp({super.key});

  @override
  State<WidgetlyApp> createState() => _WidgetlyAppState();
}

class _WidgetlyAppState extends State<WidgetlyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widgetBackgroundRefresh.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widgetBackgroundRefresh.refreshAllOnResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return flutter.MaterialApp.router(
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
      routerConfig: appRouter,
    );
  }
}
