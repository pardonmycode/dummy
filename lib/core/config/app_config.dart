import 'package:flutter/foundation.dart';

enum Environment { dev, staging, prod }

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

  // API keys should be configured via the backend or environment variables.
  // Hardcoding keys in client code is insecure.
  // - supabaseAnonKey: Configure via supabase config or env var
  // - mapboxToken: Configure via mapbox config or env var
  // - openaiApiKey: Should be on backend, not in client binary

  static bool get isDebug => kDebugMode;
  static bool get isRelease => kReleaseMode;
}
