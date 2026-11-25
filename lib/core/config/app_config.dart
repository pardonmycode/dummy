import 'package:flutter/foundation.dart';

enum Environment { dev, staging, prod }

/// Validate API keys and print warnings for unconfigured placeholders.
void _validateApiKeys() {
  final keys = {
    'supabaseAnonKey': supabaseAnonKey,
    'mapboxToken': mapboxToken,
    'openaiApiKey': openaiApiKey,
  };

  for (final entry in keys.entries) {
    if (entry.value.contains('YOUR_') || entry.value.contains('PLACEHOLDER')) {
      debugPrint(
        '⚠️  AppConfig warning: ${entry.key} still contains a placeholder value. '
        'Set it to your real API key.',
      );
    }
  }
}

class AppConfig {
  static const Environment environment = kReleaseMode
      ? Environment.prod
      : Environment.dev;

  static String get apiBaseUrl {
    switch (environment) {
      case Environment.dev:
        return 'http://localhost:8092/api';
      case Environment.staging:
        return 'https://staging-api.widgetly.app';
      case Environment.prod:
        return 'https://api.widgetly.app';
    }
  }

  static String get supabaseUrl {
    switch (environment) {
      case Environment.dev:
        return 'https://dev.supabase.co';
      case Environment.staging:
        return 'https://staging.supabase.co';
      case Environment.prod:
        return 'https://prod.supabase.co';
    }
  }

  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String mapboxToken = 'YOUR_MAPBOX_TOKEN';
  static const String openaiApiKey = 'YOUR_OPENAI_API_KEY';

  static bool get isDebug => kDebugMode;
  static bool get isRelease => kReleaseMode;

  /// Validate all API keys — call early in app startup.
  static void validateApiKeys() {
    _validateApiKeys();
  }
}
