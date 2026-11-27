import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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