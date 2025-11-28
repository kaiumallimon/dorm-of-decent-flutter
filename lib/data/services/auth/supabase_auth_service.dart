import 'package:dorm_of_decents/data/models/login_response.dart';
import 'package:dorm_of_decents/data/services/client/supabase_client.dart';

class SupabaseAuthService {
  /// Login with email and password using Supabase
  /// Returns LoginResponse to maintain compatibility with existing code
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Supabase
      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        throw Exception('Login failed: No session returned');
      }

      final session = response.session!;
      final user = response.user;

      if (user == null) {
        throw Exception('Login failed: No user data');
      }

      // Fetch user profile from Supabase profiles table
      final profileResponse = await SupabaseService.client
          .from('profiles')
          .select('id, name, phone, role')
          .eq('id', user.id)
          .single();

      // Convert to UserData using Supabase profile data
      final userData = UserData(
        id: profileResponse['id'] as String,
        email: user.email ?? '',
        name: profileResponse['name'] as String,
        role: profileResponse['role'] as String? ?? 'member',
      );

      // Calculate expiry time
      final expiresIn = DateTime.now().add(
        Duration(seconds: session.expiresIn ?? 3600),
      );

      // Return LoginResponse in the same format as before
      return LoginResponse(
        success: true,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken ?? '',
        expiresIn: expiresIn,
        userData: userData,
      );
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated() async {
    return SupabaseService.isAuthenticated;
  }

  /// Logout
  Future<void> logout() async {
    await SupabaseService.client.auth.signOut();
  }

  /// Get current session tokens
  Future<Map<String, String?>> getTokens() async {
    return {
      'accessToken': SupabaseService.accessToken,
      'refreshToken': SupabaseService.refreshToken,
    };
  }
}
