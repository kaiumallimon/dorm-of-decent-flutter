import 'package:dorm_of_decents/data/models/meal_response.dart';
import 'package:dorm_of_decents/data/services/api/logs.dart';
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

  Future<Map<String, dynamic>> addMeal({
    required String date,
    required double mealCount,
    String? userId,
  }) async {
    try {
      final supabase = SupabaseService.client;

      // Get current user
      final user = supabase.auth.currentUser;
      if (user == null) {
        return {'error': 'You must be logged in to add meals'};
      }

      // Validate meal count
      if (mealCount < 0.5) {
        return {'error': 'Meal count must be at least 0.5'};
      }
      if (mealCount > 10) {
        return {'error': 'Meal count too high'};
      }

      // Validate date format (YYYY-MM-DD)
      final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      if (!dateRegex.hasMatch(date)) {
        return {'error': 'Invalid date format'};
      }

      // Get active month
      final monthResponse = await supabase
          .from('months')
          .select('id')
          .eq('status', 'active')
          .single();

      final monthId = monthResponse['id'];

      // Use provided userId or current user's id
      final targetUserId = userId ?? user.id;

      // Insert meal
      final insertResponse = await supabase
          .from('meals')
          .insert({
            'date': date,
            'meal_count': mealCount,
            'month_id': monthId,
            'user_id': targetUserId,
          })
          .select('id')
          .single();

      final mealId = insertResponse['id'];

      // Log the action
      try {
        String? targetUserName;
        if (targetUserId != user.id) {
          final targetProfile = await supabase
              .from('profiles')
              .select('name')
              .eq('id', targetUserId)
              .single();
          targetUserName = targetProfile['name'];
        }

        await LogsApi().createLog(
          action: 'create',
          entityType: 'meal',
          entityId: mealId,
          metadata: {
            'meal_count': mealCount,
            'date': date,
            if (targetUserId != user.id) 'target_user_id': targetUserId,
            if (targetUserName != null) 'target_user_name': targetUserName,
          },
        );
      } catch (e) {
        // Continue even if logging fails
      }

      return {'success': true, 'id': mealId};
    } catch (e) {
      return {'error': 'Failed to add meal. Please try again.'};
    }
  }

  Future<Map<String, dynamic>> deleteMeal(String id) async {
    try {
      final supabase = SupabaseService.client;

      // Get current user
      final user = supabase.auth.currentUser;
      if (user == null) {
        return {'error': 'You must be logged in to delete meals'};
      }

      await supabase.from('meals').delete().eq('id', id);

      // Log the action
      try {
        await LogsApi().createLog(
          action: 'delete',
          entityType: 'meal',
          entityId: id,
        );
      } catch (e) {
        // Continue even if logging fails
      }

      return {'success': true};
    } catch (e) {
      return {'error': 'Failed to delete meal'};
    }
  }
}
