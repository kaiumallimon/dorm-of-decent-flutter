import 'package:dorm_of_decents/data/models/expense_response.dart';
import 'package:dorm_of_decents/data/services/client/supabase_client.dart';

class MonthsApi {
  Future<List<ExpenseMonth>> fetchMonths() async {
    try {
      final supabase = SupabaseService.client;

      final months = await supabase
          .from('months')
          .select('*')
          .order('start_date', ascending: false);

      return months
          .map<ExpenseMonth>((month) => ExpenseMonth.fromJson(month))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch months: $e');
    }
  }
}
