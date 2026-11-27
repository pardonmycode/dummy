import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetly/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'test_helpers.dart';

void main() {
  setUp(setupTestEnvironment);
  tearDown(teardownTestEnvironment);

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
