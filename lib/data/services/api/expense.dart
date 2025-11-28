import 'package:dorm_of_decents/data/models/expense_response.dart';
import 'package:dorm_of_decents/data/services/client/supabase_client.dart';

class ExpenseApi {
  Future<ExpenseResponse> fetchExpenses() async {
    try {
      final supabase = SupabaseService.client;

      // 1. Get active month
      final monthResponse = await supabase
          .from('months')
          .select('*')
          .eq('status', 'active')
          .single();

      // 2. Get expenses for active month with profile data
      final expensesResponse = await supabase
          .from('expenses')
          .select('''
            id,
            amount,
            category,
            description,
            date,
            created_at,
            added_by,
            profiles!expenses_added_by_fkey (
              id,
              name
            )
          ''')
          .eq('month_id', monthResponse['id'])
          .order('date', ascending: false);

      // 3. Get all profiles
      final profilesResponse = await supabase
          .from('profiles')
          .select('id, name')
          .order('name');

      // 4. Get current user
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // 5. Build the response structure
      final responseData = {
        'month': monthResponse,
        'expenses': expensesResponse,
        'profiles': profilesResponse,
        'user': {
          'id': user.id,
          'aud': user.aud,
          'role': user.role,
          'email': user.email,
          'user_metadata': user.userMetadata,
        },
      };

      return ExpenseResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to fetch expenses: ${e.toString()}');
    }
  }
}
