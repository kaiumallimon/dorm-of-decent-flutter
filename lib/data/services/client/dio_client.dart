import 'package:dio/dio.dart';
import 'package:dorm_of_decents/configs/environments.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;

  static const _storage = FlutterSecureStorage();
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';

  String? _accessToken;
  String? _refreshToken;

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
          // Attach access token if available
          if (_accessToken == null) {
            await loadTokensFromStorage();
          }
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioError error, handler) async {
          // Handle 401 and refresh token
          if (error.response?.statusCode == 401 && _refreshToken != null) {
            try {
              await _refreshAccessToken();

              // Retry original request
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $_accessToken';
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
          return handler.next(error);
        },
      ),
    );
  }

  // Load tokens from secure storage
  Future<void> loadTokensFromStorage() async {
    _accessToken = await _storage.read(key: _keyAccessToken);
    _refreshToken = await _storage.read(key: _keyRefreshToken);
  }

  // Save tokens to secure storage
  Future<void> _saveTokensToStorage() async {
    if (_accessToken != null) {
      await _storage.write(key: _keyAccessToken, value: _accessToken);
    }
    if (_refreshToken != null) {
      await _storage.write(key: _keyRefreshToken, value: _refreshToken);
    }
  }

  // Set tokens in client and storage
  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _saveTokensToStorage();
  }

  // Clear tokens (logout)
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }

  // Refresh token logic
  Future<void> _refreshAccessToken() async {
    if (_refreshToken == null) throw Exception('No refresh token available');

    final response = await dio.post(
      'auth/refresh',
      data: {'refresh_token': _refreshToken},
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      _accessToken = response.data['access_token'];
      _refreshToken = response.data['refresh_token'];
      await _saveTokensToStorage();
      print('Token refreshed successfully');
    } else {
      await clearTokens();
      throw Exception('Failed to refresh token');
    }
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
