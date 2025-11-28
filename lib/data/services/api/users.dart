import 'package:dorm_of_decents/data/models/profile.dart';
import 'package:dorm_of_decents/data/services/client/supabase_client.dart';

class UsersApi {
  Future<List<Profile>> fetchUsers() async {
    try {
      final supabase = SupabaseService.client;
      final usersData = await supabase
          .from('profiles')
          .select('*')
          .order('created_at', ascending: false);

      return (usersData as List).map((user) => Profile.fromJson(user)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: ${e.toString()}');
    }
  }

  Future<Profile?> fetchUserById(String userId) async {
    try {
      final supabase = SupabaseService.client;
      final userData = await supabase
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      if (userData == null) return null;
      return Profile.fromJson(userData);
    } catch (e) {
      throw Exception('Failed to fetch user: ${e.toString()}');
    }
  }

  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      final supabase = SupabaseService.client;
      await supabase
          .from('profiles')
          .update({'role': role.value})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update user role: ${e.toString()}');
    }
  }
}
