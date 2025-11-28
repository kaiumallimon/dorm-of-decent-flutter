import 'package:dorm_of_decents/data/models/logs_response.dart';
import 'package:dorm_of_decents/data/services/client/supabase_client.dart';

class LogsApi {
  Future<void> createLog({
    required String action,
    required String entityType,
    String? entityId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final supabase = SupabaseService.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        return;
      }

      await supabase.from('logs').insert({
        'user_id': user.id,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'metadata': metadata,
      });
    } catch (e) {
      // Silently fail - logging should not break the main functionality
      print('Failed to create log: $e');
    }
  }

  Future<List<ActivityLog>> fetchLogs() async {
    try {
      final supabase = SupabaseService.client;
      final logsData = await supabase
          .from('logs')
          .select('*, profiles(id, name)')
          .order('created_at', ascending: false);
      return (logsData as List)
          .map((log) => ActivityLog.fromJson(log))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch logs: ${e.toString()}');
    }
  }
}
