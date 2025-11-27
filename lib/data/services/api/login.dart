import 'package:dorm_of_decents/data/models/login_response.dart';
import 'package:dorm_of_decents/data/services/client/dio_client.dart';

class LoginApi {
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final client = ApiClient();

    final response = await client.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200 && response.data['success'] == true) {
      final loginResponse = LoginResponse.fromJson(response.data);

      // Set tokens in ApiClient for future requests
      client.setTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
      );

      return loginResponse;
    } else {
      throw Exception('Login failed');
    }
  }
}
