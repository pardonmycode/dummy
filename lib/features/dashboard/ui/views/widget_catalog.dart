import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetly/features/widgets/framework/widget_registry.dart';
import 'package:widgetly/features/widgets/framework/widget_type_ids.dart';
import 'package:widgetly/features/widgets/ui/types/weather/weather_widget.dart';
import 'package:widgetly/features/widgets/ui/types/parties/parties_widget.dart';
import 'package:widgetly/features/widgets/ui/types/steps/steps_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/sleep/sleep_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/weight/weight_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/briefing/tagesbriefing_widget.dart';
import 'package:widgetly/features/widgets/ui/types/body_fat/body_fat_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/heart_rate/heart_rate_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/mood/mood_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/tasks/tasks_widget.dart';
import 'package:widgetly/features/widgets/ui/types/stress/stress_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/screen_time/screen_time_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/medications/medications_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/calendar/calendar_widget.dart';
import 'package:widgetly/features/widgets/ui/types/quick_notes/quick_notes_widget.dart';
import 'package:widgetly/features/widgets/ui/types/active_minutes/active_minutes_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/distance/distance_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/custom/custom_tracker_widget.dart';
import 'package:widgetly/features/widgets/ui/types/nutrient_tracker/nutrient_tracker_widget.dart';

/// Singleton widget registry — created once, shared across the app
final _sharedRegistry = WidgetRegistry()
  ..register(WeatherWidget())
  ..register(PartiesWidget())
  ..register(StepsTrackerWidget())
  ..register(SleepTrackerWidget())
  ..register(WeightTrackerWidget())
  ..register(TagesbriefingWidget())
  ..register(BodyFatTrackerWidget())
  ..register(HeartRateTrackerWidget())
  ..register(MoodTrackerWidget())
  ..register(TasksWidget())
  ..register(StressTrackerWidget())
  ..register(ScreenTimeTrackerWidget())
  ..register(MedicationsTrackerWidget())
  ..register(CalendarWidget())
  ..register(QuickNotesWidget())
  ..register(ActiveMinutesTrackerWidget())
  ..register(DistanceTrackerWidget())
  ..register(CustomTrackerWidget())
  // Generic nutrient tracker instances for each nutrient type
  ..register(NutrientTrackerWidget(nutrient: WidgetTypeIds.protein, unit: 'g', defaultGoalKey: 'goal', defaultGoal: 150))
  ..register(NutrientTrackerWidget(nutrient: WidgetTypeIds.carbs, unit: 'g', defaultGoalKey: 'goal', defaultGoal: 250))
  ..register(NutrientTrackerWidget(nutrient: WidgetTypeIds.fat, unit: 'g', defaultGoalKey: 'goal', defaultGoal: 70))
  ..register(NutrientTrackerWidget(nutrient: WidgetTypeIds.calories, unit: 'kcal', defaultGoalKey: 'goal', defaultGoal: 2000))
  ..register(NutrientTrackerWidget(nutrient: WidgetTypeIds.fiber, unit: 'g', defaultGoalKey: 'goal', defaultGoal: 30))
  ..register(NutrientTrackerWidget(nutrient: WidgetTypeIds.sugar, unit: 'g', defaultGoalKey: 'goal', defaultGoal: 50))
  ..register(NutrientTrackerWidget(nutrient: WidgetTypeIds.caffeine, unit: 'mg', defaultGoalKey: 'goal', defaultGoal: 400))
  ..register(NutrientTrackerWidget(nutrient: WidgetTypeIds.water, unit: 'ml', defaultGoalKey: 'goal', defaultGoal: 2000));

/// Provider for the widget registry
final widgetRegistryProvider = Provider<WidgetRegistry>((ref) => _sharedRegistry);
