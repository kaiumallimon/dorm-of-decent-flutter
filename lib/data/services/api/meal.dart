import 'package:dorm_of_decents/data/models/meal_response.dart';
import 'package:dorm_of_decents/data/services/client/supabase_client.dart';

class MealApi {
  Future<MealResponse> fetchMeals() async {
    try {
      final supabase = SupabaseService.client;

      // 1. Get active month
      final monthResponse = await supabase
          .from('months')
          .select('*')
          .eq('status', 'active')
          .single();

      final monthId = monthResponse['id'];

      // 2. Get meals for active month with profile data
      final mealsResponse = await supabase
          .from('meals')
          .select('''
            id,
            meal_count,
            date,
            created_at,
            user_id,
            month_id,
            profiles (
              id,
              name
            )
          ''')
          .eq('month_id', monthId)
          .order('date', ascending: false);

      // 3. Convert to MealResponse format
      final List<Meal> meals = (mealsResponse as List).map((mealData) {
        return Meal.fromJson(mealData as Map<String, dynamic>);
      }).toList();

      return MealResponse(success: true, meals: meals);
    } catch (e) {
      throw Exception('Failed to fetch meals: ${e.toString()}');
    }
  }
}
