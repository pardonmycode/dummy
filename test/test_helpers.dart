import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart' as fl;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widgetly/core/i18n/app_localizations.dart';

/// Centralized test setup and teardown for all tests.
/// Usage:
///   setUp(() => setupTestEnvironment());
///   tearDown(() => teardownTestEnvironment());
Future<void> setupTestEnvironment() async {
  SharedPreferences.setMockInitialValues({});
}

Future<void> teardownTestEnvironment() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  } catch (e) {
    // Ignore cleanup errors in tests
  }
}

/// Pump a widget with all required localization delegates and test binding setup.
/// This is the standard way to pump widgets in Widgetly tests.
Future<void> pumpApp(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        fl.GlobalMaterialLocalizations.delegate,
        fl.GlobalWidgetsLocalizations.delegate,
        fl.GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(body: widget),
    ),
  );
}