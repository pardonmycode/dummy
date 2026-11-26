import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetly/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() {
  setUp(() async {
    // Mock shared_preferences
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      // Ignore
    }
  });

  testWidgets('App renders dashboard', (WidgetTester tester) async {
    // Ignore layout overflow warnings during test
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;

    await tester.pumpWidget(const ProviderScope(child: WidgetlyApp()));

    expect(find.byType(MaterialApp), findsOneWidget);
    // Wait for async operations to complete
    await tester.pumpAndSettle(const Duration(seconds: 1));
    
    // Find any text in the app to debug
    final texts = find.byType(Text);
    expect(texts.evaluate().isNotEmpty, true);
  });
}
