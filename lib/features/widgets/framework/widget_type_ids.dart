/// Centralized widget type ID constants.
///
/// All widget types must use these constants instead of magic strings
/// to prevent typos and ensure consistency across the codebase.

class WidgetTypeIds {
  WidgetTypeIds._();

  // Weather
  static const String weather = 'weather';

  // Health & Fitness
  static const String stepsTracker = 'steps_tracker';
  static const String sleepTracker = 'sleep_tracker';
  static const String weightTracker = 'weight_tracker';
  static const String bodyFatTracker = 'body_fat_tracker';
  static const String heartRateTracker = 'heart_rate_tracker';
  static const String activeMinutesTracker = 'active_minutes_tracker';
  static const String distanceTracker = 'distance_tracker';

  // Nutrition (base names for NutrientTrackerWidget)
  static const String protein = 'protein';
  static const String carbs = 'carbs';
  static const String fat = 'fat';
  static const String calories = 'calories';
  static const String fiber = 'fiber';
  static const String sugar = 'sugar';
  static const String caffeine = 'caffeine';
  static const String water = 'water';

  // Productivity
  static const String tasks = 'tasks';
  static const String calendar = 'calendar';
  static const String quickNotes = 'quick_notes';

  // Lifestyle
  static const String parties = 'parties';
  static const String moodTracker = 'mood_tracker';
  static const String stressTracker = 'stress_tracker';
  static const String screenTimeTracker = 'screen_time_tracker';
  static const String medicationsTracker = 'medications_tracker';
  static const String budget = 'budget';
  static const String stocks = 'stocks';
  static const String news = 'news';
  static const String briefing = 'tagesbriefing';
  static const String opnv = 'opnv';
  static const String customTracker = 'custom_tracker';
}