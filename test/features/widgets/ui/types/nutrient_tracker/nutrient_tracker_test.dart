import 'package:flutter_test/flutter_test.dart';
import 'package:widgetly/features/widgets/ui/types/nutrient_tracker/nutrient_tracker_widget.dart';

void main() {
  group('NutrientTrackerWidget', () {
    test('can be instantiated with different nutrients', () {
      final protein = NutrientTrackerWidget(
        nutrient: 'protein',
        unit: 'g',
        defaultGoalKey: 'goal',
      );
      expect(protein, isNotNull);
      expect(protein.id, 'protein_tracker');
      
      final carbs = NutrientTrackerWidget(
        nutrient: 'carbs',
        unit: 'g',
        defaultGoalKey: 'goal',
      );
      expect(carbs, isNotNull);
      expect(carbs.id, 'carbs_tracker');
      
      final calories = NutrientTrackerWidget(
        nutrient: 'calories',
        unit: 'kcal',
        defaultGoalKey: 'goal',
        defaultGoal: 2000,
      );
      expect(calories, isNotNull);
      expect(calories.id, 'calories_tracker');
    });
  });
}
