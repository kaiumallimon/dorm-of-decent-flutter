import 'package:dorm_of_decents/configs/environments.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient? _client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppEnvironment.supabaseUrl!,
      anonKey: AppEnvironment.supabaseAnonKey!,
    );
    _client = Supabase.instance.client;
  }

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return _client!;
  }

  // Get current session access token
  static String? get accessToken => client.auth.currentSession?.accessToken;

  // Get current session refresh token
  static String? get refreshToken => client.auth.currentSession?.refreshToken;

  // Check if user is authenticated
  static bool get isAuthenticated => client.auth.currentSession != null;

  // Get current user
  static User? get currentUser => client.auth.currentUser;

  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;
}
