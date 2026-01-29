import 'package:dorm_of_decents/data/models/bills.dart';
import 'package:dorm_of_decents/data/models/expense_response.dart';
import 'package:dorm_of_decents/data/services/client/supabase_client.dart';

class BillsAPi {
  Future<BillsResponse> fetchBills() async {
    try {
      final supabase = SupabaseService.client;
      final month = await supabase
          .from('months')
          .select('*')
          .eq('status', 'active')
          .single();

      final bills = await supabase
          .from('bills')
          .select('''
                id,
                bill_type,
                amount,
                description,
                date,
                created_at,
                profiles!inner (
                    id,
                    name
                )''')
          .eq('month_id', month['id'])
          .eq('profiles.isActive', true)
          .order('created_at', ascending: false);

      final profiles = await supabase
          .from('profiles')
          .select('id, name')
          .eq('isActive', true)
          .order('name');

      var userProfile;

      final user = SupabaseService.currentUser;

      if (user != null) {
        final data = await supabase
            .from('profiles')
            .select('id, name')
            .eq('id', user.id)
            .single();
        userProfile = data;
      } else {
        userProfile = null;
      }

      return BillsResponse(
        month: ExpenseMonth.fromJson(month),
        bills: bills.map<Bill>((bill) => Bill.fromJson(bill)).toList(),
        profiles: profiles
            .map<Profile>((profile) => Profile.fromJson(profile))
            .toList(),
        userProfile: UserProfile.fromJson(userProfile),
      );
    } catch (error) {
      rethrow;
    }
  }
}
