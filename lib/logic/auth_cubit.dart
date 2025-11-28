import 'package:dorm_of_decents/data/models/login_response.dart';
import 'package:dorm_of_decents/data/services/api/profile.dart';
import 'package:dorm_of_decents/data/services/client/dio_client.dart';
import 'package:dorm_of_decents/data/services/storage/user_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String accessToken;
  final String refreshToken;
  final UserData userData;

  AuthAuthenticated({
    required this.accessToken,
    required this.refreshToken,
    required this.userData,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, userData];
}

class AuthUnauthenticated extends AuthState {}

/// Auth Cubit to manage authentication state persistently
class AuthCubit extends Cubit<AuthState> {
  final ApiClient _apiClient = ApiClient();

  AuthCubit() : super(AuthInitial());

  /// Check if user is authenticated by loading tokens from storage
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

    try {
      await _apiClient.loadTokensFromStorage();

      // Get tokens from storage
      final tokens = await _apiClient.getTokens();

      // Get user data from storage
      final userData = await UserStorage.getUserData();

      if (tokens['accessToken'] != null &&
          tokens['refreshToken'] != null &&
          userData != null) {
        emit(
          AuthAuthenticated(
            accessToken: tokens['accessToken']!,
            refreshToken: tokens['refreshToken']!,
            userData: userData,
          ),
        );
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  /// Set authentication tokens and user data (called after successful login)
  Future<void> setAuthentication({
    required String accessToken,
    required String refreshToken,
    required UserData userData,
  }) async {
    await _apiClient.setTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    // Save user data to local storage
    await UserStorage.saveUserData(userData);

    emit(
      AuthAuthenticated(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userData: userData,
      ),
    );
  }

  /// Logout user by clearing tokens and user data
  Future<void> logout() async {
    await _apiClient.clearTokens();
    await UserStorage.clearUserData();
    emit(AuthUnauthenticated());
  }

  /// Check if currently authenticated
  bool get isAuthenticated => state is AuthAuthenticated;

  /// Refresh user profile data from API and update storage
  Future<void> refreshUserProfile() async {
    if (state is! AuthAuthenticated) return;

    try {
      final currentState = state as AuthAuthenticated;
      final profileApi = ProfileAPi();
      final profileResponse = await profileApi.fetchUserProfile();

      // Convert ProfileData to UserData
      final updatedUserData = UserData(
        id: profileResponse.data.id,
        email: profileResponse.data.email,
        name: profileResponse.data.name,
        role: profileResponse.data.role,
      );

      // Update storage
      await UserStorage.saveUserData(updatedUserData);

      // Update state
      emit(
        AuthAuthenticated(
          accessToken: currentState.accessToken,
          refreshToken: currentState.refreshToken,
          userData: updatedUserData,
        ),
      );
    } catch (e) {
      // If profile not found in backend, that means user needs to be synced
      // For now, keep existing user data and rethrow for UI to handle
      rethrow;
    }
  }
}
