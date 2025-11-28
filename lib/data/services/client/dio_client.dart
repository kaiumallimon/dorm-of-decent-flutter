import 'package:dio/dio.dart';
import 'package:dorm_of_decents/configs/environments.dart';
import 'package:dorm_of_decents/data/services/client/supabase_client.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppEnvironment.apiBaseurl!,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get access token from Supabase session
          final accessToken = SupabaseService.accessToken;
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          // Supabase handles token refresh automatically
          // Just retry the request if we get a 401
          if (error.response?.statusCode == 401) {
            // Wait a moment for Supabase to refresh
            await Future.delayed(const Duration(milliseconds: 100));

            // Retry original request with new token
            final opts = error.requestOptions;
            final newToken = SupabaseService.accessToken;
            if (newToken != null) {
              opts.headers['Authorization'] = 'Bearer $newToken';
              try {
                final cloneReq = await dio.request(
                  opts.path,
                  options: Options(method: opts.method, headers: opts.headers),
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                );
                return handler.resolve(cloneReq);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Load tokens from Supabase (kept for compatibility)
  Future<void> loadTokensFromStorage() async {
    // Supabase manages tokens automatically
  }

  // Set tokens (kept for compatibility but not used with Supabase)
  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    // Tokens are managed by Supabase
  }

  // Get current tokens from Supabase
  Future<Map<String, String?>> getTokens() async {
    return {
      'accessToken': SupabaseService.accessToken,
      'refreshToken': SupabaseService.refreshToken,
    };
  }

  // Clear tokens (logout from Supabase)
  Future<void> clearTokens() async {
    await SupabaseService.client.auth.signOut();
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return dio.get(path, queryParameters: queryParameters);
  }

  // POST request
  Future<Response> post(String path, {dynamic data}) async {
    return dio.post(path, data: data);
  }
}
