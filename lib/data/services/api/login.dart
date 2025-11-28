import 'package:dio/dio.dart';
import 'package:dorm_of_decents/data/models/login_response.dart';
import 'package:dorm_of_decents/data/services/client/dio_client.dart';

class LoginApi {
  static Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final client = ApiClient();

    try {
      final response = await client.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final loginResponse = LoginResponse.fromJson(response.data);

        // Set tokens in ApiClient for future requests
        client.setTokens(
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
        );

        return loginResponse;
      } else {
        throw Exception(response.data['error'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      // Extract error message from response
      String errorMessage = 'Login failed. Please try again.';

      if (e.response?.data != null) {
        if (e.response!.data is Map && e.response!.data['error'] != null) {
          errorMessage = e.response!.data['error'];
        } else if (e.response!.statusCode == 401) {
          errorMessage = 'Invalid email or password.';
        } else if (e.response!.statusCode == 500) {
          errorMessage = 'Server error. Please try again later.';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server response timeout. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Network error. Please check your connection.';
      }

      throw Exception(errorMessage);
    } catch (error) {
      throw Exception('An unexpected error occurred.');
    }
  }
}
