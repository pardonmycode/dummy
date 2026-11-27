import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../i18n/app_localizations.dart';

final localizationProvider = Provider<AppLocalizations>((ref) {
  throw UnimplementedError('Use read(context, localizationProvider) instead');
});

// Locale state provider
final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('de');
});

// Helper to get localized string from a provider reference
extension LocalizationProviderExt on WidgetRef {
  AppLocalizations get localization {
    // In real app, would use context-aware provider
    throw UnimplementedError('Use context.l10n inside widgets');
  }
}