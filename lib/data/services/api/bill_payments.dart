import 'package:dorm_of_decents/data/services/client/supabase_client.dart';

class BillPaymentsApi {
  /// Record a bill repayment
  Future<Map<String, dynamic>> recordRepayment({
    required String billId,
    required String paidBy,
    required double amount,
  }) async {
    try {
      final supabase = SupabaseService.client;

      // Validate amount
      if (amount <= 0) {
        throw Exception('Amount must be greater than 0');
      }

      // Get the bill details
      final billResponse = await supabase
          .from('bills')
          .select('id, bill_type, amount, paid_by')
          .eq('id', billId)
          .maybeSingle();

      if (billResponse == null) {
        throw Exception('Bill not found');
      }

      // Check if user is trying to pay their own bill
      if (billResponse['paid_by'] == paidBy) {
        throw Exception('You cannot mark your own bill as paid');
      }

      // Insert bill payment
      final paymentResponse = await supabase
          .from('bill_payments')
          .insert({
            'bill_id': billId,
            'paid_by': paidBy,
            'amount': amount,
          })
          .select('id, bill_id, amount, created_at')
          .single();

      // Create activity log
      final user = SupabaseService.currentUser;
      if (user != null) {
        await supabase.from('activity_logs').insert({
          'user_id': user.id,
          'action': 'create',
          'entity_type': 'bill_payment',
          'entity_id': paymentResponse['id'],
          'metadata': {
            'bill_id': billId,
            'bill_type': billResponse['bill_type'],
            'amount': amount,
            'description': 'Marked ${billResponse['bill_type']} bill as paid ($amount BDT)',
          },
        });
      }

      return paymentResponse;
    } catch (error) {
      rethrow;
    }
  }

  /// Delete a bill payment
  Future<void> deleteRepayment(String paymentId) async {
    try {
      final supabase = SupabaseService.client;

      // Get payment details before deleting for logging
      final paymentResponse = await supabase
          .from('bill_payments')
          .select('bill_id, amount, paid_by')
          .eq('id', paymentId)
          .maybeSingle();

      // Delete the payment
      await supabase
          .from('bill_payments')
          .delete()
          .eq('id', paymentId);

      // Create activity log
      final user = SupabaseService.currentUser;
      if (user != null && paymentResponse != null) {
        await supabase.from('activity_logs').insert({
          'user_id': user.id,
          'action': 'delete',
          'entity_type': 'bill_payment',
          'entity_id': paymentId,
          'metadata': {
            'bill_id': paymentResponse['bill_id'],
            'amount': paymentResponse['amount'],
            'description': 'Removed bill payment of ${paymentResponse['amount']} BDT',
          },
        });
      }
    } catch (error) {
      rethrow;
    }
  }
}
