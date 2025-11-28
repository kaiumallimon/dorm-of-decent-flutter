import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnvironment {
  static String? get apiBaseurl => dotenv.env['API_BASE_URL'];
  static String? get supabaseUrl => dotenv.env['SUPABASE_URL'];
  static String? get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'];
}
