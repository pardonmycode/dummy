import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  final Map<String, String> _messages;

  AppLocalizations(this.locale, this._messages);

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('de'),
  ];

  static const List<LocalizationsDelegate> localizationsDelegates = [
    AppLocalizationsDelegate(),
  ];

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

  String translateWithParams(String key, Map<String, String> params) {
    String result = _messages[key] ?? key;
    for (var entry in params.entries) {
      result = result.replaceAll('{' + entry.key + '}', entry.value);
    }
    return result;
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
  String get noWeatherData => translate('no_weather_data');
  String get offlineCached => translate('offline_cached');
  String get stepsLabel => translate('steps');
  String get goalLabel => translate('goal');
  String get distanceLabel => translate('distance');
  String get caloriesLabel => translate('calories');
  String get streakDays => translate('streak_days');
  String get proteinConsumed => translate('protein_consumed');
  String get goalReached => translate('goal_reached');
  String get remainingLabel => translate('remaining');
  String get moreMeals => translate('more_meals');
  String get waterConsumed => translate('water_consumed');
  String get addWater => translate('add_water');
  String get sleepGoal => translate('sleep_goal');
  String get qualityLabel => translate('quality');
  String get currentWeight => translate('current_weight');
  String get weightLoss => translate('weight_loss');
  String get weightGain => translate('weight_gain');
  String get lastChange => translate('last_change');
  String get todayBriefing => translate('today_briefing');
  String get weatherToday => translate('weather_today');
  String get appointmentsLabel => translate('appointments');
  String get tasksToday => translate('tasks_today');
  String get newsLabel => translate('news');
  String get noEventsFound => translate('no_events_found');
  String get tryAgainLater => translate('try_again_later');
  String get loadingDepartures => translate('loading_departures');
  String get errorLoadingDepartures => translate('error_loading_departures');
  String get errorLoadingCourses => translate('error_loading_courses');
  String get noDeparturesSoon => translate('no_departures_soon');
  String get noDeparturesAvailable => translate('no_departures_available');
  String get nextDeparture => translate('next_departure');
  String get currentLabel => translate('current');
  String get upcomingLabel => translate('upcoming');
  String get freeSlots => translate('free_slots');
  String get todayLabel => translate('today');
  String get eventsLabel => translate('events');
  String get eatenToday => translate('eaten_today');
  String get remainingToGoal => translate('remaining_to_goal');
  String get watchlistLabel => translate('watchlist');
  String get lastLabel => translate('last');
  String get maxLabel => translate('max');
  String get restingLabel => translate('resting');
  String get bodyFatLabel => translate('body_fat');
  String get takingOff => translate('taking_off');
  String get comingOff => translate('coming_off');
  String get stableLabel => translate('stable');
  String get moodGood => translate('mood_good');
  String get moodNeutral => translate('mood_neutral');
  String get moodBad => translate('mood_bad');
  String get highPriority => translate('high_priority');
  String get budgetSpent => translate('budget_spent');
  String get budgetRemaining => translate('budget_remaining');
  String get categoriesLabel => translate('categories');
  String get loadingBudget => translate('loading_budget');

  // Budget widget strings
  String get budgetLoading => translate('budget_loading');
  String get budgetError => translate('budget_error');
  String get budgetEmpty => translate('budget_empty');
  String get budgetRemainingLabel => translate('budget_remaining_label');
  String get budgetSpentLabel => translate('budget_spent_label');
  String get budgetByCategory => translate('budget_by_category');
  String get budgetRecent => translate('budget_recent');

  // Water widget strings
  String get waterOf => translate('water_of');
  String get waterAdd => translate('water_add');

  // Screen time widget strings
  String get screenTimeHours => translate('screen_time_hours');
  String get screenTimeMinutes => translate('screen_time_minutes');
  String screenTimeGoal({required int goal}) =>
      translateWithParams('screen_time_goal', {'goal': goal.toString()});

  // Protein widget strings
  String get proteinOf => translate('protein_of');
  String proteinRemaining({required int remaining}) =>
      translateWithParams('protein_remaining', {'remaining': remaining.toString()});
  String proteinMeal({required int amount}) =>
      translateWithParams('protein_meal', {'amount': amount.toString()});
  String get proteinUnit => translate('protein_unit');

  // Parties widget strings
  String get partiesNoEvents => translate('parties_no_events');
  String get partiesTryAgain => translate('parties_try_again');

  // Notes widget strings
  String get notesEmpty => translate('notes_empty');

  // Calories widget strings
  String get caloriesOf => translate('calories_of');
  String get caloriesUnit => translate('calories_unit');
  String caloriesMeal({required int amount}) =>
      translateWithParams('calories_meal', {'amount': amount.toString()});

  // News widget strings
  String get newsLoading => translate('news_loading');
  String get newsError => translate('news_error');
  String get newsEmpty => translate('news_empty');
  String get newsSeparator => translate('news_separator');

  // Distance widget strings
  String get distanceKm => translate('distance_km');
  String get distanceKeepGoing => translate('distance_keep_going');
  String distanceGoal({required int goal}) =>
      translateWithParams('distance_goal', {'goal': goal.toString()});

  // Briefing widget strings
  String get briefingAiSummary => translate('briefing_ai_summary');

  // Sleep widget strings
  String get sleepOf => translate('sleep_of');
  String get sleepHours => translate('sleep_hours');
  String sleepRemaining({required int remaining}) =>
      translateWithParams('sleep_remaining', {'remaining': remaining.toString()});

  // Active minutes widget strings
  String get activeMinutesOf => translate('active_minutes_of');
  String get activeMinutesMin => translate('active_minutes_min');
  String activeMinutesRemaining({required int remaining}) =>
      translateWithParams('active_minutes_remaining', {'remaining': remaining.toString()});
  String get activeMinutesKeepGoing => translate('active_minutes_keep_going');
  String activeMinutesValue({required int amount}) =>
      translateWithParams('active_minutes_value', {'amount': amount.toString()});

  // Metric tracker widget strings
  String get metricOf => translate('metric_of');
  String metricRemaining({required int remaining, required String unit}) =>
      translateWithParams('metric_remaining', {'remaining': remaining.toString(), 'unit': unit});
  String get metricKeepGoing => translate('metric_keep_going');
  String metricAdd({required int amount, required String unit}) =>
      translateWithParams('metric_add', {'amount': amount.toString(), 'unit': unit});

  // Calendar widget strings
  String get calendarNoEvents => translate('calendar_no_events');
  String get calendarFreeSlots => translate('calendar_free_slots');

  // Tasks widget strings
  String get tasksTodayLabel => translate('tasks_today_label');
  String get tasksEmpty => translate('tasks_empty');

  // Mood widget strings
  String get moodToday => translate('mood_today');

  // Steps widget strings
  String get stepsGoalLabel => translate('steps_goal_label');
  String stepsStreak({required int streak}) =>
      translateWithParams('steps_streak', {'streak': streak.toString()});
  String get stepsDistanceLabel => translate('steps_distance_label');
  String get stepsCaloriesLabel => translate('steps_calories_label');

  // Sugar widget strings
  String get sugarOf => translate('sugar_of');
  String sugarRemaining({required int remaining}) =>
      translateWithParams('sugar_remaining', {'remaining': remaining.toString()});
  String sugarMeal({required int amount}) =>
      translateWithParams('sugar_meal', {'amount': amount.toString()});
  String get sugarUnit => translate('sugar_unit');

  // Stocks widget strings
  String get stocksLoading => translate('stocks_loading');
  String get stocksError => translate('stocks_error');
  String get stocksEmpty => translate('stocks_empty');
  String get stocksWatchlist => translate('stocks_watchlist');
  String get stocksNoSymbols => translate('stocks_no_symbols');

  // Weight widget strings
  String get weightCurrent => translate('weight_current');
  String get weightGoal => translate('weight_goal');

  // Heart rate widget strings
  String get heartRateCurrent => translate('heart_rate_current');
  String get heartRateBpm => translate('heart_rate_bpm');
  String get heartRateResting => translate('heart_rate_resting');
  String get heartRateMax => translate('heart_rate_max');

  // Fat widget strings
  String get fatOf => translate('fat_of');
  String fatRemaining({required int remaining}) =>
      translateWithParams('fat_remaining', {'remaining': remaining.toString()});
  String fatMeal({required int amount}) =>
      translateWithParams('fat_meal', {'amount': amount.toString()});
  String get fatUnit => translate('fat_unit');

  // Stress widget strings
  String get stressToday => translate('stress_today');

  // Medications widget strings
  String get medicationsToday => translate('medications_today');
  String get medicationsNext => translate('medications_next');

  // OPNV widget strings
  String get opnvLoading => translate('opnv_loading');
  String get opnvError => translate('opnv_error');
  String get opnvEmpty => translate('opnv_empty');
  String get opnvSoon => translate('opnv_soon');

  // Custom tracker widget strings
  String customCurrent({required int current, required String unit}) =>
      translateWithParams('custom_current', {'current': current.toString(), 'unit': unit});
  String customOf({required int goal, required String unit}) =>
      translateWithParams('custom_of', {'goal': goal.toString(), 'unit': unit});
  String customRemaining({required int remaining, required String unit}) =>
      translateWithParams('custom_remaining', {'remaining': remaining.toString(), 'unit': unit});
  String get customKeepGoing => translate('custom_keep_going');
  String customAdd({required int amount}) =>
      translateWithParams('custom_add', {'amount': amount.toString()});

  // Fiber widget strings
  String get fiberOf => translate('fiber_of');
  String fiberRemaining({required int remaining}) =>
      translateWithParams('fiber_remaining', {'remaining': remaining.toString()});
  String fiberMeal({required int amount}) =>
      translateWithParams('fiber_meal', {'amount': amount.toString()});
  String get fiberUnit => translate('fiber_unit');

  // Nutrient tracker widget strings
  String get nutrientOf => translate('nutrient_of');
  String nutrientRemaining({required int remaining, required String unit}) =>
      translateWithParams('nutrient_remaining', {'remaining': remaining.toString(), 'unit': unit});
  String nutrientStreak({required int streak}) =>
      translateWithParams('nutrient_streak', {'streak': streak.toString()});
  String nutrientMeal({required int amount, required String unit}) =>
      translateWithParams('nutrient_meal', {'amount': amount.toString(), 'unit': unit});

  // Caffeine widget strings
  String get caffeineOf => translate('caffeine_of');
  String caffeineRemaining({required int remaining}) =>
      translateWithParams('caffeine_remaining', {'remaining': remaining.toString()});
  String get caffeineUnit => translate('caffeine_unit');
  String caffeineAdd({required int amount}) =>
      translateWithParams('caffeine_add', {'amount': amount.toString()});

  // Carbs widget strings
  String get carbsOf => translate('carbs_of');
  String carbsRemaining({required int remaining}) =>
      translateWithParams('carbs_remaining', {'remaining': remaining.toString()});
  String get carbsToGoal => translate('carbs_to_goal');
  String get carbsEaten => translate('carbs_eaten');

  // Caffeine additional strings
  String caffeineCups({required int cups}) =>
      translateWithParams('caffeine_cups', {'cups': cups.toString()});
  String get caffeineDrink => translate('caffeine_drink');

  // Calories additional strings
  String caloriesBurned({required int burned}) =>
      translateWithParams('calories_burned', {'burned': burned.toString()});
  String get caloriesMealName => translate('calories_meal');

  // Calendar additional strings
  String get calendarEvent => translate('calendar_event');
  String get calendarAllday => translate('calendar_allday');

  // Generic strings
  String get activityName => translate('activity');
  String get appointmentName => translate('appointment');
  String get taskName => translate('task');
  String get newsItem => translate('news_item');
  String get monthName => translate('month');
  String get categoryName => translate('category');
  String get transactionName => translate('transaction');
  String get myTracker => translate('my_tracker');
  String get units => translate('units');
  String get entryName => translate('entry');
  String fatMeals({required int meals}) =>
      translateWithParams('fat_meals', {'meals': meals.toString()});
  String get fiberTip => translate('fiber_tip');

  // Heart rate additional strings
  String get heartRateImproving => translate('heart_rate_improving');
  String get heartRateStable => translate('heart_rate_stable');

  // Medications additional strings
  String get medicationsNoneToday => translate('medications_none_today');
  String get medicationName => translate('medication_name');
  String get supplementName => translate('supplement_name');

  // Mood labels
  String get moodVeryBad => translate('mood_very_bad');
  String get moodVeryGood => translate('mood_very_good');

  // News additional strings
  String get newsForYou => translate('news_for_you');
  String get newsTitle => translate('news_title');
  String get newsBreaking => translate('news_breaking');

  // OPNV additional strings
  String get opnvStop => translate('opnv_stop');
  String get opnvLine => translate('opnv_line');
  String opnvDelay({required int delay}) =>
      translateWithParams('opnv_delay', {'delay': delay.toString()});
  String get opnvCancelled => translate('opnv_cancelled');
  String opnvPlatform({required String platform}) =>
      translateWithParams('opnv_platform', {'platform': platform});

  // Screen time additional strings
  String get screenTimeApp => translate('screen_time_app');

  // Sleep additional strings
  String get sleepQualityGood => translate('sleep_quality_good');
  String get sleepQualityImprove => translate('sleep_quality_improve');

  // Stocks additional strings
  String get stocksTicker => translate('stocks_ticker');

  // Stress additional strings
  String get stressLow => translate('stress_low');
  String get stressModerate => translate('stress_moderate');
  String get stressHigh => translate('stress_high');

  // Sugar additional strings
  String sugarSpoons({required int spoons}) =>
      translateWithParams('sugar_spoons', {'spoons': spoons.toString()});

  // Tasks additional strings
  String tasksCompleted({required int completed, required int total}) =>
      translateWithParams('tasks_completed', {
        'completed': completed.toString(),
        'total': total.toString(),
      });

  // Weight additional strings
  String weightToGoal({required String kg}) =>
      translateWithParams('weight_to_goal', {'kg': kg});
  String get weightStable => translate('weight_stable');
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
    return true;
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n {
    return Localizations.of<AppLocalizations>(this, AppLocalizations)!;
  }
}