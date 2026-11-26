import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  final Map<String, String> _messages;

  AppLocalizations(this.locale, this._messages);

  static Future<AppLocalizations> load(Locale locale) async {
    final String fileName =
        'assets/translations/${locale.languageCode}.json';
    final String jsonString = await rootBundle.loadString(fileName);
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final Map<String, String> messages = {};
    for (final MapEntry entry in jsonMap.entries) {
      messages[entry.key] = entry.value.toString();
    }
    return AppLocalizations(locale, messages);
  }

  String translate(String key) {
    return _messages[key] ?? key;
  }

  String get appName => translate('app_name');
  String get dashboard => translate('dashboard');
  String get widgets => translate('widgets');
  String get settings => translate('settings');
  String get addWidget => translate('add_widget');
  String get editDashboard => translate('edit_dashboard');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get loading => translate('loading');
  String get error => translate('error');
  String get retry => translate('retry');
  String get refresh => translate('refresh');
  String get sources => translate('sources');
  String get myDashboard => translate('my_dashboard');
  String get switchDashboard => translate('switch_dashboard');
  String get sync => translate('sync');
  String get templates => translate('templates');
  String get undo => translate('undo');
  String get redo => translate('redo');
  String get done => translate('done');
  String get edit => translate('edit');
  String get small => translate('small');
  String get medium => translate('medium');
  String get large => translate('large');
  String get renameDashboard => translate('rename_dashboard');
  String get dashboardName => translate('dashboard_name');
  String get newDashboard => translate('new_dashboard');
  String get dashboards => translate('dashboards');
  String get addWidgets => translate('add_widgets');
  String get widgetCatalog => translate('widget_catalog');
  String get searchWidgets => translate('search_widgets');
  String get all => translate('all');
  String get preview => translate('preview');
  String get close => translate('close');
  String get add => translate('add');
  String get layoutCopied => translate('layoutCopied');
  String get layoutImported => translate('layoutImported');
  String get importLayout => translate('importLayout');
  String get uploadToServer => translate('uploadToServer');
  String get uploadDescription => translate('uploadDescription');
  String get layoutSynced => translate('layoutSynced');
  String get syncFailed => translate('syncFailed');
  String get downloadFromServer => translate('downloadFromServer');
  String get downloadDescription => translate('downloadDescription');
  String get layoutDownloaded => translate('layoutDownloaded');
  String get noLayoutOnServer => translate('noLayoutOnServer');
  String get downloadFailed => translate('downloadFailed');
  String get fitnessTemplateApplied => translate('fitnessTemplateApplied');
  String get workTemplateApplied => translate('workTemplateApplied');
  String get weatherTemplateApplied => translate('weatherTemplateApplied');
}

@immutable
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'de'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(covariant AppLocalizationsDelegate old) {
    return false;
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n {
    return Localizations.of<AppLocalizations>(this, AppLocalizations)!;
  }
}