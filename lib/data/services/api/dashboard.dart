import 'package:dorm_of_decents/data/models/dashboard_response.dart';
import 'package:dorm_of_decents/data/services/client/supabase_client.dart';

class DashboardApi {
  /// Fetches dashboard data directly from Supabase
  Future<DashboardResponse> fetchDashboardData() async {
    try {
      final supabase = SupabaseService.client;

      // 1. Get active month
      final monthResponse = await supabase
          .from('months')
          .select('*')
          .eq('status', 'active')
          .maybeSingle();

      if (monthResponse == null) {
        return const DashboardResponse(
          month: null,
          meals: [],
          expenses: [],
          memberCount: 0,
          userMealBreakdown: [],
          bills: [],
        );
      }

      final monthId = monthResponse['id'];

      // 2. Fetch meals
      final mealsData = await supabase
          .from('meals')
          .select('meal_count, user_id, date')
          .eq('month_id', monthId);

      // 3. Fetch expenses with profile names
      final expensesData = await supabase
          .from('expenses')
          .select(
            'id, amount, category, date, description, added_by, profiles(name)',
          )
          .eq('month_id', monthId)
          .order('created_at', ascending: false);

      // 4. Get member count
      final memberCountResponse = await supabase
          .from('profiles')
          .select('*')
          .count();

      // 5. Fetch user meal breakdown with profile names
      final userMealBreakdownData = await supabase
          .from('meals')
          .select('user_id, meal_count, profiles(name)')
          .eq('month_id', monthId);

      /*
        const { data: bills } = await (supabase as any)
            .from('bills')
            .select('id, amount, bill_type, date, paid_by, profiles!inner(name)')
            .eq('month_id', month.id)
            .eq('profiles.isActive', true)
            .order('created_at', { ascending: false })
           */

      final bills = await supabase
          .from('bills')
          .select('id, amount, bill_type, date, paid_by, profiles!inner(name)')
          .eq('month_id', monthId)
          .eq('profiles.isActive', true)
          .order('created_at', ascending: false);

      print('Fetched bills: $bills');

      return DashboardResponse.fromJson({
        'month': monthResponse,
        'meals': mealsData,
        'expenses': expensesData,
        'memberCount': memberCountResponse.count,
        'userMealBreakdown': userMealBreakdownData,
        'bills': bills,
      });
    } catch (e) {
      throw Exception('Failed to fetch dashboard data: ${e.toString()}');
    }
  }
}
