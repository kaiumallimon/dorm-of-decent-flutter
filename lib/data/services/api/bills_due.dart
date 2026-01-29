import 'package:dorm_of_decents/data/models/bills_due_response.dart';
import 'package:dorm_of_decents/data/services/client/supabase_client.dart';

class BillsDueApi {
  Future<BillsDueResponse> fetchBillsDue() async {
    try {
      final supabase = SupabaseService.client;

      // Get active month
      final monthResponse = await supabase
          .from('months')
          .select('*')
          .eq('status', 'active')
          .maybeSingle();

      if (monthResponse == null) {
        return const BillsDueResponse(
          month: null,
          bills: [],
          billPayments: [],
          profiles: [],
        );
      }

      // Fetch bills, bill payments, and profiles in parallel
      final results = await Future.wait([
        supabase
            .from('bills')
            .select('id, bill_type, amount, paid_by')
            .eq('month_id', monthResponse['id']),
        supabase
            .from('bill_payments')
            .select('bill_id, paid_by, amount, bills!inner(month_id, paid_by)')
            .eq('bills.month_id', monthResponse['id']),
        supabase
            .from('profiles')
            .select('*')
            .eq('isActive', true),
      ]);

      return BillsDueResponse.fromJson({
        'month': monthResponse,
        'bills': results[0] as List,
        'billPayments': results[1] as List,
        'profiles': results[2] as List,
      });
    } catch (error) {
      rethrow;
    }
  }
}
