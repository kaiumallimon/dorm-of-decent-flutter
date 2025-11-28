import 'package:dio/dio.dart';
import 'package:dorm_of_decents/data/models/profile_response.dart';
import 'package:dorm_of_decents/data/services/client/dio_client.dart';

class ProfileAPi {
  Future<ProfileResponse> fetchUserProfile() async {
    try {
      final client = ApiClient();

      // Ensure tokens are loaded before making request
      await client.loadTokensFromStorage();

      final response = await client.get('/users/me');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ProfileResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to fetch profile');
      }
    } on DioException catch (e) {
      // Extract error message from response
      String errorMessage = 'Failed to fetch profile. Please try again.';

      if (e.response?.data != null) {
        if (e.response!.data is Map && e.response!.data['error'] != null) {
          errorMessage = e.response!.data['error'];
          // If profile not found, provide a helpful message
          if (e.response!.statusCode == 404 &&
              errorMessage.toLowerCase().contains('not found')) {
            errorMessage =
                'Your profile needs to be created in the system. Please contact administrator.';
          }
        } else if (e.response!.statusCode == 404) {
          errorMessage =
              'Profile not found. Your account may need to be set up in the system.';
        } else if (e.response!.statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
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
    } catch (e) {
      throw Exception('An unexpected error occurred.');
    }
  }
}
