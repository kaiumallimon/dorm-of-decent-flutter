import 'package:dorm_of_decents/data/services/client/dio_client.dart';
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

  AuthAuthenticated({required this.accessToken, required this.refreshToken});

  @override
  List<Object?> get props => [accessToken, refreshToken];
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

      if (tokens['accessToken'] != null && tokens['refreshToken'] != null) {
        emit(
          AuthAuthenticated(
            accessToken: tokens['accessToken']!,
            refreshToken: tokens['refreshToken']!,
          ),
        );
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  /// Set authentication tokens (called after successful login)
  Future<void> setAuthentication({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _apiClient.setTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    emit(
      AuthAuthenticated(accessToken: accessToken, refreshToken: refreshToken),
    );
  }

  /// Logout user by clearing tokens
  Future<void> logout() async {
    await _apiClient.clearTokens();
    emit(AuthUnauthenticated());
  }

  /// Check if currently authenticated
  bool get isAuthenticated => state is AuthAuthenticated;
}
